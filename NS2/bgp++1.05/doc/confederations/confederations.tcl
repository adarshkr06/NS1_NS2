# Confederations example
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
puts "Creating the nodes and BGP Applications"
# Create the AS nodes and BGP applications
set r [new BgpRegistry]
# Set the finish time of the simulation here 
set tf [ open bgplog.tr w ]
$ns trace-all $tf
puts "Creating NODE 1"
set NODE1 [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 finish-time  $opt(stop)
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $NODE1
puts "Creating NODE 2"
set NODE2 [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 register  $r
$BGP2 finish-time  $opt(stop)
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $NODE2
puts "Creating NODE 3"
set NODE3 [$ns node]
set BGP3 [new Application/Route/Bgp]
$BGP3 register  $r
$BGP3 finish-time  $opt(stop)
$BGP3 config-file $opt(dir)/bgpd3.conf
$BGP3 attach-node $NODE3
puts "Creating NODE 4"
set NODE4 [$ns node]
set BGP4 [new Application/Route/Bgp]
$BGP4 register  $r
$BGP4 finish-time  $opt(stop)
$BGP4 config-file $opt(dir)/bgpd4.conf
$BGP4 attach-node $NODE4
puts "Creating NODE 5"
set NODE5 [$ns node]
set BGP5 [new Application/Route/Bgp]
$BGP5 register  $r
$BGP5 finish-time  $opt(stop)
$BGP5 config-file $opt(dir)/bgpd5.conf
$BGP5 attach-node $NODE5
puts "Creating NODE 6"
set NODE6 [$ns node]
set BGP6 [new Application/Route/Bgp]
$BGP6 register  $r
$BGP6 finish-time  $opt(stop)
$BGP6 config-file $opt(dir)/bgpd6.conf
$BGP6 attach-node $NODE6
puts "Creating NODE 7"
set NODE7 [$ns node]
set BGP7 [new Application/Route/Bgp]
$BGP7 register  $r
$BGP7 finish-time  $opt(stop)
$BGP7 config-file $opt(dir)/bgpd7.conf
$BGP7 attach-node $NODE7
puts "Creating NODE 8"
set NODE8 [$ns node]
set BGP8 [new Application/Route/Bgp]
$BGP8 register  $r
$BGP8 finish-time  $opt(stop)
$BGP8 config-file $opt(dir)/bgpd8.conf
$BGP8 attach-node $NODE8
puts "Creating NODE 9"
set NODE9 [$ns node]
set BGP9 [new Application/Route/Bgp]
$BGP9 register  $r
$BGP9 finish-time  $opt(stop)
$BGP9 config-file $opt(dir)/bgpd9.conf
$BGP9 attach-node $NODE9
puts "Creating NODE 10"
set NODE10 [$ns node]
set BGP10 [new Application/Route/Bgp]
$BGP10 register  $r
$BGP10 finish-time  $opt(stop)
$BGP10 config-file $opt(dir)/bgpd10.conf
$BGP10 attach-node $NODE10
puts "Creating NODE 11"
set NODE11 [$ns node]
set BGP11 [new Application/Route/Bgp]
$BGP11 register  $r
$BGP11 finish-time  $opt(stop)
$BGP11 config-file $opt(dir)/bgpd11.conf
$BGP11 attach-node $NODE11
set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"
# Create the NODE connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting NODE 1"
puts "Connecting NODE 2"
$ns duplex-link $NODE2 $NODE1 1.5Mb 1ms DropTail
puts "Connecting NODE 3"
$ns duplex-link $NODE3 $NODE1 1.5Mb 1ms DropTail
$ns duplex-link $NODE3 $NODE2 1.5Mb 1ms DropTail
puts "Connecting NODE 4"
$ns duplex-link $NODE4 $NODE1 1.5Mb 1ms DropTail
puts "Connecting NODE 5"
$ns duplex-link $NODE5 $NODE4 1.5Mb 1ms DropTail
puts "Connecting NODE 6"
$ns duplex-link $NODE6 $NODE4 1.5Mb 1ms DropTail
puts "Connecting NODE 7"
$ns duplex-link $NODE7 $NODE6 1.5Mb 1ms DropTail
puts "Connecting NODE 8"
$ns duplex-link $NODE8 $NODE6 1.5Mb 1ms DropTail
$ns duplex-link $NODE8 $NODE7 1.5Mb 1ms DropTail
puts "Connecting NODE 9"
$ns duplex-link $NODE9 $NODE6 1.5Mb 1ms DropTail
$ns duplex-link $NODE9 $NODE7 1.5Mb 1ms DropTail
$ns duplex-link $NODE9 $NODE8 1.5Mb 1ms DropTail
puts "Connecting NODE 10"
$ns duplex-link $NODE10 $NODE1 1.5Mb 1ms DropTail
puts "Connecting NODE 11"
$ns duplex-link $NODE11 $NODE4 1.5Mb 1ms DropTail
puts "created 14 peering agreements"
set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"
puts "Starting the run"
$ns at 99 "$BGP1 command \"show ip bgp\""
$ns at 99 "$BGP2 command \"show ip bgp\""
$ns at 99 "$BGP3 command \"show ip bgp\""
$ns at 99 "$BGP4 command \"show ip bgp\""
$ns at 99 "$BGP5 command \"show ip bgp\""
$ns at 99 "$BGP6 command \"show ip bgp\""
$ns at 99 "$BGP7 command \"show ip bgp\""
$ns at 99 "$BGP8 command \"show ip bgp\""
$ns at 99 "$BGP9 command \"show ip bgp\""
$ns at 99 "$BGP10 command \"show ip bgp\""
$ns at 99 "$BGP11 command \"show ip bgp\""
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
