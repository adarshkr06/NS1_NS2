/****************************************************************************/
/*  File:            bgp.h                                                  */ 
/*  Author:          Xenofontas Dimitropoulos                               */ 
/*  Email:           fontas@ece.gatech.edu                                  */
/*  Documentation:   at <http://www.ece.gatech.edu/                         */
/*                       research/labs/MANIACS/BGP++>                       */
/*  Version:         1.05 beta with pdns support and Zebra MRAI             */
/*                                                                          */
/*  Copyright (c) 2003 Georgia Institute of Technology                      */
/*  This program is free software; you can redistribute it and/or           */
/*  modify it under the terms of the GNU General Public License             */
/*  as published by the Free Software Foundation; either version 2          */
/*  of the License, or (at your option) any later version.                  */
/*                                                                          */
/*  This program is distributed in the hope that it will be useful,         */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of          */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           */
/*  GNU General Public License for more details.                            */
/*                                                                          */
/****************************************************************************/

#ifndef ns_bgp_
#define ns_bgp_

#include <stdio.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <errno.h>
#include <syslog.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include "bgp/regex-gnu.h"
#include <netinet/in.h>  
#include <arpa/inet.h>
#include <sys/types.h> 

#ifdef __cplusplus
extern "C" { 
#include "bgp/c-lib/hash.h"
} 
#include <string>
#include <list>
#include <iostream>
#include <sstream>
#include <utility>
#include <map>

#include "tcp-full.h"
#include "ranvar.h"
#include "scheduler.h"
#include "routeapp.h"
#include "bgp/routemsg.h"
#include "bgp/memusage.h"
#include "tcp/divert.h"
#include "rtmodule.h"
#include <assert.h>

class Bgp;
class BgpTimer;
class BgpRegistry;

#endif /*__cplusplus*/

//////zebra.h 

/* Zebra route's types. */
#define ZEBRA_ROUTE_CONNECT              0
#define ZEBRA_ROUTE_STATIC               1
#define ZEBRA_ROUTE_BGP                  2
#define ZEBRA_ROUTE_MAX                  3

/* Default Administrative Distance of each protocol. */
#define ZEBRA_KERNEL_DISTANCE_DEFAULT      0
#define ZEBRA_CONNECT_DISTANCE_DEFAULT     0
#define ZEBRA_STATIC_DISTANCE_DEFAULT      1
#define ZEBRA_IBGP_DISTANCE_DEFAULT      200
#define ZEBRA_EBGP_DISTANCE_DEFAULT       20

/* Filter direction.  */
#define FILTER_IN                 0
#define FILTER_OUT                1
#define FILTER_MAX                2

/* Address family numbers from RFC1700. */
#define AFI_IP                    1
#define AFI_IP6                   2
#define AFI_MAX                   2

/* Subsequent Address Family Identifier. */
#define SAFI_UNICAST              1
#define SAFI_MULTICAST            2
#define SAFI_UNICAST_MULTICAST    3
#define SAFI_MAX                  2

/* Flag manipulation macros. */
#define CHECK_FLAG(V,F)      ((V) & (F))
#define SET_FLAG(V,F)        (V) = (V) | (F)
#define UNSET_FLAG(V,F)      (V) = (V) & ~(F)

/* AFI and SAFI type. */
typedef u_int16_t afi_t;
typedef u_char safi_t;

/* Zebra's family types. */
#define ZEBRA_FAMILY_IPV4                1

//////sockunion.h 

union sockunion 
{
  struct sockaddr sa;
  struct sockaddr_in sin;
};

enum connect_result
  {
    connect_error,
    connect_success,
    connect_in_progress
  };

/* Sockunion address string length.  Same as INET6_ADDRSTRLEN. */
#define SU_ADDRSTRLEN 46

//////log.h 

#define ZLOG_NOLOG              0x00
#define ZLOG_FILE		0x01
#define ZLOG_SYSLOG		0x02
#define ZLOG_STDOUT             0x04
#define ZLOG_STDERR             0x08

#define ZLOG_NOLOG_INDEX        0
#define ZLOG_FILE_INDEX         1
#define ZLOG_SYSLOG_INDEX       2
#define ZLOG_STDOUT_INDEX       3
#define ZLOG_STDERR_INDEX       4
#define ZLOG_MAX_INDEX          5

typedef enum 
  {
    ZLOG_NONE,
    ZLOG_DEFAULT,
    ZLOG_ZEBRA,
    ZLOG_RIP,
    ZLOG_BGP,
    ZLOG_OSPF,
    ZLOG_RIPNG,  
    ZLOG_OSPF6,
    ZLOG_MASC
  } zlog_proto_t;

struct zlog 
{
  const char *ident;
  zlog_proto_t protocol;
  int flags;
  FILE *fp;
  char *filename;
  int syslog;
  int stat;
  int connected;
  int maskpri;      /* as per syslog setlogmask */
  int priority;     /* as per syslog priority */
  int facility;     /* as per syslog facility */
  int record_priority;
};

/* Message structure. */
struct message
{
  int key;
  char *str;
};

/* For hackey massage lookup and check */
#define LOOKUP(x, y) mes_lookup( x, (int)(  x ## _max ),(int) y)


/* For time string format. */
#define TIME_BUF 27


//////vector.h 

/* struct for vector */
struct _vector 
{
  unsigned int max;     /* max number of used slot */
  unsigned int alloced;     /* number of allocated slot */
  void **index;         /* index to data */
};


#define VECTOR_MIN_SIZE 1

/* (Sometimes) usefull macros.  This macro convert index expression to
   array expression. */
#define vector_slot(V,I)  ((V)->index[(I)])
#define vector_max(V) ((V)->max)


//////memory.h 

/* For tagging memory, below is the type of the memory. */
enum
  {
    MTYPE_TMP = 1,
    MTYPE_STRVEC,
    MTYPE_VECTOR,
    MTYPE_VECTOR_INDEX,
    MTYPE_LINK_LIST,
    MTYPE_LINK_NODE,
    MTYPE_THREAD,
    MTYPE_THREAD_MASTER,
    MTYPE_VTY,
    MTYPE_VTY_HIST,
    MTYPE_IF,
    MTYPE_CONNECTED,
    MTYPE_AS_SEG,
    MTYPE_AS_STR,
    MTYPE_AS_PATH,
    MTYPE_COMMUNITY,
    MTYPE_COMMUNITY_VAL,
    MTYPE_ECOMMUNITY,
    MTYPE_ECOMMUNITY_VAL,
    MTYPE_CLUSTER,
    MTYPE_CLUSTER_VAL,
    MTYPE_BGP_ROUTE,
    MTYPE_ATTR,
    MTYPE_TRANSIT,
    MTYPE_TRANSIT_VAL,
    MTYPE_BUFFER,
    MTYPE_BUFFER_DATA,
    MTYPE_STREAM,
    MTYPE_STREAM_DATA,
    MTYPE_STREAM_FIFO,
    MTYPE_BGP_PEER,
    MTYPE_PREFIX,
    MTYPE_PREFIX_IPV4,
    MTYPE_HASH,
    MTYPE_HASH_BACKET,
    MTYPE_RIPNG_ROUTE,
    MTYPE_RIPNG_AGGREGATE,
    MTYPE_ROUTE_TABLE,
    MTYPE_ROUTE_NODE,
    MTYPE_ACCESS_LIST,
    MTYPE_ACCESS_LIST_STR,
    MTYPE_ACCESS_FILTER,
    MTYPE_PREFIX_LIST,
    MTYPE_PREFIX_LIST_STR,
    MTYPE_PREFIX_LIST_ENTRY,
    MTYPE_ROUTE_MAP,
    MTYPE_ROUTE_MAP_NAME,
    MTYPE_ROUTE_MAP_INDEX,
    MTYPE_ROUTE_MAP_RULE,
    MTYPE_ROUTE_MAP_RULE_STR,
    MTYPE_ROUTE_MAP_COMPILED,
    MTYPE_RIP_INFO,
    MTYPE_RIP_PEER,
    MTYPE_RIB,
    MTYPE_DESC,
    MTYPE_DISTRIBUTE,
    MTYPE_ZLOG,
    MTYPE_AS_FILTER,
    MTYPE_AS_FILTER_STR,
    MTYPE_AS_LIST,
    MTYPE_COMMUNITY_ENTRY,
    MTYPE_COMMUNITY_LIST,
    MTYPE_COMMUNITY_REGEXP,
    MTYPE_ZCLIENT,
    MTYPE_NEXTHOP,
    MTYPE_RTADV_PREFIX,
    MTYPE_IF_RMAP,
    MTYPE_BGP,
    MTYPE_PEER_CONF,
    MTYPE_BGP_STATIC,
    MTYPE_BGP_AGGREGATE,
    MTYPE_BGP_CONFED_LIST,
    MTYPE_RIP_OFFSET_LIST,
    MTYPE_KEYCHAIN,
    MTYPE_KEY,
    MTYPE_RIP,
    MTYPE_RIP_INTERFACE,
    MTYPE_RIP_DISTANCE,
    MTYPE_BGP_DISTANCE,
    MTYPE_OSPF_DISTANCE,
    MTYPE_SOCKUNION,
    MTYPE_STATIC_IPV4,
    MTYPE_STATIC_IPV6,
    MTYPE_BGP_NEXTHOP_CACHE,
    MTYPE_BGP_DAMP_INFO,
    MTYPE_BGP_DAMP_ARRAY,
    MTYPE_BGP_ANNOUNCE,
    MTYPE_BGP_ATTR_QUEUE,
    MTYPE_BGP_ROUTE_QUEUE,
    MTYPE_BGP_ADVERTISE,
    MTYPE_OSPF_IF_INFO,
    MTYPE_OSPF_IF_PARAMS,
    MTYPE_BGP_MRAI_INFO,
    MTYPE_BGP_ROUTEADV_LIST,
    MTYPE_BGP_ADVERTISE_ATTR,
    MTYPE_BGP_ADJ_OUT,
    MTYPE_BGP_ADJ_IN,
    MTYPE_MAX
  };

#ifdef MEMORY_LOG
#define XMALLOC(mtype, size) \
  mtype_zmalloc (__FILE__, __LINE__, (mtype), (size))
#define XCALLOC(mtype, size) \
  mtype_zcalloc (__FILE__, __LINE__, (mtype), (size))
#define XREALLOC(mtype, ptr, size)  \
  mtype_zrealloc (__FILE__, __LINE__, (mtype), (ptr), (size))
#define XFREE(mtype, ptr) \
  mtype_zfree (__FILE__, __LINE__, (mtype), (ptr))
#define XSTRDUP(mtype, str) \
  mtype_zstrdup (__FILE__, __LINE__, (mtype), (str))
#else
#define XMALLOC(mtype, size)       zmalloc ((mtype), (size))
#define XCALLOC(mtype, size)  zcalloc ((mtype), (size))
#define XREALLOC(mtype, ptr, size) zrealloc ((mtype), (ptr), (size))
#define XFREE(mtype, ptr)          zfree ((mtype), (ptr))
#define XSTRDUP(mtype, str)        zstrdup ((mtype), (str))
#endif /* MEMORY_LOG */



/* For pretty printng of memory allocate information. */
struct memory_list
{
  int index;
  char *format;
  size_t size;
};



//////buffer.h


/* Buffer master. */
struct buffer
{
  /* Data list. */
  struct buffer_data *head;
  struct buffer_data *tail;

  /* Current allocated data. */
  unsigned long alloc;

  /* Total length of buffer. */
  unsigned long size;

  /* For allocation. */
  struct buffer_data *unused_head;
  struct buffer_data *unused_tail;

  /* Current total length of this buffer. */
  unsigned long length;
};

/* Data container. */
struct buffer_data
{
  struct buffer *parent;
  struct buffer_data *next;
  struct buffer_data *prev;

  /* Acctual data stream. */
  unsigned char *data;

  /* Current pointer. */
  unsigned long cp;

  /* Start pointer. */
  unsigned long sp;
};


//////command.h


/* Host configuration variable */
struct host
{
  /* Host name of this router. */
  char *name;

  /* Password for vty interface. */
  char *password;
  char *password_encrypt;

  /* Enable password */
  char *enable;
  char *enable_encrypt;

  /* System wide terminal lines. */
  int lines;

  /* Log filename. */
  char *logfile;

  /* Log stdout. */
  u_char log_stdout;

  /* Log syslog. */
  u_char log_syslog;

  /* config file name of this host */
  char *config;

  /* Flags for services */
  int encrypt;

  /* Banner configuration. */
  char *motd;
};

/* There are some command levels which called from command node. */
enum node_type 
  {
    CONFIG_NODE,          /* Config node. Default mode of config file. */
    RMAP_NODE,            /* Route map node. */
  };

#ifdef __cplusplus

/* Node which has some commands and prompt string and configuration
   function pointer . */
struct cmd_node 
{
  /* Node index. */
  enum node_type node;      

  /* Prompt character at vty interface. */
  char *prompt;         

  /* Is this node's configuration goes to vtysh ? */
  int vtysh;

  /* Node's configuration write function */
  int (Bgp::*func) (struct vty *);

  /* Vector of this node's command list. */
  struct _vector* cmd_vector;   
};

/* Structure of command element. */
struct cmd_element 
{
  char *string;         /* Command specification by string. */
  int (Bgp::*func) (struct cmd_element *, struct vty *, int, char **);
  char *doc;            /* Documentation of this command. */
  int daemon;                   /* Daemon to which this command belong. */
  struct _vector* strvec;       /* Pointing out each description vector. */
  int cmdsize;          /* Command index count. */
  char *config;         /* Configuration string */
  struct _vector* subconfig;        /* Sub configuration string */
};

#endif /* __cplusplus*/

/* Command description structure. */
struct desc
{
  char *cmd;            /* Command string. */
  char *str;            /* Command's description. */
};

/* Return value of the commands. */
#define CMD_SUCCESS              0
#define CMD_WARNING              1
#define CMD_ERR_NO_MATCH         2
#define CMD_ERR_AMBIGUOUS        3
#define CMD_ERR_INCOMPLETE       4
#define CMD_ERR_EXEED_ARGC_MAX   5
#define CMD_ERR_NOTHING_TODO     6
#define CMD_COMPLETE_FULL_MATCH  7
#define CMD_COMPLETE_MATCH       8
#define CMD_COMPLETE_LIST_MATCH  9
#define CMD_SUCCESS_DAEMON      10


/* Argc max counts. */
#define CMD_ARGC_MAX   25

#ifdef  __cplusplus

/* DEFUN for vty command interafce. Little bit hacky ;-). */
#define DEFUN(funcname, cmdname, cmdstr, helpstr) \
   int Bgp::funcname \
  (struct cmd_element *self, struct vty *vty, int argc, char **argv)

#define DEFUNST(funcname, cmdname, cmdstr, helpstr) \
  struct cmd_element Bgp::cmdname = \
  { \
    cmdstr, \
    &Bgp::funcname, \
    helpstr \
  }; 

/* ALIAS macro which define existing command's alias. */
#define ALIAS(funcname, cmdname, cmdstr, helpstr) \
  struct cmd_element Bgp::cmdname = \
  { \
    cmdstr, \
    &Bgp::funcname, \
    helpstr \
  };

#endif  /*__cplusplus*/

/* Some macroes */
#define CMD_OPTION(S)   ((S[0]) == '[')
#define CMD_VARIABLE(S) (((S[0]) >= 'A' && (S[0]) <= 'Z') || ((S[0]) == '<'))
#define CMD_VARARG(S)   ((S[0]) == '.')
#define CMD_RANGE(S)	((S[0] == '<'))

#define CMD_IPV4(S)	   ((strcmp ((S), "A.B.C.D") == 0))
#define CMD_IPV4_PREFIX(S) ((strcmp ((S), "A.B.C.D/M") == 0))
#define CMD_IPV6(S)        ((strcmp ((S), "X:X::X:X") == 0))
#define CMD_IPV6_PREFIX(S) ((strcmp ((S), "X:X::X:X/M") == 0))


/* Common descriptions. */
#define SHOW_STR "Show running system information\n"
#define IP_STR "IP information\n"
#define IPV6_STR "IPv6 information\n"
#define NO_STR "Negate a command or set its defaults\n"
#define CLEAR_STR "Reset functions\n"
#define RIP_STR "RIP information\n"
#define BGP_STR "BGP information\n"
#define OSPF_STR "OSPF information\n"
#define NEIGHBOR_STR "Specify neighbor router\n"
#define DEBUG_STR "Debugging functions (see also 'undebug')\n"
#define UNDEBUG_STR "Disable debugging functions (see also 'debug')\n"
#define ROUTER_STR "Enable a routing process\n"
#define AS_STR "AS number\n"
#define MBGP_STR "MBGP information\n"
#define MATCH_STR "Match values from routing table\n"
#define SET_STR "Set values in destination routing protocol\n"
#define OUT_STR "Filter outgoing routing updates\n"
#define IN_STR  "Filter incoming routing updates\n"
#define V4NOTATION_STR "specify by IPv4 address notation(e.g. 0.0.0.0)\n"
#define OSPF6_NUMBER_STR "Specify by number\n"
#define INTERFACE_STR "Interface infomation\n"
#define IFNAME_STR "Interface name(e.g. ep0)\n"
#define IP6_STR "IPv6 Information\n"
#define OSPF6_STR "Open Shortest Path First (OSPF) for IPv6\n"
#define OSPF6_ROUTER_STR "Enable a routing process\n"
#define OSPF6_INSTANCE_STR "<1-65535> Instance ID\n"
#define SECONDS_STR "<1-65535> Seconds\n"
#define ROUTE_STR "Routing Table\n"
#define PREFIX_LIST_STR "Build a prefix list\n"
#define OSPF6_DUMP_TYPE_LIST \
"(hello|dbdesc|lsreq|lsupdate|lsack|neighbor|interface|area|"\
"lsa|zebra|config|dbex|spf|route|lsdb|redistribute)"

#define CONF_BACKUP_EXT ".sav"



#define NEIGHBOR_CMD       "neighbor A.B.C.D "
#define NO_NEIGHBOR_CMD    "no neighbor A.B.C.D "
#define NEIGHBOR_ADDR_STR  "IP address\n"


/* Completion match types. */
enum match_type 
  {
    no_match,
    extend_match,
    ipv4_prefix_match,
    ipv4_match,
    ipv6_prefix_match,
    ipv6_match,
    range_match,
    vararg_match,
    partly_match,
    exact_match 
  };



#define IPV6_ADDR_STR		"0123456789abcdefABCDEF:.%"
#define IPV6_PREFIX_STR		"0123456789abcdefABCDEF:.%/"
#define STATE_START		1
#define STATE_COLON		2
#define STATE_DOUBLE		3
#define STATE_ADDR		4
#define STATE_DOT               5
#define STATE_SLASH		6
#define STATE_MASK		7


#define DECIMAL_STRLEN_MAX 10



//////linklist.h


typedef struct llist *list_p;
typedef struct listnode *listnode_p;

struct listnode 
{
  struct listnode *next;
  struct listnode *prev;
  void *data;
};

#ifdef  __cplusplus

struct llist 
{
  struct listnode *head;
  struct listnode *tail;
  unsigned int count;
  int (Bgp::*cmp) (void *val1, void *val2);
  void (Bgp::*del) (void *val);
};

#endif /*__cplusplus*/


#define nextnode(X) ((X) = (X)->next)
#define listhead(X) ((X)->head)
#define listcount(X) ((X)->count)
#define list_isempty(X) ((X)->head == NULL && (X)->tail == NULL)
#define getdata(X) ((X)->data)

/* list_p iteration macro. */
#define LIST_LOOP(L,V,N) \
  for ((N) = (L)->head; (N); (N) = (N)->next) \
    if (((V) = (N)->data) != NULL)


/* list_p node add macro.  */
#define LISTNODE_ADD(L,N) \
  do { \
    (N)->prev = (L)->tail; \
    if ((L)->head == NULL) \
      (L)->head = (N); \
    else \
      (L)->tail->next = (N); \
    (L)->tail = (N); \
  } while (0)


/* list_p node delete macro.  */
#define LISTNODE_DELETE(L,N) \
  do { \
    if ((N)->prev) \
      (N)->prev->next = (N)->next; \
    else \
      (L)->head = (N)->next; \
    if ((N)->next) \
      (N)->next->prev = (N)->prev; \
    else \
      (L)->tail = (N)->prev; \
  } while (0)




//////thread.h 


/* Linked list of thread. */
struct thread_list
{
  struct thread *head;
  struct thread *tail;
  int count;
};

/* Master of the theads. */
struct thread_master
{
  struct thread_list read;
  struct thread_list write;
  struct thread_list timer;
  struct thread_list event;
  struct thread_list ready;
  struct thread_list unuse;
  unsigned long alloc;
};

#ifdef  __cplusplus

/* Thread itself. */
struct thread
{
  unsigned char type;       /* thread type */
  struct thread *next;      /* next pointer of the thread */
  struct thread *prev;      /* previous pointer of the thread */
  struct thread_master *master; /* pointer to the struct thread_master. */
  int (Bgp::*func) (struct thread *); /* event function */
  void *arg;            /* event argument */
  union
  {
    int val;                            /* second argument of the event. */
    Agent * ListenAgent;         /* file descriptor in case of read/write. */
    double time;                        /* rest of time sands value. */
  } u;
};

#endif /* __cplusplus*/

/* Macros. */
#define THREAD_ARG(X) ((X)->arg)
#define THREAD_VAL(X) ((X)->u.val)


/* Thread types. */
#define THREAD_READ   0
#define THREAD_WRITE  1
#define THREAD_TIMER  2
#define THREAD_EVENT  3
#define THREAD_READY  4
#define THREAD_UNUSED 5

//////prefix.h 

#define IPV6_MAX_BITLEN    128

/* IPv4  prefix structure. */
struct prefix
{
  u_char family;
  u_char prefixlen;
  union 
  {
    u_char prefix;
    struct in_addr prefix4;
    struct 
    {
      struct in_addr id;
      struct in_addr adv_router;
    } lp;
    u_char val[8];
  } u __attribute__ ((aligned (8)));
};

/* IPv4 prefix structure. */
struct prefix_ipv4
{
  u_char family;
  u_char prefixlen;
  struct in_addr prefix __attribute__ ((aligned (8)));
};


struct prefix_ls
{
  u_char family;
  u_char prefixlen;
  struct in_addr id __attribute__ ((aligned (8)));
  struct in_addr adv_router;
};

/* Prefix for routing distinguisher. */
struct prefix_rd
{
  u_char family;
  u_char prefixlen;
  u_char val[8] __attribute__ ((aligned (8)));
};

#ifndef INET_ADDRSTRLEN
#define INET_ADDRSTRLEN 16
#endif /* INET_ADDRSTRLEN */

#ifndef INET6_ADDRSTRLEN
#define INET6_ADDRSTRLEN 46
#endif /* INET6_ADDRSTRLEN */

#ifndef INET6_BUFSIZ
#define INET6_BUFSIZ 51
#endif /* INET6_BUFSIZ */


/* Max bit/byte length of IPv4 address. */
#define IPV4_MAX_BYTELEN    4
#define IPV4_MAX_BITLEN    32
#define IPV4_MAX_PREFIXLEN 32
#define IPV4_ADDR_CMP(D,S)   memcmp ((D), (S), IPV4_MAX_BYTELEN)
#define IPV4_ADDR_SAME(D,S)  (memcmp ((D), (S), IPV4_MAX_BYTELEN) == 0)
#define IPV4_ADDR_COPY(D,S)  memcpy ((D), (S), IPV4_MAX_BYTELEN)

#define IPV4_NET0(a)    ((((u_int32_t) (a)) & 0xff000000) == 0x00000000)
#define IPV4_NET127(a)  ((((u_int32_t) (a)) & 0xff000000) == 0x7f000000)


/* Count prefix size from mask length */
#define PSIZE(a) (((a) + 7) / (8))

/* Prefix's family member. */
#define PREFIX_FAMILY(p)  ((p)->family)

/* Number of bits in prefix type. */
#ifndef PNBBY
#define PNBBY 8
#endif /* PNBBY */

#define MASKBIT(offset)  ((0xff << (PNBBY - (offset))) & 0xff)

//////filter.h 

/* Filter type is made by `permit', `deny' and `dynamic'. */
enum filter_type 
  {
    FILTER_DENY,
    FILTER_PERMIT,
    FILTER_DYNAMIC
  };

enum access_type
  {
    ACCESS_TYPE_STRING,
    ACCESS_TYPE_NUMBER
  };

/* Access list */
struct access_list
{
  char *name;
  char *remark;

  struct access_master *master;

  enum access_type type;

  struct access_list *next;
  struct access_list *prev;

  struct filter *head;
  struct filter *tail;
};


/* Filter element of access list */
struct filter
{
  /* For doubly linked list. */
  struct filter *next;
  struct filter *prev;

  /* Filter type information. */
  enum filter_type type;

  /* If this filter is "any" match then this flag is set. */
  int any;

  /* If this filter is "exact" match then this flag is set. */
  int exact;

  /* Prefix information. */
  struct prefix prefix;
};

/* List of access_list. */
struct access_list_list
{
  struct access_list *head;
  struct access_list *tail;
};

#ifdef  __cplusplus

/* Master structure of access_list. */
struct access_master
{
  /* List of access_list which name is number. */
  struct access_list_list num;

  /* List of access_list which name is string. */
  struct access_list_list str;

  /* Hook function which is executed when new access_list is added. */
  void (Bgp::*add_hook) (struct access_list * );

  /* Hook function which is executed when access_list is deleted. */
  void (Bgp::*delete_hook) (struct access_list * );
};

#endif  /**__cplusplus*/



//////vty.h 


#define VTY_BUFSIZ 512

enum Type
  {
    VTY_TERM,
    VTY_FILE,
    VTY_SHELL, 
    VTY_SHELL_SERV
  } ;

enum Status
  {
    VTY_NORMAL,
    VTY_CLOSE,
    VTY_MORE,
    VTY_START,
    VTY_CONTINUE
  } ;


#ifdef  __cplusplus

/* VTY struct. */
struct vty 
{
  /* Node status of this vty */
  int node;

  /* Command input buffer */
  char *buf;

  /* For current referencing point of interface, route-map,
     access-list etc... */
  void *index;

  /* Output data pointer. */
  void (Bgp::*output_clean) (struct vty *);
  unsigned long output_count;
  void *output_arg;
};

#endif /*__cplusplus*/

/* Integrated configuration file. */
#define INTEGRATE_DEFAULT_CONFIG "Zebra.conf"


/* Small macro to determine newline is newline only or linefeed needed. */
#define VTY_NEWLINE  new_line



/* Default time out value */
#define VTY_TIMEOUT_DEFAULT 600


/* Vty read buffer size. */
#define VTY_READ_BUFSIZ 512


/* Directory separator. */
#ifndef DIRECTORY_SEP
#define DIRECTORY_SEP '/'
#endif /* DIRECTORY_SEP */

#ifndef IS_DIRECTORY_SEP
#define IS_DIRECTORY_SEP(c) ((c) == DIRECTORY_SEP)
#endif

/* Vty events */
enum event 
  {
    VTY_SERV,
    VTY_READ,
    VTY_WRITE,
    VTY_TIMEOUT_RESET,
  };


#define CONTROL(X)  ((X) - '@')
#define VTY_NORMAL     0
#define VTY_PRE_ESCAPE 1
#define VTY_ESCAPE     2

///////stream.h 

/* Stream buffer. */
struct stream
{
  struct stream *next;

  unsigned char *data;

  /* Put pointer. */
  unsigned long putp;

  /* Get pointer. */
  unsigned long getp;

  /* End of pointer. */
  unsigned long endp;

  /* Data size. */
  unsigned long size;
};

/* First in first out queue structure. */
struct stream_fifo
{
  unsigned long count;

  struct stream *head;
  struct stream *tail;
};

/* Utility macros. */
#define STREAM_PNT(S)   ((S)->data + (S)->getp)
#define STREAM_SIZE(S)  ((S)->size)
#define STREAM_DATA(S)  ((S)->data)
#define STREAM_REMAIN(S) ((S)->size - (S)->putp)


/*A macro to check pointers in order to not
  go behind the allocated mem block 
  S -- stream reference
  Z -- size of data to be written 
*/

#define CHECK_SIZE(S, Z) \
	if (((S)->putp + (Z)) > (S)->size) \
           (Z) = (S)->size - (S)->putp;



//////table.h 

/* Routing table top structure. */
struct route_table
{
  struct route_node *top;
};

/* Each routing entry. */
struct route_node
{
  /* Actual prefix of this radix. */
  struct prefix p;

  /* Tree link. */
  struct route_table *table;
  struct route_node *parent;
  struct route_node *link[2];
#define l_left   link[0]
#define l_right  link[1]

  /* Lock of this radix */
  unsigned int lock;
  
  /* Each node of route. */
  void *info;

  /* Aggregation. */
  void *aggregate;
#ifdef HAVE_ZEBRA_93b

  struct bgp_adj_out *adj_out;

  struct bgp_adj_in *adj_in;

#endif
};

struct bgp_table
{
  struct bgp_node *top;
};

struct bgp_node
{
  struct prefix p;

  struct bgp_table *table;
  struct bgp_node *parent;
  struct bgp_node *link[2];
#define l_left   link[0]
#define l_right  link[1]

  unsigned int lock;

  void *info;

#ifdef HAVE_ZEBRA_93b
  struct bgp_adj_out *adj_out;

  struct bgp_adj_in *adj_in;
#endif

  void *aggregate;
};


/* Macro version of check_bit (). */
#define CHECK_BIT(X,P) ((((u_char *)(X))[(P) / 8]) >> (7 - ((P) % 8)) & 1)


/* Macro version of set_link (). */
#define SET_LINK(X,Y) (X)->link[CHECK_BIT(&(Y)->prefix,(X)->prefixlen)] = (Y);\
                      (Y)->parent = (X)

//////rtadv.c

/* Router advertisement prefix. */
struct rtadv_prefix
{
  /* Prefix to be advertised. */
  struct prefix prefix;

  /* The value to be placed in the Valid Lifetime in the Prefix */
  u_int32_t AdvValidLifetime;
#define RTADV_VALID_LIFETIME 2592000


  /* The value to be placed in the on-link flag */
  int AdvOnLinkFlag;

  /* The value to be placed in the Preferred Lifetime in the Prefix
     Information option, in seconds.*/
  u_int32_t AdvPreferredLifetime;
#define RTADV_PREFERRED_LIFETIME 604800


  /* The value to be placed in the Autonomous Flag. */
  int AdvAutonomousFlag;
};



//////routemap.h 

/* Route map's type. */
enum route_map_type
  {
    RMAP_PERMIT,
    RMAP_DENY,
    RMAP_ANY
  };

typedef enum 
  {
    RMAP_MATCH,
    RMAP_DENYMATCH,
    RMAP_NOMATCH,
    RMAP_ERROR,
    RMAP_OKAY
  } route_map_result_t;

typedef enum
  {
    RMAP_RIP,
    RMAP_RIPNG,
    RMAP_OSPF,
    RMAP_OSPF6,
    RMAP_BGP
  } route_map_object_t;

typedef enum
  {
    RMAP_EXIT,
    RMAP_GOTO,
    RMAP_NEXT
  } route_map_end_t;

typedef enum
  {
    RMAP_EVENT_SET_ADDED,
    RMAP_EVENT_SET_DELETED,
    RMAP_EVENT_SET_REPLACED,
    RMAP_EVENT_MATCH_ADDED,
    RMAP_EVENT_MATCH_DELETED,
    RMAP_EVENT_MATCH_REPLACED,
    RMAP_EVENT_INDEX_ADDED,
    RMAP_EVENT_INDEX_DELETED
  } route_map_event_t;


#ifdef  __cplusplus

/* Route map rule structure for matching and setting. */
struct route_map_rule_cmd
{
  /* Route map rule name (e.g. as-path, metric) */
  char *str;

  /* Function for value set or match. */
  route_map_result_t (Bgp::*func_apply)(void *, struct prefix *, 
					route_map_object_t, void *);

  /* Compile argument and return result as void *. */
  void *(Bgp::*func_compile)(char *);

  /* Free allocated value by func_compile (). */
  void (Bgp::*func_free)(void *);
};

#endif /* __cplusplus*/

/* Route map apply error. */
enum
  {
    /* Route map rule is missing. */
    RMAP_RULE_MISSING = 1,

    /* Route map rule can't compile */
    RMAP_COMPILE_ERROR
  };

/* Route map rule list. */
struct route_map_rule_list
{
  struct route_map_rule *head;
  struct route_map_rule *tail;
};

/* Route map index structure. */
struct route_map_index
{
  struct route_map *map;

  /* Preference of this route map rule. */
  int pref;

  /* Route map type permit or deny. */
  enum route_map_type type;         

  /* Do we follow old rules, or hop forward? */
  route_map_end_t exitpolicy;

  /* If we're using "GOTO", to where do we go? */
  int nextpref;

  /* Matching rule list. */
  struct route_map_rule_list match_list;
  struct route_map_rule_list set_list;

  /* Make linked list. */
  struct route_map_index *next;
  struct route_map_index *prev;
};

/* Route map list structure. */
struct route_map
{
  /* Name of route map. */
  char *name;

  /* Route map's rule. */
  struct route_map_index *head;
  struct route_map_index *tail;

  /* Make linked list. */
  struct route_map *next;
  struct route_map *prev;
};


/* Route map rule. This rule has both `match' rule and `set' rule. */
struct route_map_rule
{
  /* Rule type. */
  struct route_map_rule_cmd *cmd;

  /* For pretty printing. */
  char *rule_str;

  /* Pre-compiled match rule. */
  void *value;

  /* Linked list. */
  struct route_map_rule *next;
  struct route_map_rule *prev;
};

#ifdef  __cplusplus

/* Making route map list. */
struct route_map_list
{
  struct route_map *head;
  struct route_map *tail;

  void (Bgp::*add_hook) ( char* );
  void (Bgp::*delete_hook) ( char* );
  void (Bgp::*event_hook) (route_map_event_t, char *); 
};

#endif /* __cplusplus*/

//////rib.h 


#define DISTANCE_INFINITY  255


/* Routing information base. */
struct rib
{
  /* Link list. */
  struct rib *next;
  struct rib *prev;

  /* Type fo this route. */
  int type;

  /* Which routing table */
  int table;            

  /* Distance. */
  u_char distance;

  /* Flags of this route.  This flag's definition is in lib/zebra.h
     ZEBRA_FLAG_* */
  u_char flags;

  /* Metric */
  u_int32_t metric;

  /* Uptime. */
  time_t uptime;

  /* Refrence count. */
  unsigned long refcnt;

  /* Nexthop information. */
  u_char nexthop_num;
  u_char nexthop_active_num;
  u_char nexthop_fib_num;

  struct nexthop *nexthop;
};

/* Static route information. */
struct static_ipv4
{
  /* For linked list. */
  struct static_ipv4 *prev;
  struct static_ipv4 *next;

  /* Administrative distance. */
  u_char distance;

  /* Flag for this static route's type. */
  u_char type;
#define STATIC_IPV4_GATEWAY  1
#define STATIC_IPV4_IFNAME   2


  /* Nexthop value. */
  union 
  {
    struct in_addr ipv4;
    char *ifname;
  } gate;
};

/* Nexthop structure. */
struct nexthop
{
  struct nexthop *next;
  struct nexthop *prev;

  u_char type;
#define NEXTHOP_TYPE_IFINDEX        1 /* Directly connected. */
#define NEXTHOP_TYPE_IFNAME         2 /* Interface route. */
#define NEXTHOP_TYPE_IPV4           3 /* IPv4 nexthop. */
#define NEXTHOP_TYPE_IPV4_IFINDEX   4 /* IPv4 nexthop with ifindex. */
#define NEXTHOP_TYPE_IPV4_IFNAME    5 /* IPv4 nexthop with ifname. */
#define NEXTHOP_TYPE_IPV6           6 /* IPv6 nexthop. */
#define NEXTHOP_TYPE_IPV6_IFINDEX   7 /* IPv6 nexthop with ifindex. */
#define NEXTHOP_TYPE_IPV6_IFNAME    8 /* IPv6 nexthop with ifname. */

  u_char flags;
#define NEXTHOP_FLAG_ACTIVE     (1 << 0) /* This nexthop is alive. */
#define NEXTHOP_FLAG_FIB        (1 << 1) /* FIB nexthop. */
#define NEXTHOP_FLAG_RECURSIVE  (1 << 2) /* Recursive nexthop. */


  /* Interface index. */
  unsigned int ifindex;
  char *ifname;

  /* Nexthop address or interface name. */
  union
  {
    struct in_addr ipv4;
  } gate;

  /* Recursive lookup nexthop. */
  u_char rtype;
  unsigned int rifindex;
  union
  {
    struct in_addr ipv4;
  } rgate;

  struct nexthop *indirect;
};




#define RIB_SYSTEM_ROUTE(R) \
        ((R)->type == ZEBRA_ROUTE_KERNEL || (R)->type == ZEBRA_ROUTE_CONNECT)

#define SHOW_ROUTE_V4_HEADER "Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,%s       B - BGP, > - selected route, * - FIB route%s%s"



#define SHOW_ROUTE_V6_HEADER "Codes: K - kernel route, C - connected, S - static, R - RIPng, O - OSPFv3,%s       B - BGP, * - FIB route.%s%s"



//////redistribute.h 

//////plist.h 


enum prefix_list_type 
  {
    PREFIX_DENY,
    PREFIX_PERMIT,
  };

enum prefix_name_type
  {
    PREFIX_TYPE_STRING,
    PREFIX_TYPE_NUMBER
  };

struct prefix_list
{
  char *name;
  char *desc;

  struct prefix_master *master;

  enum prefix_name_type type;

  int count;
  int rangecount;

  struct prefix_list_entry *head;
  struct prefix_list_entry *tail;

  struct prefix_list *next;
  struct prefix_list *prev;
};

//////plist.h 


/* Each prefix-list's entry. */
struct prefix_list_entry
{
  int seq;

  int le;
  int ge;

  enum prefix_list_type type;

  int any;
  struct prefix prefix;

  unsigned long refcnt;
  unsigned long hitcnt;

  struct prefix_list_entry *next;
  struct prefix_list_entry *prev;
};

/* List of struct prefix_list. */
struct prefix_list_list
{
  struct prefix_list *head;
  struct prefix_list *tail;
};


#ifdef  __cplusplus

/* Master structure of prefix_list. */
struct prefix_master
{
  /* List of prefix_list which name is number. */
  struct prefix_list_list num;

  /* List of prefix_list which name is string. */
  struct prefix_list_list str;

  /* Whether sequential number is used. */
  int seqnum;

  /* The latest update. */
  struct prefix_list *recent;

  /* Hook function which is executed when new prefix_list is added. */
  void (Bgp::*add_hook) ();

  /* Hook function which is executed when prefix_list is deleted. */
  void (Bgp::*delete_hook) ();
};

#endif /* __cplusplus*/

enum display_type
  {
    normal_display,
    summary_display,
    detail_display,
    sequential_display,
    longer_display,
    first_match_display
  };

//////if_rmap.h 

enum if_rmap_type
  {
    IF_RMAP_IN,
    IF_RMAP_OUT,
    IF_RMAP_MAX
  };

struct if_rmap
{
  /* Name of the interface. */
  char *ifname;

  char *routemap[IF_RMAP_MAX];
}; 


//////hash.h 

/* for Hash tables */
#define HASHTABSIZE     2048

typedef struct HashBacket
{
  void *data;
  struct HashBacket *next;
} HashBacket;



#ifdef  __cplusplus

struct Hash
{
  /* Hash backet. */
  HashBacket **index;

  /* Hash size. */
  int size;

  /* Key make function. */
  unsigned int (*hash_key)( void *);

  /* Data compare function. */
  int (*hash_cmp)( void *, void *);

  /* Backet alloc. */
  unsigned long count;
};

#endif /* __cplusplus*/

//////destribute.h

/* Disctirubte list types. */
enum distribute_type
  {
    DISTRIBUTE_IN,
    DISTRIBUTE_OUT,
    DISTRIBUTE_MAX
  };

struct distribute
{
  /* Name of the interface. */
  char *ifname;

  /* Filter name of `in' and `out' */
  char *list[DISTRIBUTE_MAX];

  /* prefix-list name of `in' and `out' */
  char *prefix[DISTRIBUTE_MAX];
};

//////bgpd.h 

typedef u_int16_t as_t;
typedef u_int16_t bgp_size_t;

/* BGP master for system wide configurations and variables.  */
struct bgp_master
{
  u_char flags;
#define BGP_DO_NOT_INSTALL_TO_FIB      (1 << 0)


  /* BGP start time.  */
  time_t start_time;

  /* BGP program name.  */
  char *progname;

  /* BGP thread master.  */
  struct thread_master *master;
};

/* BGP instance structure.  */
struct bgp 
{
  /* AS number of this BGP instance.  */
  as_t as;

  /* Name of this BGP instance.  */
  char *name;

  /* BGP configuration.  */
  u_int16_t config;
#define BGP_CONFIG_ROUTER_ID              (1 << 0)
#define BGP_CONFIG_CLUSTER_ID             (1 << 1)
#define BGP_CONFIG_CONFEDERATION          (1 << 2)
#define BGP_CONFIG_ALWAYS_COMPARE_MED     (1 << 3)
#define BGP_CONFIG_DETERMINISTIC_MED      (1 << 4)
#define BGP_CONFIG_MED_MISSING_AS_WORST   (1 << 5)
#define BGP_CONFIG_MED_CONFED             (1 << 6)
#define BGP_CONFIG_NO_DEFAULT_IPV4        (1 << 7)
#define BGP_CONFIG_NO_CLIENT_TO_CLIENT    (1 << 8)
#define BGP_CONFIG_ENFORCE_FIRST_AS       (1 << 9)
#define BGP_CONFIG_COMPARE_ROUTER_ID      (1 << 10)
#define BGP_CONFIG_ASPATH_IGNORE          (1 << 11)
#define BGP_CONFIG_DAMPENING              (1 << 12) 
  /* This DAMPENING should be confed in a per AF 
     basis. However since there are no multiple
     AFs it is not */

  /* BGP identifier.  */
  struct in_addr id;

  /* Local sockunion*/
  union sockunion su; 

  /* BGP route reflector cluster ID.  */
  struct in_addr cluster;

  /* BGP Confederation Information.  */
  as_t confederation_id;
  int confederation_peers_cnt;
  as_t *confederation_peers;

  /* BGP peer-conf.  */
  struct llist *peer_conf;

  /* Static route configuration.  */
  struct bgp_table *route[AFI_MAX][SAFI_MAX];

  /* Aggregate address configuration.  */
  struct bgp_table *aggregate[AFI_MAX][SAFI_MAX];

  /* BGP Routing information base.  */
  struct bgp_table *rib[AFI_MAX][SAFI_MAX];

  /* BGP redistribute configuration. */
  u_char redist[AFI_MAX][ZEBRA_ROUTE_MAX];

  /* BGP redistribute route-map.  */
  struct
  {
    char *name;
    struct route_map *map;
  } rmap[AFI_MAX][ZEBRA_ROUTE_MAX];

  /* BGP distance configuration.  */
  u_char distance_ebgp;
  u_char distance_ibgp;
  u_char distance_local;

  /* BGP default local-preference.  */
  u_int32_t default_local_pref;

  /* BGP default timer.  */
  u_int32_t default_holdtime;
  u_int32_t default_keepalive;
};

/* BGP filter structure. */
struct bgp_filter
{
  /* Distribute-list.  */
  struct 
  {
    char *name;
    struct access_list *alist;
  } dlist[FILTER_MAX];

  /* Prefix-list.  */
  struct
  {
    char *name;
    struct prefix_list *plist;
  } plist[FILTER_MAX];

  /* Filter-list.  */
  struct
  {
    char *name;
    struct as_list *aslist;
  } aslist[FILTER_MAX];

  /* Route-map.  */
  struct
  {
    char *name;
    struct route_map *map;
  } map[FILTER_MAX];
};

/* BGP peer configuration. */
struct peer_conf
{
  /* Pointer to BGP structure. */
  struct bgp *bgp;

  /* Pointer to peer. */
  struct peer *peer;

  /* Address Family Configuration. */
  u_char afc[AFI_MAX][SAFI_MAX];

  /* Prefix count. */
  unsigned long pcount[AFI_MAX][SAFI_MAX];

  /* Max prefix count. */
  unsigned long pmax[AFI_MAX][SAFI_MAX];
  u_char pmax_warning[AFI_MAX][SAFI_MAX];

  /* Filter structure. */
  struct bgp_filter filter[AFI_MAX][SAFI_MAX];
};

/* Next hop self address. */
struct bgp_nexthop
{
  struct interface *ifp;
  struct in_addr v4;
};

/* Store connection information. */
struct peer_connection
{
  /* Peer is on the connected link. */
  int shared;

  /* Socket's remote and local address. */
  union sockunion remote;
  union sockunion local;

  /* For next-hop-self detemination. */
  struct interface *ifp;
  struct in_addr v4;
};

/* Update source configuration. */
struct peer_source
{
  unsigned int ifindex;
  char *ifname;
  char *update_if;
  union sockunion *update_source;
};

/* BGP Notify message format. */
struct bgp_notify 
{
  u_char code;
  u_char subcode;
  char *data;
  bgp_size_t length;
};

/* Utility macro to convert VTY argument to unsigned integer.  */
#define VTY_GET_INTEGER(NAME,V,STR)                              \
{                                                                \
  char *endptr = NULL;                                           \
  (V) = strtoul ((STR), &endptr, 10);                            \
  if ((V) == ULONG_MAX || *endptr != '\0')                       \
    {                                                            \
      vty_out (zlog_default,LOG_DEBUG, "%% Invalid %s value%s",  \
	       NAME, VTY_NEWLINE);                               \
      return CMD_WARNING;                                        \
    }                                                            \
}

#define VTY_GET_INTEGER_RANGE(NAME,V,STR,MIN,MAX)                \
{                                                                \
  char *endptr = NULL;                                           \
  (V) = strtoul ((STR), &endptr, 10);                            \
  if ((V) == ULONG_MAX || *endptr != '\0'                        \
      || (V) < (MIN) || (V) > (MAX))                             \
    {                                                            \
      vty_out (zlog_default,LOG_DEBUG, "%% Invalid %s value%s",  \
	       NAME, VTY_NEWLINE);                               \
      return CMD_WARNING;                                        \
    }                                                            \
}

#ifdef  __cplusplus
typedef list<pair<struct prefix,double> >                 Prefix2Timestamp_t;

/* BGP neighbor structure. */
struct peer
{
  /* Peer's remote AS number. */
  as_t as;          

  /* Peer's local AS number. */
  as_t local_as;

  /* Remote router ID. */
  struct in_addr remote_id;

  /* Local router ID. */
  struct in_addr local_id;

  /* Packet receive and send buffer. */
  struct stream *ibuf;
  struct stream_fifo *obuf;
#ifdef HAVE_ZEBRA_93b
  struct stream *work;
#endif  
  /* Status of the peer. */
  int status;
  int ostatus;

  /* Peer information */
  int ttl;          /* TTL of TCP connection to the peer. */
  char *desc;           /* Description of the peer. */
  //unsigned short port;          /* Destination port for peer */
  char *host;           /* Printable address of the peer. */
  union sockunion su;       /* Sockunion address of the peer. */
  time_t uptime;        /* Last Up/Down time */
  time_t readtime;      /* Last read time */
  //safi_t translate_update;       

  //unsigned int ifindex;     /* ifindex of the BGP connection. */
  struct zlog *log;
  u_char version;       /* Peer BGP version. */

  union sockunion *su_local;    /* Sockunion of local address.  */
  union sockunion *su_remote;   /* Sockunion of remote address.  */
  struct bgp_nexthop nexthop;   /* Nexthop */

  /* Peer address family configuration. */
  u_char afc[AFI_MAX][SAFI_MAX];
  u_char afc_nego[AFI_MAX][SAFI_MAX];
  u_char afc_adv[AFI_MAX][SAFI_MAX];
  u_char afc_recv[AFI_MAX][SAFI_MAX];

  /* Route refresh capability. */
  u_char refresh_adv;
  u_char refresh_nego_old;
  u_char refresh_nego_new;

  /* Global configuration flags. */
  u_int32_t flags;
#define PEER_FLAG_PASSIVE                   (1 << 0) /* passive mode */
#define PEER_FLAG_SHUTDOWN                  (1 << 1) /* shutdown */
#define PEER_FLAG_DEFAULT_ORIGINATE         (1 << 2) /* default-originate */
#define PEER_FLAG_DONT_CAPABILITY           (1 << 3) /* dont-capability */
#define PEER_FLAG_OVERRIDE_CAPABILITY       (1 << 4) /* override-capability */
#define PEER_FLAG_STRICT_CAP_MATCH          (1 << 5) /* strict-capability-match */
#define PEER_FLAG_CAPABILITY_ROUTE_REFRESH  (1 << 6) /* route-refresh */
#define PEER_FLAG_TRANSPARENT_AS            (1 << 7) /* transparent-as */
#define PEER_FLAG_TRANSPARENT_NEXTHOP       (1 << 8) /* transparent-next-hop */
#define PEER_FLAG_IGNORE_LINK_LOCAL_NEXTHOP (1 << 9) /* ignore-link-local-nexthop */


  /* Per AF configuration flags. */
  u_int32_t af_flags[AFI_MAX][SAFI_MAX];
#define PEER_FLAG_SEND_COMMUNITY            (1 << 0) /* send-community */
#define PEER_FLAG_SEND_EXT_COMMUNITY        (1 << 1) /* send-community ext. */
#define PEER_FLAG_NEXTHOP_SELF              (1 << 2) /* next-hop-self */
#define PEER_FLAG_REFLECTOR_CLIENT          (1 << 3) /* reflector-client */
#define PEER_FLAG_RSERVER_CLIENT            (1 << 4) /* route-server-client */
#define PEER_FLAG_SOFT_RECONFIG             (1 << 5) /* soft-reconfiguration */


  /* Peer status flags. */
  u_int16_t sflags;
#define PEER_STATUS_ACCEPT_PEER	      (1 << 0) /* accept peer */
#define PEER_STATUS_PREFIX_OVERFLOW   (1 << 1) /* prefix-overflow */
#define PEER_STATUS_CAPABILITY_OPEN   (1 << 2) /* capability open send */
#define PEER_STATUS_HAVE_ACCEPT       (1 << 3) /* accept peer's parent */


  /* Default attribute value for the peer. */
  u_int32_t config;
#define PEER_CONFIG_TIMER             (1 << 0) /* keepalive & holdtime */
#define PEER_CONFIG_CONNECT           (1 << 1) /* connect */
#define PEER_CONFIG_ROUTEADV          (1 << 2) /* route advertise */
  u_int32_t weight;
  u_int32_t holdtime;
  u_int32_t keepalive;
  u_int32_t connect;
  u_int32_t routeadv;

  /* Global timer */
  u_int32_t global_holdtime;
  u_int32_t global_keepalive;

  /* Timer values. */
  u_int32_t v_start;
  u_int32_t v_connect;
  u_int32_t v_holdtime;
  u_int32_t v_keepalive;
  u_int32_t v_asorig;
  u_int32_t v_routeadv;

  /* Threads. */
  struct thread *t_read;
  struct thread *t_write;
  struct thread *t_start;
  struct thread *t_connect;
  struct thread *t_holdtime;
  struct thread *t_keepalive;
  struct thread *t_asorig;

  // pending timer pointer 
  // used for per peer MRAI
  struct thread *t_routeadv;

#ifndef HAVE_ZEBRA_93b
 
  // List of pending MRAI timers, for per prefix MRAI 
  // there are more than one pending MRAI timers
  struct bgp_routeadv_list *t_routeadv_list;
    
  //per prefix list of last update timestamps
  Prefix2Timestamp_t  update_stamps;
  
  //List of supressed advertisements
  struct bgp_advertise *top_adv;
#endif 
    
  /* Statistics field */
  u_int32_t open_in;        /* Open message input count */
  u_int32_t open_out;       /* Open message output count */
  u_int32_t update_in;      /* Update message input count */
  u_int32_t update_out;     /* Update message ouput count */
  time_t update_time;       /* Update message received time. */
  u_int32_t keepalive_in;   /* Keepalive input count */
  u_int32_t keepalive_out;  /* Keepalive output count */
  u_int32_t notify_in;      /* Notify input count */
  u_int32_t notify_out;     /* Notify output count */
  u_int32_t refresh_in;     /* Route Refresh input count */
  u_int32_t refresh_out;    /* Route Refresh output count */
  
  /* BGP state count */
  u_int32_t established;    /* Established */
  u_int32_t dropped;        /* Dropped */


#ifndef HAVE_ZEBRA_93b
  /* Adj-RIBs-In.  */
  struct bgp_table *adj_in[AFI_MAX][SAFI_MAX];
  struct bgp_table *adj_out[AFI_MAX][SAFI_MAX];
#endif
  /* Linked peer configuration. */
  struct llist *conf;

  /* Notify data. */
  struct bgp_notify notify;

  /* Whole packet size to be read. */
  unsigned long packet_size;
  
  /* pointer to local tcp agent */
  FullTcpAgent*   LocalAgent;

#ifdef HAVE_PDNS_BGP
  bool is_peer_remote;
#endif   

#ifdef HAVE_ZEBRA_93b
  /* Announcement attribute hash.  */
  struct hash *hash[AFI_MAX][SAFI_MAX];

  /* Syncronization list and time.  */
  struct bgp_synchronize *sync[AFI_MAX][SAFI_MAX];
  time_t synctime;
  
#endif
  /* This is the head of the link that 
     is used to reach this peer
  */
  NsObject *target;

};

#endif  /*__cplusplus*/

/* This structure's member directly points incoming packet data
   stream. */
struct bgp_nlri
{
  /* AFI.  */
  afi_t afi;

  /* SAFI.  */
  safi_t safi;

  /* Pointer to NLRI byte stream.  */
  u_char *nlri;

  /* Length of whole NLRI.  */
  bgp_size_t length;
};

/* BGP version.  Zebra bgpd supports BGP-4 and it's various
   extensions.  */
#define BGP_VERSION_4		           4
#define BGP_VERSION_MP_4_DRAFT_00         40


/* Default BGP port number.  */
#define BGP_PORT_DEFAULT                 179


/* BGP message header and packet size.  */
#define BGP_MARKER_SIZE		          16
#define BGP_HEADER_SIZE		          19
#define BGP_MAX_PACKET_SIZE             4096


/* BGP minimum message size.  */
#define BGP_MSG_OPEN_MIN_SIZE              (BGP_HEADER_SIZE + 10)
#define BGP_MSG_UPDATE_MIN_SIZE            (BGP_HEADER_SIZE + 4)
#define BGP_MSG_NOTIFY_MIN_SIZE            (BGP_HEADER_SIZE + 2)
#define BGP_MSG_KEEPALIVE_MIN_SIZE         (BGP_HEADER_SIZE + 0)
#define BGP_MSG_ROUTE_REFRESH_MIN_SIZE     (BGP_HEADER_SIZE + 4)


/* BGP message types.  */
#define	BGP_MSG_OPEN		           1
#define	BGP_MSG_UPDATE		           2
#define	BGP_MSG_NOTIFY		           3
#define	BGP_MSG_KEEPALIVE	           4
#define BGP_MSG_ROUTE_REFRESH_01           5
#define BGP_MSG_ROUTE_REFRESH	         128


/* BGP open optional parameter.  */
#define BGP_OPEN_OPT_AUTH                  1
#define BGP_OPEN_OPT_CAP                   2


/* BGP attribute type codes.  */
#define BGP_ATTR_ORIGIN                    1
#define BGP_ATTR_AS_PATH                   2
#define BGP_ATTR_NEXT_HOP                  3
#define BGP_ATTR_MULTI_EXIT_DISC           4
#define BGP_ATTR_LOCAL_PREF                5
#define BGP_ATTR_ATOMIC_AGGREGATE          6
#define BGP_ATTR_AGGREGATOR                7
#define BGP_ATTR_COMMUNITIES               8
#define BGP_ATTR_ORIGINATOR_ID             9
#define BGP_ATTR_CLUSTER_LIST             10
#define BGP_ATTR_DPA                      11
#define BGP_ATTR_ADVERTISER               12
#define BGP_ATTR_RCID_PATH                13
#define BGP_ATTR_MP_REACH_NLRI            14
#define BGP_ATTR_MP_UNREACH_NLRI          15
#define BGP_ATTR_EXT_COMMUNITIES          16


/* BGP update origin.  */
#define BGP_ORIGIN_IGP                     0
#define BGP_ORIGIN_EGP                     1
#define BGP_ORIGIN_INCOMPLETE              2


/* BGP notify message codes.  */
#define BGP_NOTIFY_HEADER_ERR              1
#define BGP_NOTIFY_OPEN_ERR                2
#define BGP_NOTIFY_UPDATE_ERR              3
#define BGP_NOTIFY_HOLD_ERR                4
#define BGP_NOTIFY_FSM_ERR                 5
#define BGP_NOTIFY_CEASE                   6
#define BGP_NOTIFY_MAX	                   7


/* BGP_NOTIFY_HEADER_ERR sub codes.  */
#define BGP_NOTIFY_HEADER_NOT_SYNC         1
#define BGP_NOTIFY_HEADER_BAD_MESLEN       2
#define BGP_NOTIFY_HEADER_BAD_MESTYPE      3
#define BGP_NOTIFY_HEADER_MAX              4


/* BGP_NOTIFY_OPEN_ERR sub codes.  */
#define BGP_NOTIFY_OPEN_UNSUP_VERSION      1
#define BGP_NOTIFY_OPEN_BAD_PEER_AS        2
#define BGP_NOTIFY_OPEN_BAD_BGP_IDENT      3
#define BGP_NOTIFY_OPEN_UNSUP_PARAM        4
#define BGP_NOTIFY_OPEN_AUTH_FAILURE       5
#define BGP_NOTIFY_OPEN_UNACEP_HOLDTIME    6
#define BGP_NOTIFY_OPEN_UNSUP_CAPBL        7
#define BGP_NOTIFY_OPEN_MAX                8


/* BGP_NOTIFY_UPDATE_ERR sub codes.  */
#define BGP_NOTIFY_UPDATE_MAL_ATTR         1
#define BGP_NOTIFY_UPDATE_UNREC_ATTR       2
#define BGP_NOTIFY_UPDATE_MISS_ATTR        3
#define BGP_NOTIFY_UPDATE_ATTR_FLAG_ERR    4
#define BGP_NOTIFY_UPDATE_ATTR_LENG_ERR    5
#define BGP_NOTIFY_UPDATE_INVAL_ORIGIN     6
#define BGP_NOTIFY_UPDATE_AS_ROUTE_LOOP    7
#define BGP_NOTIFY_UPDATE_INVAL_NEXT_HOP   8
#define BGP_NOTIFY_UPDATE_OPT_ATTR_ERR     9
#define BGP_NOTIFY_UPDATE_INVAL_NETWORK   10
#define BGP_NOTIFY_UPDATE_MAL_AS_PATH     11
#define BGP_NOTIFY_UPDATE_MAX             12


/* BGP finite state machine status.  */
#define Idle                               1
#define Connect                            2
#define Active                             3
#define OpenSent                           4
#define OpenConfirm                        5
#define Established                        6
#define BGP_STATUS_MAX                     7


/* BGP finite state machine events.  */
#define BGP_Start                          1
#define BGP_Stop                           2
#define TCP_connection_open                3
#define TCP_connection_closed              4
#define TCP_connection_open_failed         5
#define TCP_fatal_error                    6
#define ConnectRetry_timer_expired         7
#define Hold_Timer_expired                 8
#define KeepAlive_timer_expired            9
#define Receive_OPEN_message              10
#define Receive_KEEPALIVE_message         11
#define Receive_UPDATE_message            12
#define Receive_NOTIFICATION_message      13
#define BGP_EVENTS_MAX                    14


/* Time in second to start bgp connection. */
#define BGP_INIT_START_TIMER               5
#define BGP_ERROR_START_TIMER             30
#define BGP_DEFAULT_HOLDTIME             180
#define BGP_DEFAULT_KEEPALIVE             60 
#define BGP_DEFAULT_ASORIGINATE           15
#define BGP_DEFAULT_EBGP_ROUTEADV         30
#define BGP_DEFAULT_IBGP_ROUTEADV          5
#define BGP_CLEAR_CONNECT_RETRY           20
#define BGP_DEFAULT_CONNECT_RETRY        120


/* BGP default local preference.  */
#define BGP_DEFAULT_LOCAL_PREF           100


/* Default max TTL.  */
#define TTL_MAX                          255


/* Default configuration file name for bgpd.  */
#define BGP_VTY_PORT                    2605
#define BGP_DEFAULT_CONFIG       "bgpd.conf"


/* IBGP/EBGP identifier.  We also have a CONFED peer, which is to say,
   a peer who's AS is part of our Confederation.  */
enum
  {
    BGP_PEER_IBGP,
    BGP_PEER_EBGP,
    BGP_PEER_INTERNAL,
    BGP_PEER_CONFED
  };

/* Macros. */
#define BGP_INPUT(P)         ((P)->ibuf)
#define BGP_INPUT_PNT(P)     (STREAM_PNT(BGP_INPUT(P)))

/* Macro to check BGP information is alive or not.  */
#define BGP_INFO_HOLDDOWN(BI)                         \
  (! CHECK_FLAG ((BI)->flags, BGP_INFO_VALID)         \
   || CHECK_FLAG ((BI)->flags, BGP_INFO_HISTORY)      \
   || CHECK_FLAG ((BI)->flags, BGP_INFO_DAMPED))



#define BGP_UPTIME_LEN 25


/* peer_flag_change_type. */
enum flag_change_type
  {
    flag_change_set,
    flag_change_set_reset,
    flag_change_unset,
    flag_change_unset_reset
  };

/* BGP clear types. */
enum clear_type
  {
    clear_all,
    clear_peer,
    clear_as
  };


/* Show BGP peer's information. */
enum show_type
  {
    show_all,
    show_peer
  };

////// bgp_routemap.c

/* `set aggregator as AS A.B.C.D' */
struct aggregator
{
  as_t as;
  struct in_addr address;
};



//////bgp_route.h 

struct bgp_routeadv_list {
  struct bgp_routeadv_list *next;
  struct bgp_routeadv_list *prev;
  struct thread *t;
};

struct bgp_info
{
  /* For linked list. */
  struct bgp_info *next;
  struct bgp_info *prev;

  /* BGP route type.  This can be static, RIP, OSPF, BGP etc.  */
  u_char type;

  /* When above type is BGP.  This sub type specify BGP sub type
     information.  */
  u_char sub_type;
#define BGP_ROUTE_NORMAL    0
#define BGP_ROUTE_STATIC    1
#define BGP_ROUTE_AGGREGATE 2


  /* BGP information status.  */
  u_char flags;
#define BGP_INFO_IGP_CHANGED    (1 << 0)
#define BGP_INFO_DAMPED         (1 << 1)
#define BGP_INFO_HISTORY        (1 << 2)
#define BGP_INFO_SELECTED       (1 << 3)
#define BGP_INFO_VALID          (1 << 4)
#define BGP_INFO_ATTR_CHANGED   (1 << 5)
#define BGP_INFO_DMED_CHECK     (1 << 6)
#define BGP_INFO_DMED_SELECTED  (1 << 7)


  /* Peer structure.  */
  struct peer *peer;

  /* Attribute structure.  */
  struct attr *attr;

  /* This route is suppressed with aggregation.  */
  int suppress;

  /* Nexthop reachability check.  */
  u_int32_t igpmetric;

  /* Uptime.  */
  time_t uptime;

#ifndef HAVE_ZEBRA_93b
  /* Pointer to dampening structure.  */
  struct bgp_damp_info *bgp_damp_info;
#else 
  /* Pointer to dampening structure.  */
  struct bgp_damp_info *damp_info;
#endif
};


/* BGP static route configuration. */
struct bgp_static
{
  /* Import check status.  */
  u_char valid;

  /* IGP metric. */
  u_int32_t igpmetric;
  
};

#define DISTRIBUTE_IN_NAME(F)   ((F)->dlist[FILTER_IN].name)
#define DISTRIBUTE_IN(F)        ((F)->dlist[FILTER_IN].alist)
#define DISTRIBUTE_OUT_NAME(F)  ((F)->dlist[FILTER_OUT].name)
#define DISTRIBUTE_OUT(F)       ((F)->dlist[FILTER_OUT].alist)

#define PREFIX_LIST_IN_NAME(F)  ((F)->plist[FILTER_IN].name)
#define PREFIX_LIST_IN(F)       ((F)->plist[FILTER_IN].plist)
#define PREFIX_LIST_OUT_NAME(F) ((F)->plist[FILTER_OUT].name)
#define PREFIX_LIST_OUT(F)      ((F)->plist[FILTER_OUT].plist)

#define FILTER_LIST_IN_NAME(F)  ((F)->aslist[FILTER_IN].name)
#define FILTER_LIST_IN(F)       ((F)->aslist[FILTER_IN].aslist)
#define FILTER_LIST_OUT_NAME(F) ((F)->aslist[FILTER_OUT].name)
#define FILTER_LIST_OUT(F)      ((F)->aslist[FILTER_OUT].aslist)

#define ROUTE_MAP_IN_NAME(F)    ((F)->map[FILTER_IN].name)
#define ROUTE_MAP_IN(F)         ((F)->map[FILTER_IN].map)
#define ROUTE_MAP_OUT_NAME(F)   ((F)->map[FILTER_OUT].name)
#define ROUTE_MAP_OUT(F)        ((F)->map[FILTER_OUT].map)



/* Aggreagete address:

advertise-map  Set condition to advertise attribute
as-set         Generate AS set path information
attribute-map  Set attributes of aggregate
route-map      Set parameters of aggregate
summary-only   Filter more specific routes from updates
suppress-map   Conditionally filter more specific routes from updates
<cr>
*/
struct bgp_aggregate
{
  /* Summary-only flag. */
  u_char summary_only;

  /* AS set generation. */
  u_char as_set;

  /* Route-map for aggregated route. */
  struct route_map *map;

  /* Suppress-count. */
  unsigned long count;

  /* SAFI configuration. */
  safi_t safi;
};

/* Aggregate route attribute. */
#define AGGREGATE_SUMMARY_ONLY 1
#define AGGREGATE_AS_SET       1


enum bgp_display_type
  {
    normal_list,
  };

#define BGP_SHOW_V4_HEADER "   Network          Next Hop            Metric LocPrf Weight Path%s"
#define BGP_SHOW_V6_HEADER "   Network                                  Metric LocPrf Weight Path%s"

enum bgp_show_type
  {
    bgp_show_type_normal,
    bgp_show_type_regexp,
    bgp_show_type_prefix_list,
    bgp_show_type_filter_list,
    bgp_show_type_neighbor,
    bgp_show_type_cidr_only,
    bgp_show_type_prefix_longer,
    bgp_show_type_community_all,
    bgp_show_type_community,
    bgp_show_type_community_exact,
    bgp_show_type_community_list,
    bgp_show_type_community_list_exact
  };


struct bgp_distance
{
  /* Distance value for the IP source prefix. */
  u_char distance;

  /* Name of the access-list to be matched. */
  char *access_list;
};

//////bgp_open.h 


/* Multiprotocol Extensions capabilities. */
#define CAPABILITY_CODE_MP            1
#define CAPABILITY_CODE_MP_LEN        4


/* Route refresh capabilities. */
#define CAPABILITY_CODE_REFRESH     128
#define CAPABILITY_CODE_REFRESH_01    2
#define CAPABILITY_CODE_REFRESH_LEN   0


/* BGP-4 Multiprotocol Extentions lead us to the complex world. We can
   negotiate remote peer supports extentions or not. But if
   remote-peer doesn't supports negotiation process itself.  We would
   like to do manual configuration.

   So there is many configurable point.  First of all we want set each
   peer whether we send capability negotiation to the peer or not.
   Next, if we send capability to the peer we want to set my capabilty
   inforation at each peer. */

/* MP Capability information. */
struct capability_mp
{
  u_int16_t afi;
  u_char reserved;
  u_char safi;
};

/* BGP open message capability. */
struct capability 
{
  u_char code;
  u_char length;
  struct capability_mp mpc;
};


//////bgp_nexthop.h 

#define BGP_SCAN_INTERVAL_DEFAULT   60
#define BGP_IMPORT_INTERVAL_DEFAULT 15

/* BGP nexthop cache value structure. */
struct bgp_nexthop_cache
{
  /* This nexthop exists in IGP. */
  u_char valid;

  /* Nexthop is changed. */
  u_char changed;

  /* Nexthop is changed. */
  u_char metricchanged;

  /* IGP route's metric. */
  u_int32_t metric;

  /* Nexthop number and nexthop linked list.*/
  u_char nexthop_num;
  struct nexthop *nexthop;
};

struct bgp_connected
{
  unsigned int refcnt;
};

//////bgp_fsm.h 

#ifdef  __cplusplus

struct fsm_struct {
  int (Bgp::*func) (struct peer*);
  int next_state;
};

#endif /* __cplusplus*/

/* Macro for BGP read add */
#define BGP_READ_ON(T,F,A) \
do { \
  if (!(T)) \
    (T) = thread_add_read (master, (F), peer,(A)); \
} while (0)


/* Macro for BGP read off. */
#define BGP_READ_OFF(X) \
do { \
  if (X) \
    { \
      thread_cancel (X); \
      (X) = NULL; \
    } \
} while (0)


/* Macro for BGP write add */
#define BGP_WRITE_ON(T,F) \
do { \
  if (!(T)) \
    (T) = thread_add_ready (master, (F), peer); \
} while (0)


/* Macro for BGP write turn off. */
#define BGP_WRITE_OFF(X) \
do { \
  if (X) \
    { \
      thread_cancel (X); \
      (X) = NULL; \
    } \
} while (0)


/* Macro for timer turn on. */
#define BGP_TIMER_ON(T,F,P,V) \
do { \
  if (!(T)) \
    (T) = thread_add_timer (master, (F), (P), (V)); \
} while (0)


/* Macro for timer turn off. */
#define BGP_TIMER_OFF(X) \
do { \
  if (X) \
    { \
      thread_cancel (X); \
      (X) = NULL; \
    } \
} while (0)

#ifdef  __cplusplus
#define BGP_EVENT_ADD(P,E) \
    thread_add_event (master, &Bgp::bgp_event, (P), (E))
#endif /* __cplusplus*/

#define BGP_EVENT_DELETE(P) \
    thread_cancel_event (master, (P))



//////bgp_filter.h 

enum as_filter_type
  {
    AS_FILTER_DENY,
    AS_FILTER_PERMIT
  };

/* List of AS filter list. */
struct as_list_list
{
  struct as_list *head;
  struct as_list *tail;
};

#ifdef  __cplusplus

/* AS path filter master. */
struct as_list_master
{
  /* List of access_list which name is number. */
  struct as_list_list num;

  /* List of access_list which name is string. */
  struct as_list_list str;

  /* Hook function which is executed when new access_list is added. */
  void (Bgp::*add_hook) ();

  /* Hook function which is executed when access_list is deleted. */
  void (Bgp::*delete_hook) ();
};
#endif /*__cplusplus*/


/* Element of AS path filter. */
struct as_filter
{
  struct as_filter *next;
  struct as_filter *prev;

  enum as_filter_type type;

  regex_t *reg;
  char *reg_str;
};
/*AS path filter list*/

struct as_list
{
  char *name;

  enum access_type type;

  struct as_list *next;
  struct as_list *prev;

  struct as_filter *head;
  struct as_filter *tail;
};


//////bgp_ecommunity.h 

/* High-order octet of the Extended Communities type field. */
#define ECOMMUNITY_ENCODE_AS       0x00
#define ECOMMUNITY_ENCODE_IP       0x01


/* Low-order octet of the Extended Communityes type field. */
#define ECOMMUNITY_ROUTE_TARGET    0x02
#define ECOMMUNITY_SITE_ORIGIN     0x03


/* Extended Communities attribute. */
struct ecommunity
{
  unsigned long refcnt;
  int size;
  u_char *val;
};

#define ecom_length(X)    ((X)->size * 8)


/* For parse Extended Community attribute tupple. */
struct ecommunity_as
{
  as_t as;
  u_int32_t val;
};

struct ecommunity_ip
{
  struct in_addr ip;
  u_int16_t val;
};
/* Extended Communities token enum. */
enum ecommunity_token
  {
    ecommunity_token_as,
    ecommunity_token_ip,
    ecommunity_token_unknown
  };



//////bgp_dump.h 

/* MRT and RADIX compatible packet dump values. */
/* type value */
#define MSG_PROTOCOL_BGP4MP  16

/* subtype value */
#define BGP4MP_STATE_CHANGE   0
#define BGP4MP_MESSAGE        1
#define BGP4MP_ENTRY          2
#define BGP4MP_SNAPSHOT       3

#define BGP_DUMP_HEADER_SIZE 12

enum bgp_dump_type
  {
    BGP_DUMP_ALL,
    BGP_DUMP_UPDATES,
    BGP_DUMP_ROUTES
  };

enum MRT_MSG_TYPES
  {
    MSG_NULL,
    MSG_START,                   /* sender is starting up */
    MSG_DIE,                     /* receiver should shut down */
    MSG_I_AM_DEAD,               /* sender is shutting down */
    MSG_PEER_DOWN,               /* sender's peer is down */
    MSG_PROTOCOL_BGP,            /* msg is a BGP packet */
    MSG_PROTOCOL_RIP,            /* msg is a RIP packet */
    MSG_PROTOCOL_IDRP,           /* msg is an IDRP packet */
    MSG_PROTOCOL_RIPNG,          /* msg is a RIPNG packet */
    MSG_PROTOCOL_BGP4PLUS,       /* msg is a BGP4+ packet */
    MSG_PROTOCOL_BGP4PLUS_01,    /* msg is a BGP4+ (draft 01) packet */
    MSG_PROTOCOL_OSPF,           /* msg is an OSPF packet */
    MSG_TABLE_DUMP               /* routing table dump */
  };

struct bgp_dump
{
  enum bgp_dump_type type;

  char *filename;

  FILE *fp;

  unsigned int interval;

  char *interval_str;

  struct thread *t_interval;
};

//////bgp_debug.h 

#define IS_SET(x, y)  ((x) & (y))


/* sort of packet direction */
#define DUMP_ON        1
#define DUMP_SEND      2
#define DUMP_RECV      4


/* for dump_update */
#define DUMP_WITHDRAW  8
#define DUMP_NLRI     16


/* dump detail */
#define DUMP_DETAIL   32

#define	NLRI	 1
#define	WITHDRAW 2
#define	NO_OPT	 3
#define	SEND	 4
#define	RECV	 5
#define	DETAIL	 6


#define BGP_DEBUG_FSM                 0x01
#define BGP_DEBUG_EVENTS              0x01
#define BGP_DEBUG_PACKET              0x01
#define BGP_DEBUG_FILTER              0x01
#define BGP_DEBUG_KEEPALIVE           0x01
#define BGP_DEBUG_UPDATE_IN           0x01
#define BGP_DEBUG_UPDATE_OUT          0x02
#define BGP_DEBUG_NORMAL              0x01

#define BGP_DEBUG_PACKET_SEND         0x01
#define BGP_DEBUG_PACKET_SEND_DETAIL  0x02

#define BGP_DEBUG_PACKET_RECV         0x01
#define BGP_DEBUG_PACKET_RECV_DETAIL  0x02

#define CONF_DEBUG_ON(a, b)	(conf_bgp_debug_ ## a |= (BGP_DEBUG_ ## b))
#define CONF_DEBUG_OFF(a, b)	(conf_bgp_debug_ ## a &= ~(BGP_DEBUG_ ## b))

#define TERM_DEBUG_ON(a, b)	(term_bgp_debug_ ## a |= (BGP_DEBUG_ ## b))
#define TERM_DEBUG_OFF(a, b)	(term_bgp_debug_ ## a &= ~(BGP_DEBUG_ ## b))

#define DEBUG_ON(a, b) \
    do { \
	CONF_DEBUG_ON(a, b); \
	TERM_DEBUG_ON(a, b); \
    } while (0)
#define DEBUG_OFF(a, b) \
    do { \
	CONF_DEBUG_OFF(a, b); \
	TERM_DEBUG_OFF(a, b); \
    } while (0)

#define BGP_DEBUG(a, b) (term_bgp_debug_ ## a & BGP_DEBUG_ ## b)
#define CONF_BGP_DEBUG(a, b) (conf_bgp_debug_ ## a & BGP_DEBUG_ ## b)


//////bgp_damp.h 
/* Zebra 0.93b has modified the damp structures */
#ifndef HAVE_ZEBRA_93b

/* Structure maintained on a per-route basis. */
struct bgp_damp_info
{
  int penalty;
  int flap;

  /* Last time penalty was updated. */
  time_t t_updated;

  /* First flap time */
  time_t start_time;

  /* Reference to next damp_info in the reuse list. */
  struct bgp_damp_info *reuse_next;

  /* Back reference to bgp_info. */
  struct bgp_info *bgp_info;
};

/* Global configuration parameters. */
struct bgp_damp_config
{
  /* Configurable parameters */
  int enabled;        /* Is damping enabled? */
  int suppress_value; /* Value over which routes suppressed */
  int reuse_limit;    /* Value below which suppressed routes reused */
  int max_suppress_time;  /* Max time a route can be suppressed */
  int half_life;      /* Time during which accumulated penalty reduces by half */

  /* Non-configurable parameters but fixed at implementation time.
   * To change this values, init_bgp_damp() should be modified.
   */
  int tmax;       /* Max time previous instability retained */
  int reuse_list_size;    /* Number of reuse lists */
  int reuse_index_array_size; /* Size of reuse index array */

  /* Non-configurable parameters.  Most of these are calculated from
   * the configurable parameters above.
   */
  unsigned int ceiling;   /* Max value a penalty can attain */
  int decay_rate_per_tick; /* Calculated from half-life */
  int decay_array_size;   /* Calculated using config parameters */
  double *decay_array;    /* Storage for decay values */
  int scale_factor;
  int reuse_scale_factor; /* To scale reuse array indices */
  int *reuse_index_array;
  struct bgp_damp_info **reuse_list_array;
};


#define BGP_DAMP_CONTINUE	1
#define BGP_DAMP_DISABLED	2
#define BGP_DAMP_DISCONTINUE 3

/* Time granularity for reuse lists */
#define DELTA_REUSE 15

/* Time granularity for decay arrays */
#define DELTA_T 1

#define DEFAULT_PENALTY 1000

#define DEFAULT_HALF_LIFE 15
#define DEFAULT_REUSE 750
#define DEFAULT_SUPPRESS 2000
#define REUSE_LIST_SIZE		256
#define REUSE_ARRAY_SIZE	1024

#else 
#include "bgp/bgp_damp.h"
#endif /* HAVE_ZEBRA_93b */


//////bgp_community.h 


/* Community attribute. */
struct community 
{
  unsigned long refcnt;
  int size;
  u_int32_t *val;
};

/* Community pre-defined values definition. */
#define COMMUNITY_NO_EXPORT             0xFFFFFF01
#define COMMUNITY_NO_ADVERTISE          0xFFFFFF02
#define COMMUNITY_NO_EXPORT_SUBCONFED   0xFFFFFF03
#define COMMUNITY_LOCAL_AS              0xFFFFFF03


/* Macros of community attribute. */
#define com_length(X)    ((X)->size * 4)
#define com_lastval(X)   ((X)->val + (X)->size - 1)
#define com_nthval(X,n)  ((X)->val + (n))


/* Community token enum. */
enum community_token
  {
    community_token_val,
    community_token_no_export,
    community_token_no_advertise,
    community_token_local_as,
    community_token_unknown
  };



//////bgp_clist.h 

enum community_list_sort
  {
    COMMUNITY_LIST_STRING,
    COMMUNITY_LIST_NUMBER
  };

struct community_list
{
  char *name;

  enum community_list_sort sort;

  struct community_list *next;
  struct community_list *prev;

  struct community_entry *head;
  struct community_entry *tail;
};

enum community_entry_type
  {
    COMMUNITY_DENY,
    COMMUNITY_PERMIT
  };

enum community_entry_style
  {
    COMMUNITY_LIST,
    COMMUNITY_REGEXP,
  };

struct community_list_list
{
  struct community_list *head;
  struct community_list *tail;
};

struct community_list_master
{
  struct community_list_list num;
  struct community_list_list str;
};

struct community_entry
{
  struct community_entry *next;
  struct community_entry *prev;

  enum community_entry_type type;

  enum community_entry_style style;

  struct community *com;
  char *regexp;
  regex_t *reg;
};



//////bgp_attr.h 

/* Simple bit mapping. */
#define BITMAP_NBBY 8

#define SET_BITMAP(MAP, NUM) \
        SET_FLAG (MAP[(NUM) / BITMAP_NBBY], 1 << ((NUM) % BITMAP_NBBY))

#define CHECK_BITMAP(MAP, NUM) \
        CHECK_FLAG (MAP[(NUM) / BITMAP_NBBY], 1 << ((NUM) % BITMAP_NBBY))


/* BGP Attribute type range. */
#define BGP_ATTR_TYPE_RANGE     256
#define BGP_ATTR_BITMAP_SIZE    (BGP_ATTR_TYPE_RANGE / BITMAP_NBBY)


/* BGP Attribute flags. */
#define BGP_ATTR_FLAG_OPTIONAL  0x80	/* Attribute is optional. */
#define BGP_ATTR_FLAG_TRANS     0x40	/* Attribute is transitive. */
#define BGP_ATTR_FLAG_PARTIAL   0x20	/* Attribute is partial. */
#define BGP_ATTR_FLAG_EXTLEN    0x10	/* Extended length flag. */


/* BGP attribute header must bigger than 2. */
#define BGP_ATTR_MIN_LEN        2       /* Attribute flag and type. */


/* BGP attribute structure. */
struct attr
{
  /* Reference count of this attribute. */
  unsigned long refcnt;

  /* Flag of attribute is set or not. */
  u_int32_t flag;

  /* Attributes. */
  u_char origin;
  struct in_addr nexthop;
  u_int32_t med;
  u_int32_t local_pref;
  as_t aggregator_as;
  struct in_addr aggregator_addr;
  /* u_int32_t dpa; */
  u_int32_t weight;
  struct in_addr originator_id;
  struct cluster_list *cluster;

  //  u_char mp_nexthop_len;
  //struct in_addr mp_nexthop_global_in;
  //struct in_addr mp_nexthop_local_in;

  /* AS Path structure */
  struct aspath *aspath;

  /* Community structure */
  struct community *community;  

  /* Extended Communities attribute. */
  struct ecommunity *ecommunity;

  /* Unknown transitive attribute. */
  struct transit *transit;
};

/* Router Reflector related structure. */
struct cluster_list
{
  unsigned long refcnt;
  int length;
  struct in_addr *list;
};

/* Unknown transit attribute. */
struct transit
{
  unsigned long refcnt;
  int length;
  u_char *val;
};

#define ATTR_FLAG_BIT(X)  (1 << ((X) - 1))

/* Structure to pass each BGP attribute information.  */
struct bgp_attr_val
{
  u_char flag;
  u_char type;
  bgp_size_t length;
  bgp_size_t total;
  u_char *startp;
};


#ifndef HAVE_ZEBRA_93b
struct bgp_advertise { 
  struct bgp_advertise *next;
  struct bgp_advertise *prev;

  struct peer_conf *conf;
  struct prefix *p;
  struct attr attribute;
  afi_t afi;
  safi_t safi;
  struct peer *from;
  struct prefix_rd *prd;
  u_char *tag;
}; 
#endif

struct bgp_mrai_info { 
  struct peer *peer;
  struct prefix *p;
  struct bgp_info *bi;
};



//////bgp_aspath.h 

/* AS path segment type. */
#define AS_SET             1
#define AS_SEQUENCE        2


/* Use draft-ietf-idr-bgp-confed-rfc1965bis-01.txt value.  */
#define AS_CONFED_SEQUENCE 3
#define AS_CONFED_SET      4


/* AS path may be include some AsSegments. */
struct aspath 
{
  /* Reference count to this aspath. */
  unsigned long refcnt;

  /* Rawdata length */
  int length;

  /* AS count. */
  int count;

  /* Rawdata */
  caddr_t data;

  /* String expression of AS path.  This string is used by vty output
     and AS path regular expression match. */
  char *str;
};

#define ASPATH_STR_DEFAULT_LEN 32



/* Minimum size of aspath header and AS value. */

/* Attr. Flags and Attr. Type Code. */
#define AS_HEADER_SIZE        2	 


/* Two octet is used for AS value. */
#define AS_VALUE_SIZE         sizeof (as_t)


/* AS segment octet length. */
#define ASSEGMENT_LEN(X)  ((X)->length * AS_VALUE_SIZE + AS_HEADER_SIZE)


/* To fetch and store as segment value. */

struct assegment
{
  u_char type;
  u_char length;
  as_t asval[1];
};

#define AS_SEG_START 0
#define AS_SEG_END 1

#define min(A,B) ((A) < (B) ? (A) : (B))

#define ASSEGMENT_SIZE(N)  (AS_HEADER_SIZE + ((N) * AS_VALUE_SIZE))



/* 
   Theoretically, one as path can have:

   One BGP packet size should be less than 4096.
   One BGP attribute size should be less than 4096 - BGP header size.
   One BGP aspath size should be less than 4096 - BGP header size -
   BGP mandantry attribute size.
*/

/* AS path string lexical token enum. */
enum as_token
  {
    as_token_asval,
    as_token_set_start,
    as_token_set_end,
    as_token_confed_start,
    as_token_confed_end,
    as_token_unknown
  };



//////zclient.h 
/* For input/output buffer to zebra. */
#define ZEBRA_MAX_PACKET_SIZ          4096


/* Zebra header size. */
#define ZEBRA_HEADER_SIZE                3

/* Zebra API message flag. */
#define ZAPI_MESSAGE_NEXTHOP  0x01
#define ZAPI_MESSAGE_IFINDEX  0x02
#define ZAPI_MESSAGE_DISTANCE 0x04
#define ZAPI_MESSAGE_METRIC   0x08


/* Zebra IPv4 route message API. */
struct zapi_ipv4
{
  u_char type;

  u_char flags;

  u_char message;

  u_char nexthop_num;
  struct in_addr **nexthop;

  u_char ifindex_num;
  unsigned int *ifindex;

  u_char distance;

  u_int32_t metric;
};



/* Zebra client events. */
enum zevent
  {
    ZCLIENT_SCHEDULE, ZCLIENT_READ, ZCLIENT_CONNECT
  };


//////////

/* Timeout types */
#define TYPE_MAIN    0
#define TYPE_FETCH1  1
#define TYPE_FETCH2  2
#define TYPE_EXECUTE 3

#define SET_TIMEOUT_TYPE_MAIN     type=TYPE_MAIN
#define SET_TIMEOUT_TYPE_FETCH1   type=TYPE_FETCH1
#define SET_TIMEOUT_TYPE_FETCH2   type=TYPE_FETCH2
#define SET_TIMEOUT_TYPE_EXECUTE  type=TYPE_EXECUTE


/*duplet that identifies an agent */
struct agent_index { 
  u_int32_t addr;
  u_int32_t port; 
};


#ifdef HAVE_ZEBRA_93b
/* BGP advertise FIFO.  */
struct bgp_advertise_fifo
{
  struct bgp_advertise *next;
  struct bgp_advertise *prev;
};

/* BGP advertise attribute.  */
struct bgp_advertise_attr
{
  /* Head of advertisement pointer. */
  struct bgp_advertise *adv;

  /* Reference counter.  */
  unsigned long refcnt;

  /* Attribute pointer to be announced.  */
  struct attr *attr;
};

struct bgp_advertise
{
  /* FIFO for advertisement.  */
  struct bgp_advertise_fifo fifo;

  /* Link list for same attribute advertise.  */
  struct bgp_advertise *next;
  struct bgp_advertise *prev;

  /* Prefix information.  */
  struct bgp_node *rn;

  /* Reference pointer.  */
  struct bgp_adj_out *adj;

  /* Advertisement attribute.  */
  struct bgp_advertise_attr *baa;

  /* BGP info.  */
  struct bgp_info *binfo;
};

/* BGP adjacency out.  */
struct bgp_adj_out
{
  /* Lined list pointer.  */
  struct bgp_adj_out *next;
  struct bgp_adj_out *prev;

  /* Advertised peer.  */
  struct peer *peer;

  /* Advertised attribute.  */
  struct attr *attr;

  /* Advertisement information.  */
  struct bgp_advertise *adv;
};

/* BGP adjacency in. */
struct bgp_adj_in
{
  /* Linked list pointer.  */
  struct bgp_adj_in *next;
  struct bgp_adj_in *prev;

  /* Received peer.  */
  struct peer *peer;

  /* Received attribute.  */
  struct attr *attr;
};

/* BGP advertisement list.  */
struct bgp_synchronize
{
  struct bgp_advertise_fifo update;
  struct bgp_advertise_fifo withdraw;
  struct bgp_advertise_fifo withdraw_low;
};

/* FIFO -- first in first out structure and macros.  */
struct fifo
{
  struct fifo *next;
  struct fifo *prev;
};

#define FIFO_INIT(F)                                  \
  do {                                                \
    struct fifo *Xfifo = (struct fifo *)(F);          \
    Xfifo->next = Xfifo->prev = Xfifo;                \
  } while (0)

#define FIFO_ADD(F,N)                                 \
  do {                                                \
    struct fifo *Xfifo = (struct fifo *)(F);          \
    struct fifo *Xnode = (struct fifo *)(N);          \
    Xnode->next = Xfifo;                              \
    Xnode->prev = Xfifo->prev;                        \
    Xfifo->prev = Xfifo->prev->next = Xnode;          \
  } while (0)

#define FIFO_DEL(N)                                   \
  do {                                                \
    struct fifo *Xnode = (struct fifo *)(N);          \
    Xnode->prev->next = Xnode->next;                  \
    Xnode->next->prev = Xnode->prev;                  \
  } while (0)

#define FIFO_HEAD(F)                                  \
  ((((struct fifo *)(F))->next == (struct fifo *)(F)) \
  ? NULL : (F)->next)

/* BGP adjacency linked list.  */
#define BGP_INFO_ADD(N,A,TYPE)                        \
  do {                                                \
    (A)->prev = NULL;                                 \
    (A)->next = (N)->TYPE;                            \
    if ((N)->TYPE)                                    \
      (N)->TYPE->prev = (A);                          \
    (N)->TYPE = (A);                                  \
  } while (0)

#define BGP_INFO_DEL(N,A,TYPE)                        \
  do {                                                \
    if ((A)->next)                                    \
      (A)->next->prev = (A)->prev;                    \
    if ((A)->prev)                                    \
      (A)->prev->next = (A)->next;                    \
    else                                              \
      (N)->TYPE = (A)->next;                          \
  } while (0)

#define BGP_ADJ_IN_ADD(N,A)    BGP_INFO_ADD(N,A,adj_in)
#define BGP_ADJ_IN_DEL(N,A)    BGP_INFO_DEL(N,A,adj_in)
#define BGP_ADJ_OUT_ADD(N,A)   BGP_INFO_ADD(N,A,adj_out)
#define BGP_ADJ_OUT_DEL(N,A)   BGP_INFO_DEL(N,A,adj_out)

////////packet.h
#define BGP_NLRI_LENGTH       1
#define BGP_TOTAL_ATTR_LEN    2
#define BGP_UNFEASIBLE_LEN    2
#define BGP_WRITE_PACKET_MAX 10

#endif

#ifdef  __cplusplus

typedef vector<pair<agent_index,pair<int,RMsgList_t> > >        Agent2MsgListMap_t ;
typedef vector<pair<agent_index,union sockunion > >             Agent2Su_t ;
typedef vector< pair < union sockunion ,Bgp* > >                Su2BgpMap_t ;
typedef pair<string,string>                                     IpAddrMaskPair_t;
typedef list<IpAddrMaskPair_t>                                  InterfaceList_t; 
typedef list<pair<string,InterfaceList_t > >                    String2List_t ;
typedef list<Bgp*>                                              BgpList_t;
struct InterruptInfo
{
  Agent *IntAgent;
  RouteMsg intmsg;
};

#ifdef HAVE_PDNS_BGP
NsObject* GetLocalIP(ipaddr_t ipaddr);
#include "rti/rtioob.h"
#endif


class Bgp : public RouteApp {
 public:
  Bgp(double);
  void bgp_main();
  void timeout();
  int  sendMessage(const RouteMsg& m,struct peer*);
  virtual int command(int argc, const char*const* argv);
  void recv(int nbytes, Agent* pFrom);
  void bgp_interrupt( Bgp* ,FullTcpAgent* ,RouteMsg);
  static void bgp_interrupt( Application* ,Agent*);

  void dump_peer_list ();
  static double last_update_time_;
  static FILE*  use_log_fp_;
  static char*  use_log_file_;   /*If this variable is set to some file, 
				   then this file is used for logging by all
				   BGP instances that have logging enabled (with
				   the "log filename" command). The argument
				   of the later command is ignored. Since all BGP instances
				   use the same file for logging each line is prefixed or suffixed 
				   with the id of the BGP instance that wrote to the file 
				   within # characters, e.g.				   

*> 189.0.0.0/8        0.0.0.0                            32768 AS path: i#192.38.14.1#
*> 190.0.0.0/8        0.0.0.0                            32768 AS path: i#192.38.14.1#
                                   or 

#192.38.14.2#2004/02/27 15:07:57  6.409467 BGP: 192.38.14.1 sending KEEPALIVE
#192.38.14.2#2004/02/27 15:07:57  6.409467 BGP: 192.38.14.1 send message type 4, length (incl. header) 19
#192.38.14.1#2004/02/27 15:07:57  6.411185 BGP: 192.38.14.2 rcv message type 1, length (excl. header) 26
#192.38.14.1#2004/02/27 15:07:57  6.411185 BGP: 192.38.14.2 rcv OPEN, version 4, remote-as 2, holdtime 180, id 192.38.14.2

				   The following command can be used from the tcl space 
				   to set and query the global log file:

				         Application/Route/Bgp use-log-file bla.log
				         puts [Application/Route/Bgp use-log-file]
				 */

  char new_line[INET_ADDRSTRLEN + 3];   /* Hack, to append BGP identifier (ip addr string)
					   when one global file for logging is used*/
  
#define NO_WORKLOAD_MODEL         0
#define UNIFORM_WORKLOAD_MODEL     1
#define TIME_SAMPLE_WORKLOAD_MODEL  2 

#ifdef HAVE_PERFCTR
  double workload(struct perfctr_sum_ctrs *);
  static int perfcnt_init;
  static struct perfctr_info info;
#else 
  double workload();
#endif /* HAVE_PERFCTR */
  
  int workload_model;                    /* type of workload model */
  static double uniform_max;
  static double uniform_min;
  static bool default_randomize; 
  static int rnd;                      /* rng initialization flag */
  BgpTimer* timer;                     /* timer used for BGP++ task scheduling */
  static time_t start_time ;           /* Global Start Time of Simulation  */
  int type ;                           /* type of timeout */
  bool debug_on;                        /* print debug information */           
  bool enable_routeadv;                /* enable per peer route adv rate limiting */  
  bool enable_routeadv_prefix;          /* enable per prefix route adv rate limiting */ 
#define MRAI_DISABLE     0
#define MRAI_PER_PEER    1 
#define MRAI_PER_PREFIX  2
  int mrai_type;                       /* MRAI type    */  
  bool ssld;                           /* sender side loop detection on */
  struct thread *thread_to_be_fetched; /* holds the thread that is fetched 
					  after the virtual select unblocks */
#define MAX_CONFIG_LENGTH  512

  char bgp_config_file[MAX_CONFIG_LENGTH]; /* bgpd configuration file */
  static BgpRegistry* Ip2BgpMap;           /* BGP registry pointer */ 

  FullTcpAgent *ServAgent;                 /* Local listening tcp agent  */ 
  Agent *InterruptAgent ;                  /* Agent, analogous to file pointer, that cause  
					      the most recently virtual select unblocking */
  RouteMsg ReceivedMsg ;                   /* most recently received msg */   
  list<struct InterruptInfo>     
    InterruptQueue ;                       /* Queue were interrupts, i.e. msg arrivals,
					      are temporary stored if the bgp daemon is busy when the 
					      interrupt occurs; as soon as the bgpd finishes with 
					      the work in progress, it checks the Interrupt queue, before 
					      entering the virtual select()					    
					   */

  Agent2MsgListMap_t  m_msgs;              /* structure that holds msgs. Since ns does not 
					      carry the actual msg that is sent, the msgs are
					      stored in destination's m_msgs before they are 
					      xmitted.
					   */
#ifdef HAVE_PDNS_BGP
  double last_sendoob_time;                /* Last sendoob timestamp*/
#endif   
  static bool enter_bgp_construct;         /*Flag turn on when first BGP instance enters constructor */
  static bool enter_bgp_main;              /*Flag turn on when first BGP instance enters main bgp_func */
  static int instance_cnt;                 /*# of BGP instances */

  static bool dont_reuse;                   /*Used to check the memory savings of the mem reusing scheme */
  int first_time_insert;                    /*Used to kick off the reuse timer*/

  ~Bgp(){
    closezlog(zlog_default);
  };

  /*
    Zebra bgpd and lib variables and functions follow 
    listed by their original file 
  */

  struct llist *dummy_peer_list;    

  static struct cmd_element ip_community_list_cmd;
  static struct cmd_element no_ip_community_list_cmd;
  static struct cmd_element no_ip_community_list_all_cmd;
  static struct cmd_element debug_bgp_fsm_cmd;
  static struct cmd_element no_debug_bgp_fsm_cmd;
  static struct cmd_element undebug_bgp_fsm_cmd;
  static struct cmd_element debug_bgp_events_cmd;
  static struct cmd_element no_debug_bgp_events_cmd;
  static struct cmd_element undebug_bgp_events_cmd;
  static struct cmd_element debug_bgp_filter_cmd;
  static struct cmd_element no_debug_bgp_filter_cmd;
  static struct cmd_element undebug_bgp_filter_cmd;
  static struct cmd_element debug_bgp_keepalive_cmd;
  static struct cmd_element no_debug_bgp_keepalive_cmd;
  static struct cmd_element undebug_bgp_keepalive_cmd;
  static struct cmd_element debug_bgp_update_cmd;
  static struct cmd_element debug_bgp_update_direct_cmd;
  static struct cmd_element no_debug_bgp_update_cmd;
  static struct cmd_element undebug_bgp_update_cmd;
  static struct cmd_element debug_bgp_normal_cmd;
  static struct cmd_element no_debug_bgp_normal_cmd;
  static struct cmd_element undebug_bgp_normal_cmd;
  static struct cmd_element no_debug_bgp_all_cmd;
  static struct cmd_element undebug_bgp_all_cmd;
  static struct cmd_element show_debugging_bgp_cmd;
  static struct cmd_element dump_bgp_all_cmd;
  static struct cmd_element dump_bgp_all_interval_cmd;
  static struct cmd_element no_dump_bgp_all_cmd;
  static struct cmd_element dump_bgp_updates_cmd;
  static struct cmd_element dump_bgp_updates_interval_cmd;
  static struct cmd_element no_dump_bgp_updates_cmd;
  static struct cmd_element dump_bgp_routes_interval_cmd;
  static struct cmd_element no_dump_bgp_routes_cmd;
  static struct cmd_element ip_as_path_cmd;
  static struct cmd_element no_ip_as_path_cmd;
  static struct cmd_element no_ip_as_path_all_cmd;
  static struct cmd_element bgp_network_cmd;
  static struct cmd_element bgp_network_mask_cmd;
  static struct cmd_element bgp_network_mask_natural_cmd;
  static struct cmd_element no_bgp_network_cmd;
  static struct cmd_element no_bgp_network_mask_cmd;
  static struct cmd_element no_bgp_network_mask_natural_cmd;
  static struct cmd_element aggregate_address_cmd;
  static struct cmd_element aggregate_address_mask_cmd;
  static struct cmd_element aggregate_address_summary_only_cmd;
  static struct cmd_element aggregate_address_mask_summary_only_cmd;
  static struct cmd_element aggregate_address_as_set_cmd;
  static struct cmd_element aggregate_address_mask_as_set_cmd;
  static struct cmd_element aggregate_address_as_set_summary_cmd;
  static struct cmd_element aggregate_address_summary_as_set_cmd;
  static struct cmd_element aggregate_address_mask_as_set_summary_cmd;
  static struct cmd_element aggregate_address_mask_summary_as_set_cmd;
  static struct cmd_element no_aggregate_address_cmd;
  static struct cmd_element no_aggregate_address_summary_only_cmd;
  static struct cmd_element no_aggregate_address_as_set_cmd;
  static struct cmd_element no_aggregate_address_as_set_summary_cmd;
  static struct cmd_element no_aggregate_address_summary_as_set_cmd;
  static struct cmd_element no_aggregate_address_mask_cmd;
  static struct cmd_element no_aggregate_address_mask_summary_only_cmd;
  static struct cmd_element no_aggregate_address_mask_as_set_cmd;
  static struct cmd_element no_aggregate_address_mask_as_set_summary_cmd;
  static struct cmd_element no_aggregate_address_mask_summary_as_set_cmd;
  static struct cmd_element show_ip_bgp_cmd;
  static struct cmd_element show_ip_bgp_route_cmd;
  static struct cmd_element show_ip_bgp_prefix_cmd;
  static struct cmd_element show_ip_bgp_regexp_cmd;
  static struct cmd_element show_ip_bgp_prefix_list_cmd;
  static struct cmd_element show_ip_bgp_filter_list_cmd;
  static struct cmd_element show_ip_bgp_cidr_only_cmd;
  static struct cmd_element show_ip_bgp_community_all_cmd;
  static struct cmd_element show_ip_bgp_community_cmd;
  static struct cmd_element show_ip_bgp_community2_cmd;
  static struct cmd_element show_ip_bgp_community3_cmd;
  static struct cmd_element show_ip_bgp_community4_cmd;
  static struct cmd_element show_ip_bgp_community_exact_cmd;
  static struct cmd_element show_ip_bgp_community2_exact_cmd;
  static struct cmd_element show_ip_bgp_community3_exact_cmd;
  static struct cmd_element show_ip_bgp_community4_exact_cmd;
  static struct cmd_element show_ip_bgp_community_list_cmd;
  static struct cmd_element show_ip_bgp_community_list_exact_cmd;
  static struct cmd_element show_ip_bgp_prefix_longer_cmd;
  static struct cmd_element show_ip_bgp_neighbor_advertised_route_cmd;
  static struct cmd_element show_ip_bgp_neighbor_received_routes_cmd;
  static struct cmd_element show_ip_bgp_neighbor_routes_cmd;
  static struct cmd_element bgp_distance_cmd;
  static struct cmd_element no_bgp_distance_cmd;
  static struct cmd_element no_bgp_distance2_cmd;
  static struct cmd_element bgp_distance_source_cmd;
  static struct cmd_element no_bgp_distance_source_cmd;
  static struct cmd_element bgp_distance_source_access_list_cmd;
  static struct cmd_element no_bgp_distance_source_access_list_cmd;
  static struct cmd_element bgp_damp_set_cmd;
  static struct cmd_element bgp_damp_set2_cmd;
  static struct cmd_element bgp_damp_set3_cmd;
  static struct cmd_element bgp_damp_unset_cmd;
  static struct cmd_element bgp_damp_unset2_cmd;
#ifdef HAVE_ZEBRA_93b
  static struct cmd_element clear_ip_bgp_dampening_cmd;
  static struct cmd_element clear_ip_bgp_dampening_prefix_cmd;
  static struct cmd_element clear_ip_bgp_dampening_address_cmd;
  static struct cmd_element clear_ip_bgp_dampening_address_mask_cmd;
#endif
  static struct cmd_element match_ip_address_cmd;
  static struct cmd_element no_match_ip_address_cmd;
  static struct cmd_element no_match_ip_address_val_cmd;
  static struct cmd_element match_ip_next_hop_cmd;
  static struct cmd_element no_match_ip_next_hop_cmd;
  static struct cmd_element no_match_ip_next_hop_val_cmd;
  static struct cmd_element match_ip_address_prefix_list_cmd;
  static struct cmd_element no_match_ip_address_prefix_list_cmd;
  static struct cmd_element no_match_ip_address_prefix_list_val_cmd;
  static struct cmd_element match_ip_next_hop_prefix_list_cmd;
  static struct cmd_element no_match_ip_next_hop_prefix_list_cmd;
  static struct cmd_element no_match_ip_next_hop_prefix_list_val_cmd;
  static struct cmd_element match_metric_cmd;
  static struct cmd_element no_match_metric_cmd;
  static struct cmd_element no_match_metric_val_cmd;
  static struct cmd_element match_community_cmd;
  static struct cmd_element no_match_community_cmd;
  static struct cmd_element no_match_community_val_cmd;
  static struct cmd_element match_aspath_cmd;
  static struct cmd_element no_match_aspath_cmd;
  static struct cmd_element no_match_aspath_val_cmd;
  static struct cmd_element set_ip_nexthop_cmd;
  static struct cmd_element no_set_ip_nexthop_cmd;
  static struct cmd_element no_set_ip_nexthop_val_cmd;
  static struct cmd_element set_metric_cmd;
  static struct cmd_element no_set_metric_cmd;
  static struct cmd_element no_set_metric_val_cmd;
  static struct cmd_element set_local_pref_cmd;
  static struct cmd_element no_set_local_pref_cmd;
  static struct cmd_element no_set_local_pref_val_cmd;
  static struct cmd_element set_weight_cmd;
  static struct cmd_element no_set_weight_cmd;
  static struct cmd_element no_set_weight_val_cmd;
  static struct cmd_element set_aspath_prepend_cmd;
  static struct cmd_element no_set_aspath_prepend_cmd;
  static struct cmd_element no_set_aspath_prepend_val_cmd;
  static struct cmd_element set_community_cmd;
  static struct cmd_element set_community_none_cmd;
  static struct cmd_element no_set_community_cmd;
  static struct cmd_element no_set_community_val_cmd;
  static struct cmd_element no_set_community_none_cmd;
  static struct cmd_element set_community_additive_cmd;
  static struct cmd_element no_set_community_additive_cmd;
  static struct cmd_element no_set_community_additive_val_cmd;
  static struct cmd_element set_community_delete_cmd;
  static struct cmd_element no_set_community_delete_cmd;
  static struct cmd_element no_set_community_delete_val_cmd;
  static struct cmd_element set_ecommunity_rt_cmd;
  static struct cmd_element no_set_ecommunity_rt_cmd;
  static struct cmd_element no_set_ecommunity_rt_val_cmd;
  static struct cmd_element set_ecommunity_soo_cmd;
  static struct cmd_element no_set_ecommunity_soo_cmd;
  static struct cmd_element no_set_ecommunity_soo_val_cmd;
  static struct cmd_element set_origin_cmd;
  static struct cmd_element no_set_origin_cmd;
  static struct cmd_element no_set_origin_val_cmd;
  static struct cmd_element set_atomic_aggregate_cmd;
  static struct cmd_element no_set_atomic_aggregate_cmd;
  static struct cmd_element set_aggregator_as_cmd;
  static struct cmd_element no_set_aggregator_as_cmd;
  static struct cmd_element no_set_aggregator_as_val_cmd;
  static struct cmd_element set_originator_id_cmd;
  static struct cmd_element no_set_originator_id_cmd;
  static struct cmd_element no_set_originator_id_val_cmd;
  static struct cmd_element bgp_router_id_cmd;
  static struct cmd_element no_bgp_router_id_cmd;
  static struct cmd_element no_bgp_router_id_val_cmd;
  static struct cmd_element bgp_timers_cmd;
  static struct cmd_element no_bgp_timers_cmd;
  static struct cmd_element bgp_cluster_id_cmd;
  static struct cmd_element bgp_cluster_id32_cmd;
  static struct cmd_element no_bgp_cluster_id_cmd;
  static struct cmd_element no_bgp_cluster_id_val_cmd;
  static struct cmd_element bgp_confederation_peers_cmd;
  static struct cmd_element bgp_confederation_identifier_cmd;
  static struct cmd_element no_bgp_confederation_peers_cmd;
  static struct cmd_element no_bgp_confederation_identifier_cmd;
  static struct cmd_element no_bgp_client_to_client_reflection_cmd;
  static struct cmd_element bgp_client_to_client_reflection_cmd;
  static struct cmd_element bgp_always_compare_med_cmd;
  static struct cmd_element no_bgp_always_compare_med_cmd;
  static struct cmd_element bgp_deterministic_med_cmd;
  static struct cmd_element no_bgp_deterministic_med_cmd;
  static struct cmd_element bgp_enforce_first_as_cmd;
  static struct cmd_element no_bgp_enforce_first_as_cmd;
  static struct cmd_element bgp_bestpath_compare_router_id_cmd;
  static struct cmd_element no_bgp_bestpath_compare_router_id_cmd;
  static struct cmd_element bgp_bestpath_aspath_ignore_cmd;
  static struct cmd_element no_bgp_bestpath_aspath_ignore_cmd;
  static struct cmd_element bgp_bestpath_med_cmd;
  static struct cmd_element bgp_bestpath_med2_cmd;
  static struct cmd_element bgp_bestpath_med3_cmd;
  static struct cmd_element no_bgp_bestpath_med_cmd;
  static struct cmd_element no_bgp_bestpath_med2_cmd;
  static struct cmd_element no_bgp_bestpath_med3_cmd;
  static struct cmd_element bgp_default_local_preference_cmd;
  static struct cmd_element no_bgp_default_local_preference_cmd;
  static struct cmd_element no_bgp_default_local_preference_val_cmd;
  static struct cmd_element router_bgp_cmd;
  static struct cmd_element no_router_bgp_cmd;
  static struct cmd_element neighbor_remote_as_cmd;
  static struct cmd_element neighbor_activate_cmd;
  static struct cmd_element no_neighbor_activate_cmd;
  static struct cmd_element no_neighbor_cmd;
  static struct cmd_element no_neighbor_remote_as_cmd;
  static struct cmd_element neighbor_passive_cmd;
  static struct cmd_element no_neighbor_passive_cmd;
  static struct cmd_element neighbor_shutdown_cmd;
  static struct cmd_element no_neighbor_shutdown_cmd;
  static struct cmd_element neighbor_ebgp_multihop_cmd;
  static struct cmd_element neighbor_ebgp_multihop_ttl_cmd;
  static struct cmd_element no_neighbor_ebgp_multihop_cmd;
  static struct cmd_element no_neighbor_ebgp_multihop_ttl_cmd;
  static struct cmd_element neighbor_description_cmd;
  static struct cmd_element no_neighbor_description_cmd;
  static struct cmd_element no_neighbor_description_val_cmd;
  static struct cmd_element neighbor_nexthop_self_cmd;
  static struct cmd_element no_neighbor_nexthop_self_cmd;
  static struct cmd_element neighbor_send_community_cmd;
  static struct cmd_element no_neighbor_send_community_cmd;
  static struct cmd_element neighbor_send_community_type_cmd;
  static struct cmd_element no_neighbor_send_community_type_cmd;
  static struct cmd_element neighbor_weight_cmd;
  static struct cmd_element no_neighbor_weight_cmd;
  static struct cmd_element no_neighbor_weight_val_cmd;
  static struct cmd_element neighbor_soft_reconfiguration_cmd;
  static struct cmd_element no_neighbor_soft_reconfiguration_cmd;
  static struct cmd_element neighbor_route_reflector_client_cmd;
  static struct cmd_element no_neighbor_route_reflector_client_cmd;
  static struct cmd_element neighbor_route_server_client_cmd;
  static struct cmd_element no_neighbor_route_server_client_cmd;
  static struct cmd_element neighbor_capability_route_refresh_cmd;
  static struct cmd_element no_neighbor_capability_route_refresh_cmd;
  static struct cmd_element neighbor_transparent_as_cmd;
  static struct cmd_element no_neighbor_transparent_as_cmd;
  static struct cmd_element neighbor_transparent_nexthop_cmd;
  static struct cmd_element no_neighbor_transparent_nexthop_cmd;
  static struct cmd_element neighbor_dont_capability_negotiate_cmd;
  static struct cmd_element no_neighbor_dont_capability_negotiate_cmd;
  static struct cmd_element neighbor_override_capability_cmd;
  static struct cmd_element no_neighbor_override_capability_cmd;
  static struct cmd_element neighbor_strict_capability_cmd;
  static struct cmd_element no_neighbor_strict_capability_cmd;
  static struct cmd_element neighbor_timers_cmd;
  static struct cmd_element no_neighbor_timers_cmd;
  static struct cmd_element neighbor_timers_connect_cmd;
  static struct cmd_element no_neighbor_timers_connect_cmd;
  static struct cmd_element neighbor_version_cmd;
  static struct cmd_element no_neighbor_version_cmd;
  static struct cmd_element neighbor_prefix_list_cmd;
  static struct cmd_element no_neighbor_prefix_list_cmd;
  static struct cmd_element neighbor_filter_list_cmd;
  static struct cmd_element no_neighbor_filter_list_cmd;
  static struct cmd_element neighbor_route_map_cmd;
  static struct cmd_element no_neighbor_route_map_cmd;
  static struct cmd_element neighbor_maximum_prefix_cmd;
  static struct cmd_element no_neighbor_maximum_prefix_cmd;
  static struct cmd_element no_neighbor_maximum_prefix_val_cmd;
  static struct cmd_element neighbor_advertise_interval_cmd;
  static struct cmd_element no_neighbor_advertise_interval_cmd;
  static struct cmd_element clear_ip_bgp_all_cmd;
  static struct cmd_element clear_ip_bgp_peer_cmd;
  static struct cmd_element clear_ip_bgp_as_cmd;
  static struct cmd_element clear_ip_bgp_peer_soft_in_cmd;
  static struct cmd_element clear_ip_bgp_peer_in_cmd;
  static struct cmd_element clear_ip_bgp_as_soft_in_cmd;
  static struct cmd_element clear_ip_bgp_as_in_cmd;
  static struct cmd_element clear_ip_bgp_all_soft_in_cmd;
  static struct cmd_element clear_ip_bgp_all_in_cmd;
  static struct cmd_element clear_ip_bgp_peer_soft_out_cmd;
  static struct cmd_element clear_ip_bgp_peer_out_cmd;
  static struct cmd_element clear_ip_bgp_as_soft_out_cmd;
  static struct cmd_element clear_ip_bgp_as_out_cmd;
  static struct cmd_element clear_ip_bgp_all_soft_out_cmd;
  static struct cmd_element clear_ip_bgp_all_out_cmd;
  static struct cmd_element clear_ip_bgp_peer_soft_cmd;
  static struct cmd_element clear_ip_bgp_as_soft_cmd;
  static struct cmd_element clear_ip_bgp_all_soft_cmd;
  static struct cmd_element show_ip_bgp_summary_cmd;
  static struct cmd_element show_ip_bgp_neighbors_cmd;
  static struct cmd_element show_ip_bgp_neighbors_peer_cmd;
  static struct cmd_element show_ip_bgp_paths_cmd;
  static struct cmd_element show_ip_bgp_community_info_cmd;
  static struct cmd_element show_ip_bgp_attr_info_cmd;
  static struct cmd_element show_startup_config_cmd;
  static struct cmd_element config_log_file_cmd;
  static struct cmd_element no_config_log_file_cmd;
  static struct cmd_element access_list_cmd;
  static struct cmd_element access_list_exact_cmd;
  static struct cmd_element no_access_list_cmd;
  static struct cmd_element no_access_list_exact_cmd;
  static struct cmd_element no_access_list_all_cmd;
  static struct cmd_element access_list_remark_cmd;
  static struct cmd_element no_access_list_remark_cmd;
  static struct cmd_element no_access_list_remark_arg_cmd;
  static struct cmd_element show_memory_all_cmd;
  static struct cmd_element show_memory_cmd;
  static struct cmd_element show_memory_lib_cmd;
  static struct cmd_element show_memory_bgp_cmd;
  static struct cmd_element ip_prefix_list_cmd;
  static struct cmd_element ip_prefix_list_ge_cmd;
  static struct cmd_element ip_prefix_list_ge_le_cmd;
  static struct cmd_element ip_prefix_list_le_cmd;
  static struct cmd_element ip_prefix_list_le_ge_cmd;
  static struct cmd_element ip_prefix_list_seq_cmd;
  static struct cmd_element ip_prefix_list_seq_ge_cmd;
  static struct cmd_element ip_prefix_list_seq_ge_le_cmd;
  static struct cmd_element ip_prefix_list_seq_le_cmd;
  static struct cmd_element ip_prefix_list_seq_le_ge_cmd;
  static struct cmd_element no_ip_prefix_list_cmd;
  static struct cmd_element no_ip_prefix_list_prefix_cmd;
  static struct cmd_element no_ip_prefix_list_ge_cmd;
  static struct cmd_element no_ip_prefix_list_ge_le_cmd;
  static struct cmd_element no_ip_prefix_list_le_cmd;
  static struct cmd_element no_ip_prefix_list_le_ge_cmd;
  static struct cmd_element no_ip_prefix_list_seq_cmd;
  static struct cmd_element no_ip_prefix_list_seq_ge_cmd;
  static struct cmd_element no_ip_prefix_list_seq_ge_le_cmd;
  static struct cmd_element no_ip_prefix_list_seq_le_cmd;
  static struct cmd_element no_ip_prefix_list_seq_le_ge_cmd;
  static struct cmd_element ip_prefix_list_sequence_number_cmd;
  static struct cmd_element no_ip_prefix_list_sequence_number_cmd;
  static struct cmd_element ip_prefix_list_description_cmd;
  static struct cmd_element no_ip_prefix_list_description_cmd;
  static struct cmd_element no_ip_prefix_list_description_arg_cmd;
  static struct cmd_element show_ip_prefix_list_cmd;
  static struct cmd_element show_ip_prefix_list_name_cmd;
  static struct cmd_element show_ip_prefix_list_name_seq_cmd;
  static struct cmd_element show_ip_prefix_list_prefix_cmd;
  static struct cmd_element show_ip_prefix_list_prefix_longer_cmd;
  static struct cmd_element show_ip_prefix_list_prefix_first_match_cmd;
  static struct cmd_element show_ip_prefix_list_summary_cmd;
  static struct cmd_element show_ip_prefix_list_summary_name_cmd;
  static struct cmd_element show_ip_prefix_list_detail_cmd;
  static struct cmd_element show_ip_prefix_list_detail_name_cmd;
  static struct cmd_element clear_ip_prefix_list_cmd;
  static struct cmd_element clear_ip_prefix_list_name_cmd;
  static struct cmd_element clear_ip_prefix_list_name_prefix_cmd;
  static struct cmd_element route_map_cmd;
  static struct cmd_element no_route_map_all_cmd;
  static struct cmd_element no_route_map_cmd;
  static struct cmd_element rmap_onmatch_next_cmd;
  static struct cmd_element no_rmap_onmatch_next_cmd;
  static struct cmd_element rmap_onmatch_goto_cmd;
  static struct cmd_element no_rmap_onmatch_goto_cmd;
  static struct route_map_rule_cmd route_match_ip_address_cmd ; 
  static struct route_map_rule_cmd route_match_ip_next_hop_cmd ;    
  static struct route_map_rule_cmd route_match_ip_address_prefix_list_cmd ;
  static struct route_map_rule_cmd route_match_ip_next_hop_prefix_list_cmd ;
  static struct route_map_rule_cmd route_match_metric_cmd ; 
  static struct route_map_rule_cmd route_match_aspath_cmd ; 
  static struct route_map_rule_cmd route_match_community_cmd ;
  static struct route_map_rule_cmd route_set_aggregator_as_cmd ; 
  static struct route_map_rule_cmd route_set_aspath_prepend_cmd ; 
  static struct route_map_rule_cmd route_set_atomic_aggregate_cmd ; 
  static struct route_map_rule_cmd route_set_community_additive_cmd ; 
  static struct route_map_rule_cmd route_set_community_cmd ; 
  static struct route_map_rule_cmd route_set_community_delete_cmd ; 
  static struct route_map_rule_cmd route_set_ecommunity_rt_cmd; 
  static struct route_map_rule_cmd route_set_ecommunity_soo_cmd ;  
  static struct route_map_rule_cmd route_set_ip_nexthop_cmd ; 
  static struct route_map_rule_cmd route_set_local_pref_cmd ; 
  static struct route_map_rule_cmd route_set_metric_cmd ; 
  static struct route_map_rule_cmd route_set_origin_cmd ; 
  static struct route_map_rule_cmd route_set_originator_id_cmd; 
  static struct route_map_rule_cmd route_set_weight_cmd ; 


  /* bgpd program name. */
  static char *progname;

  /* Master of threads. */
  struct thread_master *master;

  //bgp_aspath.c///////////////////////////    
    
  /* Hash for aspath.  This is the top level structure of AS path. */
  static struct Hash *ashash; 

  //bgp_attr.c//////////////////////////    

  /* Attribute strings for logging. */
  static struct message attr_str[16] ;

  static struct Hash *cluster_hash;

  /* Unknown transit attribute. */
  static struct Hash *transit_hash;      

  /* Attribute hash routines. */
  static struct Hash *attrhash;


  //bgp_clist.c//////////////////////////    
  struct community_list_master community_list_master; 

  //bgp_community.c//////////////////////////    

  /* Hash of community attribute. */
  static struct Hash *comhash;

  //bgp_damp.c//////////////////////////    

#ifndef HAVE_ZEBRA_93b
  /* Global variable to access damping configuration */
  struct bgp_damp_config bgp_damp_cfg;
  int reuse_array_offset ;
  struct thread *bgp_reuse_thread ;
  struct bgp_damp_config *prev_bgp_damp_cfg ;
#else
  /* Global variable to access damping configuration */
  struct bgp_damp_config bgp_damp_cfg;
  struct bgp_damp_config *damp;
#endif /*HAVE_ZEBRA_93b*/

  //bgp_debug.c//////////////////////////    

  unsigned long conf_bgp_debug_fsm;
  unsigned long conf_bgp_debug_events;
  unsigned long conf_bgp_debug_packet;
  unsigned long conf_bgp_debug_filter;
  unsigned long conf_bgp_debug_keepalive;
  unsigned long conf_bgp_debug_update;
  unsigned long conf_bgp_debug_normal;

  unsigned long term_bgp_debug_fsm;
  unsigned long term_bgp_debug_events;
  unsigned long term_bgp_debug_packet;
  unsigned long term_bgp_debug_filter;
  unsigned long term_bgp_debug_keepalive;
  unsigned long term_bgp_debug_update;
  unsigned long term_bgp_debug_normal;

  /* messages for BGP-4 status */
  static struct message bgp_status_msg[7] ;
  static int bgp_status_msg_max  ;

  /* BGP message type string. */
  static char *bgp_type_str[6] ;

  /* message for BGP-4 Notify */
  static struct message bgp_notify_msg[7] ;
  static int bgp_notify_msg_max  ;

  static struct message bgp_notify_head_msg[4] ;
  static int bgp_notify_head_msg_max ;

  static struct message bgp_notify_open_msg[8] ;
  static int bgp_notify_open_msg_max  ;

  static struct message bgp_notify_update_msg[12]; 
  static int bgp_notify_update_msg_max  ;

  /* Origin strings. */
  static char *bgp_origin_str[3] ;
  static char *bgp_origin_long_str[3] ;

  //bgp_route.c//////////////////////////
  
  /* Static annoucement peer. */
  struct peer *peer_self;
  /* Not used */
  struct bgp_table *bgp_distance_table;

  //bgp_dump.c//////////////////////////    

  /* BGP packet dump output buffer. */
  struct stream *bgp_dump_obuf;

  /* BGP dump strucuture for 'dump bgp all' */
  struct bgp_dump bgp_dump_all;

  /* BGP dump structure for 'dump bgp updates' */
  struct bgp_dump bgp_dump_updates;

  /* BGP dump structure for 'dump bgp routes' */
  struct bgp_dump bgp_dump_routes;

  /* Dump whole BGP table is very heavy process.  */
  struct thread *t_bgp_dump_routes;

  //bgp_ecommunity.c//////////////////////////    

  /* Hash of community attribute. */
  static struct Hash *ecomhash;

  //bgp_filter.c//////////////////////////    

  /* ip as-path access-list 10 permit AS1. */
  struct as_list_master as_list_master  ;

  //bgp_fsm.c//////////////////////////    

  /* Finite State Machine structure */
  static struct fsm_struct FSM [BGP_STATUS_MAX - 1][BGP_EVENTS_MAX - 1] ;
  static char *bgp_event_str[14] ;


  //bgpd.c/////////////////////////////////
  struct llist *bgp_list;
  struct llist *peer_list;

  //command.c//////////////////////////    
  /* Command vector which includes some level of command lists. Normally
     each daemon maintains each own cmdvec. */
  static struct _vector* cmdvec;
  static bool cmdvec_init;
  static bool bgp_attr_initialize;

  /* Host information structure. */
  struct host host;

  static struct cmd_node config_node ;
  //log.c//////////////////////////    
  struct zlog *zlog_default ;
  static char *zlog_proto_names[10];
  static char *zlog_priority[9];

  //distribute.c//////////////////////////

  /* Hash of distribute list. */
  struct Hash *disthash;
  void (Bgp::*distribute_add_hook) (struct distribute *);
  void (Bgp::*distribute_delete_hook) (struct distribute *);

  //filter.c//////////////////////////    

  /* Static structure for IPv4 access_list's master. */
  struct access_master access_master_ipv4 ; 

  //memory.c//////////////////////////

  static struct message mstr[6] ; 
#ifdef MEMORY_LOG
  struct
  {
    char *name;
    unsigned long alloc;
    unsigned long t_malloc;
    unsigned long c_malloc;
    unsigned long t_calloc;
    unsigned long c_calloc;
    unsigned long t_realloc;
    unsigned long t_free;
    unsigned long c_strdup;
  } mstat [MTYPE_MAX];
#else
  struct
  {
    char *name;
    unsigned long alloc;
  } mstat [MTYPE_MAX];
#endif /* MTPYE_LOG */

  static struct memory_list memory_list_lib[28];
#ifndef HAVE_ZEBRA_93b
  static struct memory_list memory_list_bgp[25] ;
#else
  static struct memory_list memory_list_bgp[28] ;
#endif
  static struct memory_list memory_list_separator[2]; 

  //plist.c//////////////////////////
  struct prefix_master prefix_master_ipv4;  

  //prefix.c//////////////////////////
  static u_char maskbit[9] ;

  //routemap.c//////////////////////////
  /* Vector for route match rules. */
  static struct cmd_node rmap_node;
  static struct _vector* route_match_vec;

  /* Vector for route set rules. */
  static struct _vector* route_set_vec;
  struct route_map_list route_map_master ;

  ////////////////////////////////////////////////////////////
  ///////////bgp_aspath///////////////////////////////////////
  ////////////////////////////////////////////////////////////
  struct aspath * aspath_add_one_as(struct aspath *,as_t,u_char);
  char aspath_delimiter_char(u_char,u_char);
  struct aspath * aspath_new();
  void aspath_free(struct aspath *);
  void aspath_unintern(struct aspath *);
  char *aspath_make_str_count(struct aspath *);
  struct aspath * aspath_intern(struct aspath *);
  struct aspath * aspath_dup(struct aspath *);
  struct aspath * aspath_parse(caddr_t,int);
  struct aspath * aspath_aggregate_segment_copy(struct aspath *,struct assegment *,int);
  struct assegment * aspath_aggregate_as_set_add(struct aspath *,struct assegment *,as_t);
  struct aspath * aspath_aggregate(struct aspath *,struct aspath *);
  int aspath_loop_check(struct aspath *,as_t);
  int aspath_firstas_check(struct aspath *,as_t);
  struct aspath * aspath_merge(struct aspath *,struct aspath *);
  struct aspath * aspath_prepend(struct aspath *,struct aspath *);
  struct aspath * aspath_add_seq(struct aspath *,as_t);
  int aspath_cmp_left(struct aspath *,struct aspath *);
  int aspath_cmp_left_confed(struct aspath *,struct aspath *);
  struct aspath * aspath_delete_confed_seq(struct aspath *);
  struct aspath * aspath_add_confed_seq(struct aspath *,as_t);
  void aspath_as_add(struct aspath *,as_t);
  void aspath_segment_add(struct aspath *,int);
  struct aspath * aspath_empty();
  unsigned long aspath_count();
  char *aspath_gettoken(char *,enum as_token *,u_short *);
  struct aspath * aspath_str2aspath(char *);
  static unsigned int aspath_key_make(struct aspath *);
  static int aspath_cmp(struct aspath *,struct aspath *);
  void aspath_init();
  const char *aspath_print(struct aspath *);
  void aspath_print_vty(struct vty *,struct aspath *);
  void aspath_print_all_vty(struct vty *);
  void aspath_aggr_test();
  void aspath_delete(struct aspath*);
  ////////////////////////////////////////////////////////////
  ///////////bgp_attr.c///////////////////////////////////////
  ////////////////////////////////////////////////////////////

  struct cluster_list *  cluster_parse(caddr_t,int);
  int  cluster_loop_check(struct cluster_list *,struct in_addr);
  static unsigned int  cluster_hash_key_make(struct cluster_list *);
  static int  cluster_hash_cmp (struct cluster_list *, struct cluster_list *);
  void  cluster_free(struct cluster_list *);
  struct cluster_list *  cluster_dup(struct cluster_list *);
  struct cluster_list *  cluster_intern(struct cluster_list *);
  void  cluster_unintern(struct cluster_list *);
  void  cluster_init();
  void  transit_free(struct transit *);
  struct transit *  transit_intern(struct transit *);
  void  transit_unintern(struct transit *);
  static unsigned int  transit_hash_key_make(struct transit *);
  static int  transit_hash_cmp(struct transit *,struct transit *);
  void transit_init();
  static unsigned int  attrhash_key_make(struct attr *);
  static int  attrhash_cmp(struct attr *,struct attr *);
  void  attrhash_init();
  void attr_dump_vty(struct vty *,struct attr *);
  void attrhash_dump(struct vty *);
  struct attr * bgp_attr_intern(struct attr *);
  struct attr * bgp_attr_default_set(struct attr *,u_char);
  struct attr * bgp_attr_default_intern(u_char);
  struct attr * bgp_attr_aggregate_intern(struct bgp *,u_char,struct aspath *,struct community *,int);
  void bgp_attr_unintern(struct attr *);
  void bgp_attr_flush(struct attr *);
  int bgp_attr_origin(struct peer *,bgp_size_t,struct attr *,u_char,u_char *);
  int bgp_attr_aspath(struct peer *,bgp_size_t,struct attr *,u_char,u_char *);
  int bgp_attr_nexthop(struct peer *,bgp_size_t,struct attr *,u_char,u_char *);
  int bgp_attr_med(struct peer *,bgp_size_t,struct attr *,u_char,u_char *);
  int bgp_attr_local_pref(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_atomic(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_aggregator(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_community(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_originator_id(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_cluster_list(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_mp_reach_parse(struct peer *,bgp_size_t,struct attr *,struct bgp_nlri *);
  int bgp_mp_unreach_parse(struct peer *,int,struct bgp_nlri *);
  int bgp_attr_ext_communities(struct peer *,bgp_size_t,struct attr *,u_char);
  int bgp_attr_unknown(struct peer *,struct attr *,u_char,u_char,bgp_size_t,u_char *);
  int bgp_attr_parse(struct peer *,struct attr *,bgp_size_t,struct bgp_nlri *,struct bgp_nlri *);
  int bgp_attr_check(struct peer *,struct attr *);
  bgp_size_t bgp_packet_attribute(struct peer_conf *,struct peer *,struct stream *,struct attr *,struct prefix *,afi_t,safi_t,struct peer *,struct prefix_rd *,u_char *);
  bgp_size_t bgp_packet_withdraw(struct peer *,struct stream *,struct prefix *,afi_t,safi_t,struct prefix_rd *,u_char *);
#ifdef HAVE_ZEBRA_93b
  struct stream *bgp_withdraw_packet (struct peer *peer, afi_t afi, safi_t safi);
  int bgp_write_proceed (struct peer *peer);
#endif

  void bgp_attr_init();
  void bgp_dump_routes_attr(struct stream *,struct attr *);


  ////////////////////////////////////////////////////////////
  ////////////////////bgp_clist.c ////////////////////////////////////////

  struct community_entry * community_entry_new();
  void community_entry_free(struct community_entry *);
  struct community_entry * community_entry_make(struct community *,enum community_entry_type);
  struct community_list * community_list_new();
  void community_list_free(struct community_list *);
  struct community_list * community_list_insert(char *);
  struct community_list * community_list_lookup(char *);
  struct community_list * community_list_get(char *);
  struct community_entry * community_entry_lookup(struct community_list *,struct community *,enum community_entry_type);
  struct community_entry * community_entry_regexp_lookup(struct community_list *,char *,enum community_entry_type);
  void community_list_entry_add(struct community_list *,struct community_entry *);
  void community_list_delete(struct community_list *);
  int community_list_empty(struct community_list *);
  void community_list_entry_delete(struct community_list *,struct community_entry *);
  int community_match_regexp(struct community_entry *,struct community *);
  struct community * community_delete_regexp(struct community *,regex_t *);
  struct community * community_list_delete_entries(struct community *,struct community_list *);
  int community_list_match(struct community *,struct community_list *);
  int community_list_match_exact(struct community *,struct community_list *);
  char *community_type_str(enum community_entry_type);
  void community_list_print(struct community_list *);
  int community_list_dup_check(struct community_list *,struct community_entry *);
  int ip_community_list(struct cmd_element *,struct vty *,int,char **);
  int no_ip_community_list(struct cmd_element *,struct vty *,int,char **);
  int no_ip_community_list_all(struct cmd_element *,struct vty *,int,char **);
  void community_list_init();
  void community_list_test() ;

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_community.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  struct community * community_new();
  void community_free(struct community *);
  void community_add_val(struct community *,u_int32_t);
  void community_del_val(struct community *,u_int32_t *);
  struct community * community_delete(struct community *,struct community *);
  static int community_compare(const void *,const void *);
  int community_include(struct community *,u_int32_t);
  u_int32_t community_val_get(struct community *,int);
  struct community * community_uniq_sort(struct community *);
  struct community * community_parse(char *,u_short);
  struct community * community_dup(struct community *);
  struct community * community_intern(struct community *);
  void community_unintern(struct community *);
  const char *community_print(struct community *);
  static unsigned int community_hash_make(struct community *);
  int community_match(struct community *,struct community *);
  static int community_cmp(struct community *,struct community *);
  struct community * community_merge(struct community *,struct community *);
  void community_init();
  void community_print_vty(struct vty *,struct community *);
  void community_print_all_vty(struct vty *);
  u_char *community_gettoken(char *,enum community_token *,u_int32_t *);
  struct community * community_str2com(char *);
  unsigned long community_count();
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_damp.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
#ifndef HAVE_ZEBRA_93b
  int bgp_damp_init(struct vty *,int,int,int,int);
  int bgp_reuse_timer(struct thread *);
  int bgp_damp_withdraw(struct bgp_info *);
  int bgp_damp_update(struct bgp_info *);
  int bgp_damp_enable(struct vty *,int,char **);
  int bgp_damp_disable(struct vty *);
  void bgp_damp_clear_config(struct bgp_damp_config *);
  void bgp_damp_clear_reuse_list();
  int bgp_config_write_damp(struct vty *);
  int bgp_damp_info_print(struct vty *,struct bgp_info *) ; 
  double bgp_damp_get_decay(time_t);
  int bgp_get_reuse_index(int);
  void bgp_reuse_list_insert(struct bgp_damp_info *);
#else 

  int 
    clear_ip_bgp_dampening(struct cmd_element *,
			   struct vty *,int,char **);

  int 
    clear_ip_bgp_dampening_prefix(struct cmd_element *,
				  struct vty *,int,char **);

  int 
    clear_ip_bgp_dampening_address(struct cmd_element *,
				   struct vty *,int,char **);

  int 
    clear_ip_bgp_dampening_address_mask(struct cmd_element *,
					struct vty *,int,char **);

  int
    bgp_clear_damp_route (struct vty *vty, char *view_name, char *ip_str,
			  afi_t afi, safi_t safi, struct prefix_rd *prd,
			  int prefix_check);

  int
    bgp_reuse_index (int penalty);

  void 
    bgp_reuse_list_add (struct bgp_damp_info *bdi);

  void
    bgp_reuse_list_delete (struct bgp_damp_info *bdi);

  int 
    bgp_damp_decay (time_t tdiff, int penalty);

  int
    bgp_reuse_timer (struct thread *t);

  int
    bgp_damp_withdraw (struct bgp_info *binfo, struct bgp_node *rn,
		       afi_t afi, safi_t safi, int attr_change);
  int
    bgp_damp_update (struct bgp_info *binfo, struct bgp_node *rn, 
		     afi_t afi, safi_t safi);
  int 
    bgp_damp_scan (struct bgp_info *binfo, afi_t afi, safi_t safi);

  void
    bgp_damp_info_free (struct bgp_damp_info *bdi, int withdraw);

  void
    bgp_damp_parameter_set (int hlife, int reuse, int sup, int maxsup);

  int
    bgp_damp_enable (struct bgp *bgp, afi_t afi, safi_t safi, int half,
		     int reuse, int suppress, int max);
  void
    bgp_damp_config_clean (struct bgp_damp_config *damp);

  void
    bgp_damp_info_clean ();

  int
    bgp_damp_disable (struct bgp *bgp, afi_t afi, safi_t safi);

  int
    bgp_config_write_damp (struct vty *vty);

  char *
    bgp_get_reuse_time (int penalty, char *buf, size_t len);

  void
    bgp_damp_info_vty (struct vty *vty, struct bgp_info *binfo);  

  char *
    bgp_damp_reuse_time_vty (struct vty *vty, struct bgp_info *binfo);

#endif 

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_debug.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
  void bgp_dump_attr(struct peer *,struct attr *,char *,size_t);
  void bgp_notify_print(struct peer *,struct bgp_notify *,char *);
  void bgp_packet_open_dump(struct stream *);
  void bgp_packet_notify_dump(struct stream *);
  void bgp_update_dump(struct stream *);
  void bgp_packet_dump(struct stream *);
  int debug_bgp_fsm(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_fsm(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_events(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_events(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_filter(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_filter(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_keepalive(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_keepalive(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_update(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_update_direct(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_update(struct cmd_element *,struct vty *,int,char **);
  int debug_bgp_normal(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_normal(struct cmd_element *,struct vty *,int,char **);
  int no_debug_bgp_all(struct cmd_element *,struct vty *,int,char **);
  int show_debugging_bgp(struct cmd_element *,struct vty *,int,char **);
  void bgp_debug_init();


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_dump.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
  FILE *bgp_dump_open_file(struct bgp_dump *);
  int bgp_dump_interval_add(struct bgp_dump *,int);
  void bgp_dump_header(struct stream *,int,int);
  void bgp_dump_set_size(struct stream *,int);
  void bgp_dump_routes_entry(struct prefix *,struct bgp_info *,int,int,unsigned int);
  void bgp_dump_routes_func(int);
  int bgp_dump_interval_func(struct thread *);
  void check_convergence(int);
  void bgp_dump_common(struct stream *,struct peer *);
  void bgp_dump_state(struct peer *,int,int);
  void bgp_dump_packet_func(struct bgp_dump *,struct peer *,struct stream *);
  void bgp_dump_packet(struct peer *,int,struct stream *);
  unsigned int bgp_dump_parse_time(char *);
  int bgp_dump_set(struct vty *,struct bgp_dump *,int,char *,char *);
  int bgp_dump_unset(struct vty *,struct bgp_dump *);
  int dump_bgp_all(struct cmd_element *,struct vty *,int,char **);
  int dump_bgp_all_interval(struct cmd_element *,struct vty *,int,char **);
  int no_dump_bgp_all(struct cmd_element *,struct vty *,int,char **);
  int dump_bgp_updates(struct cmd_element *,struct vty *,int,char **);
  int dump_bgp_updates_interval(struct cmd_element *,struct vty *,int,char **);
  int no_dump_bgp_updates(struct cmd_element *,struct vty *,int,char **);
  int dump_bgp_routes(struct cmd_element *,struct vty *,int,char **);
  int dump_bgp_routes_interval(struct cmd_element *,struct vty *,int,char **);
  int no_dump_bgp_routes(struct cmd_element *,struct vty *,int,char **);
  void bgp_dump_init();

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_ecommunity.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 

  struct ecommunity * ecommunity_new();
  void ecommunity_free(struct ecommunity *);
  struct ecommunity * ecommunity_parse(char *,u_short);
  struct ecommunity * ecommunity_dup(struct ecommunity *);
  struct ecommunity * ecommunity_merge(struct ecommunity *,struct ecommunity *);
  struct ecommunity * ecommunity_intern(struct ecommunity *);
  void ecommunity_unintern(struct ecommunity *);
  static unsigned int ecommunity_hash_make(struct ecommunity *);
  static int ecommunity_cmp(struct ecommunity *,struct ecommunity *);
  void ecommunity_init();
  u_char *ecommunity_gettoken(char *,enum ecommunity_token *,struct ecommunity_as *,struct ecommunity_ip *);
  void ecommunity_add_val(struct ecommunity *,int,enum ecommunity_token,struct ecommunity_as *,struct ecommunity_ip *);
  struct ecommunity * ecommunity_str2com(int,char *);
  void ecommunity_print(struct ecommunity *);
  void ecommunity_vty_out(struct ecommunity *);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_filter.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 

  int as_filter_match(struct as_filter *,struct aspath *);
  int as_list_empty(struct as_list *);
  char *filter_type_str(enum as_filter_type);
  //Globs   
  struct as_filter * as_filter_new();
  void as_filter_free(struct as_filter *);
  struct as_filter * as_filter_make(regex_t *,char *,enum as_filter_type);
  struct as_filter * as_filter_lookup(struct as_list *,char *,enum as_filter_type);
  void as_list_filter_add(struct as_list *,struct as_filter *);
  struct as_list * as_list_lookup(char *);
  struct as_list * as_list_new();
  void as_list_free(struct as_list *);
  struct as_list * as_list_insert(char *);
  struct as_list * as_list_get(char *);
  void as_list_print(struct as_list *);
  void as_list_print_all();
  void as_list_delete(struct as_list *);
  void as_list_filter_delete(struct as_list *,struct as_filter *);
  enum as_filter_type as_list_apply(struct as_list *,void *);
  void as_list_add_hook(void ( Bgp::*) ( ));
  void as_list_delete_hook(void ( Bgp::*) ( ));
  int as_list_dup_check(struct as_list *,struct as_filter *);
  int ip_as_path(struct cmd_element *,struct vty *,int,char **);
  int no_ip_as_path(struct cmd_element *,struct vty *,int,char **);
  int no_ip_as_path_all(struct cmd_element *,struct vty *,int,char **);
  void bgp_filter_init();
  void bgp_filter_test();


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_fsm.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
  int bgp_connect_timer(struct thread *);
  int bgp_holdtime_timer(struct thread *);
  int bgp_keepalive_timer(struct thread *);
  int bgp_start_timer(struct thread *);
  void bgp_uptime_reset(struct peer *);
  double bgp_start_jitter(int);
  void bgp_timer_set(struct peer *);
  int bgp_stop(struct peer *) ; 
  int bgp_stop_with_error(struct peer *);
  int bgp_connect_success(struct peer *);
  int bgp_connect_fail(struct peer *);
  int bgp_start(struct peer *);
  int bgp_reconnect(struct peer *);
  int fsm_open(struct peer *);
  void fsm_change_status(struct peer *,int);
  int fsm_keepalive_expire(struct peer *);
  int fsm_holdtime_expire(struct peer *);
  int bgp_establish(struct peer *);
  int fsm_keepalive(struct peer *);
  int fsm_update(struct peer *);
  int bgp_ignore(struct peer *);
  int bgp_event(struct thread *) ;

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_network.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 


  struct agent_index GetLocalIndex(FullTcpAgent *);
  struct agent_index GetRemoteIndex(FullTcpAgent *);
  Bgp* Index2Bgp (struct agent_index*);    
#ifdef HAVE_PDNS_BGP
  bool is_session_local(FullTcpAgent *tcp);
#endif
  int bgp_connect(struct peer *);
  int bgp_accept(struct thread *);
  void bgp_serv_sock_family();
  void bgp_getsockname(struct peer *) ;


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_open.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
      
  void bgp_capability_mp_log(struct peer *,struct capability *,char *);
  void bgp_capability_vty_out(struct vty *,struct peer *);
  int bgp_capability_mp(struct peer *,struct capability *);
  int bgp_capability_parse(struct peer *,u_char *,u_char,u_char **);
  int bgp_auth_parse(struct peer *,u_char *,size_t);
  int strict_capability_same(struct peer *);
  int bgp_open_option_parse(struct peer *,u_char,int *);
  void bgp_open_capability(struct stream *,struct peer *) ;
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_packet.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
      
  void bgp_packet_add(struct peer *,struct stream *);
  void bgp_packet_delete(struct peer *);
  int bgp_packet_set_marker( struct stream *s, u_char type );
  int bgp_packet_set_size(struct stream *s, bgp_size_t size);
  struct stream * bgp_packet_dup(struct stream *);
  int bgp_write(struct thread *);
  int bgp_write_notify(struct peer *);
#ifdef HAVE_ZEBRA_93b
  struct stream *bgp_write_packet (struct peer *peer);
  struct stream *bgp_update_packet (struct peer *peer, afi_t afi, safi_t safi);
#endif
  void bgp_keepalive_send(struct peer *);
  void bgp_open_send(struct peer *);
  void bgp_notify_send_with_data(struct peer *,u_char,u_char,u_char *,size_t);
  void bgp_notify_send(struct peer *,u_char,u_char);
  void bgp_update_send(struct peer_conf *,struct peer *,struct prefix *,struct attr *,afi_t,safi_t,struct peer *,struct prefix_rd *,u_char *);
  void bgp_withdraw_send(struct peer *,struct prefix *,afi_t,safi_t,struct prefix_rd *,u_char *);
  char *afi2str(afi_t);
  char *safi2str(safi_t);
  void bgp_route_refresh_send(struct peer *,afi_t,safi_t);
  int bgp_collision_detect(struct peer *,struct in_addr);
  int bgp_open_receive(struct peer *,bgp_size_t);
  int bgp_update_receive(struct peer *,bgp_size_t);
  void bgp_notify_receive(struct peer *,bgp_size_t);
  void bgp_keepalive_receive(struct peer *,bgp_size_t);
  void bgp_route_refresh_receive(struct peer *,bgp_size_t);
  int bgp_read_packet(struct peer *);
  int bgp_marker_all_one(struct stream *,int);
  int bgp_read(struct thread *);
  void bgp_connect_check (struct peer *peer);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_regexp.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 

  regex_t *bgp_regcomp(char *);
  int bgp_regexec(regex_t *,struct aspath *);
  void bgp_regex_free(regex_t *) ;

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_route.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 

  struct bgp_node * bgp_route_node_get(struct bgp *,afi_t,safi_t,struct prefix *,struct prefix_rd *);
  struct bgp_info * bgp_info_new();
  void bgp_info_free(struct bgp_info *);
  void bgp_info_add(struct bgp_info **,struct bgp_info *);
  void bgp_info_delete(struct bgp_info **,struct bgp_info *);
  u_int32_t bgp_med_value(struct attr *,struct bgp *);
  int bgp_info_cmp(struct bgp *,struct bgp_info *,struct bgp_info *);
  enum filter_type bgp_input_filter(struct peer_conf *,struct prefix *,struct attr *,afi_t,safi_t);
  enum filter_type bgp_output_filter(struct peer_conf *,struct prefix *,struct attr *,afi_t,safi_t);
  int bgp_community_filter(struct peer *,struct attr *);
  int bgp_cluster_filter(struct peer_conf *,struct attr *);
  void bgp_reset();
  int bgp_input_modifier(struct peer *,struct peer_conf *,struct prefix *,struct attr *,afi_t,safi_t);
  int bgp_adj_set(struct bgp_table *,struct prefix *,struct attr *,struct prefix_rd *,safi_t);
  int bgp_adj_unset(struct bgp_table *,struct prefix *,struct prefix_rd *,safi_t);
  int bgp_adj_lookup(struct bgp_table *,struct prefix *,struct prefix_rd *,safi_t);
  void bgp_adj_clear(struct bgp_table *,safi_t);
  int bgp_announce_check(struct bgp_info *,struct peer_conf *,struct prefix *,struct attr *,afi_t,safi_t);
#ifndef HAVE_ZEBRA_93b
  void bgp_refresh_rib(struct peer_conf *,afi_t,safi_t);
  void bgp_announce_table(struct peer *);
  void bgp_announce_rib(struct peer_conf *,afi_t,safi_t);
  void bgp_refresh_table(struct peer *,afi_t,safi_t);
#else
  void bgp_announce_table (struct peer *peer, afi_t afi, safi_t safi, struct bgp_table *table);
  void bgp_announce_route (struct peer *peer, afi_t afi, safi_t safi);
  void bgp_announce_route_all (struct peer *peer);
#endif
  int bgp_process(struct bgp *,struct bgp_node *,afi_t,safi_t,struct bgp_info *,struct prefix_rd *,u_char *);
  int bgp_maximum_prefix_overflow(struct peer_conf *,afi_t,safi_t);
  void bgp_implicit_withdraw(struct peer_conf *,struct bgp *,struct prefix *,struct bgp_info *,struct bgp_node *,afi_t,safi_t);
  int bgp_update(struct peer *,struct prefix *,struct attr *,afi_t,safi_t,int,int,struct prefix_rd *,u_char *,int);
#ifndef HAVE_ZEBRA_93b
  int bgp_withdraw(struct peer *,struct prefix *,struct attr *,int,int,int,int,struct prefix_rd *,u_char *);
#else 
  int bgp_withdraw (struct peer *peer, struct prefix *p, struct attr *attr, 
		    int afi, int safi, int type, int sub_type, struct prefix_rd *prd,
		    u_char *tag);
#endif
  int nlri_parse(struct peer *,struct attr *,struct bgp_nlri *);
  int nlri_sanity_check(struct peer *,int,u_char *,bgp_size_t);
#ifndef HAVE_ZEBRA_93b
  void bgp_soft_reconfig_in(struct peer *,afi_t,safi_t);
  void bgp_route_clear(struct peer *);
#else 
  void bgp_soft_reconfig_in (struct peer *peer, afi_t afi, safi_t safi);
  void bgp_soft_reconfig_table (struct peer *peer, afi_t afi, safi_t safi,
				struct bgp_table *table);    
#endif
  void bgp_route_clear_with_afi(struct peer *,struct bgp *,afi_t,safi_t);
#ifdef HAVE_ZEBRA_93b
  void bgp_clear_route_table (struct peer *peer, afi_t afi, safi_t safi, struct bgp_table *table);
  void bgp_clear_route (struct peer *peer, afi_t afi, safi_t safi);
  void bgp_clear_route_all (struct peer *peer);
  void bgp_rib_remove (struct bgp_node *rn, struct bgp_info *ri, struct peer *peer, afi_t afi, safi_t safi);
  void bgp_rib_withdraw (struct bgp_node *rn, struct bgp_info *ri, struct peer *peer, afi_t afi, safi_t safi, int force);
#endif
  struct bgp_static * bgp_static_new();
  void bgp_static_free(struct bgp_static *);
  void bgp_static_update(struct bgp *,struct prefix *,u_int16_t,u_char);
  void bgp_static_withdraw(struct bgp *,struct prefix *,u_int16_t,u_char);
  int bgp_static_set(struct vty *,struct bgp *,char *,u_int16_t,u_char);
  int bgp_static_unset(struct vty *,struct bgp *,char *,u_int16_t,u_char);
  void bgp_static_delete(struct bgp *);
  afi_t bgp_node_afi(struct vty *);
  safi_t bgp_node_safi(struct vty *);
  int bgp_network(struct cmd_element *,struct vty *,int,char **);
  int bgp_network_mask(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_network(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_network_mask(struct cmd_element *,struct vty *,int,char **);
  struct bgp_aggregate * bgp_aggregate_new();
  void bgp_aggregate_free(struct bgp_aggregate *);
  void bgp_aggregate_route(struct bgp *,struct prefix *,struct bgp_info *,afi_t,safi_t,struct bgp_info *,struct bgp_aggregate *);
  void bgp_aggregate_increment(struct bgp *,struct prefix *,struct bgp_info *,afi_t,safi_t);
  void bgp_aggregate_decrement(struct bgp *,struct prefix *,struct bgp_info *,afi_t,safi_t);
  void bgp_aggregate_add(struct bgp *,struct prefix *,afi_t,safi_t,struct bgp_aggregate *);
  void bgp_aggregate_delete(struct bgp *,struct prefix *,afi_t,safi_t,struct bgp_aggregate *);
  int bgp_aggregate_set(struct vty *,char *,afi_t,safi_t,u_char,u_char);
  int bgp_aggregate_unset(struct vty *,char *,afi_t,safi_t);
  int aggregate_address(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_mask(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_summary_only(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_mask_summary_only(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_as_set(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_mask_as_set(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_as_set_summary(struct cmd_element *,struct vty *,int,char **);
  int aggregate_address_mask_as_set_summary(struct cmd_element *,struct vty *,int,char **);
  int no_aggregate_address(struct cmd_element *,struct vty *,int,char **);
  int no_aggregate_address_mask(struct cmd_element *,struct vty *,int,char **);
  void bgp_redistribute_add(struct prefix *,struct in_addr *,u_int32_t,u_char);
  void bgp_redistribute_delete(struct prefix *,u_char);
  void bgp_redistribute_withdraw(struct bgp *,afi_t,int);
  void route_vty_out_route(struct prefix *,struct vty *);
  int vty_calc_line(struct vty *,unsigned long);
  int route_vty_out(struct vty *,struct prefix *,struct bgp_info *,int,safi_t);
  void route_vty_out_tmp(struct vty *,struct prefix *,struct attr *,safi_t);
  void route_vty_out_detail(struct vty *,struct prefix *,struct bgp_info *,afi_t,safi_t);
  int bgp_show(struct vty *,char *,afi_t,safi_t,enum bgp_show_type);
  int bgp_show_route(struct vty *,char *,char *,afi_t,safi_t,int);
  int show_ip_bgp(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_ipv4(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_route(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_ipv4_route(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_prefix(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_ipv4_prefix(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_view(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_view_route(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_view_prefix(struct cmd_element *,struct vty *,int,char **);
  void bgp_show_regexp_clean(struct vty *);
  int bgp_show_regexp(struct vty *,int,char **,u_int16_t,u_char);
  int show_ip_bgp_regexp(struct cmd_element *,struct vty *,int,char **);
  int bgp_show_prefix_list(struct vty *,char *,u_int16_t,u_char);
  int show_ip_bgp_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int bgp_show_filter_list(struct vty *,char *,u_int16_t,u_char);
  int show_ip_bgp_filter_list(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_cidr_only(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_community_all(struct cmd_element *,struct vty *,int,char **);
  int bgp_show_community(struct vty *,int,char **,int,u_int16_t,u_char);
  int show_ip_bgp_community(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_ipv4_community(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_community_exact(struct cmd_element *,struct vty *,int,char **);
  int bgp_show_community_list(struct vty *,char *,int,u_int16_t,u_char);
  int show_ip_bgp_community_list(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_community_list_exact(struct cmd_element *,struct vty *,int,char **);
  void bgp_show_prefix_longer_clean(struct vty *);
  int bgp_show_prefix_longer(struct vty *,char *,u_int16_t,u_char);
  int show_ip_bgp_prefix_longer(struct cmd_element *,struct vty *,int,char **);
  void show_adj_route(struct vty *,struct peer *,afi_t,safi_t,int);
  int peer_adj_routes(struct vty *,char *,afi_t,safi_t,int);
  int show_ip_bgp_neighbor_advertised_route(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_neighbor_received_routes(struct cmd_element *,struct vty *,int,char **);
  void bgp_show_neighbor_route_clean(struct vty *);
  int bgp_show_neighbor_route(struct vty *,char *,u_int16_t,u_char);
  int show_ip_bgp_neighbor_routes(struct cmd_element *,struct vty *,int,char **);
  struct bgp_distance * bgp_distance_new();
  void bgp_distance_free(struct bgp_distance *);
  int bgp_distance_set(struct vty *,char *,char *,char *);
  int bgp_distance_unset(struct vty *,char *,char *,char *);
  void bgp_distance_reset();
  u_char bgp_distance_apply(struct prefix *,struct bgp_info *,struct bgp *);
  int bgp_distance(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_distance(struct cmd_element *,struct vty *,int,char **);
  int bgp_distance_source(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_distance_source(struct cmd_element *,struct vty *,int,char **);
  int bgp_distance_source_access_list(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_distance_source_access_list(struct cmd_element *,struct vty *,int,char **);
  int bgp_damp_set(struct cmd_element *,struct vty *,int,char **);
  int bgp_damp_unset(struct cmd_element *,struct vty *,int,char **);
  int bgp_config_write_network(struct vty *,struct bgp *,afi_t,safi_t,int *);
  int bgp_config_write_distance(struct vty *,struct bgp *);
  void bgp_route_init();

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgp_routemap.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////
  route_map_result_t route_match_ip_address(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_ip_address_compile(char *);
  void route_match_ip_address_free(void *);
  route_map_result_t route_match_ip_next_hop(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_ip_next_hop_compile(char *);
  void route_match_ip_next_hop_free(void *);
  route_map_result_t route_match_ip_address_prefix_list(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_ip_address_prefix_list_compile(char *);
  void route_match_ip_address_prefix_list_free(void *);
  route_map_result_t route_match_ip_next_hop_prefix_list(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_ip_next_hop_prefix_list_compile(char *);
  void route_match_ip_next_hop_prefix_list_free(void *);
  route_map_result_t route_match_metric(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_metric_compile(char *);
  void route_match_metric_free(void *);
  route_map_result_t route_match_aspath(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_aspath_compile(char *);
  void route_match_aspath_free(void *);
  route_map_result_t route_match_community(void *,struct prefix *,route_map_object_t,void *);
  void *route_match_community_compile(char *);
  void route_match_community_free(void *);
  route_map_result_t route_set_ip_nexthop(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_ip_nexthop_compile(char *);
  void route_set_ip_nexthop_free(void *);
  route_map_result_t route_set_local_pref(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_local_pref_compile(char *);
  void route_set_local_pref_free(void *);
  route_map_result_t route_set_weight(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_weight_compile(char *);
  void route_set_weight_free(void *);
  route_map_result_t route_set_metric(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_metric_compile(char *);
  void route_set_metric_free(void *);
  route_map_result_t route_set_aspath_prepend(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_aspath_prepend_compile(char *);
  void route_set_aspath_prepend_free(void *);
  route_map_result_t route_set_community(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_community_compile(char *);
  void route_set_community_free(void *);
  route_map_result_t route_set_community_additive(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_community_additive_compile(char *);
  void route_set_community_additive_free(void *);
  route_map_result_t route_set_community_delete(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_community_delete_compile(char *);
  void route_set_community_delete_free(void *);
  route_map_result_t route_set_ecommunity_rt(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_ecommunity_rt_compile(char *);
  void route_set_ecommunity_rt_free(void *);
  route_map_result_t route_set_ecommunity_soo(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_ecommunity_soo_compile(char *);
  void route_set_ecommunity_soo_free(void *);
  route_map_result_t route_set_origin(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_origin_compile(char *);
  void route_set_origin_free(void *);
  route_map_result_t route_set_atomic_aggregate(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_atomic_aggregate_compile(char *);
  void route_set_atomic_aggregate_free(void *);
  route_map_result_t route_set_aggregator_as(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_aggregator_as_compile(char *);
  void route_set_aggregator_as_free(void *);
  route_map_result_t route_set_originator_id(void *,struct prefix *,route_map_object_t,void *);
  void *route_set_originator_id_compile(char *);
  void route_set_originator_id_free(void *);
  int bgp_route_match_add(struct vty *,struct route_map_index *,char *,char *);
  int bgp_route_match_delete(struct vty *,struct route_map_index *,char *,char *);
  int bgp_route_set_add(struct vty *,struct route_map_index *,char *,char *);
  int bgp_route_set_delete(struct vty *,struct route_map_index *,char *,char *);
  void bgp_route_map_update(char*);
  int match_ip_address(struct cmd_element *,struct vty *,int,char **);
  int no_match_ip_address(struct cmd_element *,struct vty *,int,char **);
  int match_ip_next_hop(struct cmd_element *,struct vty *,int,char **);
  int no_match_ip_next_hop(struct cmd_element *,struct vty *,int,char **);
  int match_ip_address_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int no_match_ip_address_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int match_ip_next_hop_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int no_match_ip_next_hop_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int match_metric(struct cmd_element *,struct vty *,int,char **);
  int no_match_metric(struct cmd_element *,struct vty *,int,char **);
  int match_community(struct cmd_element *,struct vty *,int,char **);
  int no_match_community(struct cmd_element *,struct vty *,int,char **);
  int match_aspath(struct cmd_element *,struct vty *,int,char **);
  int no_match_aspath(struct cmd_element *,struct vty *,int,char **);
  int set_ip_nexthop(struct cmd_element *,struct vty *,int,char **);
  int no_set_ip_nexthop(struct cmd_element *,struct vty *,int,char **);
  int set_metric(struct cmd_element *,struct vty *,int,char **);
  int no_set_metric(struct cmd_element *,struct vty *,int,char **);
  int set_local_pref(struct cmd_element *,struct vty *,int,char **);
  int no_set_local_pref(struct cmd_element *,struct vty *,int,char **);
  int set_weight(struct cmd_element *,struct vty *,int,char **);
  int no_set_weight(struct cmd_element *,struct vty *,int,char **);
  int set_aspath_prepend(struct cmd_element *,struct vty *,int,char **);
  int no_set_aspath_prepend(struct cmd_element *,struct vty *,int,char **);
  int set_community(struct cmd_element *,struct vty *,int,char **);
  int no_set_community(struct cmd_element *,struct vty *,int,char **);
  int set_community_additive(struct cmd_element *,struct vty *,int,char **);
  int no_set_community_additive(struct cmd_element *,struct vty *,int,char **);
  int set_community_delete(struct cmd_element *,struct vty *,int,char **);
  int no_set_community_delete(struct cmd_element *,struct vty *,int,char **);
  int set_ecommunity_rt(struct cmd_element *,struct vty *,int,char **);
  int no_set_ecommunity_rt(struct cmd_element *,struct vty *,int,char **);
  int set_ecommunity_soo(struct cmd_element *,struct vty *,int,char **);
  int no_set_ecommunity_soo(struct cmd_element *,struct vty *,int,char **);
  int set_origin(struct cmd_element *,struct vty *,int,char **);
  int no_set_origin(struct cmd_element *,struct vty *,int,char **);
  int set_atomic_aggregate(struct cmd_element *,struct vty *,int,char **);
  int no_set_atomic_aggregate(struct cmd_element *,struct vty *,int,char **);
  int set_aggregator_as(struct cmd_element *,struct vty *,int,char **);
  int no_set_aggregator_as(struct cmd_element *,struct vty *,int,char **);
  int set_originator_id(struct cmd_element *,struct vty *,int,char **);
  int no_set_originator_id(struct cmd_element *,struct vty *,int,char **);
  void bgp_route_map_init();

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////bgpd.c/////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  int bgp_aslist_set(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_aslist_unset(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_prefix_list_set(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_prefix_list_unset(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_route_map_set(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_route_map_unset(struct vty *,char *,afi_t,safi_t,char *,char *);
  int bgp_router_id_set(struct vty *,char *);
  int bgp_router_id_unset(struct vty *,char *);
  int bgp_router_id(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_router_id(struct cmd_element *,struct vty *,int,char **);
  int bgp_timers_set(struct vty *,char *,char *,int);
  int bgp_timers(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_timers(struct cmd_element *,struct vty *,int,char **);
  int bgp_cluster_id_set(struct vty *,char *);
  int bgp_cluster_id_unset(struct vty *,char *);
  int bgp_cluster_id(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_cluster_id(struct cmd_element *,struct vty *,int,char **);
  int bgp_confederation_id_set(struct vty *,char *);
  int bgp_confederation_id_unset(struct vty *,char *);
  int bgp_confederation_peers_check(struct bgp *,as_t);
  void bgp_confederation_peers_add(struct bgp *,as_t);
  void bgp_confederation_peers_remove(struct bgp *,as_t);
  int bgp_confederation_peers_set(struct vty *,int,char *[]);
  int bgp_confederation_peers_unset(struct vty *,int,char *[]);
  void bgp_confederation_peers_print(struct vty *,struct bgp *);
  int bgp_confederation_peers(struct cmd_element *,struct vty *,int,char **);
  int bgp_confederation_identifier(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_confederation_peers(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_confederation_identifier(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_client_to_client_reflection(struct cmd_element *,struct vty *,int,char **);
  int bgp_client_to_client_reflection(struct cmd_element *,struct vty *,int,char **);
  int bgp_always_compare_med(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_always_compare_med(struct cmd_element *,struct vty *,int,char **);
  int bgp_deterministic_med(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_deterministic_med(struct cmd_element *,struct vty *,int,char **);
  int bgp_enforce_first_as(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_enforce_first_as(struct cmd_element *,struct vty *,int,char **);
  int bgp_bestpath_compare_router_id(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_bestpath_compare_router_id(struct cmd_element *,struct vty *,int,char **);
  int bgp_bestpath_aspath_ignore(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_bestpath_aspath_ignore(struct cmd_element *,struct vty *,int,char **);
  int bgp_bestpath_med(struct cmd_element *,struct vty *,int,char **);
  int bgp_bestpath_med2(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_bestpath_med(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_bestpath_med2(struct cmd_element *,struct vty *,int,char **);
  int bgp_default_local_preference(struct cmd_element *,struct vty *,int,char **);
  int no_bgp_default_local_preference(struct cmd_element *,struct vty *,int,char **);
  struct peer * peer_new();
  int peer_sort(struct peer *);
  int peer_list_cmp(struct peer *,struct peer *);
  int peer_conf_cmp(struct peer_conf *,struct peer_conf *);
  struct peer_conf * peer_conf_new();
  void peer_conf_free(struct peer_conf *);
  void peer_conf_delete(struct peer_conf *);
  struct bgp * bgp_create();
  struct bgp * bgp_get_default();
  struct bgp * bgp_lookup(as_t,char *);
  struct bgp * bgp_lookup_by_name(char *);
  int bgp_get(struct vty *,as_t,char *);
  int bgp_get_by_str(struct vty *,char *,char *);
  void bgp_delete(struct bgp *);
  int bgp_destroy(struct vty *,char *,char *);
  int router_bgp(struct cmd_element *,struct vty *,int,char **);
  int no_router_bgp(struct cmd_element *,struct vty *,int,char **);
  struct peer * peer_lookup_with_local_as(union sockunion *,as_t);
  struct peer * peer_lookup_by_su(union sockunion *);
  struct peer * peer_lookup_with_open(union sockunion *,as_t,struct in_addr *,int *);
  struct peer_conf * peer_conf_lookup(struct bgp *,union sockunion *,int);
  struct peer_conf * peer_conf_lookup_vty(struct vty *,char *,int);
  struct peer_conf * peer_conf_lookup_existing(struct bgp *,union sockunion *);
  char *peer_uptime(time_t,char *,size_t);
  int peer_active(struct peer *);
  struct peer * peer_create(union sockunion *,as_t,struct in_addr,as_t,u_int32_t,u_int32_t);
  struct peer * peer_create_accept();
  int peer_as_change(struct peer *,as_t);
  void peer_af_flag_reset(afi_t,safi_t,struct peer_conf *);
  struct peer_conf * peer_conf_create(int,int,struct peer *);
  void peer_conf_active(int,int,struct peer_conf *);
  void peer_conf_deactive(int,int,struct peer_conf *);
  int peer_remote_as(struct vty *,char *,char *,int,int);
  int peer_activate(struct vty *,char *,int,int);
  int peer_deactivate(struct vty *,char *,int,int);
  void peer_delete(struct peer *);
  int peer_destroy(struct vty *,char *,char *,int,int);
  int peer_change_af_flag(struct vty *,char *,afi_t,safi_t,u_int16_t,enum flag_change_type);
  int peer_change_flag(struct vty *,char *,int,u_int16_t,int);
  int peer_change_flag_with_reset(struct vty *,char *,int,u_int16_t,int);
  int neighbor_remote_as(struct cmd_element *,struct vty *,int,char **);
  int neighbor_activate(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_activate(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_remote_as(struct cmd_element *,struct vty *,int,char **);
  int peer_router_id(struct vty *,char *,int,char *);
  int neighbor_passive(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_passive(struct cmd_element *,struct vty *,int,char **);
  int neighbor_shutdown(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_shutdown(struct cmd_element *,struct vty *,int,char **);
  int peer_ebgp_multihop_set(struct vty *,char *,char *,int);
  int peer_ebgp_multihop_unset(struct vty *,char *,char *,int);
  int neighbor_ebgp_multihop(struct cmd_element *,struct vty *,int,char **);
  int neighbor_ebgp_multihop_ttl(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_ebgp_multihop(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_ebgp_multihop_ttl(struct cmd_element *,struct vty *,int,char **);
  int peer_description_set(struct vty *,char *,int,char *);
  int peer_description_unset(struct vty *,char *,int);
  int neighbor_description(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_description(struct cmd_element *,struct vty *,int,char **);
  int neighbor_nexthop_self(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_nexthop_self(struct cmd_element *,struct vty *,int,char **);
  int neighbor_send_community(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_send_community(struct cmd_element *,struct vty *,int,char **);
  int neighbor_send_community_type(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_send_community_type(struct cmd_element *,struct vty *,int,char **);
  int peer_weight_set(struct vty *,char *,int,char *);
  int peer_weight_unset(struct vty *,char *,int);
  int neighbor_weight(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_weight(struct cmd_element *,struct vty *,int,char **);
  int neighbor_soft_reconfiguration(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_soft_reconfiguration(struct cmd_element *,struct vty *,int,char **);
  int neighbor_route_reflector_client(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_route_reflector_client(struct cmd_element *,struct vty *,int,char **);
  int neighbor_route_server_client(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_route_server_client(struct cmd_element *,struct vty *,int,char **);
  int neighbor_capability_route_refresh(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_capability_route_refresh(struct cmd_element *,struct vty *,int,char **);
  int neighbor_transparent_as(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_transparent_as(struct cmd_element *,struct vty *,int,char **);
  int neighbor_transparent_nexthop(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_transparent_nexthop(struct cmd_element *,struct vty *,int,char **);
  int neighbor_dont_capability_negotiate(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_dont_capability_negotiate(struct cmd_element *,struct vty *,int,char **);
  int peer_override_capability(struct vty *,char *,int,int);
  int neighbor_override_capability(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_override_capability(struct cmd_element *,struct vty *,int,char **);
  int peer_strict_capability(struct vty *,char *,int,int);
  int neighbor_strict_capability(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_strict_capability(struct cmd_element *,struct vty *,int,char **);
  int peer_timers_set(struct vty *,char *,int,char *,char *);
  int peer_timers_unset(struct vty *,char *,int);
  int neighbor_timers(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_timers(struct cmd_element *,struct vty *,int,char **);
  int peer_timers_connect_set(struct vty *,char *,int,char *);
  int peer_timers_connect_unset(struct vty *,char *,int);
  int neighbor_timers_connect(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_timers_connect(struct cmd_element *,struct vty *,int,char **);
  int peer_version(struct vty *,char *,int,char *);
  int neighbor_version(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_version(struct cmd_element *,struct vty *,int,char **);
  void bgp_distribute_update(struct access_list *);
  void bgp_prefix_list_update();
  int neighbor_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_prefix_list(struct cmd_element *,struct vty *,int,char **);
  void bgp_aslist_update();
  int neighbor_filter_list(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_filter_list(struct cmd_element *,struct vty *,int,char **);
  int neighbor_route_map(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_route_map(struct cmd_element *,struct vty *,int,char **);
  int bgp_maximum_prefix_set(struct vty *,char *,afi_t,safi_t,char *,int);
  int bgp_maximum_prefix_unset(struct vty *,char *,afi_t,safi_t);
  int neighbor_maximum_prefix(struct cmd_element *,struct vty *,int,char **);
  int no_neighbor_maximum_prefix(struct cmd_element *,struct vty *,int,char **);
  int peer_have_afi(struct peer *,int);
  int clear_bgp(struct vty *,int,enum clear_type,char *);
  int clear_ip_bgp_all(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_peer(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_as(struct cmd_element *,struct vty *,int,char **);
  int clear_bgp_soft_in(struct vty *,afi_t,safi_t,enum clear_type,char *,int);
  int clear_ip_bgp_peer_soft_in(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_peer_in(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_as_soft_in(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_as_in(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_all_soft_in(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_all_in(struct cmd_element *,struct vty *,int,char **);
  int clear_bgp_soft_out(struct vty *,afi_t,safi_t,enum clear_type,char *);
  int clear_ip_bgp_peer_soft_out(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_as_soft_out(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_all_soft_out(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_peer_soft(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_as_soft(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_bgp_all_soft(struct cmd_element *,struct vty *,int,char **);
  int bgp_show_summary(struct vty *,int,int);
  int show_ip_bgp_summary(struct cmd_element *,struct vty *,int,char **);
  double bgp_next_timer(struct thread *);
  void bgp_show_peer_afi(struct vty *,struct peer_conf *,afi_t,safi_t);
  void bgp_show_peer(struct vty *,struct peer_conf *,afi_t,safi_t);
  int bgp_show_neighbor(struct vty *,int,int,enum show_type,char *);
  int show_ip_bgp_neighbors(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_neighbors_peer(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_paths(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_community_info(struct cmd_element *,struct vty *,int,char **);
  int show_ip_bgp_attr_info(struct cmd_element *,struct vty *,int,char **);
  void bgp_config_write_filter(struct vty *,struct bgp_filter *,char *);
  void bgp_config_write_peer(struct vty *,struct bgp *,struct peer_conf *,afi_t,safi_t);
  void bgp_config_write_family_header(struct vty *,afi_t,safi_t,int *);
  int bgp_config_write_family(struct vty *,struct bgp *,afi_t,safi_t);
  void bgp_init();

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////buffer.c//////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  struct buffer_data * buffer_data_new(size_t);
  void buffer_data_free(struct buffer_data *);
  struct buffer * buffer_new(size_t);
  void buffer_free(struct buffer *);
  char *buffer_getstr(struct buffer *);
  int buffer_empty(struct buffer *);
  void buffer_reset(struct buffer *);
  void buffer_add(struct buffer *);
  int buffer_write(struct buffer *,u_char *,size_t);
  int buffer_putc(struct buffer *,u_char);
  int buffer_putw(struct buffer *,u_short);
  int buffer_putstr(struct buffer *,u_char *);
  void buffer_flush(struct buffer *,int,size_t);
  int buffer_flush_all(struct buffer *,int);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////command.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////
  void install_node(struct cmd_node *,int (Bgp:: *) ( struct vty* ));
  static int cmp_node(const void *,const void *);
  static int cmp_desc(const void *,const void *);
  void sort_node();
  struct _vector* cmd_make_strvec(char *);
  void cmd_free_strvec(struct _vector*);
  char *cmd_desc_str(char **);
  struct _vector* cmd_make_descvec(char *,char *);
  int cmd_cmdsize(struct _vector*);
  char *cmd_prompt(enum node_type);
  void install_element(enum node_type,struct cmd_element *);
  void to64(char *,long,int);
  int config_write_host(struct vty *);
  struct _vector* cmd_node_vector(struct _vector*,enum node_type);
  int cmd_filter_by_symbol(char *,char *);
  enum match_type cmd_ipv4_match(char *);
  enum match_type cmd_ipv4_prefix_match(char *);
  enum match_type cmd_ipv6_match(char *);
  enum match_type cmd_ipv6_prefix_match(char *);
  int cmd_range_match(char *,char *);
  enum match_type cmd_filter_by_completion(char *,struct _vector*,int);
  enum match_type cmd_filter_by_string(char *,struct _vector*,int);
  int is_cmd_ambiguous(char *,struct _vector*,int,enum match_type);
  char *cmd_entry_function(char *,char *);
  char *cmd_entry_function_desc(char *,char *);
  int cmd_unique_string(struct _vector*,char *);
  int desc_unique_string(struct _vector*,char *);
  struct _vector* cmd_describe_command(struct _vector*,struct vty *,int *);
  int cmd_lcd(char **);
  char **cmd_complete_command(struct _vector*,struct vty *,int *);
  int cmd_execute_command(struct _vector*,struct vty *,struct cmd_element **);
  int cmd_execute_command_strict(struct _vector*,struct vty *,struct cmd_element **);
  int config_from_file(struct vty *,FILE *);
  int show_startup_config(struct cmd_element *,struct vty *,int,char **);  
  int config_log_file(struct cmd_element *,struct vty *,int,char **);
  int no_config_log_file(struct cmd_element *,struct vty *,int,char **);
  void host_config_set(char *);
  void cmd_init(int);


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////destribute.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////
  struct distribute * distribute_new();
  void distribute_free(struct distribute *);
  struct distribute * distribute_lookup(char *);
  void distribute_list_add_hook(void (Bgp::*) (struct distribute* ));
  void distribute_list_delete_hook(void (Bgp::*) (struct distribute* ));
  struct distribute * distribute_get(char *);
  static unsigned int distribute_hash_make(struct distribute *);
  static int distribute_cmp(struct distribute *,struct distribute *);
  void distribute_print(struct distribute *);
  struct distribute * distribute_list_set(char *,enum distribute_type,char *);
  int distribute_list_unset(char *,enum distribute_type,char *);
  struct distribute * distribute_list_prefix_set(char *,enum distribute_type,char *);
  int distribute_list_prefix_unset(char *,enum distribute_type,char *);
  int config_show_distribute(struct vty *);
  int config_write_distribute(struct vty *);
  void distribute_list_reset();
  void distribute_list_init(int);
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////filter.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  int access_list_empty(struct access_list *);
  int filter_match(struct filter *,struct prefix *);
  char *filter_type_str(struct filter *);
  struct access_master * access_master_get(afi_t);
  struct filter * filter_new();
  void filter_free(struct filter *);
  struct filter * filter_make(struct prefix *,enum filter_type);
  struct filter * filter_lookup(struct access_list *,struct prefix *,enum filter_type,int);
  struct access_list * access_list_new();
  void access_list_free(struct access_list *);
  void access_list_delete(struct access_list *);
  struct access_list * access_list_insert(afi_t,char *);
  struct access_list * access_list_lookup(afi_t,char *);
  struct access_list * access_list_get(afi_t,char *);
  void access_list_print(struct access_list *);
  enum filter_type access_list_apply(struct access_list *,void *);
  void access_list_add_hook(void (Bgp::*) (struct access_list *));
  void access_list_delete_hook(void ( Bgp::*) (struct access_list *));
  void access_list_filter_add(struct access_list *,struct filter *);
  void access_list_filter_delete(struct access_list *,struct filter *);
  int access_list_dup_check(struct access_list *,struct filter *);
  int vty_access_list_remark_unset(struct vty *,afi_t,char *);
  int access_list(struct cmd_element *,struct vty *,int,char **);
  int no_access_list(struct cmd_element *,struct vty *,int,char **);
  int no_access_list_all(struct cmd_element *,struct vty *,int,char **);
  int access_list_remark(struct cmd_element *,struct vty *,int,char **);
  int no_access_list_remark(struct cmd_element *,struct vty *,int,char **);
  int config_write_access_afi(afi_t,struct vty *);
  void access_list_reset_ipv4();
  void access_list_init_ipv4();
  void access_list_init();
  void access_list_reset();
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////hash.c//////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  struct Hash * hash_new(int);
  HashBacket *hash_backet_new (void *data);
  HashBacket *hash_head(struct Hash *,int);
  void *hash_search(struct Hash *,void *);
  HashBacket *hash_push(struct Hash *,void *);
  void *hash_pull(struct Hash *,void *);
  void hash_clean(struct Hash *,void ( Bgp::*) (void*));
  void Hash_free(struct Hash *);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////linklist.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  void listnode_free(struct listnode *);
  struct listnode * listnode_new();
  struct llist * list_new();
  void list_free(struct llist *);
  void listnode_add(struct llist *,void *);
  void listnode_add_sort(struct llist *,void *);
  void listnode_add_after(struct llist *,struct listnode *,void *);
  void listnode_delete(struct llist *,void *);
  void list_delete_all_node(struct llist *);
  void list_delete(struct llist *);
  struct listnode * listnode_lookup(struct llist *,void *);
  void list_delete_node(list_p,listnode_p );
  void list_add_node_prev(list_p,listnode_p ,void *);
  void list_add_node_next(list_p,listnode_p ,void *);
  void list_add_list(struct llist *,struct llist *);
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////log.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
           
  void time_print(FILE *);
  /* Generic function for zlog. */
  void zlog (struct zlog *zl, int priority, const char *format, ...);
  void  vzlog(struct zlog *,int,const char *,va_list *);
  /* Handy zlog functions. */
  void zlog_err (const char *format, ...);
  void zlog_warn (const char *format, ...);
  void zlog_info (const char *format, ...);
  void zlog_notice (const char *format, ...);
  void zlog_debug (const char *format, ...) ;
  /* For bgpd's peer oriented log. */
  void plog_err (struct zlog *, const char *format, ...);
  void plog_warn (struct zlog *, const char *format, ...);
  void plog_info (struct zlog *, const char *format, ...);
  void plog_notice (struct zlog *, const char *format, ...);
  void plog_debug (struct zlog *, const char *format, ...);
  struct zlog * openzlog(const char *,int,zlog_proto_t,int,int);
  void  closezlog(struct zlog *);
  void zlog_set_flag(struct zlog *,int);
  void zlog_reset_flag(struct zlog *,int);
  int zlog_set_file(struct zlog *,int,char *);
  int zlog_reset_file(struct zlog *);
  int zlog_rotate(struct zlog *);
  char *lookup(struct message *,int);
  char *mes_lookup(struct message *,int,int);


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////memory.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  void zerror(const char *,int,size_t);
  //Global
  void *zmalloc(int,size_t);
  void *zcalloc(int,size_t);
  void *zrealloc(int,void *,size_t);
  void zfree(int,void *);
  char *zstrdup(int,char *);
#ifdef MEMORY_LOG
  void mtype_log (char *func, void *memory, const char *file, int line, int type);
  void *mtype_zmalloc (const char *file, int line, int type, size_t size);
  void *mtype_zcalloc (const char *file, int line, int type, size_t size);
  void *mtype_zrealloc (const char *file, int line, int type, void *ptr, size_t size);
  void mtype_zfree (const char *file, int line, int type, void *ptr);
  char *mtype_zstrdup (const char *file, int line, int type, char *str);
#endif  /* MEMORY_LOG */

  void alloc_inc(int);
  void alloc_dec(int);
  void show_memory_zlog( struct memory_list *);
  int show_memory_all(struct cmd_element *,struct vty *,int,char **);
  int show_memory_lib(struct cmd_element *,struct vty *,int,char **);
  int show_memory_bgp(struct cmd_element *,struct vty *,int,char **);
  void memory_init() ;
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////network.c//////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////      
  int readn(int,char *,int);
  int peer_writen(struct peer*,char*,int);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////plist.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////      
  char *prefix_list_type_str(struct prefix_list_entry *);
  struct prefix_master * prefix_master_get(afi_t);
  struct prefix_list * prefix_list_lookup(afi_t,char *);
  struct prefix_list * prefix_list_new();
  void prefix_list_free(struct prefix_list *);
  struct prefix_list_entry * prefix_list_entry_new();
  void prefix_list_entry_free(struct prefix_list_entry *);
  struct prefix_list * prefix_list_insert(afi_t,char *);
  struct prefix_list * prefix_list_get(afi_t,char *);
  void prefix_list_delete(struct prefix_list *);
  struct prefix_list_entry * prefix_list_entry_make(struct prefix *,enum prefix_list_type,int,int,int);
  void prefix_list_add_hook(void ( Bgp::*) ( ));
  void prefix_list_delete_hook(void ( Bgp::*) ( ));
  int prefix_new_seq_get(struct prefix_list *);
  struct prefix_list_entry * prefix_seq_check(struct prefix_list *,int);
  struct prefix_list_entry * prefix_list_entry_lookup(struct prefix_list *,struct prefix *,enum prefix_list_type,int,int,int);
  void prefix_list_entry_delete(struct prefix_list *,struct prefix_list_entry *);
  void prefix_list_entry_add(struct prefix_list *,struct prefix_list_entry *);
  int prefix_list_entry_match(struct prefix_list_entry *,struct prefix *);
  enum prefix_list_type prefix_list_apply(struct prefix_list *,void *);
  void prefix_list_print(struct prefix_list *);
  struct prefix_list_entry * prefix_entry_dup_check(struct prefix_list *,struct prefix_list_entry *);
  int vty_prefix_list_install(struct vty *,afi_t,char *,char *,char *,char *,char *,char *);
  int vty_prefix_list_uninstall(struct vty *,afi_t,char *,char *,char *,char *,char *,char *);
  int vty_prefix_list_desc_unset(struct vty *,afi_t,char *);
  void vty_show_prefix_entry(struct vty *,afi_t,struct prefix_list *,struct prefix_master *,enum display_type,int);
  int vty_show_prefix_list(struct vty *,afi_t,char *,char *,enum display_type);
  int vty_show_prefix_list_prefix(struct vty *,afi_t,char *,char *,enum display_type);
  int vty_clear_prefix_list(struct vty *,afi_t,char *,char *);
  int ip_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_ge(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_ge_le(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_le(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_le_ge(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_seq(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_seq_ge(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_seq_ge_le(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_seq_le(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_seq_le_ge(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_prefix(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_ge(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_ge_le(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_le(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_le_ge(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_seq(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_seq_ge(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_seq_ge_le(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_seq_le(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_seq_le_ge(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_sequence_number(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_sequence_number(struct cmd_element *,struct vty *,int,char **);
  int ip_prefix_list_description(struct cmd_element *,struct vty *,int,char **);
  int no_ip_prefix_list_description(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_name(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_name_seq(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_prefix(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_prefix_longer(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_prefix_first_match(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_summary(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_summary_name(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_detail(struct cmd_element *,struct vty *,int,char **);
  int show_ip_prefix_list_detail_name(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_prefix_list(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_prefix_list_name(struct cmd_element *,struct vty *,int,char **);
  int clear_ip_prefix_list_name_prefix(struct cmd_element *,struct vty *,int,char **);
  int config_write_prefix_afi(afi_t,struct vty *);
  void prefix_list_reset_ipv4();
  void prefix_list_init_ipv4();
  void prefix_list_init();
  void prefix_list_reset();

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////prefix.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////    
  int afi2family(int);
  int family2afi(int);
  int prefix_match(struct prefix *,struct prefix *);
  void prefix_copy(struct prefix *,struct prefix *);
  int prefix_same(struct prefix *,struct prefix *);
  int prefix_cmp(struct prefix *,struct prefix *);
  char *prefix_family_str(struct prefix *);
  struct prefix_ipv4 * prefix_ipv4_new();
  void prefix_ipv4_free(struct prefix_ipv4 *);
  int str2prefix_ipv4(char *,struct prefix_ipv4 *);
  void masklen2ip(int,struct in_addr *);
  u_char ip_masklen(struct in_addr);
  void apply_mask_ipv4(struct prefix_ipv4 *);
  int prefix_ipv4_any(struct prefix_ipv4 *);
  void apply_mask(struct prefix *);
  struct prefix * sockunion2prefix(union sockunion *,union sockunion *);
  struct prefix * sockunion2hostprefix(union sockunion *);
  int prefix_blen(struct prefix *);
  int str2prefix(char *,struct prefix *);
  int prefix2str(struct prefix *,char *,int);
  struct prefix * prefix_new();
  void prefix_free(struct prefix *);
  int all_digit(char *);
  void apply_classful_mask_ipv4(struct prefix_ipv4 *);
  int netmask_str2prefix_str(char *,char *,char *);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////routemap.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  struct route_map * route_map_add(char *);
  void route_map_delete(struct route_map *);
  void route_map_index_delete(struct route_map_index *,int);
  struct route_map * route_map_new(char *);
  void route_map_rule_add(struct route_map_rule_list *,struct route_map_rule *);
  void route_map_rule_delete(struct route_map_rule_list *,struct route_map_rule *);
  char *route_map_type_str(enum route_map_type);         
  struct route_map * route_map_lookup_by_name(char *);
  struct route_map * route_map_get(char *);
  int route_map_empty(struct route_map *);
  void route_map_print();
  struct route_map_index * route_map_index_new();
  struct route_map_index * route_map_index_lookup(struct route_map *,enum route_map_type,int);
  struct route_map_index * route_map_index_add(struct route_map *,enum route_map_type,int);
  struct route_map_index * route_map_index_get(struct route_map *,enum route_map_type,int);
  struct route_map_rule * route_map_rule_new();
  void route_map_install_match(struct route_map_rule_cmd *);
  void route_map_install_set(struct route_map_rule_cmd *);
  struct route_map_rule_cmd * route_map_lookup_match(char *);
  struct route_map_rule_cmd * route_map_lookup_set(char *);
  int rulecmp(char *,char *);
  int route_map_add_match(struct route_map_index *,char *,char *);
  int route_map_delete_match(struct route_map_index *,char *,char *);
  int route_map_add_set(struct route_map_index *,char *,char *);
  int route_map_delete_set(struct route_map_index *,char *,char *);
  route_map_result_t route_map_apply_index(struct route_map_index *,struct prefix *,route_map_object_t,void *);
  route_map_result_t route_map_apply(struct route_map *,struct prefix *,route_map_object_t,void *);
  void route_map_add_hook(void ( Bgp::*) (char*));
  void route_map_delete_hook(void ( Bgp::*) (char*));
  void route_map_event_hook(void ( Bgp::*) (route_map_event_t,char * ));
  void route_map_init();
  int route_map(struct cmd_element *,struct vty *,int,char **);
  int no_route_map_all(struct cmd_element *,struct vty *,int,char **);
  int no_route_map(struct cmd_element *,struct vty *,int,char **);
  int rmap_onmatch_next(struct cmd_element *,struct vty *,int,char **);
  int no_rmap_onmatch_next(struct cmd_element *,struct vty *,int,char **);
  int rmap_onmatch_goto(struct cmd_element *,struct vty *,int,char **);
  int no_rmap_onmatch_goto(struct cmd_element *,struct vty *,int,char **);
  int route_map_config_write(struct vty *);
  void route_map_init_vty() ;


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////sockunion.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////      
  int inet_aton(const char *,struct in_addr *);
  int inet_pton(int,const char *,void *);
  static const char *inet_ntop(int,const void *,char *,size_t);
  static const char *inet_sutop(union sockunion *,char *);
  int str2sockunion(char *,union sockunion *);
  const char *sockunion2str(union sockunion *,char *,size_t);
  union sockunion * sockunion_str2su(char *);
  char *sockunion_su2str(union sockunion *);
  static int sockunion_same(union sockunion *,union sockunion *);
  int sockunion_cmp(union sockunion *,union sockunion *);

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////str.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////

  size_t strlcpy(char *,const char *,size_t); 
  size_t strlcat(char *,const char *,size_t); 
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////stream.c//////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////
      
  struct stream * stream_new(size_t);
  void stream_free(struct stream *);
  unsigned long stream_get_getp(struct stream *);
  unsigned long stream_get_putp(struct stream *);
  unsigned long stream_get_endp(struct stream *);
  unsigned long stream_get_size(struct stream *);
  void stream_set_getp(struct stream *,unsigned long);
  void stream_set_putp(struct stream *,unsigned long);
  void stream_forward(struct stream *,int);
  void stream_get(void *,struct stream *,size_t);
  u_char stream_getc(struct stream *);
  u_char stream_getc_from(struct stream *,unsigned long);
  u_int16_t stream_getw(struct stream *);
  u_int16_t stream_getw_from(struct stream *,unsigned long);
  u_int32_t stream_getl(struct stream *);
  u_int32_t stream_get_ipv4(struct stream *);
  void stream_put(struct stream *,void *,size_t);
  int stream_putc(struct stream *,u_char);
  int stream_putw(struct stream *,u_int16_t);
  int stream_putl(struct stream *,u_int32_t);
  int stream_putc_at(struct stream *,unsigned long,u_char);
  int stream_putw_at(struct stream *,unsigned long,u_int16_t);
  int stream_putl_at(struct stream *,unsigned long,u_int32_t);
  int stream_put_ipv4(struct stream *,u_int32_t);
  int stream_put_in_addr(struct stream *,struct in_addr *);
  int stream_put_prefix(struct stream *,struct prefix *);
  int stream_read(struct stream *,int,size_t);
  int stream_read_unblock(struct stream *,size_t);
  int stream_write(struct stream *,u_char *,size_t);
  u_char *stream_pnt(struct stream *);
  int stream_empty(struct stream *);
  void stream_reset(struct stream *);
  int stream_flush(struct stream *,int);
  struct stream_fifo * stream_fifo_new();
  void stream_fifo_push(struct stream_fifo *,struct stream *);
  struct stream * stream_fifo_pop(struct stream_fifo *);
  struct stream * stream_fifo_head(struct stream_fifo *);
  void stream_fifo_free(struct stream_fifo *);
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////table.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  int check_bit(u_char *,u_char);
  void route_common(struct prefix *,struct prefix *,struct prefix *);
  void set_link(struct bgp_node *,struct bgp_node *);
  struct bgp_table * route_table_init();
  void route_table_finish(struct bgp_table *);
  struct bgp_node * route_node_new();
  struct bgp_node * route_node_set(struct bgp_table *,struct prefix *);
  void route_node_free(struct bgp_node *);
  void route_table_free(struct bgp_table *);
  struct bgp_node * route_lock_node(struct bgp_node *);
  void route_unlock_node(struct bgp_node *);
  void route_dump_node(struct bgp_table *);
  struct bgp_node * route_node_match(struct bgp_table *,struct prefix *);
  struct bgp_node * route_node_match_ipv4(struct bgp_table *,struct in_addr *);
  struct bgp_node * route_node_lookup(struct bgp_table *,struct prefix *);
  struct bgp_node * route_node_get(struct bgp_table *,struct prefix *);
  void route_node_delete(struct bgp_node *);
  struct bgp_node * route_top(struct bgp_table *);
  struct bgp_node * route_next(struct bgp_node *);
  struct bgp_node * route_next_until(struct bgp_node *,struct bgp_node *);
  struct bgp_node * bgp_table_top (struct bgp_table *table);
  struct bgp_node * bgp_route_next (struct bgp_node *node);
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////thread.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  void thread_add_unuse(struct thread_master *,struct thread *);
  void thread_clean_unuse(struct thread_master *);
  void thread_list_add(struct thread_list *,struct thread *);
  int thread_timer_cmp(double,double);
  struct thread_master * thread_make_master();
  void thread_list_add_before(struct thread_list *,struct thread *,struct thread *);
  struct thread * thread_list_delete(struct thread_list *,struct thread *);
  void thread_destroy_master(struct thread_master *);
  struct thread * thread_trim_head(struct thread_list *);
  struct thread * thread_new(struct thread_master *);     
  struct thread * thread_add_read(struct thread_master *,int (Bgp::*) (struct thread * ),void *,Agent*);
  struct thread * thread_add_ready(struct thread_master *,int (Bgp::*) (struct thread * ),void *);
  struct thread * thread_add_timer(struct thread_master *,int (Bgp::*) ( struct thread * ),void *,double);
  struct thread * thread_add_event(struct thread_master *,int (Bgp::*) (struct thread * ),void *,int);
  void thread_cancel(struct thread *);
  void thread_cancel_event(struct thread_master *,void *);
  double thread_timer_sub(double , double);
  void thread_timer_dump(double);
  void thread_fetch_part1 (struct thread_master *);
  void thread_fetch_part2 (struct thread_master *, Agent * );
  void thread_list_debug(struct thread_list *);
  void thread_master_debug(struct thread_master *);
  void thread_debug(struct thread *);
  void thread_call(struct thread *);
  struct thread * thread_execute(struct thread_master *,int ( Bgp::*) (struct thread * ),void *,int);


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////vector.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     

      
  struct _vector* vector_init(unsigned int);
  void vector_only_wrapper_free(struct _vector*);
  void vector_only_index_free(void *);
  void vector_free(struct _vector*);
  struct _vector* vector_copy(struct _vector*);
  void vector_ensure(struct _vector*,unsigned int);
  int vector_empty_slot(struct _vector*);
  int vector_set(struct _vector*,void *);
  int vector_set_index(struct _vector*,unsigned int,void *);
  void *vector_lookup_index(struct _vector*,unsigned int);
  void vector_unset(struct _vector*,unsigned int);
  unsigned int vector_count(struct _vector*);
  void vector_describe(FILE *,struct _vector*);
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////vty.c//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////// 
     
  void vty_read_file(FILE *);
  int vty_out (struct zlog *, int, const char *, ...) ; 
  int vty_log(struct zlog *,int,const char *,va_list *);
  struct vty * vty_new();
  void vty_close(struct vty *);
  void vty_read_config();
#ifndef HAVE_ZEBRA_93b
  int bgp_advertise_insert( struct peer*,struct bgp_advertise*);
  void bgp_advertise_remove( struct peer*,struct bgp_advertise*);
  void bgp_advertise_remove_by_prefix( struct peer*,struct prefix*);
  struct bgp_advertise* bgp_advertise_new();
#endif
  int bgp_routeadv_timer (struct thread *thread);
  int bgp_update_send_check (struct bgp_info *,struct peer_conf *conf, struct peer *peer,
			     struct prefix *p, struct attr *attr, afi_t afi, safi_t safi,
			     struct peer *from, struct prefix_rd *prd, u_char *tag);
    
  int bgp_withdraw_send_check(struct peer* peer,struct prefix *);

  int peer_advertise_interval_set (struct peer *peer, u_int32_t routeadv);
  int peer_advertise_interval_unset (struct peer *peer);
  int peer_advertise_interval_vty (struct vty *vty, char *ip_str, char *time_str,
				   int set);
  int neighbor_advertise_interval(struct cmd_element *self, struct vty *vty, 
				  int argc, char **argv);
  int no_neighbor_advertise_interval(struct cmd_element *self, struct vty *vty, 
				     int argc, char **argv);

#ifndef HAVE_ZEBRA_93b
  void bgp_update_add_timestamp( struct peer* peer, struct prefix *);
  void bgp_mrai_timers_off(struct peer *);  
  bool routeadv_list_search(struct peer *peer, struct prefix *p);
  void bgp_cancel_timer_by_prefix(struct peer *peer,struct prefix* p);
  void bgp_cancel_supressed_update_by_prefix(struct peer *peer,struct prefix* p);
  void routeadv_list_add(struct peer*,struct thread*);
  void routeadv_list_remove(struct peer*,struct thread*);
#endif
  FullTcpAgent* get_remoteagent_by_localagent (FullTcpAgent * Agent);

#ifdef HAVE_ZEBRA_93b

  /*BGP advertise modifications */
  static struct bgp_advertise_attr *
    baa_new ();

  void
    baa_free (struct bgp_advertise_attr *baa);

  static void *
    baa_hash_alloc (struct bgp_advertise_attr *ref);

  static unsigned int
    baa_hash_key (struct bgp_advertise_attr *baa);

  static int
    baa_hash_cmp (struct bgp_advertise_attr *baa1, struct bgp_advertise_attr *baa2);

  struct bgp_advertise *
    bgp_advertise_new ();

  void
    bgp_advertise_free (struct bgp_advertise *adv);

  void
    bgp_advertise_add (struct bgp_advertise_attr *baa,
		       struct bgp_advertise *adv);
  void
    bgp_advertise_delete (struct bgp_advertise_attr *baa,
			  struct bgp_advertise *adv);
  struct bgp_advertise_attr *
    bgp_advertise_intern (struct hash *hash, struct attr *attr);

  void
    bgp_advertise_unintern (struct hash *hash, struct bgp_advertise_attr *baa);

  void
    bgp_adj_out_free (struct bgp_adj_out *adj);

  int
    bgp_adj_out_lookup (struct peer *peer, struct prefix *p,
			afi_t afi, safi_t safi, struct bgp_node *rn);
  struct bgp_advertise *
    bgp_advertise_clean (struct peer *peer, struct bgp_adj_out *adj,
			 afi_t afi, safi_t safi);
  void
    bgp_adj_out_set (struct bgp_node *rn, struct peer *peer, struct prefix *p,
		     struct attr *attr, afi_t afi, safi_t safi,
		     struct bgp_info *binfo);
  void
    bgp_adj_out_unset (struct bgp_node *rn, struct peer *peer, struct prefix *p, 
		       afi_t afi, safi_t safi);
  void
    bgp_adj_out_remove (struct bgp_node *rn, struct bgp_adj_out *adj, 
			struct peer *peer, afi_t afi, safi_t safi);
  void
    bgp_adj_in_set (struct bgp_node *rn, struct peer *peer, struct attr *attr);

  void
    bgp_adj_in_remove (struct bgp_node *rn, struct bgp_adj_in *bai);

  void
    bgp_adj_in_unset (struct bgp_node *rn, struct peer *peer);

  void
    bgp_sync_init (struct peer *peer);

  void
    bgp_sync_delete (struct peer *peer);
  
  void
    bgp_clear_adj_in (struct peer *peer, afi_t afi, safi_t safi);

#endif /*HAVE_ZEBRA_93b*/

  NsObject* peer_2_target_link (Bgp*);  
  NsObject* bgp_table_lookup (struct in_addr*);
  static void bgp_randomize();
};


/* The BgpTimer in addition to the regular Timer stores the 
   expiration time.
*/

class BgpTimer : public RouteTimer {
 public:
  BgpTimer(Bgp* a) : RouteTimer(a) { bgp_p = a;}
  void Bgpsched(double delay){
    expire_ = Scheduler::instance().clock()+delay;
    sched(delay);
  };
  void Bgpresched(double delay){ 
    expire_ = Scheduler::instance().clock() + delay;
    resched(delay);
  };  
  void expire(Event *e) { 
    bgp_p->timeout();
  };
  double expire_;
 protected:
  Bgp *bgp_p;
};

/* 
   The BGP registry maintains a mapping 
   between ip addresses and BGP instances.
   It is used to translate the Zebra
   ip addresses from the .conf file to 
   simulated bgpd. 
*/

class BgpRegistry : public TclObject
{
 public:

  BgpRegistry() {
#ifdef HAVE_PDNS_BGP    
    debug = 0;
#endif /* HAVE_PDNS_BGP */
    Bgp::Ip2BgpMap = this;    
  };

  void AddEntry( Bgp* bgp, union sockunion su){
    pair<union sockunion,Bgp* >   tmp(su,bgp);
    Su2BgpMap.push_back(tmp);
    
  };
  
  void RemoveEntry (union sockunion su){
    Su2BgpMap_t::iterator itr ;   
    for(itr = Su2BgpMap.begin();itr != Su2BgpMap.end();++itr) 
      if(memcmp(&itr->first,&su,sizeof(union sockunion))==0) { 
	Su2BgpMap.erase(itr);
	break;
      }
  };

#ifdef HAVE_PDNS_BGP    
  int command(int argc, const char*const* argv);

  InterfaceList_t* FindPdnsNeighbor(string ip_str);
  string* FindPdnsPeerByInterface(string if_str);  /*returns the ip of the 
						     neighbor that has the 
						     given interface ip 
						     attached */
  
#endif /*HAVE_PDNS_BGP*/
  
  Bgp*  FindBySu (union sockunion su) {
      
    Su2BgpMap_t::iterator itr ; 
    bool found = false; 
      
    for(itr = Su2BgpMap.begin(); itr != Su2BgpMap.end();++itr)
      if(Bgp::sockunion_same(&itr->first,&su)) { 
	found = true;
	break;
      }

    return found?itr->second:NULL;
  };
  /*Returns a list of all the BGP speakers in the simulation*/
  BgpList_t* GetAllBgp();
 private:
#ifdef HAVE_PDNS_BGP    
  String2List_t   PeerIp2PeerIfTable;    /*This table stores a list of addr-mask strings duplets 
					   for each bgp peer, including remote peers. i.e. peers that
					   reside in other federates. It is only used with pdns.
					 */
  int debug;
#endif /*HAVE_PDNS_BGP*/ 
  Su2BgpMap_t Su2BgpMap;
};

static class BgpRegistryClass : public TclClass
{
 public:
  BgpRegistryClass() : TclClass("BgpRegistry") {}
  TclObject* create(int, const char*const*) {
    return(new BgpRegistry);
  }
} class_bgpregistry_;

#endif /* __cplusplus*/


#endif  /* ns_bgp_ */
