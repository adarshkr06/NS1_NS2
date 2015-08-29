
/*
 * rs_cmds.h
 * Copyright (C) 2000 by the University of Southern California
 * $Id: ping.h,v 1.5 2005/08/25 18:58:01 johnh Exp $
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

//
// $Header: /cvsroot/nsnam/ns-2/apps/rs_cmds.h,v 1.5 2005/08/25 18:58:01 Adarsh KR $

/*
 * File: Header File for a new ns commands Agent Class for the ns
 *       network simulator
 * Author: Adarsh KR (aranagaiah@umass.edu), May 1998
 *
 * IMPORTANT: Incase of any changes made to this file ,
 * tutorial/examples/rs_cmds.h should be updated as well.
 */


#ifndef rs_cmds_h
#define rs_cmds_h

#include "agent.h"
#include "tclcl.h"
#include "packet.h"
#include "address.h"
#include "ip.h"
#include <iostream>
#include <string>
#include <fstream>

/* Event type enumeration */
enum event_type {
	PREFIX_ADVER = 0,
	PREFIX_WITHD,
	NEIGHB_SHUTDOWN,
	NO_NEIGHB_SHUTDOWN,
	POLICY_CHANGE_PERMIT_NONCUST,
	POLICY_CHANGE_DENY_NONCUST,
};

/* IPv4 prefix structure. */
struct prefix_ipv4
{
  int prefixlen;
  struct in_addr prefix;
};

struct hdr_rs_cmds {
	int as_number;			// AS which generated the event 
 	enum event_type etype;		// Event type
	union {
		struct prefix_ipv4 ip_addr;	// Prefix to be announced/withdrawn
		struct in_addr router_id;	// Router id of neighbor
	}u;

	// Header access methods
	static int offset_; // required by PacketHeaderManager
	inline static int& offset() { return offset_; }
	inline static hdr_rs_cmds* access(const Packet* p) {
		return (hdr_rs_cmds*) p->access(offset_);
	}
};

class RSAgent : public Agent {
public:
	RSAgent();
	virtual int command(int argc, const char*const* argv);
	virtual void recv(Packet*, Handler*);
};

#endif // rs_cmds_h
