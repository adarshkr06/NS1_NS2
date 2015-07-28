/* Created by Fontas Dimitropoulos GaTech Spring 2003 */
#include "libperfctr.h"

struct perfctr_sum_ctrs ;
struct vperfctr_control;


struct perfctr_info do_init(void);
void do_read(struct perfctr_sum_ctrs *sum);
void print_control(const struct perfctr_cpu_control *control);
void do_enable(void);
void do_setup(struct perfctr_info info);
void do_print(const struct perfctr_sum_ctrs *before,
	      const struct perfctr_sum_ctrs *after);
unsigned fac(unsigned n);
void do_fac(unsigned n);


