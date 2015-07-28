/* -*-	Mode:C++; c-basic-offset:2; tab-width:2; indent-tabs-mode:t -*- */
/*
 * Copyright (c) 1997 Regents of the University of California.
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
 *	This product includes software developed by the Daedalus Research
 *	Group at the University of California Berkeley.
 * 4. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
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
 *
 */

#include "routeapp.h"
#include "scheduler.h"

UniformRandomVariable* RouteApp::pRNG;

static class RouteAppClass : public TclClass {
 public:
	RouteAppClass() : TclClass("Application/Route") {}
	TclObject* create(int, const char*const*) {
		return (new RouteApp);
	}
} class_app_route;

RouteApp::RouteApp() : pNode(0)
{ // Constructor
	if (!pRNG) pRNG = new UniformRandomVariable(0,1);
  timer = new RouteTimer(this);
  //timer->resched(pRNG->value()); // Call the timeout for testing
	//		xo	timer->resched(pRNG->value() * 180.0); // Call the timeout for testing
}

void RouteApp::recv(int nbytes, Agent* pFrom)
{
  // First find the peer entry
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      if (peers[i].m_rxagent == pFrom)
        { // Found it
          Peer& p = peers[i];
          p.m_rxbytes += nbytes;
          if(0)printf("RouteApp::recv self %s nb %d rxb %d\n",
                      name(), nbytes, p.m_rxbytes);
          while(true)
            { // Deliver complete messages
              if (p.m_msgs.size() == 0) break;
							RouteMsg& msg = p.m_msgs.front();
              if (p.m_rxbytes < msg.Size()) break; // Not enough yet
              p.m_rxbytes -= msg.Size(); // Reduce pending bytes
							msg.Reset();  // Reset offset to beginning
              recvMessage(msg, p.m_app);
              p.m_msgs.pop_front(); // And delete from the deque
            }
          if (p.m_rxbytes && (p.m_msgs.size() == 0))
            { // ? HuH, got bytes with no pending message
              printf("RouteApp::recv %d bytes w/o pending message, ignoring\n",
                     p.m_rxbytes);
              p.m_rxbytes = 0;
            }
          return;
        }
    }
  printf("RouteApp::recv from %p, cant find\n", pFrom);
}

void RouteApp::timeout()
{
  double now = Scheduler::instance().clock();
  printf("RouteApp::timeout, time %f\n", now);
  //timer->resched(29.5+pRNG->value()); // Call the timeout again ~30 sec in future
  timer->resched(175.0 + pRNG->value()*10.0); // timeout again [175-185] sec in future
  // for debugging, send a sample msg to all peers
  RouteMsg m;
  char buf[100];
  for (int i = 0; i < 100; ++i) buf[i] = i;
  m.Append(sizeof(buf), buf);
  sendMessage(m);
}

int RouteApp::command(int argc, const char*const* argv)
{
	if (argc == 2)
		{
      if (strcmp(argv[1], "debug-print") == 0)
				{
					printf("Print debug info here\n");
          return(TCL_OK);
				}
		}
  if (argc == 3)
    {
      if (strcmp(argv[1], "attach-node") == 0)
        {
          Tcl& tcl = Tcl::instance();
          pNode = (NsObject*) TclObject::lookup(argv[2]);
          if (!pNode)
            {
              tcl.resultf("RouteApp::attach-node, no such node %s", argv[2]);
              return(TCL_ERROR);
            }
          return(TCL_OK);
        }
      if (strcmp(argv[1], "connect-peer") == 0)
        {
          if (!pNode)
            {
              printf("RouteApp::connect-peer, cant connect without node\n");
              return(TCL_ERROR);
            }
          Tcl& tcl = Tcl::instance();
          RouteApp* pPeer = (RouteApp*) TclObject::lookup(argv[2]);
          if (!pPeer)
            {
              tcl.resultf("RouteApp::connect-peer, no such peer %s", argv[2]);
              return(TCL_ERROR);
            }
          tcl.evalc("new Agent/TCP/FullTcp");
          FullTcpAgent* pLocal = (FullTcpAgent*)TclObject::lookup(tcl.result());          
					tcl.evalc("new Agent/TCP/FullTcp");
          FullTcpAgent* pRemote = (FullTcpAgent*)TclObject::lookup(tcl.result());
          MyAgent =(FullTcpAgent*) pLocal ; 
					if(0)printf("pLocal %s pRemote %s\n",
                      pLocal->name(), pRemote->name());
          attachTxAgent(pPeer, pLocal);
          pPeer->attachRxAgent(this, pRemote);
          tcl.evalf("%s listen", pRemote->name());
          tcl.evalf("[Simulator instance] connect %s %s",
                    pLocal->name(), pRemote->name());
          return(TCL_OK);
  			}
    }
  if (argc == 4)
    {
      if (strcmp(argv[1], "message-to") == 0)
        { // This is just for testing
          Tcl& tcl = Tcl::instance();
          RouteApp* pPeer = (RouteApp*)TclObject::lookup(argv[2]);
          if (!pPeer)
            {
              tcl.resultf("RouteApp::message-to, no such peer %s", argv[2]);
              return(TCL_ERROR);
            }
          int nbytes = atoi(argv[3]);
          char d[nbytes];
          memset(d, 0, nbytes); // Clear the buffer (just testing)
          RouteMsg m(nbytes, d);
          return sendMessage(pPeer, m);
        }
    }
  return Application::command(argc, argv);
}

void RouteApp::attachAgent(NsObject* pAgent)
{
  Tcl& tcl = Tcl::instance();
  // Attach agent to node

	tcl.evalf("[Simulator instance] attach-agent %s %s",
            pNode->name(), pAgent->name());
  // And attach application to agent
  tcl.evalf("%s attach-agent %s", name(), pAgent->name());
  
}

void RouteApp::attachTxAgent(RouteApp* peer, FullTcpAgent* pAgent)
{
  attachAgent(pAgent);
  Peer* pPeer = NULL;
  // Find already known peer
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      if (peers[i].m_app == peer)
        { // Found it
          pPeer = &peers[i];
          break;
        }
    }  
  if (pPeer)
    { // existing
      if(0)printf("RouteApp::attachTxAgent using existing peer %s\n",
             pPeer->m_app->name());
      pPeer->m_txagent = pAgent;
    }
  else
    {
      if(0)printf("RouteApp::attachTxAgent creating new peer %s\n",
             peer->name());
      peers.push_back(Peer(peer, pAgent, NULL));
    }
}

void RouteApp::attachRxAgent(RouteApp* peer, FullTcpAgent* pAgent)
{
  attachAgent(pAgent);
  Peer* pPeer = NULL;
  // Find already known peer
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      if (peers[i].m_app == peer)
        { // Found it
          pPeer = &peers[i];
          break;
        }
    }  
  if (pPeer)
    { // existing
      if(0)printf("RouteApp::attachRxAgent using existing peer %s\n",
             pPeer->m_app->name());
      pPeer->m_rxagent = pAgent;
    }
  else
    {
      if(0)printf("RouteApp::attachRxAgent creating new peer %s\n",
             peer->name());
      peers.push_back(Peer(peer, NULL, pAgent));
    }
}

void RouteApp::sendMessage(const RouteMsg& m)
{ // Send a message to all peers
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      sendMessage(peers[i].m_app, m);
    }  
}

int  RouteApp::sendMessage(RouteApp* pPeer, const RouteMsg& m)
{
  // Locate the peer in the peer list
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      if (peers[i].m_app == pPeer)
        { // Pass the msg contents out-of-band
          pPeer->acceptMessage(m, this);
          // Then tell tcp to send
          Tcl& tcl = Tcl::instance();
					double now = Scheduler::instance().clock();
          tcl.evalf("%s advance-bytes %d",
                    peers[i].m_txagent->name(), m.Size());
          return(TCL_OK);
        }
    }
  printf("RouteApp::sendMessage, cant find peer %s\n", pPeer->name());
  return(TCL_ERROR);
}

void RouteApp::acceptMessage(const RouteMsg& m, RouteApp* f)
{
  // Find the peer
  for (PeerVec_t::size_type i = 0; i < peers.size(); ++i)
    {
      if (peers[i].m_app == f)
        { // Found it
          //Peer& p = peers[i];
					int *r;
				 
          peers[i].m_msgs.push_back(m); // Add to end of list of pending messages
					printf("%d",r);
				}
    }
}

void RouteApp::recvMessage(RouteMsg& m, RouteApp* pFrom)
{
  double now = Scheduler::instance().clock();
  printf("RouteApp::recvMessage, self %s from %s size %d time %f\n", 
         name(), pFrom->name(), m.Size(), now);
}

















