# policies example 3
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


set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"
# Create the NODE connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting NODE 1"
puts "Connecting NODE 2"
$ns duplex-link $NODE2 $NODE1 1.5Mb 1ms DropTail
puts "Connecting NODE 3"
$ns duplex-link $NODE3 $NODE2 1.5Mb 1ms DropTail
puts "Connecting NODE 4"
$ns duplex-link $NODE4 $NODE3 1.5Mb 1ms DropTail
puts "Connecting NODE 5"
$ns duplex-link $NODE5 $NODE4 1.5Mb 1ms DropTail
$ns duplex-link $NODE2 $NODE4 1.5Mb 1ms DropTail
puts "Connecting NODE 6"
$ns duplex-link $NODE1 $NODE6 1.5Mb 1ms DropTail
puts "Connecting NODE 7"
$ns duplex-link $NODE6 $NODE7 1.5Mb 1ms DropTail

puts "created 4 peering agreements"
set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

$ns at 50 "$BGP5 command \"show ip bgp\""
$ns at 50 "$BGP2 command \"show ip bgp\""

puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
