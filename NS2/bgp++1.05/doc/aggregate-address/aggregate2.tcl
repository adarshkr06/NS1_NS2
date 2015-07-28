# ASConnectivity ns2odel
# Created by George Riley and Fontas Dimitropoulos
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


puts "Creating AS 1"
set AS1 [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 finish-time  $opt(stop)
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $AS1
$BGP1 ssld-on

puts "Creating AS 2"
set AS2 [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 finish-time  $opt(stop)
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $AS2
$BGP2 ssld-on

puts "Creating AS 3"
set AS3 [$ns node]
set BGP3 [new Application/Route/Bgp]
$BGP3 finish-time  $opt(stop)
$BGP3 config-file $opt(dir)/bgpd3.conf
$BGP3 attach-node $AS3
$BGP3 ssld-on

puts "Creating AS 4"
set AS4 [$ns node]
set BGP4 [new Application/Route/Bgp]
$BGP4 finish-time  $opt(stop)
$BGP4 config-file $opt(dir)/bgpd4.conf
$BGP4 attach-node $AS4
$BGP4 ssld-on

set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"

# Create the AS connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting AS 1"
puts "Connecting AS 2"


$ns duplex-link $AS2 $AS1 1.5Mb 1ms DropTail
$ns duplex-link $AS3 $AS2 1.5Mb 1ms DropTail
$ns duplex-link $AS4 $AS2 1.5Mb 1ms DropTail


set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

$ns at 100  "$BGP1 command \"show ip bgp\""
$ns at 100  "$BGP2 command \"show ip bgp\""
$ns at 100  "$BGP3 command \"show ip bgp\""
$ns at 100  "$BGP4 command \"show ip bgp\""


puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
