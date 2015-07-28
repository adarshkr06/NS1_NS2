#!/usr/bin/perl
# validation for simple 2 peer simulation
# the simulation is considered successful 
# if the peers establish a bgp session and 
# exchange their configured networks. At 
# the end each Bgp speaker should have 4
# entries in its routing table. The script
# checks if the this is true.

# check arguments
if (($ARGV[0] eq "")) {
    print "Usage: validate.pl ns\n";
    exit;
}

$verbose = 0;
if (($ARGV[1] eq "verbose")) {
    $verbose = 1;
}  
    

system "rm  bgpd1.log bgpd2.log >& /dev/null";

print "\n===========================\n";
print "  Running 2peers.tcl\n";
print "===========================\n";

if (!$verbose) { 
    system "$ARGV[0] 2peers.tcl > /dev/null 2>&1";
} else { 
    system "$ARGV[0] 2peers.tcl";
}

print "===========================\n";
print "  Validating 2peers.tcl\n";
print "===========================\n";




@files = qw ( bgpd1.log bgpd2.log);

foreach $filename (@files) {
    open(GREP,"grep 'Total number of prefixes' $filename |") 
	|| die "--> 2peer.tcl failed:: Cannot open file $filename";
    
    $line = <GREP>;
    chomp($line);
    ($line eq "Total number of prefixes 4") ||
	die "--> 2peer.tcl failed:: $filename:\"$line\" != \"Total number of prefixes 4\"";
}
 
print "--> Successful!\n";   
    
	
	
