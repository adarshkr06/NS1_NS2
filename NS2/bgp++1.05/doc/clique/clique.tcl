# Created by Xenofontas Dimitropoulos
# Georgia Tech, Spring 2002
set opt(stop) 100
set opt(dir)  [pwd]
proc finish { }  {
	global tf ns
	if [info exists tf] {
		close $tf
	}
	$ns halt
}
proc process_args {} {
	global argc argv opt
	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]

		switch x$arg {
	    		x-stop {
					incr i
					set opt(stop) [lindex $argv $i]
	    		}
	    		x-dir {
					incr i
					set opt(dir)  [lindex $argv $i]
	    		}
	    		default {
					puts [format "unrecognized argument: %s" [lindex $argv $i]]
					puts "Usage: \n -stop sec \tdefault 100 \n -dir  dir \tdefault cwd "
					exit 1
	    		}
		}
    	}
}

process_args
set stime [clock seconds]
set ns [new Simulator]
#$ns use-scheduler RealTime


puts "Creating the nodes and BGP Applications"
# Create the AS nodes and BGP applications
set r [new BgpRegistry]

Application/Route/Bgp use-log-file clique.log

# Set the finish time of the simulation here 
set tf [ open bgplog.tr w ]
$ns trace-all $tf
puts "Creating AS 1"
set AS1 [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $AS1

puts "Creating AS 2"
set AS2 [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 register  $r
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $AS2

puts "Creating AS 3"
set AS3 [$ns node]
set BGP3 [new Application/Route/Bgp]
$BGP3 register  $r
$BGP3 config-file $opt(dir)/bgpd3.conf
$BGP3 attach-node $AS3

set AS4 [$ns node]
set BGP4 [new Application/Route/Bgp]
$BGP4 register  $r
$BGP4 config-file $opt(dir)/bgpd4.conf
$BGP4 attach-node $AS4

set AS5 [$ns node]
set BGP5 [new Application/Route/Bgp]
$BGP5 register  $r
$BGP5 config-file $opt(dir)/bgpd5.conf
$BGP5 attach-node $AS5

set AS6 [$ns node]
set BGP6 [new Application/Route/Bgp]
$BGP6 register  $r
$BGP6 config-file $opt(dir)/bgpd6.conf
$BGP6 attach-node $AS6

set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"

# Create the AS connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting AS 1"
puts "Connecting AS 2"
puts "Connecting AS 3"
puts "Connecting AS 4"
puts "Connecting AS 5"


$ns duplex-link $AS1 $AS2 1.5Mb 1ms DropTail
$ns duplex-link $AS1 $AS3 1.5Mb 1ms DropTail
$ns duplex-link $AS1 $AS4 1.5Mb 1ms DropTail
$ns duplex-link $AS1 $AS5 1.5Mb 1ms DropTail
$ns duplex-link $AS1 $AS6 1.5Mb 1ms DropTail
$ns duplex-link $AS2 $AS3 1.5Mb 1ms DropTail
$ns duplex-link $AS2 $AS4 1.5Mb 1ms DropTail
$ns duplex-link $AS2 $AS5 1.5Mb 1ms DropTail
$ns duplex-link $AS2 $AS6 1.5Mb 1ms DropTail
$ns duplex-link $AS3 $AS4 1.5Mb 1ms DropTail
$ns duplex-link $AS3 $AS5 1.5Mb 1ms DropTail
$ns duplex-link $AS3 $AS6 1.5Mb 1ms DropTail
$ns duplex-link $AS4 $AS5 1.5Mb 1ms DropTail
$ns duplex-link $AS4 $AS6 1.5Mb 1ms DropTail
$ns duplex-link $AS5 $AS6 1.5Mb 1ms DropTail
puts "created 6 peering agreements"


set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

$ns at 20 "$BGP1 command \"network 10.0.3.0 mask 255.255.255.0\""

$ns at 60 "$BGP1 command \"no network 10.0.3.0 mask 255.255.255.0\""

$ns at 160 "$BGP1 command \"show ip bgp\""
$ns at 160 "$BGP2 command \"show ip bgp\""
$ns at 160 "$BGP3 command \"show ip bgp\""
$ns at 160 "$BGP4 command \"show ip bgp\""
$ns at 160 "$BGP5 command \"show ip bgp\""
$ns at 160 "$BGP6 command \"show ip bgp\""
$ns at 90 "$BGP1 command \"show ip bgp\""
$ns at 90 "$BGP2 command \"show ip bgp\""
$ns at 90 "$BGP3 command \"show ip bgp\""
$ns at 90 "$BGP4 command \"show ip bgp\""
$ns at 90 "$BGP5 command \"show ip bgp\""
$ns at 90 "$BGP6 command \"show ip bgp\""
$ns at 120 "$BGP1 command \"show ip bgp\""
$ns at 120 "$BGP2 command \"show ip bgp\""
$ns at 120 "$BGP3 command \"show ip bgp\""
$ns at 120 "$BGP4 command \"show ip bgp\""
$ns at 120 "$BGP5 command \"show ip bgp\""
$ns at 120 "$BGP6 command \"show ip bgp\""
#$ns at 20 "$BGP4 command \"no neighbor 192.38.0.5 remote-as 5\""


puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
