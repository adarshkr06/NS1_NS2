#include "divert.h"
#include "app.h"
#include "bgp/bgp.h"
#include "bgp/hdr_bgp.h"
/*****************************************************/
/***************  TCL LINKAGE ************************/
/*****************************************************/
static class DivertSocketClass : public TclClass
{
public:
  DivertSocketClass() : TclClass("Agent/DivertSocket") {}
  TclObject* create(int, const char*const*) {
    return(new DivertSocket);
  }
} class_divert_socket_;

/*****************************************************/
/***************  Divert Socket Methods **************/
/*****************************************************/

DivertSocket::DivertSocket():Agent(PT_NTYPE),callback_(NULL),app_(NULL),node_(NULL){
}

DivertSocket::~DivertSocket(){
  /*Remove Divert Socket */
  /*To remove the divert socket we also have to store 
    a pointer to the link end point and change the 
    target of the link end point!!!. The following code 
    alone wont work*/
//   if(node_) {
//     Tcl& tcl = Tcl::instance();               
//     tcl.evalf("
//        proc remove-divert-sock {node target} { 
//            $node instvar classifier_ mod_assoc_ hook_assoc_;
//            if [info exists classifier_] { 
//              if [info exists mod_assoc_($classifier_)] { 
// 	       unset mod_assoc_($classifier_); 
// 	     } 
//              if [info exists hook_assoc_($classifier_)] { 
//                unset hook_assoc_($classifier_); 
//              } 
//            }
//            set classifier_ $target ;
//     }");    
//     tcl.evalf("remove-divert-sock %s %s",node_->name(),target()->name());    
//   }
}

// DivertSocket::DivertSocket(NsObject* n):Agent(PT_NTYPE),callback_(NULL),app_(NULL),node_(NULL){
//   if (n) cout<<"Object passed: "<<n->name()<<flush;
//   else cout<<"No object passed"<<endl<<flush;
//   Tcl& tcl = Tcl::instance();     
//   /*Place Divert Socket */
//   tcl.evalf("%s insert-entry dummy_module %s target",n->name(),name());
//   node_ =(Node*) n;
// }

void 
DivertSocket::recv(Packet* p, Handler* h){ 

  if(0)printf("DivertSocket::recv Rcvd packet!!!\n");
  MsgQueue_.push_back(packet_h_t(p,h));

//   hdr_cmn* chdr;
//   chdr = hdr_cmn::access(p);  
//   int id;
//   id = chdr->uid();				

//   printf("divert %s enque: %d",name(),id);
  
//   hdr_bgp* bgph;
//   bgph = HDR_BGP(p);
//   printf(" bgpd header :%s",bgph->valid()?"true\n":"false\n");
  
  if(callback_)
    (*callback_)(app_,this);
} 

int 
DivertSocket::command(int argc, const char*const* argv){ 

  if (argc == 3)
    {
      if (strcmp(argv[1], "bind") == 0) {
	Node* n = NULL;
	Tcl& tcl = Tcl::instance();
	n = (Node*) TclObject::lookup(argv[2]);

	if(!n) { 
	  printf("DivertSocket(bind): Bad node identifier %s\n",argv[2]);fflush(stdout);
	  return (TCL_ERROR);
	}
	if(node_){ 
	  printf("DivertSocket(bind): Error DivertSocket already bound to node %s\n",node_->name());fflush(stdout);
	  return (TCL_ERROR);
	}
	node_ = n;	
	tcl.evalf("%s insert-entry dummy_module %s target",n->name(),name());
	/*Update incident links */
	tcl.evalf("foreach nb [ %s neighbors ]  {\n"
		  "[[[Simulator instance] link $nb %s] set ttl_] target [%s entry];\n"
		  "}"
		  ,n->name(),n->name(),n->name());
	/*Update agents */
	tcl.evalf("foreach agent [ %s set agents_ ]  {\n"
		  "$agent target [%s entry];\n"
		  "}"
		  ,n->name(),n->name());
	return (TCL_OK);
      }
      if (strcmp(argv[1], "set-callback-bgp") == 0) {
	//for testing
	Bgp* bgp;
	Tcl& tcl = Tcl::instance();
	bgp = (Bgp*) TclObject::lookup(argv[2]);
	if(!bgp) { 
	  printf("DivertSocket(set-callback-bgp):Bad Bgp identifier %s",
		 argv[2]);fflush(stdout);
	  return (TCL_ERROR);
	}
	set_callback((void (*) (Application *, Agent *))&Bgp::bgp_interrupt,
		     (Application*)bgp);
	return (TCL_OK);
      }
  
  }
  
  return (Agent::command(argc, argv));  
} 

void 
DivertSocket::set_callback(void (*func)(Application*,Agent*),Application* a){ 
  callback_ = func;
  app_ = a;
}
/*Free the returned pointer if u don't need it*/
packet_h_t*
DivertSocket::recvfrom(){ 

  packet_h_t* ret;
  if(0) printf("DivertSocket:: Rcvfrom !!!\n");

  if (MsgQueue_.empty()) {
    printf("DivertSocket::recvfrom() warning MsgQueue is empty\n");
    return NULL;
  }
  
  ret = new packet_h_t(MsgQueue_.front());

//   hdr_cmn* chdr;
//   chdr = hdr_cmn::access(ret->first);  
//   int id;
//   id = chdr->uid();				

//   printf("divert %s  deque: %d",name(),id);

//   hdr_bgp* bgph;
//   bgph = HDR_BGP(ret->first);
//   printf(" bgpd header :%s",bgph->valid()?"true\n":"false\n");

  MsgQueue_.pop_front();

  return ret;
}

