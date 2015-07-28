#! /usr/bin/perl 

use Getopt::Std;
use Cwd;

getopts('ve:');

$ns = $opt_e;
$verbose= $opt_v;

if ($verbose) { 
    $verbose = "verbose";
} else { 
    $verbose = "";
}

if (!$ns) {
  print <<__EOP__;
usage: validate.pl -e <ns> [-v] 
    -e <ns> absolute path to ns executable
    -v validate in verbose mode
__EOP__
exit;
}

chdir "2peers";
print cwd();
system("./validate.pl $ns $verbose");
system("rm *.log *.tr seed >& /dev/null");
chdir "../aggregate-address";
system("./validate.pl $ns $verbose");
system("rm *.log *.tr seed >& /dev/null");
chdir "../flap-dampening";
system("./validate.pl $ns $verbose");
system("rm *.log *.tr seed >& /dev/null");
chdir "../med";
system("./validate.pl $ns $verbose");
system("rm *.log *.tr seed >& /dev/null");
