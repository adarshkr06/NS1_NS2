/* 
   Bgp Tcp Listener, Tcp Listener slightly modified for BGP++ 
   Xenofontas Dimitropoulos, GaTech Spring 2003
*/

#include "tcp-bgplistener.h"
#include "rti/rtioob.h"
#include "flags.h"

// Need prototype from rtisched.h GetLocalIP
NsObject* GetLocalIP(ipaddr_t ipaddr);

static class BgpTcpListenerClass : public TclClass {
public:
  BgpTcpListenerClass() : TclClass("Agent/TCP/Listener/BGP") {}
  TclObject* create(int, const char*const*) {
    return (new BgpTcpListenerAgent());
  }
} bgplistener_class;


void BgpTcpListenerAgent::recv(Packet *pkt, Handler*) {
  
  hdr_tcp *tcph = hdr_tcp::access(pkt);
  hdr_cmn *th = hdr_cmn::access(pkt);
  hdr_flags *fh = hdr_flags::access(pkt);
  hdr_rti *rti = hdr_rti::access(pkt);

  int datalen = th->size() - tcph->hlen();
  int tiflags = tcph->flags();
  Tcl &tcl = Tcl::instance();

  ipaddr_t src_ip = rti->ipsrc();
  char src_ip_str[INET_ADDRSTRLEN];
  inet_ntop(AF_INET,(void*)&src_ip,src_ip_str,sizeof(src_ip_str));
  ipaddr_t dst_ip = rti->ipdst();
  ipportaddr_t sport = rti->ipsrcport();
  ipportaddr_t dport = rti->ipdstport();

  // Store Node info for future reference
  if (!pNode) {
    pNode = (Node *)GetLocalIP(dst_ip);
    if (!pNode) {
      tcl.evalf("%s set node_", name());
      strcpy(node_name, tcl.result());
      pNode = (Node *)TclObject::lookup(node_name);
      if (!pNode) {
        printf("%f: TcpListenerAgent(%s): Fatal: Node lookup failed!\n", \
            now(), name());
        exit(0);
      }
    } else {
      strcpy(node_name, pNode->name());
    }
    strcpy(agent_name, name());
    if (trace_enable_ > 0) {
      tcl.evalf("%s set id_", node_name);
      trace_nodename_ = strdup(tcl.result());
    }
  }
  
  if (debug_ > 1) {
    printf("%f: TcpListenerAgent(%s): incoming %s packet:\n", now(), 
        agent_name, flagstr(tiflags));
    printf("  srcip %08x sport %d dstip %08x dport %d\n", src_ip, sport, \
        dst_ip, dport);
    printf("  ts %d conn %d tiflags %d datalen %d seqno %d ackno %d\n", \
        table_size_, connections_, tiflags, datalen, tcph->seqno(), \
        tcph->ackno());
  }
  // Increment trace packet counter
  if (trace_enable_ > 0) {
    trace_pktcount_++;
  }
  
  // Incoming SYN Packet (passive open)
  if (tiflags & TH_SYN) {
    // Trace this data to out file
    if (trace_enable_ > 0 && trace_pktcount_ % trace_interval_ == 0) {
      trace_pktcount_ = 0;
      if ((trace_fp_ = fopen(trace_file_, "a")) == NULL) {
        printf("%f: TcpListenerAgent(%s): cannot open tracefile (%s)\n", \
            now(), agent_name, trace_file_);
        printf("  for writing. Disabling tracefile output.\n");
        trace_enable_ = 0;
      } else {
        fprintf(trace_fp_, "PACKET * %s.%s %f %s 1.0\n", trace_prefix_, \
            trace_nodename_, now(), COLOR_SYN);
        fclose(trace_fp_);
      }
    }
#ifdef HAVE_FILTER
    if (filter_enable_ == 1) {
      if (connections_ / table_size_ >= filter_trigger_) {
        if (max_synack_retries_ == 0) {
          expire_connections();
        }
        if (connections_ / table_size_ >= filter_trigger_) {
          if (filter_on_ == false) {
            filter_on_ = true;
            SendOOBFilter(RTIFilterStart);
            if (debug_ > 0) {
              printf("%f: TcpListenerAgent(%s): Filter Triggered! (%.1f%)\n", \
                 now(), agent_name, filter_trigger_ * 100);
            }
          }
        } else if ((connections_ / table_size_ <= filter_release_) && 
            (filter_on_ == true)) {
          filter_on_ = false;
          SendOOBFilter(RTIFilterStop);
          if (debug_ > 0) {
            printf("%f: TcpListenerAgent(%s): Filter Released! (%.1f%)\n", \
               now(), agent_name, filter_release_ * 100);
          }
        } // release else
      } // trigger check
    } // filter_enable_
#endif
    // Check TCP Connection Table first
    if (connections_ >= table_size_) {
      if (max_synack_retries_ == 0) {
        expire_connections();
      }
      if (connections_ >= table_size_) {
        if (debug_ > 0) {
          printf("%f: TcpListenerAgent(%s): TCP connection table full (%d)\n", \
             now(), agent_name, table_size_);
        }
      } else {
        goto cont;
      }
    } else {
cont:
      if (debug_ > 1) {
        printf("%f: TcpListenerAgent(%s): SYN packet recv'd\n", now(), 
            agent_name);
      }
      // Allocate connection information
      if (get_connection(src_ip, sport) == false) {
        add_connection(src_ip, sport);
      }
      // Send SYN+ACK packet back to src_ip
      dooptions(pkt);
      irs_ = tcph->seqno();
      t_seqno_ = iss_;
      rcv_nxt_ = rcvseqinit(irs_, datalen);
      flags_ |= TF_ACKNOW;
      tcph->seqno()++;
      cwnd_ = initial_window();
      newstate(TCPS_SYN_RECEIVED);
      // Reconnect back to remote sources
      NsObject *pObj = GetLocalIP(src_ip);
      if(0) cout<<"1Source ip is "<<src_ip_str<<" Object"<<pObj<<"Agent ipaddr: "<<get_ipaddr()<<endl;
      if (pObj == NULL) {
        tcl.evalf("%s set-dst-ipaddr %d", agent_name, src_ip);
        tcl.evalf("%s set-dst-port %d", agent_name, sport);
        tcl.evalf("[[Simulator instance] set scheduler_] iproute-connect %s %d %d", agent_name, src_ip, sport);
        if (debug_ > 1) {
          printf("%f: TcpListenerAgent(%s): remote iproute-connect (%08x:%d)\n",
              now(), agent_name, src_ip, sport);
        }
      } else {
        char tmp[255];
        tcl.evalf("%s findport %d", pObj->name(), sport);
        strcpy(tmp, tcl.result());
        if (strcmp(tmp, "") == 0) {
          tcl.evalf("%s get-droptarget", pObj->name());
          strcpy(tmp, tcl.result());
        }
        tcl.evalf("[Simulator instance] connect %s %s", agent_name, tmp);
        if (debug_ > 1) {
          printf("%f: TcpListenerAgent(%s): local connect (%08x:%d)\n",
              now(), agent_name, src_ip, sport);
        }
      }
      dst_ipaddr_ = src_ip;
      dst_ipport_ = sport;
      send_much(1, REASON_NORMAL, maxburst_);
      // Add timeout to map
      if (max_synack_retries_ > 0) {
        add_timeout(rtt_timeout(), src_ip, sport, 0);
        schedule_timeout();
      }
      // Trace this data to out file
      if (trace_enable_ > 1 && trace_pktcount_ % trace_interval_ == 0) {
        trace_pktcount_ = 0;
        if ((trace_fp_ = fopen(trace_file_, "a")) == NULL) {
          printf("%f: TcpListenerAgent(%s): cannot open tracefile (%s)\n", \
              now(), agent_name, trace_file_);
          printf("  for writing. Disabling tracefile output.\n");
          trace_enable_ = 0;
        } else {
          fprintf(trace_fp_, "PACKET %s.%s * %f %s\n", trace_prefix_, \
              trace_nodename_, now(), COLOR_SYNACK);
          fclose(trace_fp_);
        }
      }
    }
    Packet::free(pkt);
  } else if (tiflags == 16) {
    // ACK for our SYN+ACK only if an existing connection doesn't exist yet
    if (get_connection(src_ip, sport) == true) {
      Agent *pAgent = get_agentinfo(src_ip, sport);
      if (!pAgent) {
        char ft_an[255];
        bool no_attach = false;
        // No existing active connection, create new
        if (prebinding_ != 0 && (fulltcp_use_ < fulltcp_num_)) {
          pAgent = fulltcp_[fulltcp_use_];
          fulltcp_use_++;
          no_attach = true;
        } else {
          tcl.evalf("new Agent/TCP/FullTcp");
          pAgent = (Agent *)TclObject::lookup(tcl.result());
        }
        if (!pAgent) {
          printf("%f: TcpListenerAgent(%s): FullTcpAgent creation error\n", \
              now(), agent_name);
          exit(1);
        }
        strcpy(ft_an, pAgent->name());
        // Attach agent to node and connect to source ip
        if (no_attach == false) {
          tcl.evalf("[Simulator instance] attach-agent %s %s", node_name, \
              ft_an);
        }
        // Set the the source ip for the new agent as my ip address
        ((BgpTcpListenerAgent *)pAgent)->set_src(dst_ip, dport);
	
        NsObject *pObj = GetLocalIP(src_ip);
	if(0) cout<<"2Source ip is "<<src_ip_str<<" Object"<<pObj<<"Agent ipaddr: "<<pAgent->get_ipaddr()<<"Attach "<<no_attach<<endl;      
        if (pObj != NULL) {
          char tmp[255];
          tcl.evalf("%s findport %d", pObj->name(), sport);
          strcpy(tmp, tcl.result());
          if (strcmp(tmp, "") == 0) {
            // This should never happen!... but just in case
            tcl.evalf("%s get-droptarget", pObj->name());
            strcpy(tmp, tcl.result());
          }
          tcl.evalf("[Simulator instance] connect %s %s", ft_an, tmp);
        } else {
          tcl.evalf("%s set-dst-ipaddr %d", ft_an, src_ip);
          tcl.evalf("%s set-dst-port %d", ft_an, sport);
          tcl.evalf("[[Simulator instance] set scheduler_] iproute-connect %s %d %d", ft_an, src_ip, sport);
        }
        // Attach a custom application if available
        if (app_agent_ != NULL) {
          if (app_reuse_ != 0) {
            if (app_pApp_ == NULL) {
              tcl.evalf("new %s", app_agent_);
              app_pApp_ = (NsObject *)TclObject::lookup(tcl.result());
              // Perform application callback
              if (strcmp(app_callback_, "0") != 0) {
                tcl.evalf("%s %s %s", app_pApp_->name(), app_callback_, ft_an);
              }
              if (app_recv_ != 0) {
                tcl.evalf("%s enable-recv", app_pApp_->name());
              }
            }
            tcl.evalf("%s attach-agent %s", app_pApp_->name(), ft_an);
          } else {
            tcl.evalf("new %s", app_agent_);
            NsObject *pApp = (NsObject *)TclObject::lookup(tcl.result());
            // Perform application callback
            if (strcmp(app_callback_, "0") != 0) {
              tcl.evalf("%s %s %s", pApp->name(), app_callback_, ft_an);
            }
            if (app_recv_ != 0) {
              tcl.evalf("%s enable-recv", pApp->name());
            }
            tcl.evalf("%s attach-agent %s", pApp->name(), ft_an);
          }
        }
        if (debug_ > 1) {
          printf("%f: TcpListenerAgent(%s): FullTcpAgent %s attached to %s\n",
              now(), agent_name, ft_an, node_name);
          printf("  rconnected to %08x on port %d\n", src_ip, sport);
        }
        // Promote FullTcpAgent to TCPS_ESTABLISHED
        ((BgpTcpListenerAgent *)pAgent)->inherit_attributes(this);
        ((BgpTcpListenerAgent *)pAgent)->promote();
        if (add_agentinfo(src_ip, sport, pAgent) == false) {
          printf("%f: TcpListenerAgent(%s): pAgent add to cmap failed\n", \
              now(), agent_name);
          exit(1);
        }
        Packet::free(pkt);
        if (debug_ > 1) {
          printf("%f: TcpListenerAgent(%s): 3-way handshake complete ", \
              now(), agent_name);
          printf("with %08x\n", src_ip);
        }
        // Modify timeout entry that connection was established
        if (max_synack_retries_ > 0) {
          est_timeout(src_ip, sport);
        }
        // Trace this data to out file
        if (trace_enable_ > 1 && trace_pktcount_ % trace_interval_ == 0) {
          trace_pktcount_ = 0;
          if ((trace_fp_ = fopen(trace_file_, "a")) == NULL) {
            printf("%f: TcpListenerAgent(%s): cannot open tracefile (%s)\n", \
                now(), agent_name, trace_file_);
            printf("  for writing. Disabling tracefile output.\n");
            trace_enable_ = 0;
          } else {
            fprintf(trace_fp_, "PACKET * %s.%s %f %s\n", trace_prefix_, \
                trace_nodename_, now(), COLOR_ACK);
            fclose(trace_fp_);
          }
        }
	if(bgpp_) { 
	  // attach bgp instance to agent 
	  tcl.evalf("%s attach-agent %s",bgpp_->name(),pAgent->name());
	
	  pAgent->bgp_app_ = 1;
	  pAgent->use_bgp_header();
	  // Add accept thread in bgp scheduler
	  bgpp_->thread_add_read(bgpp_->master, &Bgp::bgp_accept, NULL,pAgent);
	  
	  //hack: used to let the bgp application know
	  //that the 3way handshake is over.
	  pAgent->recvBytes(0);
	}

      } else {
        // forward packet to FullTcpAgent
        goto handoff;
      }
    }
  } else {
handoff:
    // forward packet to FullTcpAgent
    Agent *pAgent = get_agentinfo(src_ip, sport);
    if (!pAgent) {
      printf("%f: TcpListenerAgent(%s): get_agentinfo() failed\n", \
          now(), agent_name);
      exit(1);
    }
    if (debug_ > 1) {
      printf("%f: TcpListenerAgent(%s): packet handoff to ", \
          now(), agent_name);
      printf("FullTcpAgent::recv()\n");
    }
    // Trace this data to out file
    if (trace_enable_ > 2 && trace_pktcount_ % trace_interval_ == 0) {
      trace_pktcount_ = 0;
      if ((trace_fp_ = fopen(trace_file_, "a")) == NULL) {
        printf("%f: TcpListenerAgent(%s): cannot open tracefile (%s)\n", \
            now(), agent_name, trace_file_);
        printf("  for writing. Disabling tracefile output.\n");
        trace_enable_ = 0;
      } else {
        fprintf(trace_fp_, "PACKET * %s.%s %f %s\n", trace_prefix_, \
            trace_nodename_, now(), COLOR_DATA);
        fclose(trace_fp_);
      }
    }
    pAgent->recv(pkt, (Handler*)NULL);
    // Check to see if the connection has been closed
    if (((BgpTcpListenerAgent *)pAgent)->get_state() == TCPS_CLOSED) {
      del_connection(src_ip, sport);
      if (debug_ > 1) {
        printf("%f: TcpListenerAgent(%s): TCP connection closed with %08x\n",
            now(), agent_name, src_ip);
        printf("  ts %d conn %d\n", table_size_, connections_);
      }
    } else if (trace_enable_ > 2 && trace_pktcount_ % trace_interval_ == 0) {
      trace_pktcount_ = 0;
      if ((trace_fp_ = fopen(trace_file_, "a")) == NULL) {
        printf("%f: TcpListenerAgent(%s): cannot open tracefile (%s)\n", \
            now(), agent_name, trace_file_);
        printf("  for writing. Disabling tracefile output.\n");
        trace_enable_ = 0;
      } else {
        fprintf(trace_fp_, "PACKET %s.%s * %f %s\n", trace_prefix_, \
            trace_nodename_, now(), COLOR_DATA);
        fclose(trace_fp_);
      }
    }
  }
  reset_state();
}
