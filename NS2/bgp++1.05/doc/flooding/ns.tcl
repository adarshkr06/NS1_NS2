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
Application/Route/Bgp use-log-file run.log

puts "Creating Router 1"
set node(1) [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $node(1)

puts "Creating Router 2"
set node(2) [$ns node]
set BGP2 [new Application/Route/Bgp]
$BGP2 register  $r
$BGP2 config-file $opt(dir)/bgpd2.conf
$BGP2 attach-node $node(2)

puts "Creating Router 3"
set node(3) [$ns node]
set BGP3 [new Application/Route/Bgp]
$BGP3 register  $r
$BGP3 config-file $opt(dir)/bgpd3.conf
$BGP3 attach-node $node(3)
set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"


# Create the Router Links
puts "Creating the links and BGP connectivity"
puts "Connecting Router 1"
puts "Connecting Router 2"
$ns duplex-link $node(2) $node(1) 1.5Mb 10ms DropTail
puts "Connecting Router 3"
$ns duplex-link $node(3) $node(2) 1.5Mb 10ms DropTail
puts "created 2 peering agreements"
set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
if { $opt(check-fin) } {
	$ns at $opt(check-start)  "finish-check $opt(check-time)"
} else {
	$ns at $opt(stop)  "finish"
}

$ns at 9 "$BGP1 command \"network 10.0.1.0 mask 255.255.255.0\""
