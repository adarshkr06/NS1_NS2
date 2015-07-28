# Created by Xenofontas Dimitropoulos
# Georgia Tech, Spring 2002
set opt(stop) 100
set opt(dir)  [pwd]
set opt(clear) 0

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
	    		x-clear {
					set opt(clear)  1
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

puts "Creating AS 2"
set AS2 [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 finish-time  $opt(stop)
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $AS2

puts "Creating AS 3"
set AS3 [$ns node]
set BGP3 [new Application/Route/Bgp]
$BGP3 finish-time  $opt(stop)
$BGP3 config-file $opt(dir)/bgpd3.conf
$BGP3 attach-node $AS3

set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"

# Create the AS connectivity
puts "Creating the links and BGP connectivity"
puts "Connecting AS 1"
puts "Connecting AS 2"
$ns duplex-link $AS2 $AS1 1.5Mb 1ms DropTail
puts "Connecting AS 3"
$ns duplex-link $AS3 $AS2 1.5Mb 1ms DropTail
puts "created 2 peering agreements"


set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at $opt(stop)  "finish"

set state adv 
for { set i 60 } { $i < 430 } { incr i 60 } {
    if  {$state == "adv"}  {
	$ns at $i "$BGP3 command \"no network 10.0.3.0/24\""
	$ns at [ expr $i + 59 ] "$BGP1 command \"show ip bgp 10.0.3.0/24\""
	$ns at [ expr $i + 59 ] "$BGP2 command \"show ip bgp 10.0.3.0/24\""
 	set state wth
    } else { 
 	$ns at $i "$BGP3 command \"network 10.0.3.0/24\""
 	$ns at [ expr $i + 59 ] "$BGP1 command \"show ip bgp 10.0.3.0/24\""
 	$ns at [ expr $i + 59 ] "$BGP2 command \"show ip bgp 10.0.3.0/24\""
 	set state adv 
    }
} 

if { $opt(clear) } { 
    $ns at 500 "$BGP2 command \"no bgp dampening\""
    $ns at 501 "$BGP3 command \"network 10.0.3.0/24\""
    $ns at 530 "$BGP2 command \"show ip bgp 10.0.3.0/24\""
}


$ns at 4000 "$BGP3 command \"network 10.0.3.0/24\""
$ns at 4001 "$BGP2 command \"show ip bgp 10.0.3.0/24\""
$ns at 4001 "$BGP1 command \"show ip bgp\""




puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
