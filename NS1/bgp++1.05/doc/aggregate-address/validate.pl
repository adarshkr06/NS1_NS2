#!/usr/bin/perl
# validation for aggregate tests.
# For the first two tests the script 
# checks the routing table of router 1.
# For the 3rd test the routing table of router 4
# is checked. For the 1st test the prefixes 160.0.0.0
# and 160.10.0.0 are expected to be in the
# table. For the 2nd test only the prefix 160.0.0.0
# is expected to be in the table. Lastly, for the 
# 3rd test the prefixes 160.0.0.0, 160.10.0.0, 
# and 160.20.0.0 as well as the AS set information are 
# expected to be in the table.

 

if (($ARGV[0] eq "")) {
    print "Usage: validate.pl ns\n";
    exit;
}

$verbose = 0;
if (($ARGV[1] eq "verbose")) {
    $verbose = 1;
}  

foreach $test (1,2,3) { 

    @events = ();

    if ($test == 1 || $test == 2) 	{ 
	system "rm  bgpd1-1.log >& /dev/null";
	@files = qw ( bgpd1-1.log );	
    } elsif ( $test == 3 ) {  
	system "rm  bgpd2-4.log >& /dev/null";
	@files = qw ( bgpd2-4.log );	
    }
    
    if ($test == 1 || $test == 2) { 
	print "====================================\n";
	print "Running aggregate1.tcl test $test\n";
	print "====================================\n";
	if ($verbose) { 	
	    if ( $test == 1 ) { 
		system "$ARGV[0] aggregate1.tcl -dir ./conf1 -stop 300";
	    } elsif ( $test == 2) { 
		system "$ARGV[0] aggregate1.tcl -dir ./conf1 -stop 300 -sum";
	    }	    
	} else { 	    
	    if ( $test == 1 ) { 
		system "$ARGV[0] aggregate1.tcl -dir ./conf1 -stop 300 > /dev/null 2>&1";
	    } elsif ( $test == 2) { 
		system "$ARGV[0] aggregate1.tcl -dir ./conf1 -stop 300 -sum > /dev/null 2>&1";
	    }	    
	}	
    } elsif ($test == 3)  { 
	print "====================================\n";
	print "Running aggregate2.tcl test\n";
	print "====================================\n";
	
	if ($verbose) { 	
	    system "$ARGV[0] aggregate2.tcl -dir ./conf2 -stop 300";
	}else { 
	    system "$ARGV[0] aggregate2.tcl -dir ./conf2 -stop 300 > /dev/null 2>&1";	    
	}
    }
    
    print "====================================\n";
    if ($test == 1 || $test == 2) { 
	print "Validating aggregate1.tcl test $test\n";
    } else { 
	print "Validating aggregate2.tcl test \n";
    }		
    print "====================================\n";
    
    $fnd_supper = 0;
    $fnd_sub1 = 0;
    $fnd_sub2 = 0;
    $set = 0;

    foreach $filename (@files) {
	open(FILE,$filename) 
	    || die "Test $test failed:: Cannot open file $filename";
	
	while (<FILE>) { 
	    if ( /^(\*\>)\s+(.*)/ ) {
		if ( $2 =~ /160\.0\.0\.0(.*)/ ) {
 		    $fnd_supper = 1;
		    if (($1 =~ /\{100\,300\}/) || ($1 =~ /\{300\,100\}/)  ) { 
			$set  = 1 ;
		    }
		} elsif ( $2 =~ /160\.10\.0\.0/ ) { 
		    $fnd_sub1 = 1;
		} elsif ( $2 =~ /160\.20\.0\.0/ ) { 
		    $fnd_sub2 = 1;
		}
	    }
	}
    }

    if ( $test == 1 ) { 
 	if  (( $fnd_supper ) && ( $fnd_sub1 ) && ( !$fnd_sub2) ) { 
	    print "--> Test successful!\n";
	} else { 
	    print "--> Test Failed!\n";
	}
    } elsif ( $test == 2 )  { 
 	if  (( $fnd_supper ) && ( !$fnd_sub1 ) && ( !$fnd_sub2) ) { 
	    print "--> Test successful!\n";
	} else { 
	    print "--> Test Failed!\n";
	}	
    } elsif ( $test == 3 ) { 
 	if  (( $fnd_supper ) && ( $fnd_sub1 ) && ( $fnd_sub2) && ($set)) { 
	    print "--> Test successful!\n";
	} else { 
	    print "--> Test Failed!\n";
	}	
    } else { 
	print "Error this should never happen\n";
    }

}
