// Define the packet header for the pdns/rti information
// Xenofontas Dimitropoulos, Georgia Tech, Fall 2003


#ifndef __HDR_ATOMS_H__
#define __HDR_ATOMS_H__

#include "packet.h"

typedef unsigned int ipaddr_t;

struct hdr_atom {
  bool            avalid_;
  ipaddr_t        ipdst_;
  static int offset_;
  inline static int& offset() { return offset_; }
  inline static hdr_atom* access(const Packet* p) {
    return (hdr_atom*) p->access(offset_);
  }

  /* per-field member acces functions */

  bool& valid() {
    return avalid_;
  }
  ipaddr_t& ipdst() {
    return ipdst_;
  }
};


#endif
