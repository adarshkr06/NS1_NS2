/* -*-	Mode:C++; c-basic-offset:8; tab-width:8; indent-tabs-mode:t -*- */
/*
 * Copyright (c) 1996 Regents of the University of California.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 * 	This product includes software developed by the MASH Research
 * 	Group at the University of California Berkeley.
 * 4. Neither the name of the University nor of the Research Group may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <stdlib.h>
#include "classifier-bgp.h"
#include "packet.h"
#include "bgp/hdr_bgp.h"
#include "bgp/hdr_atoms.h"
#include "assert.h"

static class BgpClassifierClass : public TclClass {
public:
	BgpClassifierClass() : TclClass("Classifier/Hash/Dest/BGP") {}
	TclObject* create(int argc, const char*const* argv) {
		
		assert(argc==5);		
		Node* node_ =	(Node*) TclObject::lookup(argv[4]);		
		if(!node_) { 
			printf("BgpClassifier linkage Error: bad node identifier %s\n",argv[4]);
			return NULL;
		}
		return (new BgpClassifier(node_));			
	}
} bgp_class_classifier;

BgpClassifier::BgpClassifier(Node* n):bgp_instance_(NULL){
	if(0) cout<<"BgpClassifier() Constructor"<<endl<<flush;
	node_ = n;
}

NsObject* BgpClassifier::find(Packet* p)
{
	NsObject* link_head = NULL;
	hdr_bgp* hdr_b;
	hdr_b = HDR_BGP(p);
	
	hdr_cmn* chdr;
	chdr = hdr_cmn::access(p);
	int id;
	id = chdr->uid();				
	
	/*If this is a BGP msg than we do static routing
	  otherwise use BGP table to route packets*/
	if(hdr_b->valid()) { 

		if(0)
			if(bgp_instance_)		
				printf("PacketTrace: router %s     \tstat \tpkt " 
				       "\tuid: %d \tat %lf\n",
				       inet_ntoa(bgp_instance_->bgp_get_default()->id),					
				       id,NOW);
		
		int cl = classify(p);
		if (cl < 0 || cl >= nslot_ || (link_head = slot_[cl]) == 0) { 
			if (default_target_) 
				return default_target_;
			/*
			 * Sigh.  Can't pass the pkt out to tcl because it's
			 * not an object.
			 */
			Tcl::instance().evalf("%s no-slot %ld", name(), cl);
			if (cl == TWICE) {
				/*
				 * Try again.  Maybe callback patched up the table.
				 */
				cl = classify(p);
				if (cl < 0 || cl >= nslot_ || (link_head = slot_[cl]) == 0)
					return (NULL);
			}
		}
		return (link_head);		
	} else { 
		if(0) cout<<"BgpClassifier::recv: rcvd regular packet, using dynamic routing"<<endl;			
				
		if(0)
			if(bgp_instance_)		
				printf("PacketTrace: router %s     \tdyn \tpkt " 
				       "\tuid: %d \tat %lf\n",
				       inet_ntoa(bgp_instance_->bgp_get_default()->id),					
				       id,NOW);
		
		hdr_ip* iphd = hdr_ip::access(p);
		
		/*First look if the packet is destined for us*/
		/*we still use the ip hdr to determine this */
		if(iphd->daddr() == node_->nodeid() ) { 
			if(0) cout<<"BgpClassifier::recv: rcvd bgp packet, \
                           fwd packet to port demux"<<endl;
			return demux();
		} else { 				

			ipaddr_t ip;
			ipaddr_t sip;

			hdr_rti* rhdr = hdr_rti::access(p);
			sip = rhdr->ipsrc();
			hdr_atom* ahdr = HDR_ATOM(p);		

			if(ahdr->valid()) { 
				/*If the atom header is valid use it
				  to do routing, otherwise use rti header. 
				*/
				ip = ahdr->ipdst();
				
			} else { 
				ip = rhdr->ipdst();
				if(0) cout<<"HDR dump d:"<<ip<<"s:"<<rhdr->ipsrc()<<endl;

			}		

			u_char * sipstr = (u_char*) &sip;			
			u_char * ipstr = (u_char*) &ip;
						
			/*Check if BGP router is set*/
			if(!bgp_instance_) { 
				if (!default_target_)  {
					cout<<"BgpClassifier::recv: Error no BGP instance set and no default target"<<endl;
					return NULL;
				}
				else { 
					if(0) cout<<name()<<": Fwding to default target"<<endl;
					printf("PacketTrace: router %s     \tdft \tpkt " 
					       "\tuid: %d \tdst ip: %u.%u.%u.%u  \tsrc ip: %u.%u.%u.%u \tat %lf\n",
					       inet_ntoa(bgp_instance_->bgp_get_default()->id),					
					       id,ipstr[3],ipstr[2],ipstr[1],ipstr[0],
					       sipstr[3],sipstr[2],sipstr[1],sipstr[0],NOW);
					return default_target_;
				}					      
			}
			
			if(0) cout<<"Using ip: "<<ip<<"to route packet"<<endl;
			
			unsigned int nip = htonl(ip);
			link_head = bgp_instance_->bgp_table_lookup((struct in_addr*)&nip);

			if(!link_head) {
				if(default_target_) { 
					if(0) cout<<"BgpClassifier::recv: fwd to default target"<<endl;				       
					printf("PacketTrace: router %s     \tfwd dft \tpkt " 
					       "\tuid: %d \tdst ip: %u.%u.%u.%u  \tsrc ip: %u.%u.%u.%u \tat %lf\n",
					       inet_ntoa(bgp_instance_->bgp_get_default()->id),					
					       id,ipstr[3],ipstr[2],ipstr[1],ipstr[0],
					       sipstr[3],sipstr[2],sipstr[1],sipstr[0],NOW);
					return default_target_;
				}
				/*Drop packet*/
				if(0) cout<<"BgpClassifier::recv: no route found in BGP routing"
					  <<" table and no default target,  dropping packet"<<endl;				
				
				printf("PacketTrace: router %s     \tdrop \tpkt " 
					"\tuid: %d \tdst ip: %u.%u.%u.%u  \tsrc ip: %u.%u.%u.%u \tat %lf\n",
					inet_ntoa(bgp_instance_->bgp_get_default()->id),					
					id,ipstr[3],ipstr[2],ipstr[1],ipstr[0],
					sipstr[3],sipstr[2],sipstr[1],sipstr[0],NOW);
				Packet::free(p);
				return NULL;
			}
			if(0) cout<<"Fwding packet to :"<<link_head->name()<<endl;
			
			printf("PacketTrace: router %s     \tfwd \tpkt " 
				"\tuid: %d \tdst ip: %u.%u.%u.%u  \tsrc ip: %u.%u.%u.%u \tat %lf\n",
				inet_ntoa(bgp_instance_->bgp_get_default()->id),
				id,ipstr[3],ipstr[2],ipstr[1],ipstr[0],
				sipstr[3],sipstr[2],sipstr[1],sipstr[0],NOW);

			return link_head;
		}

	} 
	cout<<"BgpClassifier::recv: Error this shouldnt happen"<<endl;			
	return NULL;
}


NsObject*
BgpClassifier::demux() { 
	Tcl& tcl  = Tcl::instance();
	tcl.evalf("%s demux",node_->name());
	return (NsObject*)TclObject::lookup(tcl.result());
}        
int BgpClassifier::command(int argc, const char*const* argv)
{
	Tcl& tcl = Tcl::instance();
	if (argc == 3) {
		if (strcmp(argv[1], "bind-bgp") == 0) {			
			if(bgp_instance_) 
				printf("BgpClassifier::command: Warning attempt to overwrite bgp instance!\n");
			
			bgp_instance_ =	(Bgp*) TclObject::lookup(argv[2]);

			if(!bgp_instance_) {
				printf("BgpClassifier::command: bad bgp instance identifier %s\n",argv[2]);
				return (TCL_ERROR);							
			}			
			return (TCL_OK);						
		}
	} 
	return (DestHashClassifier::command(argc, argv));
}
