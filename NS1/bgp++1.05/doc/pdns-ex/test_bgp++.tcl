#Scenarios for testing BGP++ with pdns 
#created by Xenofontas Dimitropoulos GaTech Summer 2003
set test_type 1

#                                             TOPOLOGIES
#####################################################################################
#test1                       sim0       !        sim1       !         sim2
#                                       !                   !
#                    \--n1---------n2--\!\--n1---------n2--\!\--n1---------n2--\  
#                       |               !   |               !   |                     
#                       |               !   |               !   |               
#                    \--n3---------n4--\!\--n3---------n4--\!\--n3---------n4--\
#                                 BGP0  !  BGP1             !





#test2
#                            sim0       !        sim1       !         sim2
#                                       !                   !
#                    \--n1---------n2--\!\--n1---------n2--\!\--n1---------n2--\  
#                       |               !   |               !   |                     
#                       |               !   |               !   |               
#                    \--n3---------n4--\!\--n3---------n4--\!\--n3---------n4--\
#                                 BGP0  !  BGP1       BGP2  !





#test3
#                            sim0       !        sim1       !         sim2
#                                       !                   !
#                    \--n1---------n2--\!\--n1---------n2--\!\--n1---------n2--\  
#                       |               !   |               !   |                     
#                       |               !   |               !   |               
#                    \--n3---------n4--\!\--n3---------n4--\!\--n3---------n4--\
#                                       !  BGP1       BGP2  !





#test4
#                            sim0       !        sim1       !         sim2
#                                       !  BGP3       BGP4  !  BGP8
#                    \--n1---------n2--\!\--n1---------n2--\!\--n1---------n2--\  
#                       |               !   |               !   |                     
#                       |               !   |               !   |               
#                    \--n3---------n4--\!\--n3---------n4--\!\--n3---------n4--\
#                      BGP0       BGP1  !  BGP2       BGP5  !  BGP6       BGP7





#test5
#                            sim0      !        sim1       !         sim2
#                                      !  BGP3       BGP4  !  BGP8
#                   \--n1---------n2 \-!-/ n1---------n2 \-!-/ n1---------n2--\\   /
#                                     \!/  |              \!/  |                \ /
#                      |               X   |               X   |                 X    
#                      |              /!\  |              /!\  |                / \
#                   \--n3---------n4 /-!-\ n3---------n4 /-!-\ n3---------n4--\/   \
#                     BGP0       BGP1  !  BGP2       BGP5  !  BGP6       BGP7 
#                                      !                   !

Simulator instproc progress { } {
    global progress_interval
    puts [format "Progress to %6.1f seconds at wctime %6.1f" [$self now] [clock seconds]]
    if { ![info exists progress_interval] } {
      set progress_interval [$self now]
    }
    $self at [expr [$self now] + $progress_interval] "$self progress"
}

proc finish {} {
    puts "Done..."
    global ns nf simnum
    $ns flush-trace
    if {[info exists nf]} {
        close $nf
    }
#    exec nam syn.$simnum.nam &
#    exit 0
    $ns halt
}

# set start time
set inittime [clock seconds]
set fin 500 

set simnum [lindex $argv 0]

# get host info
set myhost [exec /bin/hostname]
puts "host is $myhost"

set ns [new Simulator]
$ns use-scheduler RTI
$ns set-nix-routing

# get handle on random number generator
set rng_ [new RNG]
set rs 100
$rng_ seed $rs
puts "Using seed value: $rs"

#set tracefile info
set nf [open syn.$simnum.tr w]
$ns trace-all $nf
#$ns namtrace-all $nf

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
$ns duplex-link $n1 $n2 100Mb 5ms DropTail
$ns duplex-link $n3 $n4 100Mb 5ms DropTail
$ns duplex-link $n1 $n3 100Mb 5ms DropTail
[$ns link $n1 $n2] set-ipaddr 192.168.[expr $simnum + 1].1 255.255.255.0
[$ns link $n2 $n1] set-ipaddr 192.168.[expr $simnum + 1].2 255.255.255.0
[$ns link $n3 $n4] set-ipaddr 192.168.[expr $simnum + 1].3 255.255.255.0
[$ns link $n4 $n3] set-ipaddr 192.168.[expr $simnum + 1].4 255.255.255.0
[$ns link $n1 $n3] set-ipaddr 192.168.[expr $simnum + 1].5 255.255.255.0
[$ns link $n3 $n1] set-ipaddr 192.168.[expr $simnum + 1].6 255.255.255.0
$n2 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 1].1 255.255.255.0
if { $test_type == 5 } { $n2 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 31].1 255.255.255.0 } 
$n4 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 101].1 255.255.255.0
if { $test_type == 5 } { $n4 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 61].1 255.255.255.0 } 

if {$simnum != 0} {
    $n1 rlink 100Mb 5ms DropTail 10.1.$simnum.2 255.255.255.0
    if { $test_type == 5 } {$n1 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 60].2 255.255.255.0 } 
    $n3 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 100].2 255.255.255.0
    if { $test_type == 5 } {$n3 rlink 100Mb 5ms DropTail 10.1.[expr $simnum + 30].2 255.255.255.0 } 
} else {
    $n1 rlink 100Mb 5ms DropTail 10.1.3.2 255.255.255.0
    if { $test_type == 5 } {$n1 rlink 100Mb 5ms DropTail 10.1.63.2 255.255.255.0 }
    $n3 rlink 100Mb 5ms DropTail 10.1.103.2 255.255.255.0
    if { $test_type == 5 } {$n3 rlink 100Mb 5ms DropTail 10.1.33.2 255.255.255.0 } 
}

puts "n1($n1) rtiagent = [$n1 set rtirouter_]"
puts "n2($n2) rtiagent = [$n2 set rtirouter_]"
puts "n3($n3) rtiagent = [$n3 set rtirouter_]"
puts "n4($n4) rtiagent = [$n4 set rtirouter_]"

if {$simnum == 0} {
    if {$test_type == 1 || $test_type == 2} { 
	$ns add-route $n4 10.1.101.1 192.168.2.3 255.255.255.0	
	$ns add-route $n4 10.1.101.1 10.1.101.2 255.255.255.0
    }
    if {$test_type == 4} { 
	$ns add-route $n4 10.1.101.1 192.168.2.3 255.255.255.0	
	$ns add-route $n4 10.1.101.1 192.168.2.6 255.255.255.0	
	$ns add-route $n4 10.1.101.1 10.1.101.2 255.255.255.0

      	$ns add-route $n3 10.1.103.2 192.168.3.4 255.255.255.0	
	$ns add-route $n3 10.1.103.2 10.1.103.1 255.255.255.0
    }

    if {$test_type == 5} { 
	$ns add-route $n4 10.1.101.1 192.168.2.3 255.255.255.0	
	$ns add-route $n4 10.1.101.1 192.168.2.6 255.255.255.0	
	$ns add-route $n4 10.1.101.1 10.1.101.2 255.255.255.0
	$ns add-route $n4 10.1.101.1 10.1.31.2 255.255.255.0

	$ns add-route $n4 10.1.61.1 10.1.1.2 255.255.255.0
	$ns add-route $n4 10.1.61.1 192.168.2.1 255.255.255.0 
	$ns add-route $n4 10.1.61.1 192.168.2.5 255.255.255.0  
	$ns add-route $n4 10.1.61.1 10.1.61.2 255.255.255.0

	$ns add-route $n3 10.1.103.2 192.168.3.4 255.255.255.0	
	$ns add-route $n3 10.1.103.2 10.1.103.1 255.255.255.0
	$ns add-route $n3 10.1.103.2 10.1.63.1 255.255.255.0
    }
}
if {$simnum == 1} {
    if {$test_type == 1 || $test_type == 2} { 
	    $ns add-route $n3 10.1.101.2 192.168.1.4 255.255.255.0	
	    $ns add-route $n3 10.1.101.2 10.1.101.1  255.255.255.0
    }
    if {$test_type == 4} { 
	$ns add-route $n1 10.1.1.2 192.168.1.2 255.255.255.0	
	$ns add-route $n1 10.1.1.2 10.1.1.1 255.255.255.0
	
	$ns add-route $n2 10.1.2.1 192.168.3.1 255.255.255.0	
	$ns add-route $n2 10.1.2.1 192.168.3.5 255.255.255.0	
	$ns add-route $n2 10.1.2.1 10.1.2.2 255.255.255.0

	$ns add-route $n3 10.1.101.2 192.168.1.4 255.255.255.0	
	$ns add-route $n3 10.1.101.2 10.1.101.1 255.255.255.0

	$ns add-route $n4 10.1.102.1 192.168.3.3 255.255.255.0	
	$ns add-route $n4 10.1.102.1 192.168.3.6 255.255.255.0	
	$ns add-route $n4 10.1.102.1 10.1.102.2 255.255.255.0
    }

    if {$test_type == 5} { 
	$ns add-route $n1 10.1.1.2 192.168.1.2 255.255.255.0	
	$ns add-route $n1 10.1.1.2 10.1.1.1 255.255.255.0
	$ns add-route $n1 10.1.1.2 10.1.31.1 255.255.255.0
	
	$ns add-route $n1 10.1.61.2 10.1.101.1 255.255.255.0 
	$ns add-route $n1 10.1.61.2 192.168.1.4 255.255.255.0
	$ns add-route $n1 10.1.61.2 10.1.61.1 255.255.255.0
	
	$ns add-route $n2 10.1.2.1 192.168.3.1 255.255.255.0	
	$ns add-route $n2 10.1.2.1 192.168.3.5 255.255.255.0	
	$ns add-route $n2 10.1.2.1 10.1.2.2 255.255.255.0
	$ns add-route $n2 10.1.2.1 10.1.62.2 255.255.255.0

	$ns add-route $n2 10.1.32.1 10.1.102.2 255.255.255.0 
	$ns add-route $n2 10.1.32.1 192.168.3.3 255.255.255.0 
	$ns add-route $n2 10.1.32.1 192.168.3.6 255.255.255.0  
	$ns add-route $n2 10.1.32.1 10.1.32.2 255.255.255.0

	$ns add-route $n3 10.1.101.2 192.168.1.4 255.255.255.0	
	$ns add-route $n3 10.1.101.2 10.1.101.1 255.255.255.0
	$ns add-route $n3 10.1.101.2 10.1.61.1 255.255.255.0

	$ns add-route $n4 10.1.102.1 192.168.3.3 255.255.255.0	
	$ns add-route $n4 10.1.102.1 192.168.3.6 255.255.255.0	
	$ns add-route $n4 10.1.102.1 10.1.102.2 255.255.255.0
	$ns add-route $n4 10.1.102.1 10.1.32.2 255.255.255.0
		
	$ns add-route $n4 10.1.62.1 10.1.2.2 255.255.255.0 
	$ns add-route $n4 10.1.62.1 192.168.3.1 255.255.255.0 
	$ns add-route $n4 10.1.62.1 192.168.3.5 255.255.255.0  
	$ns add-route $n4 10.1.62.1 10.1.62.2 255.255.255.0
    }
}
if {$simnum == 2} {

    if {$test_type == 4} { 
	$ns add-route $n1 10.1.2.2 192.168.2.2 255.255.255.0	
	$ns add-route $n1 10.1.2.2 10.1.2.1 255.255.255.0
	
	$ns add-route $n3 10.1.102.2 192.168.2.4 255.255.255.0	
	$ns add-route $n3 10.1.102.2 10.1.102.1 255.255.255.0

	$ns add-route $n4 10.1.103.1 192.168.1.3 255.255.255.0	
	$ns add-route $n4 10.1.103.1 192.168.1.6 255.255.255.0	
	$ns add-route $n4 10.1.103.1 10.1.103.2 255.255.255.0
    }

    if {$test_type == 5} { 
	$ns add-route $n1 10.1.2.2 192.168.2.2 255.255.255.0	
	$ns add-route $n1 10.1.2.2 10.1.2.1 255.255.255.0
	$ns add-route $n1 10.1.2.2 10.1.32.1 255.255.255.0
	
	$ns add-route $n1 10.1.62.2 10.1.102.1 255.255.255.0 
	$ns add-route $n1 10.1.62.2 192.168.2.4 255.255.255.0  
	$ns add-route $n1 10.1.62.2 10.1.62.1 255.255.255.0

	$ns add-route $n3 10.1.102.2 192.168.2.4 255.255.255.0	
	$ns add-route $n3 10.1.102.2 10.1.102.1 255.255.255.0
	$ns add-route $n3 10.1.102.2 10.1.62.1 255.255.255.0

	$ns add-route $n3 10.1.32.2 10.1.2.1 255.255.255.0 
	$ns add-route $n3 10.1.32.2 192.168.2.2 255.255.255.0  
	$ns add-route $n3 10.1.32.2 10.1.32.1 255.255.255.0

	$ns add-route $n4 10.1.103.1 192.168.1.3 255.255.255.0	
	$ns add-route $n4 10.1.103.1 192.168.1.6 255.255.255.0	
	$ns add-route $n4 10.1.103.1 10.1.103.2 255.255.255.0
	$ns add-route $n4 10.1.103.1 10.1.33.2 255.255.255.0
    }
}

if {$test_type == 1 } { 
    if {$simnum == 0} {
	# Create the AS nodes and BGP applications
	set r0 [new BgpRegistry]

	$r0 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.3 255.255.255.0 
	$r0 print-peer-table

	set BGP0 [new Application/Route/Bgp]
	$BGP0 register  $r0
	$BGP0 finish-time  $fin
	#bgpd id 192.38.14.1
	$BGP0 config-file ./conf/test1/bgpd1.conf
	$BGP0 attach-node $n4
	$BGP0 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP0 command \"show ip bgp\""
    }

    if {$simnum == 1} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	
	$r1 bgp-router 192.38.14.1  10.1.101.1 255.255.255.0 192.168.1.4 255.255.255.0	
	$r1 print-peer-table
	
	set BGP1 [new Application/Route/Bgp]
	$BGP1 register  $r1
	$BGP1 finish-time  $fin
	#bgpd id 192.38.14.2
	$BGP1 config-file ./conf/test1/bgpd2.conf
	$BGP1 attach-node $n3
	$BGP1 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP1 command \"show ip bgp\""
    }
}

if {$test_type == 2 } { 
    if {$simnum == 0} {
	# Create the AS nodes and BGP applications
	set r0 [new BgpRegistry]

	$r0 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.3 255.255.255.0 
	$r0 print-peer-table

	set BGP0 [new Application/Route/Bgp]
	$BGP0 register  $r0
	$BGP0 finish-time  $fin
	#bgpd id 192.38.14.1
	$BGP0 config-file ./conf/test2/bgpd1.conf
	$BGP0 attach-node $n4
	$BGP0 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP0 command \"show ip bgp\""
    }

    if {$simnum == 1} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.1  10.1.101.1 255.255.255.0  192.168.1.4 255.255.255.0	
	$r1 bgp-router 192.38.14.2  10.1.101.2 255.255.255.0  192.168.2.3 255.255.255.0 
	$r1 bgp-router 192.38.14.3  10.1.102.1 255.255.255.0  192.168.2.4 255.255.255.0	
	
	set BGP1 [new Application/Route/Bgp]
	$BGP1 register  $r1
	$BGP1 finish-time  $fin
	#bgpd id 192.38.14.2
	$BGP1 config-file ./conf/test2/bgpd2.conf
	$BGP1 attach-node $n3
	$BGP1 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP1 command \"show ip bgp\""

	set BGP2 [new Application/Route/Bgp]
	$BGP2 register  $r1
	$BGP2 finish-time  $fin
	#bgpd id 192.38.14.3
	$BGP2 config-file ./conf/test2/bgpd3.conf
	$BGP2 attach-node $n4
	$BGP2 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP2 command \"show ip bgp\""
    }
}

if {$test_type == 3 } { 

    if {$simnum == 1} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.2  10.1.101.2 255.255.255.0  192.168.2.3 255.255.255.0 
	$r1 bgp-router 192.38.14.3  10.1.102.1 255.255.255.0  192.168.2.4 255.255.255.0	
	
	set BGP1 [new Application/Route/Bgp]
	$BGP1 register  $r1
	$BGP1 finish-time  $fin
	#bgpd id 192.38.14.2
	$BGP1 config-file ./conf/test3/bgpd2.conf
	$BGP1 attach-node $n3
	$BGP1 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP1 command \"show ip bgp\""

	set BGP2 [new Application/Route/Bgp]
	$BGP2 register  $r1
	$BGP2 finish-time  $fin
	#bgpd id 192.38.14.3
	$BGP2 config-file ./conf/test3/bgpd3.conf
	$BGP2 attach-node $n4
	$BGP2 cpu-load-model uniform 0.0001 0.00001
	$ns at 29  "$BGP2 command \"show ip bgp\""
    }
}



if {$test_type == 4 } { 
    if {$simnum == 0} {
	# Create the AS nodes and BGP applications
	set r0 [new BgpRegistry]
	$r0 bgp-router 192.38.14.0 10.1.103.2 255.255.255.0 192.168.1.3 255.255.255.0 192.168.1.6 255.255.255.0 
	$r0 bgp-router 192.38.14.1 10.1.101.1 255.255.255.0 192.168.1.4 255.255.255.0 
	$r0 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.6 255.255.255.0 192.168.2.3 255.255.255.0 
	$r0 bgp-router 192.38.14.7 10.1.103.1 255.255.255.0 192.168.3.4 255.255.255.0 

	set BGP0 [new Application/Route/Bgp]
	$BGP0 register  $r0
	$BGP0 finish-time  $fin
	#bgpd id 192.38.14.0
	$BGP0 config-file ./conf/test4/bgpd0.conf
	$BGP0 attach-node $n3
	$BGP0 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP0 command \"show ip bgp\""

	set BGP1 [new Application/Route/Bgp]
	$BGP1 register  $r0
	$BGP1 finish-time  $fin
	#bgpd id 192.38.14.1
	$BGP1 config-file ./conf/test4/bgpd1.conf
	$BGP1 attach-node $n4
	$BGP1 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP1 command \"show ip bgp\""
    }

    if {$simnum == 1} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.1 10.1.101.1 255.255.255.0 192.168.1.4 255.255.255.0 
	$r1 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.6 255.255.255.0 192.168.2.3 255.255.255.0 
	$r1 bgp-router 192.38.14.3 10.1.1.2 255.255.255.0 192.168.2.1 255.255.255.0 192.168.2.5 255.255.255.0 
	$r1 bgp-router 192.38.14.4 10.1.2.1 255.255.255.0 192.168.2.2 255.255.255.0 
	$r1 bgp-router 192.38.14.5 10.1.102.1 255.255.255.0 192.168.2.4 255.255.255.0 
	$r1 bgp-router 192.38.14.6 10.1.102.2 255.255.255.0 192.168.3.3 255.255.255.0 192.168.3.6 255.255.255.0 
	$r1 bgp-router 192.38.14.8 10.1.2.2 255.255.255.0 192.168.3.1 255.255.255.0 192.168.3.5 255.255.255.0 

	set BGP2 [new Application/Route/Bgp]
	$BGP2 register  $r1
	$BGP2 finish-time  $fin
	#bgpd id 192.38.14.2
	$BGP2 config-file ./conf/test4/bgpd2.conf
	$BGP2 attach-node $n3
	$BGP2 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP2 command \"show ip bgp\""

	set BGP3 [new Application/Route/Bgp]
	$BGP3 register  $r1
	$BGP3 finish-time  $fin
	#bgpd id 192.38.14.3
	$BGP3 config-file ./conf/test4/bgpd3.conf
	$BGP3 attach-node $n1
	$BGP3 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP3 command \"show ip bgp\""

	set BGP4 [new Application/Route/Bgp]
	$BGP4 register  $r1
	$BGP4 finish-time  $fin
	#bgpd id 192.38.14.4
	$BGP4 config-file ./conf/test4/bgpd4.conf
	$BGP4 attach-node $n2
	$BGP4 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP4 command \"show ip bgp\""

	set BGP5 [new Application/Route/Bgp]
	$BGP5 register  $r1
	$BGP5 finish-time  $fin
	#bgpd id 192.38.14.5
	$BGP5 config-file ./conf/test4/bgpd5.conf
	$BGP5 attach-node $n4
	$BGP5 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP5 command \"show ip bgp\""
    }
    if {$simnum == 2} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.0 10.1.103.2 255.255.255.0 192.168.1.3 255.255.255.0 192.168.1.6 255.255.255.0 	
	$r1 bgp-router 192.38.14.4 10.1.2.1 255.255.255.0 192.168.2.2 255.255.255.0 
	$r1 bgp-router 192.38.14.5 10.1.102.1 255.255.255.0 192.168.2.4 255.255.255.0 
	$r1 bgp-router 192.38.14.6 10.1.102.2 255.255.255.0 192.168.3.3 255.255.255.0 192.168.3.6 255.255.255.0 
	$r1 bgp-router 192.38.14.7 10.1.103.1 255.255.255.0 192.168.3.4 255.255.255.0 
	$r1 bgp-router 192.38.14.8 10.1.2.2 255.255.255.0 192.168.3.1 255.255.255.0 192.168.3.5 255.255.255.0 

	set BGP6 [new Application/Route/Bgp]
	$BGP6 register  $r1
	$BGP6 finish-time  $fin
	#bgpd id 192.38.14.6
	$BGP6 config-file ./conf/test4/bgpd6.conf
	$BGP6 attach-node $n3
	$BGP6 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP6 command \"show ip bgp\""

	set BGP8 [new Application/Route/Bgp]
	$BGP8 register  $r1
	$BGP8 finish-time  $fin
	#bgpd id 192.38.14.8
	$BGP8 config-file ./conf/test4/bgpd8.conf
	$BGP8 attach-node $n1
	$BGP8 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP8 command \"show ip bgp\""

	set BGP7 [new Application/Route/Bgp]
	$BGP7 register  $r1
	$BGP7 finish-time  $fin
	#bgpd id 192.38.14.7
	$BGP7 config-file ./conf/test4/bgpd7.conf
	$BGP7 attach-node $n4
	$BGP7 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP7 command \"show ip bgp\""
    }
}

if {$test_type == 5} { 
    if {$simnum == 0} {
	# Create the AS nodes and BGP applications
	set r0 [new BgpRegistry]
	$r0 bgp-router 192.38.14.0 10.1.103.2 255.255.255.0 192.168.1.3 255.255.255.0 192.168.1.6 255.255.255.0 10.1.33.2 255.255.255.0
	$r0 bgp-router 192.38.14.1 10.1.101.1 255.255.255.0 192.168.1.4 255.255.255.0 10.1.61.1 255.255.255.0
	$r0 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.6 255.255.255.0 192.168.2.3 255.255.255.0 10.1.31.2 255.255.255.0
	$r0 bgp-router 192.38.14.3 10.1.1.2 255.255.255.0 192.168.2.1 255.255.255.0 192.168.2.5 255.255.255.0  10.1.61.2 255.255.255.0
	$r0 bgp-router 192.38.14.7 10.1.103.1 255.255.255.0 192.168.3.4 255.255.255.0 10.1.63.1 255.255.255.0

	set BGP0 [new Application/Route/Bgp]
	$BGP0 register  $r0
	$BGP0 finish-time  $fin
	#bgpd id 192.38.14.0
	$BGP0 config-file ./conf/test5/bgpd0.conf
	$BGP0 attach-node $n3
	$BGP0 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP0 command \"show ip bgp\""

	set BGP1 [new Application/Route/Bgp]
	$BGP1 register  $r0
	$BGP1 finish-time  $fin
	#bgpd id 192.38.14.1
	$BGP1 config-file ./conf/test5/bgpd1.conf
	$BGP1 attach-node $n4
	$BGP1 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP1 command \"show ip bgp\""
    }

    if {$simnum == 1} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.1 10.1.101.1 255.255.255.0 192.168.1.4 255.255.255.0 10.1.61.1 255.255.255.0
	$r1 bgp-router 192.38.14.2 10.1.101.2 255.255.255.0 192.168.2.6 255.255.255.0 192.168.2.3 255.255.255.0 10.1.31.2 255.255.255.0
	$r1 bgp-router 192.38.14.3 10.1.1.2 255.255.255.0 192.168.2.1 255.255.255.0 192.168.2.5 255.255.255.0  10.1.61.2 255.255.255.0
	$r1 bgp-router 192.38.14.4 10.1.2.1 255.255.255.0 192.168.2.2 255.255.255.0  10.1.32.1 255.255.255.0
	$r1 bgp-router 192.38.14.5 10.1.102.1 255.255.255.0 192.168.2.4 255.255.255.0  10.1.62.1 255.255.255.0
	$r1 bgp-router 192.38.14.6 10.1.102.2 255.255.255.0 192.168.3.3 255.255.255.0 192.168.3.6 255.255.255.0  10.1.32.2 255.255.255.0
	$r1 bgp-router 192.38.14.8 10.1.2.2 255.255.255.0 192.168.3.1 255.255.255.0 192.168.3.5 255.255.255.0  10.1.62.2 255.255.255.0

	set BGP2 [new Application/Route/Bgp]
	$BGP2 register  $r1
	$BGP2 finish-time  $fin
	#bgpd id 192.38.14.2
	$BGP2 config-file ./conf/test5/bgpd2.conf
	$BGP2 attach-node $n3
	$BGP2 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP2 command \"show ip bgp\""

	set BGP3 [new Application/Route/Bgp]
	$BGP3 register  $r1
	$BGP3 finish-time  $fin
	#bgpd id 192.38.14.3
	$BGP3 config-file ./conf/test5/bgpd3.conf
	$BGP3 attach-node $n1
	$BGP3 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP3 command \"show ip bgp\""

	set BGP4 [new Application/Route/Bgp]
	$BGP4 register  $r1
	$BGP4 finish-time  $fin
	#bgpd id 192.38.14.4
	$BGP4 config-file ./conf/test5/bgpd4.conf
	$BGP4 attach-node $n2
	$BGP4 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP4 command \"show ip bgp\""

	set BGP5 [new Application/Route/Bgp]
	$BGP5 register  $r1
	$BGP5 finish-time  $fin
	#bgpd id 192.38.14.5
	$BGP5 config-file ./conf/test5/bgpd5.conf
	$BGP5 attach-node $n4
	$BGP5 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP5 command \"show ip bgp\""
    }
    if {$simnum == 2} {
	# Create the AS nodes and BGP applications
	set r1 [new BgpRegistry]
	$r1 bgp-router 192.38.14.4 10.1.2.1 255.255.255.0 192.168.2.2 255.255.255.0  10.1.32.1 255.255.255.0
	$r1 bgp-router 192.38.14.5 10.1.102.1 255.255.255.0 192.168.2.4 255.255.255.0 10.1.62.1 255.255.255.0
	$r1 bgp-router 192.38.14.6 10.1.102.2 255.255.255.0 192.168.3.3 255.255.255.0 192.168.3.6 255.255.255.0  10.1.32.2 255.255.255.0
	$r1 bgp-router 192.38.14.8 10.1.2.2 255.255.255.0 192.168.3.1 255.255.255.0 192.168.3.5 255.255.255.0  10.1.62.2 255.255.255.0
	$r1 bgp-router 192.38.14.0 10.1.103.2 255.255.255.0 192.168.1.3 255.255.255.0 192.168.1.6 255.255.255.0 10.1.33.2 255.255.255.0
	$r1 bgp-router 192.38.14.7 10.1.103.1 255.255.255.0 192.168.3.4 255.255.255.0 10.1.63.1 255.255.255.0

	set BGP6 [new Application/Route/Bgp]
	$BGP6 register  $r1
	$BGP6 finish-time  $fin
	#bgpd id 192.38.14.6
	$BGP6 config-file ./conf/test5/bgpd6.conf
	$BGP6 attach-node $n3
	$BGP6 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP6 command \"show ip bgp\""

	set BGP8 [new Application/Route/Bgp]
	$BGP8 register  $r1
	$BGP8 finish-time  $fin
	#bgpd id 192.38.14.8
	$BGP8 config-file ./conf/test5/bgpd8.conf
	$BGP8 attach-node $n1
	$BGP8 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP8 command \"show ip bgp\""

	set BGP7 [new Application/Route/Bgp]
	$BGP7 register  $r1
	$BGP7 finish-time  $fin
	#bgpd id 192.38.14.7
	$BGP7 config-file ./conf/test5/bgpd7.conf
	$BGP7 attach-node $n4
	$BGP7 cpu-load-model uniform 0.0001 0.00001
	$ns at [ expr $fin - 1 ]  "$BGP7 command \"show ip bgp\""
    }
}
# set time info
set inittime [expr [clock seconds] - $inittime]
set starttime [clock seconds]

$ns at 1.0 "$ns progress"
$ns at $fin  "finish"

# start simulator
puts "**** Simulation Start ****"
$ns run

# print out time info
set starttime [expr [clock seconds] - $starttime]
# print out info
puts "-----------"
puts "$myhost init elapsed seconds $inittime"
puts "$myhost run elapsed seconds $starttime"
puts "$myhost total elapsed seconds [expr $inittime + $starttime]"
global simstart
if {[info exists simstart] } {
    puts "$myhost elapsed sim     [expr [clock seconds] - $simstart]"
}
