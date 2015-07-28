# 1st policies example
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
puts "Creating AS 1"
set AS1 [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 finish-time  $opt(stop)
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $AS1

puts "Creating AS 2"
set AS2 [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 register  $r
$BGP2 finish-time  $opt(stop)
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $AS2

set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"

# Create the AS connectivity
puts "Connecting AS 1"
puts "Connecting AS 2"
$ns duplex-link $AS2 $AS1 1.5Mb 1ms DropTail
puts "created 2 peering agreements"

set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

#Routing Table
$ns at 49 "$BGP1 command \"show ip bgp\""
#change access-list
$ns at 50 "$BGP1 command \"no access-list 1 deny 10.0.1.0/24\""
#reset connection
$ns at 51 "$BGP1 command \"clear ip bgp 2\""
#What the routing table is now?
$ns at 70 "$BGP1 command \"show ip bgp\""


puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
