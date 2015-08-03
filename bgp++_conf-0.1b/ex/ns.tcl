# ns2 model
# Created by BGP++ config utility
set opt(stop) 100
set opt(dir)  [pwd]
set opt(check-fin) 0
set opt(check-start)  300
set opt(check-halt) 1
set opt(ckpt-file) ns.ckpt
#
#Checks if the last $time seconds,
#there has been an update. If false
#it stops/checkpoints the simulation,
#otherwise it issues a call to finish-check
#in $time seconds in the future.
#
proc finish-check { time }  {
    global tf opt ns
    puts "finish-check at [[ Simulator instance ] now], Time of last update: [Application/Route/Bgp last-update-time],"
    if { [ expr [ [ Simulator instance ] now ] - [ Application/Route/Bgp last-update-time ] ]  > $time  }  { 
	#
       if {  [ set opt(check-halt) ] } { 
           [ Simulator instance ] halt	
	    puts "End of simulation at [[ Simulator instance ] now]"
           if [info exists tf] {
       	close $tf
           }
       } else { 
           [ Simulator instance ]  at [ expr [[ Simulator instance ] now ] + $time ]   "finish-check $time"
           [ Simulator instance ] checkpoint
           catch { source restart.tcl } 
       }
    } else { 
	puts "rescheduling"
	[ Simulator instance ]  at [ expr [[ Simulator instance ] now ] + $time ]   "finish-check $time"
    }
}
proc finish { }  {
	global tf ns
	if [info exists tf] {
		close $tf
	}
	$ns halt
  #puts "Time of last update: [Application/Route/Bgp last_update_time]"
}
proc process_args {} {
global argc argv opt
for {set i 0} {$i < $argc} {incr i} {
set arg [lindex $argv $i]

switch x$arg {
	    x-stop {
		incr i
		set opt(stop) [lindex $argv $i]
	    }	    x-dir {
		incr i
		set opt(dir)  [lindex $argv $i]
	    }
	    x-ckpt {
		incr i
		set opt(ckpt-file) [lindex $argv $i]
		if { ! [ string compare $opt(ckpt-file) "" ] } {
		    puts "Error while parsing -ckpt switch, specify a file name"
		    exit
		}
		
		Application/Route/Bgp checkpoint $opt(ckpt-file)
	    }
	    x-check {
		incr i 
		set opt(check-fin)  1
		set opt(check-time)  [lindex $argv $i]
		incr i
		set opt(check-halt)  [lindex $argv $i]
		incr i
               	set opt(check-start) [lindex $argv $i]
	    }
	    default {
		puts [format "unrecognized argument: %s" [lindex $argv $i]]
		puts "Usage:"
		puts "  -stop   <time>"
		puts "          Time to stop the simulation (sec), default 100."
		puts "  -dir    <path>"
		puts "          Router configuration files directory, default cwd."
		puts "  -check  <int> <1/0> <start>"
		puts "          This option enables to dynamically stop/pause the simulation when the system has"
                puts "          converged. This works as follows: every <int> simulation secs, starting at the <start>"
                puts "          sec, the time (denoted as <last>) of the last update in the system is checked. If"
                puts "          <current sim time> - <last> greater than <int> the simulation ends (1) or pauses (0)"
                puts "          based on the <1/0> argument. For example -check 50 1 200, will stop a simulation if for"
                puts "          at a period of 50 secs no updates are exchanged, and will start checking at the 200th sec."
                puts "          Pausing a simulation is designed for use with CONDOR, i.e. to take a checkpoint when the sim"
                puts "          is paused. After resuming the simulation, the simulator will attempt to parse a restart.tcl"
                puts "          which should be in the same dir with the original .tcl file. The restart.tcl file may include"
                puts "          commands to reconfigure the simulation, for example ns-2 at commands. If the restart.tcl file"
                puts "          is not found the simulation will proceed according to the initial configuration. This feature"
                puts "          enables to change the configuration of a simulation after it has started."
		puts "  -ckpt   <file>"
		puts "          This option will take a checkpoint of the process as soon as"
		puts "          all BGP initializations have completed. The checkpoint will be"
		puts "          written in the <file>. ns-2 must be compiled with CONDOR to work."
		exit 1
	    }
	}
    }
}

process_args
set stime [clock seconds]
puts "Starting simulation at $stime"
set ns [new Simulator]
puts "Creating the nodes and BGP Routers"
set r [new BgpRegistry]
# Create the Router nodes and BGP applications
Application/Route/Bgp use-log-file logall

puts "Creating Router 1e1"
set node(1e1) [$ns node]
set BGP1e1 [new Application/Route/Bgp]
$BGP1e1 register  $r
$BGP1e1 finish-time  $opt(stop)
$BGP1e1 config-file $opt(dir)/bgpd1e1.conf
$BGP1e1 attach-node $node(1e1)
$ns at 10 "$BGP1e1 command \"show ip bgp\""
$ns at 100 "$BGP1e1 command \"show ip bgp\""

puts "Creating Router 1e2"
set node(1e2) [$ns node]
set BGP1e2 [new Application/Route/Bgp]
$BGP1e2 register  $r
$BGP1e2 finish-time  $opt(stop)
$BGP1e2 config-file $opt(dir)/bgpd1e2.conf
$BGP1e2 attach-node $node(1e2)
$ns at 10 "$BGP1e2 command \"show ip bgp\""
$ns at 100 "$BGP1e2 command \"show ip bgp\""

puts "Creating Router 1e3"
set node(1e3) [$ns node]
set BGP1e3 [new Application/Route/Bgp]
$BGP1e3 register  $r
$BGP1e3 finish-time  $opt(stop)
$BGP1e3 config-file $opt(dir)/bgpd1e3.conf
$BGP1e3 attach-node $node(1e3)
$ns at 10 "$BGP1e3 command \"show ip bgp\""
$ns at 100 "$BGP1e3 command \"show ip bgp\""

puts "Creating Router 2e1"
set node(2e1) [$ns node]
set BGP2e1 [new Application/Route/Bgp]
$BGP2e1 register  $r
$BGP2e1 finish-time  $opt(stop)
$BGP2e1 config-file $opt(dir)/bgpd2e1.conf
$BGP2e1 attach-node $node(2e1)
$ns at 10 "$BGP2e1 command \"show ip bgp\""
$ns at 100 "$BGP2e1 command \"show ip bgp\""

puts "Creating Router 2e2"
set node(2e2) [$ns node]
set BGP2e2 [new Application/Route/Bgp]
$BGP2e2 register  $r
$BGP2e2 finish-time  $opt(stop)
$BGP2e2 config-file $opt(dir)/bgpd2e2.conf
$BGP2e2 attach-node $node(2e2)
$ns at 10 "$BGP2e2 command \"show ip bgp\""
$ns at 100 "$BGP2e2 command \"show ip bgp\""

puts "Creating Router 3e1"
set node(3e1) [$ns node]
set BGP3e1 [new Application/Route/Bgp]
$BGP3e1 register  $r
$BGP3e1 finish-time  $opt(stop)
$BGP3e1 config-file $opt(dir)/bgpd3e1.conf
$BGP3e1 attach-node $node(3e1)
$ns at 10 "$BGP3e1 command \"show ip bgp\""
$ns at 100 "$BGP3e1 command \"show ip bgp\""

puts "Creating Router 3e2"
set node(3e2) [$ns node]
set BGP3e2 [new Application/Route/Bgp]
$BGP3e2 register  $r
$BGP3e2 finish-time  $opt(stop)
$BGP3e2 config-file $opt(dir)/bgpd3e2.conf
$BGP3e2 attach-node $node(3e2)
$ns at 10 "$BGP3e2 command \"show ip bgp\""
$ns at 100 "$BGP3e2 command \"show ip bgp\""

puts "Creating Router 4"
set node(4) [$ns node]
set BGP4 [new Application/Route/Bgp]
$BGP4 register  $r
$BGP4 finish-time  $opt(stop)
$BGP4 config-file $opt(dir)/bgpd4.conf
$BGP4 attach-node $node(4)
$ns at 10 "$BGP4 command \"show ip bgp\""
$ns at 100 "$BGP4 command \"show ip bgp\""

puts "Creating Router 5"
set node(5) [$ns node]
set BGP5 [new Application/Route/Bgp]
$BGP5 register  $r
$BGP5 finish-time  $opt(stop)
$BGP5 config-file $opt(dir)/bgpd5.conf
$BGP5 attach-node $node(5)
$ns at 10 "$BGP5 command \"show ip bgp\""
$ns at 100 "$BGP5 command \"show ip bgp\""

puts "Creating Router 6"
set node(6) [$ns node]
set BGP6 [new Application/Route/Bgp]
$BGP6 register  $r
$BGP6 finish-time  $opt(stop)
$BGP6 config-file $opt(dir)/bgpd6.conf
$BGP6 attach-node $node(6)
$ns at 10 "$BGP6 command \"show ip bgp\""
$ns at 100 "$BGP6 command \"show ip bgp\""

puts "Creating Router 7"
set node(7) [$ns node]
set BGP7 [new Application/Route/Bgp]
$BGP7 register  $r
$BGP7 finish-time  $opt(stop)
$BGP7 config-file $opt(dir)/bgpd7.conf
$BGP7 attach-node $node(7)
$ns at 10 "$BGP7 command \"show ip bgp\""
$ns at 100 "$BGP7 command \"show ip bgp\""

puts "Creating Router 8"
set node(8) [$ns node]
set BGP8 [new Application/Route/Bgp]
$BGP8 register  $r
$BGP8 finish-time  $opt(stop)
$BGP8 config-file $opt(dir)/bgpd8.conf
$BGP8 attach-node $node(8)
$ns at 10 "$BGP8 command \"show ip bgp\""
$ns at 100 "$BGP8 command \"show ip bgp\""
set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"


# Create the Router Links
puts "Creating the links and BGP connectivity"
puts "Connecting Router 1e1"
puts "Connecting Router 1e2"
$ns duplex-link $node(1e2) $node(1e1) 1.5Mb 10ms DropTail
puts "Connecting Router 1e3"
$ns duplex-link $node(1e3) $node(1e2) 1.5Mb 10ms DropTail
$ns duplex-link $node(1e3) $node(1e1) 1.5Mb 10ms DropTail
puts "Connecting Router 2e1"
$ns duplex-link $node(2e1) $node(1e1) 1.5Mb 10ms DropTail
puts "Connecting Router 2e2"
$ns duplex-link $node(2e2) $node(2e1) 1.5Mb 10ms DropTail
puts "Connecting Router 3e1"
$ns duplex-link $node(3e1) $node(1e2) 1.5Mb 10ms DropTail
$ns duplex-link $node(3e1) $node(2e1) 1.5Mb 10ms DropTail
puts "Connecting Router 3e2"
$ns duplex-link $node(3e2) $node(3e1) 1.5Mb 10ms DropTail
puts "Connecting Router 4"
$ns duplex-link $node(4) $node(2e2) 1.5Mb 10ms DropTail
puts "Connecting Router 5"
$ns duplex-link $node(5) $node(2e1) 1.5Mb 10ms DropTail
puts "Connecting Router 6"
$ns duplex-link $node(6) $node(3e1) 1.5Mb 10ms DropTail
puts "Connecting Router 7"
$ns duplex-link $node(7) $node(1e2) 1.5Mb 10ms DropTail
puts "Connecting Router 8"
$ns duplex-link $node(8) $node(1e1) 1.5Mb 10ms DropTail
puts "created 13 peering agreements"
set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
$ns at 100 "$BGP4 command \"no network 0.4.104.0/24\""
if { $opt(check-fin) } {
	$ns at $opt(check-start)  "finish-check $opt(check-time)"
} else {
	$ns at $opt(stop)  "finish"
}
puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
