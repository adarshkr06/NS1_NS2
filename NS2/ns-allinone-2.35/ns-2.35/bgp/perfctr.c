/* 
 * This test program illustrates how a process may use the
 * Linux x86 Performance-Monitoring Counters interface to
 * monitor its own execution.
 *
 * The library uses mmap() to map the kernel's accumulated counter
 * state into the process' address space.
 * When perfctr_read_ctrs() is called, it uses the RDPMC and RDTSC
 * instructions to get the current register values, and combines
 * these with (sum,start) values found in the mapped-in kernel state.
 * The resulting counts are then delivered to the application.
 *
 * Copyright (C) 1999-2003  Mikael Pettersson
 */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include "perfctr.h"

static struct vperfctr *self;
static struct vperfctr_control control;


struct perfctr_info do_init(void)
{
  
  struct perfctr_info info;
  self = vperfctr_open();
  if( !self ) {
    perror("vperfctr_open");
    exit(1);
  }
  if( vperfctr_info(self, &info) < 0 ) {
    perror("vperfctr_info");
    exit(1);
  }
  perfctr_info_print(&info);
  return info ;
}

void do_read(struct perfctr_sum_ctrs *sum)
{
    /*
     * This is the preferred method for sampling all enabled counters.
     * It doesn't return control data or current kernel-level state though.
     * The control data can be retrieved using vperfctr_read_state().
     *
     * Alternatively you may call vperfctr_read_tsc() or vperfctr_read_pmc()
     * to sample a single counter's value.
     */
    vperfctr_read_ctrs(self, sum);
}

void print_control(const struct perfctr_cpu_control *control)
{
    printf("\nControl used:\n");
    perfctr_cpu_control_print(control);
}

void do_setup(struct perfctr_info info)
{
    unsigned int tsc_on = 1;
    unsigned int nractrs = 1;
    unsigned int pmc_map0 = 0;
    unsigned int evntsel0 = 0;

    memset(&control, 0, sizeof control);

    /* Attempt to set up control to count clocks via the TSC
       and retired instructions via PMC0. */
    switch( info.cpu_type ) {
      case PERFCTR_X86_GENERIC:
	nractrs = 0;		/* no PMCs available */
	break;
      case PERFCTR_X86_INTEL_P5:
      case PERFCTR_X86_INTEL_P5MMX:
      case PERFCTR_X86_CYRIX_MII:
	/* event 0x16 (INSTRUCTIONS_EXECUTED), count at CPL 3 */
	evntsel0 = 0x16 | (2 << 6);
	break;
      case PERFCTR_X86_INTEL_P6:
      case PERFCTR_X86_INTEL_PII:
      case PERFCTR_X86_INTEL_PIII:
      case PERFCTR_X86_AMD_K7:
      case PERFCTR_X86_AMD_K8:
	/* event 0xC0 (INST_RETIRED), count at CPL > 0, Enable */
	evntsel0 = 0xC0 | (1 << 16) | (1 << 22);
	break;
      case PERFCTR_X86_WINCHIP_C6:
	tsc_on = 0;		/* no working TSC available */
	evntsel0 = 0x02;	/* X86_INSTRUCTIONS */
	break;
      case PERFCTR_X86_WINCHIP_2:
	tsc_on = 0;		/* no working TSC available */
	evntsel0 = 0x16;	/* INSTRUCTIONS_EXECUTED */
	break;
      case PERFCTR_X86_VIA_C3:
	pmc_map0 = 1;		/* redirect PMC0 to PERFCTR1 */
	evntsel0 = 0xC0;	/* INSTRUCTIONS_EXECUTED */
	break;
      case PERFCTR_X86_INTEL_P4:
      case PERFCTR_X86_INTEL_P4M2:
	/* PMC0: IQ_COUNTER0 with fast RDPMC */
	pmc_map0 = 0x0C | (1 << 31);
	/* IQ_CCCR0: required flags, ESCR 4 (CRU_ESCR0), Enable */
	evntsel0 = (0x3 << 16) | (4 << 13) | (1 << 12);
	/* CRU_ESCR0: event 2 (instr_retired), NBOGUSNTAG, CPL>0 */
	control.cpu_control.p4.escr[0] = (2 << 25) | (1 << 9) | (1 << 2);
	break;
      default:
	fprintf(stderr, "cpu type %u (%s) not supported\n",
		info.cpu_type, perfctr_info_cpu_name(&info));
	exit(1);
    }
    control.cpu_control.tsc_on = tsc_on;
    control.cpu_control.nractrs = nractrs;
    control.cpu_control.pmc_map[0] = pmc_map0;
    control.cpu_control.evntsel[0] = evntsel0;

}

void do_enable(void)
{
    if( vperfctr_control(self, &control) < 0 ) {
	perror("vperfctr_control");
	exit(1);
    }
}

void do_print(const struct perfctr_sum_ctrs *before,
	      const struct perfctr_sum_ctrs *after)
{
    printf("\nFinal Sample:\n");
    if( control.cpu_control.tsc_on )
	printf("tsc\t\t\t%lld\n", after->tsc - before->tsc);
    if( control.cpu_control.nractrs )
	printf("pmc[0]\t\t\t%lld\n", after->pmc[0] - before->pmc[0]);
}

unsigned fac(unsigned n)
{
    return (n < 2) ? 1 : n * fac(n-1);
}

void do_fac(unsigned n)
{
    printf("\nfac(%u) == %u\n", n, fac(n));
}
//#define PERF_HAVE_MAIN
#ifdef PERF_HAVE_MAIN
int main(void)
{
    struct perfctr_sum_ctrs before, after;

    do_init();
    do_setup();
    do_enable();
    do_read(&before);
    do_fac(15);
    do_read(&after);
    do_print(&before, &after);
    do_read(&before);
    do_fac(15);
    do_read(&after);
    do_read(&before);
    do_fac(15);
    do_read(&after);
    perfctr_info_print(&info);
    do_print(&before, &after);
    return 0;
}
#endif  /* PERF_HAVE_MAIN*/
