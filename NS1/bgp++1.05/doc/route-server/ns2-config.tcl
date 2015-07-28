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

Application/Route/Bgp use-log-file ns2-config.log

# Set the finish time of the simulation here 
set tf [ open bgplog.tr w ]
$ns trace-all $tf
puts "Creating AS 1"
set AS11 [$ns node]
set BGP11 [new Application/Route/Bgp]
$BGP11 register  $r
$BGP11 config-file $opt(dir)/bgpd11.conf
$BGP11 attach-node $AS11

puts "Creating AS 2"
set AS12 [$ns node]
set BGP12 [new Application/Route/Bgp]
$BGP12 register  $r
$BGP12 config-file $opt(dir)/bgpd12.conf
$BGP12 attach-node $AS12

puts "Creating AS 3"
set AS13 [$ns node]
set BGP13 [new Application/Route/Bgp]
$BGP13 register  $r
$BGP13 config-file $opt(dir)/bgpd13.conf
$BGP13 attach-node $AS13

set AS14 [$ns node]
set BGP14 [new Application/Route/Bgp]
$BGP14 register  $r
$BGP14 config-file $opt(dir)/bgpd14.conf
$BGP14 attach-node $AS14

set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"

# Create the AS connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting AS 1"
puts "Connecting AS 2"


$ns duplex-link $AS12 $AS11 1.5Mb 1ms DropTail
$ns duplex-link $AS13 $AS12 1.5Mb 1ms DropTail
$ns duplex-link $AS14 $AS12 1.5Mb 1ms DropTail
puts "created 2 peering agreements"


set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

#$ns at 20 "$BGP13 command \"network 10.0.3.0/24\""
#$ns at 21 "$BGP14 command \"network 10.0.3.0/24\""

#$ns at 25 "$BGP11 command \"show ip bgp\""

#puts "Starting the run"
#$ns run
#set etime [clock seconds]
#puts "simulation elapsed seconds [expr $etime - $ltime]"
$ns at 20 "$BGP13 command \"network 10.0.3.0/24\""
$ns at 21 "$BGP14 command \"network 10.0.3.0/24\""
$ns run
