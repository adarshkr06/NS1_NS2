// Define the packet header for the pdns/rti information
// Xenofontas Dimitropoulos, Georgia Tech, Fall 2003

#include "hdr_bgp.h"

// Define the TCL glue for the packet header
int hdr_bgp::offset_;

static class BgpHeaderClass : public PacketHeaderClass {
public:
  BgpHeaderClass() : PacketHeaderClass("PacketHeader/BGP",
				       sizeof(hdr_bgp)) {
    bind_offset(&hdr_bgp::offset_);
    
  }
  void export_offsets() {
    field_offset("valid_", OFFSET(hdr_bgp, valid_));
  }
  
} class_bgp_hdr;
