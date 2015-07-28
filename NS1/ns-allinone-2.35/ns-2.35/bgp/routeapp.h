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
 * @(#) $Header$
 */

// Base class for routing applications
// George F. Riley, Georgia Tech, Spring 2002

#ifndef ns_routeapp_h
#define ns_routeapp_h

#include "apps/app.h"
#include "common/agent.h"
#include "tcp/tcp-full.h"
#include "scheduler.h"
#include "bgp/routemsg.h"
#include "ranvar.h"

#include <vector>
#include <list>

class RouteApp;
class RouteTimer;

typedef list<RouteMsg>  RMsgList_t;   // Queue of pending messages
class Peer {
public:
  Peer(RouteApp* a, FullTcpAgent* s, FullTcpAgent* r) 
    : m_app(a), m_txagent(s), m_rxagent(r), m_rxbytes(0) { };
public:
  RouteApp* m_app;
  FullTcpAgent*    m_txagent;
  FullTcpAgent*    m_rxagent;
  int       m_rxbytes; // Pending received bytes from this peer
  RMsgList_t m_msgs;    // Queue of pending msgs from this peer
};

//typedef pair<RouteApp*, Agent*> AgentPair_t; // Connected tcp agents(old)
typedef vector<Peer> PeerVec_t;   // Used for peer list (tcp agents)

class RouteApp : public Application {
 public:
	RouteApp();
	virtual void recv(int nbytes, Agent* pFrom);
  virtual void timeout();             // Timer has expired
protected:
	int command(int argc, const char*const* argv);
	// Attach the specified agent
	void attachAgent(NsObject* pAgent);
	// Tx and Rx endpoint management
	void attachTxAgent(RouteApp* pPeer, FullTcpAgent* pAgent);
	void attachRxAgent(RouteApp* pPeer, FullTcpAgent* pAgent);
	void sendMessage(const RouteMsg& m); // Send to all peers
	int  sendMessage(RouteApp* peer, const RouteMsg& m);
	// OOB message passing, acceptMessage from peer app
	void acceptMessage(const RouteMsg& m, RouteApp* f);
	virtual void recvMessage(RouteMsg& m, RouteApp* pFrom);  // msg recv
	bool isPeer(NsObject* pPeer);       // True if peer already known
	bool isPeer(char* pPeer);           // True if peer already known
protected:
	NsObject*  pNode;  // Node attached to
	PeerVec_t peers;   // Vector of peers
	RouteTimer* timer; // Timer for routing updates
        FullTcpAgent*  MyAgent ; 
        static UniformRandomVariable* pRNG;
};

class RouteTimer : public TimerHandler { // Timer for routing apps
public: 
	RouteTimer(RouteApp* a) : TimerHandler() { pRouteApp = a; }
protected:
	void expire(Event *e) { pRouteApp->timeout();}
	RouteApp* pRouteApp;
};

#endif


