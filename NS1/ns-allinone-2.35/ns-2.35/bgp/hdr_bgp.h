// Define the packet header for the pdns/rti information
// Xenofontas Dimitropoulos, Georgia Tech, Fall 2003

#ifndef __HDR_BGP_H__
#define __HDR_BGP_H__

#include "packet.h"

struct hdr_bgp {
  bool            valid_;
  static int offset_;
  inline static int& offset() { return offset_; }
  inline static hdr_bgp* access(const Packet* p) {
    return (hdr_bgp*) p->access(offset_);
  }

  /* per-field member acces functions */

  bool& valid() {
    return valid_;
  }
};


#endif
