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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "routemsg.h"

// Constructors
RouteMsg::RouteMsg() : m_sz(0), m_offs(0), m_msg(0)
{
}

RouteMsg::RouteMsg(int sz) : m_sz(sz), m_offs(0)
{
  m_msg = (char*)malloc(m_sz);
}

RouteMsg::RouteMsg(int sz, char* pd) : m_sz(sz)
{
  m_offs = m_sz;
  m_msg = (char*)malloc(m_sz);
  memcpy(m_msg, pd, sz);
}

// Copy Constructor
RouteMsg::RouteMsg(const RouteMsg& r) : m_sz(r.Size()), m_offs(r.Offs())
{
  m_msg = (char*)malloc(m_sz);
  r.GetAll(m_sz, m_msg); // Copy the data
}

// Destructor
RouteMsg::~RouteMsg()
{
  free(m_msg);
}

// Assignment Operator
RouteMsg& RouteMsg::operator=(const RouteMsg& r)
{
  if (&r != this)
    { // ignore self assignment
      m_sz = r.Size();
      m_offs = r.Offs();
      m_msg = (char*)realloc(m_msg, m_sz); // Set to new size
      r.GetAll(m_sz, m_msg);
    }
  return *this;
}

// Data Management
void RouteMsg::Append(int sz, char* pd)
{ // Append some data to the message
  if ((m_offs + sz) >= m_sz)
    { // Need more space
      m_sz = m_offs + sz;
      m_msg = (char*)realloc(m_msg, m_sz);
    }
  memcpy(&m_msg[m_offs], pd, sz);
  m_offs += sz;
}

void RouteMsg::Append(unsigned long m)
{ // Append a 32 bit value to the message
	Append(sizeof(m), (char*)&m);
}

int RouteMsg::Get(int sz, char* pt)
{
  if (sz + m_offs > m_sz) sz = m_sz - m_offs; // Reduce if asking too much
  memcpy(pt, &m_msg[m_offs], sz);    // Copy to caller's buffer
  m_offs += sz;             // Adjust offset
  return sz;                // Return actual copied
}

int RouteMsg::Get(unsigned long* p)       // Get the next unsigned long
{
	return Get(sizeof(*p), (char*)p);
}

int RouteMsg::GetAll(int sz, char* pt) const
{ // Get data, ignoring offset
  if (sz > m_sz) sz = m_sz; // Reduce if asking too much
  memcpy(pt, m_msg, sz);    // Copy to caller's buffer
  return sz;                // Return actual copied
}


