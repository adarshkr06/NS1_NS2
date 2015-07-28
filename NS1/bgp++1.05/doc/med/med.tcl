#Created by Xenofontas Dimitropoulos
#Georgia Tech, Spring 2003
set opt(stop) 200
set opt(dir)  [pwd]
set opt(cmp-med) 0
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
	    		x-cmpmed {
					set opt(cmp-med)  1
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
set ns [new Simulator]
set r [new BgpRegistry]
set tf [ open bgplog.tr w ]
$ns trace-all $tf

set AS100 [$ns node]
set BGP100 [new Application/Route/Bgp]
$BGP100 finish-time  $opt(stop)
$BGP100 config-file $opt(dir)/bgpd100.conf
$BGP100 attach-node $AS100

set AS400 [$ns node]
set BGP400 [new Application/Route/Bgp 200 ]
$BGP400 finish-time  $opt(stop)
$BGP400 config-file $opt(dir)/bgpd400.conf
$BGP400 attach-node $AS400

set AS300a [$ns node]
set BGP300a [new Application/Route/Bgp]
$BGP300a finish-time  $opt(stop)
$BGP300a config-file $opt(dir)/bgpd300a.conf
$BGP300a attach-node $AS300a

set AS300b [$ns node]
set BGP300b [new Application/Route/Bgp]
$BGP300b finish-time  $opt(stop)
$BGP300b config-file $opt(dir)/bgpd300b.conf
$BGP300b attach-node $AS300b

$ns duplex-link $AS100  $AS400 1.5Mb 1ms DropTail
$ns duplex-link $AS300a $AS300b 1.5Mb 1ms DropTail
$ns duplex-link $AS100  $AS300a 1.5Mb 1ms DropTail
$ns duplex-link $AS100  $AS300b 1.5Mb 1ms DropTail


$ns at [expr $opt(stop) - 1] "$BGP100 command  \"show ip bgp\""
$ns at [expr $opt(stop) - 1] "$BGP400 command  \"show ip bgp\""
$ns at [expr $opt(stop) - 1] "$BGP300a command \"show ip bgp\""
$ns at [expr $opt(stop) - 1] "$BGP300b command \"show ip bgp\""

if { $opt(cmp-med) } { 
    puts "using: bgp always-compare-med" 
    $ns at 0.1 "$BGP100 command  \"bgp always-compare-med\""
}

puts "Starting the run"
$ns at $opt(stop) "finish"
$ns run
