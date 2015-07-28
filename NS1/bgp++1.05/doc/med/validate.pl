#!/usr/bin/perl
# validation for med 
# For each of the two tests
# we check which is the selected 
# route at router 100. The first
# test is successful if the selected 
# route is through  router 3.3.3.1, 
# while the second is succesful if the 
# selected route is through router 4.4.4.4.


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
    system "rm  bgpd100.log >& /dev/null";

    print "====================================\n";
    print "Running med.tcl test $test\n";
    print "====================================\n";

    if ($test == 1) { 
	if (!$verbose) { 
	    system "$ARGV[0] med.tcl -dir ./conf -stop 300 > /dev/null 2>&1";
	} else { 
	    system "$ARGV[0] med.tcl -dir ./conf -stop 300";
	}		    
    } elsif ($test == 2) { 
	if (!$verbose) { 
	    system "$ARGV[0] med.tcl -dir ./conf -stop 300 -cmpmed > /dev/null 2>&1";
	} else { 
	    system "$ARGV[0] med.tcl -dir ./conf -stop 300 -cmpmed";
	}
    } else { 
	print "Bad test number $test";
	exit;
    }

    print "====================================\n";
    print "Validating med.tcl test $test\n";
    print "====================================\n";

    @files = qw ( bgpd100.log );
    
    $failed = 1;

    foreach $filename (@files) {
	open(FILE,$filename) 
	    || die "--> med.tcl Test $test failed:: Cannot open file $filename";
	
	while (<FILE>) { 
	    if ( /^(\*\>)\s+(.*)/ ) {
		if ( $test == 1 ) {
		    if ( $2 =~ /3\.3\.3\.1/ ) {
			print "--> Test $test Successful!\n";   
			$failed = 0;
			break;	    	    
		    } else { 
			print "--> Test $test Failed!: Selected path: $_";   
			break;	    	    
		    }
		}
		
		if ( $test == 2 ){ 
		    if ( $2 =~ /4\.4\.4\.4/ ) {
			print "--> Test $test Successful!\n";   	
			$failed = 0;
			break;	    	    
		    } else { 
			print "--> Test $test Failed!: Selected path: $_";   
			break;	    	    
		    }
		}
	    }
	}
	
    }
    if ( $failed ) { 
	print "--> Test $test Failed!\n";    
    }
}

