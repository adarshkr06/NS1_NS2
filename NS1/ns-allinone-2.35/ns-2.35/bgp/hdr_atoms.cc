// Define the packet header for the pdns/rti information
// Xenofontas Dimitropoulos, Georgia Tech, Fall 2003

#include "hdr_atoms.h"

// Define the TCL glue for the packet header
int hdr_atom::offset_;

static class AtomsHeaderClass : public PacketHeaderClass {
public:
        AtomsHeaderClass() : PacketHeaderClass("PacketHeader/ATOM",
					       sizeof(hdr_atom)) {
	  bind_offset(&hdr_atom::offset_);

	}
        void export_offsets() {
	  field_offset("avalid_", OFFSET(hdr_atom, avalid_));
        }

} class_atomshdr;
