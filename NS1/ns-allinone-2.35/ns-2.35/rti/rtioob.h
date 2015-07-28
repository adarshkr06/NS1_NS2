// Out-of-Band message for PDNS
// Allows one ns to communicate useful info to a second instance
// George F. Riley, Georgia Tech, Winter 2000
#ifndef rti_oob_
#define rti_oob_

#include <rti/hdr_rti.h>

typedef enum {
  RTIM_LoadNewAgent,  // Request a new agent be loaded
  RTIM_UnloadAgent,   // Unload an existing agent
  RTIM_SetDestPort    // Set destination port for an agent
  // Will need more as time goes on
} RTIMsgEnum_t;

typedef struct {
  RTIMsgEnum_t  t;     // Type of messgae
  ipaddr_t      da;    // Specified dest address
  ipportaddr_t  dp;    // Dest port
  ipaddr_t      sa;    // Specified src address
  ipportaddr_t  sp;    // Src port
  unsigned long ep1;   // Extra parameter 1
  unsigned long ep2;   // Extra parameter 2
  unsigned long ep3;   // Extra parameter 3
  unsigned long ep4;   // Extra parameter 4
  // Will need more
} RTIMsg_t;

void SendOOB(int t, int da, int dp, int sa, int sp); // See rtisched.cc

#ifdef HAVE_FILTER

void SendOOBFilter(int t);

typedef enum {
  RTIFilterStart,  // Request to start filtering
  RTIFilterStop    //Request to stop filtering
} RTIFilterEnum_t;

#endif /*HAVE_FILTER*/

#ifdef HAVE_PDNS_BGP
/*BGP extentions */
#include "bgp/bgp.h"
#define RTI_BGP_HEADER_SIZE 49

typedef enum {
  RTI_BgpPacket,     //Sending bgp packet
  RTI_BgpInitMsgList //Initiate BGP msg list
} RTIBgpMsgType_t; 

typedef struct {
  RTIBgpMsgType_t type;     //4
  union sockunion lsu;   //16
  union sockunion rsu;
  struct agent_index index; //8
  int msglength ;          //4
  unsigned char Payload[1];
} RTIBgpMsg_t;

void SendBgpOOB(int t, union sockunion lsu, union sockunion rsu, 
		struct agent_index index, RouteMsg* msg, double delta);
void SendBgpOOB(int t, union sockunion lsu, union sockunion rsu, 
		struct agent_index index);

#endif /*HAVE BGP*/

#endif /* rti_oob_ */
