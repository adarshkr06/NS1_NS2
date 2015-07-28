#ifndef ns_divert_h
#define ns_divert_h

#include "agent.h"
#include "node.h"
#include "packet.h"

#include <list>
#include <utility>

typedef pair<Packet*,Handler*> packet_h_t;

class DivertSocket : public Agent {
 public:
  DivertSocket();
  //DivertSocket(NsObject*);	
  ~DivertSocket();
  virtual void recv(Packet*, Handler*);
  int command(int argc, const char*const* argv);
  void set_callback(void (*func)(Application*,Agent*),Application*);
  packet_h_t* recvfrom();

 protected:    
  list<packet_h_t> MsgQueue_;
  void (*callback_) (Application*,Agent*);  //app callback,
                                            //called when new 
                                            //packets arrive
  Application* app_;  //app that this socket is attached to
  Node* node_;
};

#endif /*ns_divert_h*/
