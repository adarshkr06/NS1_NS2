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

// Base class for routing messages
// George F. Riley, Georgia Tech, Spring 2002

#ifndef ns_routemsg_h
#define ns_routemsg_h
class RouteMsg {
  public :
    RouteMsg();                  // Default, size = 0
    RouteMsg(int sz);            // Specified size
    RouteMsg(int sz, char* pd);  // Specified size and data
    RouteMsg(const RouteMsg& r); // Copy constructor
    virtual ~RouteMsg();
    RouteMsg& operator=(const RouteMsg& r); // Assignment operator
    // Data Management
    void Append(int sz, char* pd); // Append to existing message
  	void Append(unsigned long m);
    int  Size() const { return m_sz;}    // Get size of message
    int  Offs() const { return m_offs;}  // Get offset
    int  Get(int sz, char* pt);    // Get data to specified target from offs
  	int  Get(unsigned long*);      // Get the next unsigned long
    int  GetAll(int sz, char* pt) const; // Get data to specified target
    int  Reset() { m_offs = 0;}    // Reset retrieval to beginning
  private: 
    int   m_sz;   // Size of message
    int   m_offs; // Current offset in retrieval or appending
    char* m_msg;  // Contents of message
};

#endif


