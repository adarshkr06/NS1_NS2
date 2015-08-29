
/*
 * rs_cmds.cc
 * Copyright (C) 2000 by the University of University of Massachussets
 * $Id: rs_cmds.cc,v 1.8 2005/08/25 18:58:01 Adarsh KR $
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 *
 * The copyright of this module includes the following
 * linking-with-specific-other-licenses addition:
 *
 * In addition, as a special exception, the copyright holders of
 * this module give you permission to combine (via static or
 * dynamic linking) this module with free software programs or
 * libraries that are released under the GNU LGPL and with code
 * included in the standard release of ns-2 under the Apache 2.0
 * license or under otherwise-compatible licenses with advertising
 * requirements (or modified versions of such code, with unchanged
 * license).  You may copy and distribute such a system following the
 * terms of the GNU GPL for this module and the licenses of the
 * other code concerned, provided that you include the source code of
 * that other code when and as the GNU GPL requires distribution of
 * source code.
 *
 * Note that people who make modified versions of this module
 * are not obligated to grant this special exception for their
 * modified versions; it is their choice whether to do so.  The GNU
 * General Public License gives permission to release a modified
 * version without this exception; this exception also makes it
 * possible to release a modified version which carries forward this
 * exception.
 *
 */

// $Header: /cvsroot/nsnam/ns-2/apps/rs_cmds.cc,v 1.5 2005/08/25 18:58:01 Adarsh KR $

/*
 * File: Code for Route Server commands Agent Class for the ns
 *       network simulator
 * Author: Adarsh KR (aranagaiah@umass.edu), May 1998
 *
 * IMPORTANT: Incase of any changes made to this file ,
 * tutorial/examples/rs_cmds.cc should be updated as well.
 */

#include "rs_cmds.h"
#include <map>

static int instance_cnt = 0;
map<int, RSAgent*> instance_map;


int hdr_rs_cmds::offset_;
static class RSHeaderClass : public PacketHeaderClass {
public:
	RSHeaderClass() : PacketHeaderClass("PacketHeader/RS", 
					      sizeof(hdr_rs_cmds)) {
		bind_offset(&hdr_rs_cmds::offset_);
	}
} class_rshdr;


static class RSClass : public TclClass {
public:
	RSClass() : TclClass("Agent/RS") {}
	TclObject* create(int, const char*const*) {
		return (new RSAgent());
	}
} class_rs;


RSAgent::RSAgent() : Agent(PT_RS)
{
	cout << "\n INSTANCE CREATED AT : " << this << endl;
	instance_map[instance_cnt] = (RSAgent *)this;
	instance_cnt++;

	bind("packetSize_", &size_);
}

int RSAgent::command(int argc, const char*const* argv)
{
  if (argc == 4) {
    if (strcmp(argv[1], "send") == 0) {
      // Create a new packet
      Packet* pkt = allocpkt();
      // Access the RS header for the new packet:
      hdr_rs_cmds* hdr = hdr_rs_cmds::access(pkt);
      // Second argument from TCL is the AS number
      hdr->as_number = std::stoi(argv[2]);
      // Third argument from TCL is the event type
      hdr->etype = (enum event_type)std::stoi(argv[3]);
      // Send the packet
      send(pkt, 0);
      // return TCL_OK, so the calling function knows that
      // the command has been processed
      return (TCL_OK);
    
    }
  }
  else if (argc == 5)
  {
    if (strcmp(argv[1],"send") == 0) {
      // Create a new packet
      Packet* pkt = allocpkt();
      // Access the RS header for the new packet:
      hdr_rs_cmds* hdr = hdr_rs_cmds::access(pkt);
      // Second argument from TCL is the AS number
      hdr->as_number = std::stoi(argv[2]);
      // Third argument from TCL is the event type
      hdr->etype = (enum event_type)std::stoi(argv[3]);
      // Fourth argument from TCL is the prefix/router id
      int ret = inet_aton (argv[4], &(hdr->u.router_id));
      if (!ret)
      {
         cout << "Malformed bgp router identifier%s" << endl;
         return (TCL_ERROR);
      }
      // Send the packet
      send(pkt, 0);
      // return TCL_OK, so the calling function knows that
      // the command has been processed
      return (TCL_OK);
    
    }

  }
  
  else if (argc == 6)
  {
    if (strcmp(argv[1],"send") == 0) {
      // Create a new packet
      Packet* pkt = allocpkt();
      // Access the RS header for the new packet:
      hdr_rs_cmds* hdr = hdr_rs_cmds::access(pkt);
      // Second argument from TCL is the AS number
      hdr->as_number = std::stoi(argv[2]);
      // Third argument from TCL is the event type
      hdr->etype = (enum event_type) std::stoi(argv[3]);
      // Fourth argument from TCL is the prefix/router id
      int ret = inet_aton (argv[4], &(hdr->u.ip_addr.prefix));
      if (!ret)
      {
         cout << "Malformed IP prefix address%s" << endl;
         return (TCL_ERROR);
      }
      hdr->u.ip_addr.prefixlen = std::stoi(argv[5]);
      // Send the packet
      send(pkt, 0);
      // return TCL_OK, so the calling function knows that
      // the command has been processed
      return (TCL_OK);
    
    }

  }
  
  // If the command hasn't been processed by PingAgent()::command,
  // call the command() function for the base class
  return (Agent::command(argc, argv));
}


void RSAgent::recv(Packet* pkt, Handler*)
{
    // Access the Route Server cmds header for the received packet:
    hdr_rs_cmds* hdr = hdr_rs_cmds::access(pkt);

    /* Logic to call NS2 from NS1 */
    int as_number = hdr->as_number;
    enum event_type etype = hdr->etype;
 
    ofstream tclfile;
    tclfile.open ("ns.tcl",ios::app);

    if (etype == PREFIX_ADVER)
    {
    	string ip_prefix = inet_ntoa(hdr->u.ip_addr.prefix);
    	int prefixlen = hdr->u.ip_addr.prefixlen;
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"network " << ip_prefix << "/" << prefixlen << "\\\"\"" << endl;
    }
    else if (etype == PREFIX_WITHD)
    {
    	string ip_prefix = inet_ntoa(hdr->u.ip_addr.prefix);
    	int prefixlen = hdr->u.ip_addr.prefixlen;
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"no network " << ip_prefix << "/" << prefixlen << "\\\"\"" << endl;

    }
    else if (etype == NEIGHB_SHUTDOWN)
    {
    	string router_id = inet_ntoa(hdr->u.router_id);
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"neighbor " << router_id << " shutdown\\\"\"" << endl;

    }
    else if (etype == NO_NEIGHB_SHUTDOWN)
    {
    	string router_id = inet_ntoa(hdr->u.router_id);
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"no neighbor " << router_id << " shutdown\\\"\"" << endl;

    }
    else if (etype == POLICY_CHANGE_PERMIT_NONCUST)
    {
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"route-map RMAP_NONCUST_OUT permit 10\\\"\"" << endl;
	tclfile << "$ns at 15 \"$BGP" << as_number << " command \\\"clear ip bgp * soft\\\"\"" << endl;

    }
    else if (etype == POLICY_CHANGE_DENY_NONCUST)
    {
	tclfile << "$ns at 10 \"$BGP" << as_number << " command \\\"route-map RMAP_NONCUST_OUT deny 10\\\"\"" << endl;
	tclfile << "$ns at 15 \"$BGP" << as_number << " command \\\"clear ip bgp * soft\\\"\"" << endl;

    }


    tclfile << "$ns run" << endl;
    tclfile.close();
    int ret;

    ret = system("cp ns.tcl  ~/NS2/bgp++1.05/doc/3peers/3peers.tcl");
    if(ret)
	cout << "\nSYSTEM CALL CP UNSUCCESSFUL" << endl;

    ret = system("~/NS2/ns-allinone-2.35/ns-2.35/ns ~/NS2/bgp++1.05/doc/3peers/3peers.tcl -dir ~/NS2/bgp++1.05/doc/3peers/ -stop 20");
    if(ret)
	cout << "\nSYSTEM CALL NS UNSUCCESSFUL" << endl;

    ret = system("cp ns_basic.tcl ns.tcl");
    if(ret)
	cout << "\nSYSTEM CALL CP UNSUCCESSFUL" << endl;

    for(int i = 0; i < instance_cnt; i++)
	cout << "INSTANCE " << i << " VALUE IS " << instance_map[i] << endl;

    return;
    
}


