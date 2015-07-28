// Compute memory usage by examining procfs
// George F. Riley, Georgia Tech, Spring 2000
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

static int pagesize = 0;
unsigned long ReportMemUsage()
{ // Returns usage in bytes
  pid_t  pid;
  pid_t  parent;
  char   work[4096];
  char   work1[255];
  FILE*  f;
  unsigned long pr_size;
  char   s;
  char*  pLine;
  char*  pCh;

  if (!pagesize)
    {
      pagesize = getpagesize();
      printf("Page size is %d\n", pagesize);
    }
  pid = getpid();
  sprintf(work, "/proc/%ld/stat", pid);
  if(0)printf("Opening %s\n", work);
  f = fopen(work, "r");
  if (f == NULL)
    {
      printf("Can't open %s\n", work);
      return(0);    
    }
  fgets(work, sizeof(work), f);
  fclose(f);
  if(0)printf("work %s\n", work);
  strtok(work, " ");
  for (int i = 1; i < 23; i++) 
    {
      pCh = strtok(NULL, " ");
    }
  if(0)printf("pCh %s\n", pCh);
  return(atol(pCh));
#ifdef OLD
  printf("%s\n", work);

  sscanf(work, "%d %s %c %d %*d %*d %*d %*d %*u %*u %*u %*u %*u %*d "
            "%*d %*d %*d %*d %*d %*u %*u %*u %lu",
         &pid, work1, &s, &parent);
  printf("pid %d cmd %s S %c parent %d\n", pid, work1, s, parent);
  exit(0);
  fscanf(f, "%*d %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %*d "
            "%*d %*d %*d %*d %*d %*u %*u %*u %lu",
         &pid, work, &s, &parent&pr_size);
         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
         NULL, NULL, &pr_size);
#endif
}


unsigned long ReportMemUsageMB()
{ // Returns usage in MB!
  return((ReportMemUsage() + 500000) / 1000000 );
}
