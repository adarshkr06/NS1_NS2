#!/usr/bin/perl
# validation for flap dampening simulation
# For the bgpd1.log file we check that the 
# router has received 3 updates and 3 withdrwals
# before the 360th of the simulation and . 
# Also we check that between the 360 
# and 4000th it does not receive any updates
# and that it receives one update after the 
# 4000th second of the simulation.
# 

if (($ARGV[0] eq "")) {
    print "Usage: validate.pl ns\n";
    exit;
}

$verbose = 0;
if (($ARGV[1] eq "verbose")) {
    $verbose = 1;
}  

foreach $test (1,2) { 

    @events = ();
    system "rm  bgpd1.log >& /dev/null";

    print "====================================\n";
    print "Running flap-dampening.tcl test $test\n";
    print "====================================\n";

    if ($test == 1) { 
	if (!$verbose) { 
	    system "$ARGV[0] flap-dampening.tcl -dir ./conf -stop 5000 > /dev/null 2>&1";
	} else { 
	    system "$ARGV[0] flap-dampening.tcl -dir ./conf -stop 5000";
	}
    } elsif ($test == 2) { 
	if (!$verbose) { 
	    system "$ARGV[0] flap-dampening.tcl -dir ./conf -stop 5000 -clear > /dev/null 2>&1";
	} else { 
	    system "$ARGV[0] flap-dampening.tcl -dir ./conf -stop 5000 -clear";
	}
    } else { 
	print "Bad test number $test";
	exit;
    }

    print "====================================\n";
    print "Validating flap-dampening.tcl test $test\n";
    print "====================================\n";

    @files = qw ( bgpd1.log );

    foreach $filename (@files) {
	open(FILE,$filename) 
	    || die "--> flap-dampening.tcl Test $test failed:: Cannot open file $filename";
	
	while (<FILE>) { 
	    /^\d+\/\d+\/\d+\s+\d+:\d+:\d+\s+(\d+\.\d+) BGP: (.*)/;
	    $t = $1;

	    if ($2 =~ /withdrawn\b/) {       
		push(@events,$t,W);
	    }

	    if ($2 =~ /rcvd 10\.0\.3\.0\/24/) {
		push(@events,$t,U);
	    }
	}
        #first check the length
	( scalar @events == 14 ) || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Bad event count";
        
	#check if expected updates were received 
	foreach (1,5,9,13) { 
	    ($events[$_] eq "U") || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Expected update not found";
	}

	#check if the first 3 updates were before the 360th second of the simulation
	foreach (0,4,8) { 
	    ($events[$_] < 360)  || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Bad update time";
	}

	#check if expected withdrawals were received 
	foreach (3,7,11) { 
	    ($events[$_] eq "W") || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Expected withdrawal not found";
	}
	
	#check if expected withdrawals were received 
	foreach (2,6,10) { 
	    ($events[$_] < 360) || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Bad withdrawal time";
	}

	if ( $test == 1) {        
	    ($events[12] > 4000) || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Bad update time";
	} else {
	    (($events[12] > 500) && ($events[12] < 560))  || die "--> flap-dampening.tcl Test $test failed::bgpd1.log Bad update time";		    
	}    

	print "--> Test $test Successful!\n";   
    }
}
