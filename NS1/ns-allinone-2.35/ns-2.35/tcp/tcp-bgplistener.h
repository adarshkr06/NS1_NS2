/* 
   Bgp Tcp Listener, Tcp Listener slightly modified for BGP 
   Created by Xenofontas Dimitropoulos, GaTech Spring 2003
*/
#ifndef ns_bgp_tcp_listener_
#define ns_bgp_tcp_listener_

#include "tcp-listener.h"
#include "bgp/bgp.h"

class BgpTcpListenerAgent : public TcpListenerAgent {
 public:
  BgpTcpListenerAgent():bgpp_(NULL){};
  virtual void recv(Packet *pkt, Handler*);
  inline void setbgp(Bgp* b) { bgpp_ = b; };
 protected:
  Bgp *bgpp_; /* pointer to bgp instance that tcp 
		 listener is attached to */
};

#endif /* ns_bgp_tcp_listener_ */
