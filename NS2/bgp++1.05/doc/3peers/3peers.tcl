# 3peers.tcl
# Created by Adarsh KR
# Umass Amherst, Summer 2015

proc finish { }  {
	global tf ns
	if [info exists tf] {
		close $tf
	}
	$ns halt
}

set ns [new Simulator]
$ns use-scheduler RealTime

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n1 $n2 1Mb 1ms DropTail
$ns duplex-link $n3 $n2 1Mb 1ms DropTail

# Create the AS nodes and BGP applications
set r [new BgpRegistry]
set fin 20

# Set the finish time of the simulation here 
set tf [ open out.tr w ]
$ns trace-all $tf

set BGP1 [new Application/Route/Bgp]
$BGP1 config-file ./bgpd1.conf
$BGP1 attach-node $n1
$BGP1 cpu-load-model uniform 0.0001 0.00001

set BGP2 [new Application/Route/Bgp]
$BGP2 config-file ./bgpd2.conf
$BGP2 attach-node $n2
$BGP2 cpu-load-model uniform 0.0001 0.00001

set BGP3 [new Application/Route/Bgp]
$BGP3 config-file ./bgpd3.conf
$BGP3 attach-node $n3
$BGP3 cpu-load-model uniform 0.0001 0.00001

$ns at 10 "$BGP1 command \"network  190.162.0.0   mask 255.255.0.0\""
$ns at 14  "$BGP1 command \"show ip bgp\""
$ns at 14  "$BGP2 command \"show ip bgp\""
$ns at 14  "$BGP3 command \"show ip bgp\""

$ns at 15 "$BGP1 command \"no network  190.162.0.0   mask 255.255.0.0\""

$ns at 19  "$BGP1 command \"show ip bgp\""
$ns at 19  "$BGP2 command \"show ip bgp\""
$ns at 19  "$BGP3 command \"show ip bgp\""

$ns at $fin  "finish"

puts "Starting the run"

$ns run


