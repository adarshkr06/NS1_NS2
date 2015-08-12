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
Application/Route/Bgp use-log-file 1k_ases_run.log

#puts "Creating Router 1"
set node(1) [$ns node]
set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 config-file $opt(dir)/bgpd1.conf
$BGP1 attach-node $node(1)
$ns at 316 "$BGP1 command \"show ip bgp\""

#puts "Creating Router 1"
set node(5) [$ns node]
set BGP5 [new Application/Route/Bgp]
$BGP5 register  $r
$BGP5 config-file $opt(dir)/bgpd5.conf
$BGP5 attach-node $node(5)

#puts "Creating Router 10240"
set node(10240) [$ns node]
set BGP10240 [new Application/Route/Bgp]
$BGP10240 register  $r
$BGP10240 config-file $opt(dir)/bgpd10240.conf
$BGP10240 attach-node $node(10240)
$ns at 316 "$BGP10240 command \"show ip bgp\""

#puts "Creating Router 10243"
set node(10243) [$ns node]
set BGP10243 [new Application/Route/Bgp]
$BGP10243 register  $r
$BGP10243 config-file $opt(dir)/bgpd10243.conf
$BGP10243 attach-node $node(10243)
$ns at 316 "$BGP10243 command \"show ip bgp\""

#puts "Creating Router 10245"
set node(10245) [$ns node]
set BGP10245 [new Application/Route/Bgp]
$BGP10245 register  $r

$BGP10245 config-file $opt(dir)/bgpd10245.conf
$BGP10245 attach-node $node(10245)
$ns at 316 "$BGP10245 command \"show ip bgp\""

#puts "Creating Router 10249"
set node(10249) [$ns node]
set BGP10249 [new Application/Route/Bgp]
$BGP10249 register  $r

$BGP10249 config-file $opt(dir)/bgpd10249.conf
$BGP10249 attach-node $node(10249)
$ns at 316 "$BGP10249 command \"show ip bgp\""

#puts "Creating Router 10252"
set node(10252) [$ns node]
set BGP10252 [new Application/Route/Bgp]
$BGP10252 register  $r

$BGP10252 config-file $opt(dir)/bgpd10252.conf
$BGP10252 attach-node $node(10252)
$ns at 316 "$BGP10252 command \"show ip bgp\""

#puts "Creating Router 10256"
set node(10256) [$ns node]
set BGP10256 [new Application/Route/Bgp]
$BGP10256 register  $r

$BGP10256 config-file $opt(dir)/bgpd10256.conf
$BGP10256 attach-node $node(10256)
$ns at 316 "$BGP10256 command \"show ip bgp\""

#puts "Creating Router 10260"
set node(10260) [$ns node]
set BGP10260 [new Application/Route/Bgp]
$BGP10260 register  $r

$BGP10260 config-file $opt(dir)/bgpd10260.conf
$BGP10260 attach-node $node(10260)
$ns at 316 "$BGP10260 command \"show ip bgp\""

#puts "Creating Router 10263"
set node(10263) [$ns node]
set BGP10263 [new Application/Route/Bgp]
$BGP10263 register  $r

$BGP10263 config-file $opt(dir)/bgpd10263.conf
$BGP10263 attach-node $node(10263)
$ns at 316 "$BGP10263 command \"show ip bgp\""

#puts "Creating Router 10264"
set node(10264) [$ns node]
set BGP10264 [new Application/Route/Bgp]
$BGP10264 register  $r

$BGP10264 config-file $opt(dir)/bgpd10264.conf
$BGP10264 attach-node $node(10264)
$ns at 316 "$BGP10264 command \"show ip bgp\""

#puts "Creating Router 10267"
set node(10267) [$ns node]
set BGP10267 [new Application/Route/Bgp]
$BGP10267 register  $r

$BGP10267 config-file $opt(dir)/bgpd10267.conf
$BGP10267 attach-node $node(10267)
$ns at 316 "$BGP10267 command \"show ip bgp\""

#puts "Creating Router 10268"
set node(10268) [$ns node]
set BGP10268 [new Application/Route/Bgp]
$BGP10268 register  $r

$BGP10268 config-file $opt(dir)/bgpd10268.conf
$BGP10268 attach-node $node(10268)
$ns at 316 "$BGP10268 command \"show ip bgp\""

#puts "Creating Router 10270"
set node(10270) [$ns node]
set BGP10270 [new Application/Route/Bgp]
$BGP10270 register  $r

$BGP10270 config-file $opt(dir)/bgpd10270.conf
$BGP10270 attach-node $node(10270)
$ns at 316 "$BGP10270 command \"show ip bgp\""

#puts "Creating Router 10275"
set node(10275) [$ns node]
set BGP10275 [new Application/Route/Bgp]
$BGP10275 register  $r

$BGP10275 config-file $opt(dir)/bgpd10275.conf
$BGP10275 attach-node $node(10275)
$ns at 316 "$BGP10275 command \"show ip bgp\""

#puts "Creating Router 10278"
set node(10278) [$ns node]
set BGP10278 [new Application/Route/Bgp]
$BGP10278 register  $r

$BGP10278 config-file $opt(dir)/bgpd10278.conf
$BGP10278 attach-node $node(10278)
$ns at 316 "$BGP10278 command \"show ip bgp\""

#puts "Creating Router 10279"
set node(10279) [$ns node]
set BGP10279 [new Application/Route/Bgp]
$BGP10279 register  $r

$BGP10279 config-file $opt(dir)/bgpd10279.conf
$BGP10279 attach-node $node(10279)
$ns at 316 "$BGP10279 command \"show ip bgp\""

#puts "Creating Router 10289"
set node(10289) [$ns node]
set BGP10289 [new Application/Route/Bgp]
$BGP10289 register  $r

$BGP10289 config-file $opt(dir)/bgpd10289.conf
$BGP10289 attach-node $node(10289)
$ns at 316 "$BGP10289 command \"show ip bgp\""

#puts "Creating Router 10292"
set node(10292) [$ns node]
set BGP10292 [new Application/Route/Bgp]
$BGP10292 register  $r

$BGP10292 config-file $opt(dir)/bgpd10292.conf
$BGP10292 attach-node $node(10292)
$ns at 316 "$BGP10292 command \"show ip bgp\""

#puts "Creating Router 10299"
set node(10299) [$ns node]
set BGP10299 [new Application/Route/Bgp]
$BGP10299 register  $r

$BGP10299 config-file $opt(dir)/bgpd10299.conf
$BGP10299 attach-node $node(10299)
$ns at 316 "$BGP10299 command \"show ip bgp\""

#puts "Creating Router 103"
set node(103) [$ns node]
set BGP103 [new Application/Route/Bgp]
$BGP103 register  $r

$BGP103 config-file $opt(dir)/bgpd103.conf
$BGP103 attach-node $node(103)
$ns at 316 "$BGP103 command \"show ip bgp\""

#puts "Creating Router 10303"
set node(10303) [$ns node]
set BGP10303 [new Application/Route/Bgp]
$BGP10303 register  $r

$BGP10303 config-file $opt(dir)/bgpd10303.conf
$BGP10303 attach-node $node(10303)
$ns at 316 "$BGP10303 command \"show ip bgp\""

#puts "Creating Router 10304"
set node(10304) [$ns node]
set BGP10304 [new Application/Route/Bgp]
$BGP10304 register  $r

$BGP10304 config-file $opt(dir)/bgpd10304.conf
$BGP10304 attach-node $node(10304)
$ns at 316 "$BGP10304 command \"show ip bgp\""

#puts "Creating Router 10305"
set node(10305) [$ns node]
set BGP10305 [new Application/Route/Bgp]
$BGP10305 register  $r

$BGP10305 config-file $opt(dir)/bgpd10305.conf
$BGP10305 attach-node $node(10305)
$ns at 316 "$BGP10305 command \"show ip bgp\""

#puts "Creating Router 10306"
set node(10306) [$ns node]
set BGP10306 [new Application/Route/Bgp]
$BGP10306 register  $r

$BGP10306 config-file $opt(dir)/bgpd10306.conf
$BGP10306 attach-node $node(10306)
$ns at 316 "$BGP10306 command \"show ip bgp\""

#puts "Creating Router 10318"
set node(10318) [$ns node]
set BGP10318 [new Application/Route/Bgp]
$BGP10318 register  $r

$BGP10318 config-file $opt(dir)/bgpd10318.conf
$BGP10318 attach-node $node(10318)
$ns at 316 "$BGP10318 command \"show ip bgp\""

#puts "Creating Router 10335"
set node(10335) [$ns node]
set BGP10335 [new Application/Route/Bgp]
$BGP10335 register  $r

$BGP10335 config-file $opt(dir)/bgpd10335.conf
$BGP10335 attach-node $node(10335)
$ns at 316 "$BGP10335 command \"show ip bgp\""

#puts "Creating Router 10339"
set node(10339) [$ns node]
set BGP10339 [new Application/Route/Bgp]
$BGP10339 register  $r

$BGP10339 config-file $opt(dir)/bgpd10339.conf
$BGP10339 attach-node $node(10339)
$ns at 316 "$BGP10339 command \"show ip bgp\""

#puts "Creating Router 10345"
set node(10345) [$ns node]
set BGP10345 [new Application/Route/Bgp]
$BGP10345 register  $r

$BGP10345 config-file $opt(dir)/bgpd10345.conf
$BGP10345 attach-node $node(10345)
$ns at 316 "$BGP10345 command \"show ip bgp\""

#puts "Creating Router 10348"
set node(10348) [$ns node]
set BGP10348 [new Application/Route/Bgp]
$BGP10348 register  $r

$BGP10348 config-file $opt(dir)/bgpd10348.conf
$BGP10348 attach-node $node(10348)
$ns at 316 "$BGP10348 command \"show ip bgp\""

#puts "Creating Router 10349"
set node(10349) [$ns node]
set BGP10349 [new Application/Route/Bgp]
$BGP10349 register  $r

$BGP10349 config-file $opt(dir)/bgpd10349.conf
$BGP10349 attach-node $node(10349)
$ns at 316 "$BGP10349 command \"show ip bgp\""

#puts "Creating Router 10352"
set node(10352) [$ns node]
set BGP10352 [new Application/Route/Bgp]
$BGP10352 register  $r

$BGP10352 config-file $opt(dir)/bgpd10352.conf
$BGP10352 attach-node $node(10352)
$ns at 316 "$BGP10352 command \"show ip bgp\""

#puts "Creating Router 10354"
set node(10354) [$ns node]
set BGP10354 [new Application/Route/Bgp]
$BGP10354 register  $r

$BGP10354 config-file $opt(dir)/bgpd10354.conf
$BGP10354 attach-node $node(10354)
$ns at 316 "$BGP10354 command \"show ip bgp\""

#puts "Creating Router 10357"
set node(10357) [$ns node]
set BGP10357 [new Application/Route/Bgp]
$BGP10357 register  $r

$BGP10357 config-file $opt(dir)/bgpd10357.conf
$BGP10357 attach-node $node(10357)
$ns at 316 "$BGP10357 command \"show ip bgp\""

#puts "Creating Router 10367"
set node(10367) [$ns node]
set BGP10367 [new Application/Route/Bgp]
$BGP10367 register  $r

$BGP10367 config-file $opt(dir)/bgpd10367.conf
$BGP10367 attach-node $node(10367)
$ns at 316 "$BGP10367 command \"show ip bgp\""

#puts "Creating Router 10377"
set node(10377) [$ns node]
set BGP10377 [new Application/Route/Bgp]
$BGP10377 register  $r

$BGP10377 config-file $opt(dir)/bgpd10377.conf
$BGP10377 attach-node $node(10377)
$ns at 316 "$BGP10377 command \"show ip bgp\""

#puts "Creating Router 10384"
set node(10384) [$ns node]
set BGP10384 [new Application/Route/Bgp]
$BGP10384 register  $r

$BGP10384 config-file $opt(dir)/bgpd10384.conf
$BGP10384 attach-node $node(10384)
$ns at 316 "$BGP10384 command \"show ip bgp\""

#puts "Creating Router 10385"
set node(10385) [$ns node]
set BGP10385 [new Application/Route/Bgp]
$BGP10385 register  $r

$BGP10385 config-file $opt(dir)/bgpd10385.conf
$BGP10385 attach-node $node(10385)
$ns at 316 "$BGP10385 command \"show ip bgp\""

#puts "Creating Router 10387"
set node(10387) [$ns node]
set BGP10387 [new Application/Route/Bgp]
$BGP10387 register  $r

$BGP10387 config-file $opt(dir)/bgpd10387.conf
$BGP10387 attach-node $node(10387)
$ns at 316 "$BGP10387 command \"show ip bgp\""

#puts "Creating Router 10393"
set node(10393) [$ns node]
set BGP10393 [new Application/Route/Bgp]
$BGP10393 register  $r

$BGP10393 config-file $opt(dir)/bgpd10393.conf
$BGP10393 attach-node $node(10393)
$ns at 316 "$BGP10393 command \"show ip bgp\""

#puts "Creating Router 10399"
set node(10399) [$ns node]
set BGP10399 [new Application/Route/Bgp]
$BGP10399 register  $r

$BGP10399 config-file $opt(dir)/bgpd10399.conf
$BGP10399 attach-node $node(10399)
$ns at 316 "$BGP10399 command \"show ip bgp\""

#puts "Creating Router 10415"
set node(10415) [$ns node]
set BGP10415 [new Application/Route/Bgp]
$BGP10415 register  $r

$BGP10415 config-file $opt(dir)/bgpd10415.conf
$BGP10415 attach-node $node(10415)
$ns at 316 "$BGP10415 command \"show ip bgp\""

#puts "Creating Router 10417"
set node(10417) [$ns node]
set BGP10417 [new Application/Route/Bgp]
$BGP10417 register  $r

$BGP10417 config-file $opt(dir)/bgpd10417.conf
$BGP10417 attach-node $node(10417)
$ns at 316 "$BGP10417 command \"show ip bgp\""

#puts "Creating Router 10420"
set node(10420) [$ns node]
set BGP10420 [new Application/Route/Bgp]
$BGP10420 register  $r

$BGP10420 config-file $opt(dir)/bgpd10420.conf
$BGP10420 attach-node $node(10420)
$ns at 316 "$BGP10420 command \"show ip bgp\""

#puts "Creating Router 10436"
set node(10436) [$ns node]
set BGP10436 [new Application/Route/Bgp]
$BGP10436 register  $r

$BGP10436 config-file $opt(dir)/bgpd10436.conf
$BGP10436 attach-node $node(10436)
$ns at 316 "$BGP10436 command \"show ip bgp\""

#puts "Creating Router 10444"
set node(10444) [$ns node]
set BGP10444 [new Application/Route/Bgp]
$BGP10444 register  $r

$BGP10444 config-file $opt(dir)/bgpd10444.conf
$BGP10444 attach-node $node(10444)
$ns at 316 "$BGP10444 command \"show ip bgp\""

#puts "Creating Router 10448"
set node(10448) [$ns node]
set BGP10448 [new Application/Route/Bgp]
$BGP10448 register  $r

$BGP10448 config-file $opt(dir)/bgpd10448.conf
$BGP10448 attach-node $node(10448)
$ns at 316 "$BGP10448 command \"show ip bgp\""

#puts "Creating Router 10450"
set node(10450) [$ns node]
set BGP10450 [new Application/Route/Bgp]
$BGP10450 register  $r

$BGP10450 config-file $opt(dir)/bgpd10450.conf
$BGP10450 attach-node $node(10450)
$ns at 316 "$BGP10450 command \"show ip bgp\""

#puts "Creating Router 10466"
set node(10466) [$ns node]
set BGP10466 [new Application/Route/Bgp]
$BGP10466 register  $r

$BGP10466 config-file $opt(dir)/bgpd10466.conf
$BGP10466 attach-node $node(10466)
$ns at 316 "$BGP10466 command \"show ip bgp\""

#puts "Creating Router 10468"
set node(10468) [$ns node]
set BGP10468 [new Application/Route/Bgp]
$BGP10468 register  $r

$BGP10468 config-file $opt(dir)/bgpd10468.conf
$BGP10468 attach-node $node(10468)
$ns at 316 "$BGP10468 command \"show ip bgp\""

#puts "Creating Router 10477"
set node(10477) [$ns node]
set BGP10477 [new Application/Route/Bgp]
$BGP10477 register  $r

$BGP10477 config-file $opt(dir)/bgpd10477.conf
$BGP10477 attach-node $node(10477)
$ns at 316 "$BGP10477 command \"show ip bgp\""

#puts "Creating Router 10479"
set node(10479) [$ns node]
set BGP10479 [new Application/Route/Bgp]
$BGP10479 register  $r

$BGP10479 config-file $opt(dir)/bgpd10479.conf
$BGP10479 attach-node $node(10479)
$ns at 316 "$BGP10479 command \"show ip bgp\""

#puts "Creating Router 10481"
set node(10481) [$ns node]
set BGP10481 [new Application/Route/Bgp]
$BGP10481 register  $r

$BGP10481 config-file $opt(dir)/bgpd10481.conf
$BGP10481 attach-node $node(10481)
$ns at 316 "$BGP10481 command \"show ip bgp\""

#puts "Creating Router 10482"
set node(10482) [$ns node]
set BGP10482 [new Application/Route/Bgp]
$BGP10482 register  $r

$BGP10482 config-file $opt(dir)/bgpd10482.conf
$BGP10482 attach-node $node(10482)
$ns at 316 "$BGP10482 command \"show ip bgp\""

#puts "Creating Router 10483"
set node(10483) [$ns node]
set BGP10483 [new Application/Route/Bgp]
$BGP10483 register  $r

$BGP10483 config-file $opt(dir)/bgpd10483.conf
$BGP10483 attach-node $node(10483)
$ns at 316 "$BGP10483 command \"show ip bgp\""

#puts "Creating Router 10487"
set node(10487) [$ns node]
set BGP10487 [new Application/Route/Bgp]
$BGP10487 register  $r

$BGP10487 config-file $opt(dir)/bgpd10487.conf
$BGP10487 attach-node $node(10487)
$ns at 316 "$BGP10487 command \"show ip bgp\""

#puts "Creating Router 10490"
set node(10490) [$ns node]
set BGP10490 [new Application/Route/Bgp]
$BGP10490 register  $r

$BGP10490 config-file $opt(dir)/bgpd10490.conf
$BGP10490 attach-node $node(10490)
$ns at 316 "$BGP10490 command \"show ip bgp\""

#puts "Creating Router 10496"
set node(10496) [$ns node]
set BGP10496 [new Application/Route/Bgp]
$BGP10496 register  $r

$BGP10496 config-file $opt(dir)/bgpd10496.conf
$BGP10496 attach-node $node(10496)
$ns at 316 "$BGP10496 command \"show ip bgp\""

#puts "Creating Router 10501"
set node(10501) [$ns node]
set BGP10501 [new Application/Route/Bgp]
$BGP10501 register  $r

$BGP10501 config-file $opt(dir)/bgpd10501.conf
$BGP10501 attach-node $node(10501)
$ns at 316 "$BGP10501 command \"show ip bgp\""

#puts "Creating Router 10505"
set node(10505) [$ns node]
set BGP10505 [new Application/Route/Bgp]
$BGP10505 register  $r

$BGP10505 config-file $opt(dir)/bgpd10505.conf
$BGP10505 attach-node $node(10505)
$ns at 316 "$BGP10505 command \"show ip bgp\""

#puts "Creating Router 10506"
set node(10506) [$ns node]
set BGP10506 [new Application/Route/Bgp]
$BGP10506 register  $r

$BGP10506 config-file $opt(dir)/bgpd10506.conf
$BGP10506 attach-node $node(10506)
$ns at 316 "$BGP10506 command \"show ip bgp\""

#puts "Creating Router 10514"
set node(10514) [$ns node]
set BGP10514 [new Application/Route/Bgp]
$BGP10514 register  $r

$BGP10514 config-file $opt(dir)/bgpd10514.conf
$BGP10514 attach-node $node(10514)
$ns at 316 "$BGP10514 command \"show ip bgp\""

#puts "Creating Router 10531"
set node(10531) [$ns node]
set BGP10531 [new Application/Route/Bgp]
$BGP10531 register  $r

$BGP10531 config-file $opt(dir)/bgpd10531.conf
$BGP10531 attach-node $node(10531)
$ns at 316 "$BGP10531 command \"show ip bgp\""

#puts "Creating Router 10533"
set node(10533) [$ns node]
set BGP10533 [new Application/Route/Bgp]
$BGP10533 register  $r

$BGP10533 config-file $opt(dir)/bgpd10533.conf
$BGP10533 attach-node $node(10533)
$ns at 316 "$BGP10533 command \"show ip bgp\""

#puts "Creating Router 10535"
set node(10535) [$ns node]
set BGP10535 [new Application/Route/Bgp]
$BGP10535 register  $r

$BGP10535 config-file $opt(dir)/bgpd10535.conf
$BGP10535 attach-node $node(10535)
$ns at 316 "$BGP10535 command \"show ip bgp\""

#puts "Creating Router 10543"
set node(10543) [$ns node]
set BGP10543 [new Application/Route/Bgp]
$BGP10543 register  $r

$BGP10543 config-file $opt(dir)/bgpd10543.conf
$BGP10543 attach-node $node(10543)
$ns at 316 "$BGP10543 command \"show ip bgp\""

#puts "Creating Router 10545"
set node(10545) [$ns node]
set BGP10545 [new Application/Route/Bgp]
$BGP10545 register  $r

$BGP10545 config-file $opt(dir)/bgpd10545.conf
$BGP10545 attach-node $node(10545)
$ns at 316 "$BGP10545 command \"show ip bgp\""

#puts "Creating Router 10562"
set node(10562) [$ns node]
set BGP10562 [new Application/Route/Bgp]
$BGP10562 register  $r

$BGP10562 config-file $opt(dir)/bgpd10562.conf
$BGP10562 attach-node $node(10562)
$ns at 316 "$BGP10562 command \"show ip bgp\""

#puts "Creating Router 10570"
set node(10570) [$ns node]
set BGP10570 [new Application/Route/Bgp]
$BGP10570 register  $r

$BGP10570 config-file $opt(dir)/bgpd10570.conf
$BGP10570 attach-node $node(10570)
$ns at 316 "$BGP10570 command \"show ip bgp\""

#puts "Creating Router 10576"
set node(10576) [$ns node]
set BGP10576 [new Application/Route/Bgp]
$BGP10576 register  $r

$BGP10576 config-file $opt(dir)/bgpd10576.conf
$BGP10576 attach-node $node(10576)
$ns at 316 "$BGP10576 command \"show ip bgp\""

#puts "Creating Router 10583"
set node(10583) [$ns node]
set BGP10583 [new Application/Route/Bgp]
$BGP10583 register  $r

$BGP10583 config-file $opt(dir)/bgpd10583.conf
$BGP10583 attach-node $node(10583)
$ns at 316 "$BGP10583 command \"show ip bgp\""

#puts "Creating Router 10585"
set node(10585) [$ns node]
set BGP10585 [new Application/Route/Bgp]
$BGP10585 register  $r

$BGP10585 config-file $opt(dir)/bgpd10585.conf
$BGP10585 attach-node $node(10585)
$ns at 316 "$BGP10585 command \"show ip bgp\""

#puts "Creating Router 10588"
set node(10588) [$ns node]
set BGP10588 [new Application/Route/Bgp]
$BGP10588 register  $r

$BGP10588 config-file $opt(dir)/bgpd10588.conf
$BGP10588 attach-node $node(10588)
$ns at 316 "$BGP10588 command \"show ip bgp\""

#puts "Creating Router 10589"
set node(10589) [$ns node]
set BGP10589 [new Application/Route/Bgp]
$BGP10589 register  $r

$BGP10589 config-file $opt(dir)/bgpd10589.conf
$BGP10589 attach-node $node(10589)
$ns at 316 "$BGP10589 command \"show ip bgp\""

#puts "Creating Router 10590"
set node(10590) [$ns node]
set BGP10590 [new Application/Route/Bgp]
$BGP10590 register  $r

$BGP10590 config-file $opt(dir)/bgpd10590.conf
$BGP10590 attach-node $node(10590)
$ns at 316 "$BGP10590 command \"show ip bgp\""

#puts "Creating Router 10601"
set node(10601) [$ns node]
set BGP10601 [new Application/Route/Bgp]
$BGP10601 register  $r

$BGP10601 config-file $opt(dir)/bgpd10601.conf
$BGP10601 attach-node $node(10601)
$ns at 316 "$BGP10601 command \"show ip bgp\""

#puts "Creating Router 10605"
set node(10605) [$ns node]
set BGP10605 [new Application/Route/Bgp]
$BGP10605 register  $r

$BGP10605 config-file $opt(dir)/bgpd10605.conf
$BGP10605 attach-node $node(10605)
$ns at 316 "$BGP10605 command \"show ip bgp\""

#puts "Creating Router 10606"
set node(10606) [$ns node]
set BGP10606 [new Application/Route/Bgp]
$BGP10606 register  $r

$BGP10606 config-file $opt(dir)/bgpd10606.conf
$BGP10606 attach-node $node(10606)
$ns at 316 "$BGP10606 command \"show ip bgp\""

#puts "Creating Router 10609"
set node(10609) [$ns node]
set BGP10609 [new Application/Route/Bgp]
$BGP10609 register  $r

$BGP10609 config-file $opt(dir)/bgpd10609.conf
$BGP10609 attach-node $node(10609)
$ns at 316 "$BGP10609 command \"show ip bgp\""

#puts "Creating Router 10618"
set node(10618) [$ns node]
set BGP10618 [new Application/Route/Bgp]
$BGP10618 register  $r

$BGP10618 config-file $opt(dir)/bgpd10618.conf
$BGP10618 attach-node $node(10618)
$ns at 316 "$BGP10618 command \"show ip bgp\""

#puts "Creating Router 10621"
set node(10621) [$ns node]
set BGP10621 [new Application/Route/Bgp]
$BGP10621 register  $r

$BGP10621 config-file $opt(dir)/bgpd10621.conf
$BGP10621 attach-node $node(10621)
$ns at 316 "$BGP10621 command \"show ip bgp\""

#puts "Creating Router 10631"
set node(10631) [$ns node]
set BGP10631 [new Application/Route/Bgp]
$BGP10631 register  $r

$BGP10631 config-file $opt(dir)/bgpd10631.conf
$BGP10631 attach-node $node(10631)
$ns at 316 "$BGP10631 command \"show ip bgp\""

#puts "Creating Router 10654"
set node(10654) [$ns node]
set BGP10654 [new Application/Route/Bgp]
$BGP10654 register  $r

$BGP10654 config-file $opt(dir)/bgpd10654.conf
$BGP10654 attach-node $node(10654)
$ns at 316 "$BGP10654 command \"show ip bgp\""

#puts "Creating Router 10656"
set node(10656) [$ns node]
set BGP10656 [new Application/Route/Bgp]
$BGP10656 register  $r

$BGP10656 config-file $opt(dir)/bgpd10656.conf
$BGP10656 attach-node $node(10656)
$ns at 316 "$BGP10656 command \"show ip bgp\""

#puts "Creating Router 10661"
set node(10661) [$ns node]
set BGP10661 [new Application/Route/Bgp]
$BGP10661 register  $r

$BGP10661 config-file $opt(dir)/bgpd10661.conf
$BGP10661 attach-node $node(10661)
$ns at 316 "$BGP10661 command \"show ip bgp\""

#puts "Creating Router 10671"
set node(10671) [$ns node]
set BGP10671 [new Application/Route/Bgp]
$BGP10671 register  $r

$BGP10671 config-file $opt(dir)/bgpd10671.conf
$BGP10671 attach-node $node(10671)
$ns at 316 "$BGP10671 command \"show ip bgp\""

#puts "Creating Router 10674"
set node(10674) [$ns node]
set BGP10674 [new Application/Route/Bgp]
$BGP10674 register  $r

$BGP10674 config-file $opt(dir)/bgpd10674.conf
$BGP10674 attach-node $node(10674)
$ns at 316 "$BGP10674 command \"show ip bgp\""

#puts "Creating Router 10684"
set node(10684) [$ns node]
set BGP10684 [new Application/Route/Bgp]
$BGP10684 register  $r

$BGP10684 config-file $opt(dir)/bgpd10684.conf
$BGP10684 attach-node $node(10684)
$ns at 316 "$BGP10684 command \"show ip bgp\""

#puts "Creating Router 10689"
set node(10689) [$ns node]
set BGP10689 [new Application/Route/Bgp]
$BGP10689 register  $r

$BGP10689 config-file $opt(dir)/bgpd10689.conf
$BGP10689 attach-node $node(10689)
$ns at 316 "$BGP10689 command \"show ip bgp\""

#puts "Creating Router 10691"
set node(10691) [$ns node]
set BGP10691 [new Application/Route/Bgp]
$BGP10691 register  $r

$BGP10691 config-file $opt(dir)/bgpd10691.conf
$BGP10691 attach-node $node(10691)
$ns at 316 "$BGP10691 command \"show ip bgp\""

#puts "Creating Router 10692"
set node(10692) [$ns node]
set BGP10692 [new Application/Route/Bgp]
$BGP10692 register  $r

$BGP10692 config-file $opt(dir)/bgpd10692.conf
$BGP10692 attach-node $node(10692)
$ns at 316 "$BGP10692 command \"show ip bgp\""

#puts "Creating Router 10708"
set node(10708) [$ns node]
set BGP10708 [new Application/Route/Bgp]
$BGP10708 register  $r

$BGP10708 config-file $opt(dir)/bgpd10708.conf
$BGP10708 attach-node $node(10708)
$ns at 316 "$BGP10708 command \"show ip bgp\""

#puts "Creating Router 10711"
set node(10711) [$ns node]
set BGP10711 [new Application/Route/Bgp]
$BGP10711 register  $r

$BGP10711 config-file $opt(dir)/bgpd10711.conf
$BGP10711 attach-node $node(10711)
$ns at 316 "$BGP10711 command \"show ip bgp\""

#puts "Creating Router 10725"
set node(10725) [$ns node]
set BGP10725 [new Application/Route/Bgp]
$BGP10725 register  $r

$BGP10725 config-file $opt(dir)/bgpd10725.conf
$BGP10725 attach-node $node(10725)
$ns at 316 "$BGP10725 command \"show ip bgp\""

#puts "Creating Router 10732"
set node(10732) [$ns node]
set BGP10732 [new Application/Route/Bgp]
$BGP10732 register  $r

$BGP10732 config-file $opt(dir)/bgpd10732.conf
$BGP10732 attach-node $node(10732)
$ns at 316 "$BGP10732 command \"show ip bgp\""

#puts "Creating Router 10734"
set node(10734) [$ns node]
set BGP10734 [new Application/Route/Bgp]
$BGP10734 register  $r

$BGP10734 config-file $opt(dir)/bgpd10734.conf
$BGP10734 attach-node $node(10734)
$ns at 316 "$BGP10734 command \"show ip bgp\""

#puts "Creating Router 10746"
set node(10746) [$ns node]
set BGP10746 [new Application/Route/Bgp]
$BGP10746 register  $r

$BGP10746 config-file $opt(dir)/bgpd10746.conf
$BGP10746 attach-node $node(10746)
$ns at 316 "$BGP10746 command \"show ip bgp\""

#puts "Creating Router 10748"
set node(10748) [$ns node]
set BGP10748 [new Application/Route/Bgp]
$BGP10748 register  $r

$BGP10748 config-file $opt(dir)/bgpd10748.conf
$BGP10748 attach-node $node(10748)
$ns at 316 "$BGP10748 command \"show ip bgp\""

#puts "Creating Router 10749"
set node(10749) [$ns node]
set BGP10749 [new Application/Route/Bgp]
$BGP10749 register  $r

$BGP10749 config-file $opt(dir)/bgpd10749.conf
$BGP10749 attach-node $node(10749)
$ns at 316 "$BGP10749 command \"show ip bgp\""

#puts "Creating Router 10757"
set node(10757) [$ns node]
set BGP10757 [new Application/Route/Bgp]
$BGP10757 register  $r

$BGP10757 config-file $opt(dir)/bgpd10757.conf
$BGP10757 attach-node $node(10757)
$ns at 316 "$BGP10757 command \"show ip bgp\""

#puts "Creating Router 10766"
set node(10766) [$ns node]
set BGP10766 [new Application/Route/Bgp]
$BGP10766 register  $r

$BGP10766 config-file $opt(dir)/bgpd10766.conf
$BGP10766 attach-node $node(10766)
$ns at 316 "$BGP10766 command \"show ip bgp\""

#puts "Creating Router 10771"
set node(10771) [$ns node]
set BGP10771 [new Application/Route/Bgp]
$BGP10771 register  $r

$BGP10771 config-file $opt(dir)/bgpd10771.conf
$BGP10771 attach-node $node(10771)
$ns at 316 "$BGP10771 command \"show ip bgp\""

#puts "Creating Router 10793"
set node(10793) [$ns node]
set BGP10793 [new Application/Route/Bgp]
$BGP10793 register  $r

$BGP10793 config-file $opt(dir)/bgpd10793.conf
$BGP10793 attach-node $node(10793)
$ns at 316 "$BGP10793 command \"show ip bgp\""

#puts "Creating Router 10814"
set node(10814) [$ns node]
set BGP10814 [new Application/Route/Bgp]
$BGP10814 register  $r

$BGP10814 config-file $opt(dir)/bgpd10814.conf
$BGP10814 attach-node $node(10814)
$ns at 316 "$BGP10814 command \"show ip bgp\""

#puts "Creating Router 10821"
set node(10821) [$ns node]
set BGP10821 [new Application/Route/Bgp]
$BGP10821 register  $r

$BGP10821 config-file $opt(dir)/bgpd10821.conf
$BGP10821 attach-node $node(10821)
$ns at 316 "$BGP10821 command \"show ip bgp\""

#puts "Creating Router 10823"
set node(10823) [$ns node]
set BGP10823 [new Application/Route/Bgp]
$BGP10823 register  $r

$BGP10823 config-file $opt(dir)/bgpd10823.conf
$BGP10823 attach-node $node(10823)
$ns at 316 "$BGP10823 command \"show ip bgp\""

#puts "Creating Router 10834"
set node(10834) [$ns node]
set BGP10834 [new Application/Route/Bgp]
$BGP10834 register  $r

$BGP10834 config-file $opt(dir)/bgpd10834.conf
$BGP10834 attach-node $node(10834)
$ns at 316 "$BGP10834 command \"show ip bgp\""

#puts "Creating Router 10839"
set node(10839) [$ns node]
set BGP10839 [new Application/Route/Bgp]
$BGP10839 register  $r

$BGP10839 config-file $opt(dir)/bgpd10839.conf
$BGP10839 attach-node $node(10839)
$ns at 316 "$BGP10839 command \"show ip bgp\""

#puts "Creating Router 10843"
set node(10843) [$ns node]
set BGP10843 [new Application/Route/Bgp]
$BGP10843 register  $r

$BGP10843 config-file $opt(dir)/bgpd10843.conf
$BGP10843 attach-node $node(10843)
$ns at 316 "$BGP10843 command \"show ip bgp\""

#puts "Creating Router 10887"
set node(10887) [$ns node]
set BGP10887 [new Application/Route/Bgp]
$BGP10887 register  $r

$BGP10887 config-file $opt(dir)/bgpd10887.conf
$BGP10887 attach-node $node(10887)
$ns at 316 "$BGP10887 command \"show ip bgp\""

#puts "Creating Router 1103"
set node(1103) [$ns node]
set BGP1103 [new Application/Route/Bgp]
$BGP1103 register  $r

$BGP1103 config-file $opt(dir)/bgpd1103.conf
$BGP1103 attach-node $node(1103)
$ns at 316 "$BGP1103 command \"show ip bgp\""

#puts "Creating Router 1129"
set node(1129) [$ns node]
set BGP1129 [new Application/Route/Bgp]
$BGP1129 register  $r

$BGP1129 config-file $opt(dir)/bgpd1129.conf
$BGP1129 attach-node $node(1129)
$ns at 316 "$BGP1129 command \"show ip bgp\""

#puts "Creating Router 1133"
set node(1133) [$ns node]
set BGP1133 [new Application/Route/Bgp]
$BGP1133 register  $r

$BGP1133 config-file $opt(dir)/bgpd1133.conf
$BGP1133 attach-node $node(1133)
$ns at 316 "$BGP1133 command \"show ip bgp\""

#puts "Creating Router 1136"
set node(1136) [$ns node]
set BGP1136 [new Application/Route/Bgp]
$BGP1136 register  $r

$BGP1136 config-file $opt(dir)/bgpd1136.conf
$BGP1136 attach-node $node(1136)
$ns at 316 "$BGP1136 command \"show ip bgp\""

#puts "Creating Router 1137"
set node(1137) [$ns node]
set BGP1137 [new Application/Route/Bgp]
$BGP1137 register  $r

$BGP1137 config-file $opt(dir)/bgpd1137.conf
$BGP1137 attach-node $node(1137)
$ns at 316 "$BGP1137 command \"show ip bgp\""

#puts "Creating Router 1138"
set node(1138) [$ns node]
set BGP1138 [new Application/Route/Bgp]
$BGP1138 register  $r

$BGP1138 config-file $opt(dir)/bgpd1138.conf
$BGP1138 attach-node $node(1138)
$ns at 316 "$BGP1138 command \"show ip bgp\""

#puts "Creating Router 114"
set node(114) [$ns node]
set BGP114 [new Application/Route/Bgp]
$BGP114 register  $r

$BGP114 config-file $opt(dir)/bgpd114.conf
$BGP114 attach-node $node(114)
$ns at 316 "$BGP114 command \"show ip bgp\""

#puts "Creating Router 1140"
set node(1140) [$ns node]
set BGP1140 [new Application/Route/Bgp]
$BGP1140 register  $r

$BGP1140 config-file $opt(dir)/bgpd1140.conf
$BGP1140 attach-node $node(1140)
$ns at 316 "$BGP1140 command \"show ip bgp\""

#puts "Creating Router 1198"
set node(1198) [$ns node]
set BGP1198 [new Application/Route/Bgp]
$BGP1198 register  $r

$BGP1198 config-file $opt(dir)/bgpd1198.conf
$BGP1198 attach-node $node(1198)
$ns at 316 "$BGP1198 command \"show ip bgp\""

#puts "Creating Router 1201"
set node(1201) [$ns node]
set BGP1201 [new Application/Route/Bgp]
$BGP1201 register  $r

$BGP1201 config-file $opt(dir)/bgpd1201.conf
$BGP1201 attach-node $node(1201)
$ns at 316 "$BGP1201 command \"show ip bgp\""

#puts "Creating Router 1205"
set node(1205) [$ns node]
set BGP1205 [new Application/Route/Bgp]
$BGP1205 register  $r

$BGP1205 config-file $opt(dir)/bgpd1205.conf
$BGP1205 attach-node $node(1205)
$ns at 316 "$BGP1205 command \"show ip bgp\""

#puts "Creating Router 1206"
set node(1206) [$ns node]
set BGP1206 [new Application/Route/Bgp]
$BGP1206 register  $r

$BGP1206 config-file $opt(dir)/bgpd1206.conf
$BGP1206 attach-node $node(1206)
$ns at 316 "$BGP1206 command \"show ip bgp\""

#puts "Creating Router 1213"
set node(1213) [$ns node]
set BGP1213 [new Application/Route/Bgp]
$BGP1213 register  $r

$BGP1213 config-file $opt(dir)/bgpd1213.conf
$BGP1213 attach-node $node(1213)
$ns at 316 "$BGP1213 command \"show ip bgp\""

#puts "Creating Router 1220"
set node(1220) [$ns node]
set BGP1220 [new Application/Route/Bgp]
$BGP1220 register  $r

$BGP1220 config-file $opt(dir)/bgpd1220.conf
$BGP1220 attach-node $node(1220)
$ns at 316 "$BGP1220 command \"show ip bgp\""

#puts "Creating Router 1221"
set node(1221) [$ns node]
set BGP1221 [new Application/Route/Bgp]
$BGP1221 register  $r

$BGP1221 config-file $opt(dir)/bgpd1221.conf
$BGP1221 attach-node $node(1221)
$ns at 316 "$BGP1221 command \"show ip bgp\""

#puts "Creating Router 1225"
set node(1225) [$ns node]
set BGP1225 [new Application/Route/Bgp]
$BGP1225 register  $r

$BGP1225 config-file $opt(dir)/bgpd1225.conf
$BGP1225 attach-node $node(1225)
$ns at 316 "$BGP1225 command \"show ip bgp\""

#puts "Creating Router 1237"
set node(1237) [$ns node]
set BGP1237 [new Application/Route/Bgp]
$BGP1237 register  $r

$BGP1237 config-file $opt(dir)/bgpd1237.conf
$BGP1237 attach-node $node(1237)
$ns at 316 "$BGP1237 command \"show ip bgp\""

#puts "Creating Router 1239"
set node(1239) [$ns node]
set BGP1239 [new Application/Route/Bgp]
$BGP1239 register  $r

$BGP1239 config-file $opt(dir)/bgpd1239.conf
$BGP1239 attach-node $node(1239)
$ns at 316 "$BGP1239 command \"show ip bgp\""

#puts "Creating Router 1241"
set node(1241) [$ns node]
set BGP1241 [new Application/Route/Bgp]
$BGP1241 register  $r

$BGP1241 config-file $opt(dir)/bgpd1241.conf
$BGP1241 attach-node $node(1241)
$ns at 316 "$BGP1241 command \"show ip bgp\""

#puts "Creating Router 1257"
set node(1257) [$ns node]
set BGP1257 [new Application/Route/Bgp]
$BGP1257 register  $r

$BGP1257 config-file $opt(dir)/bgpd1257.conf
$BGP1257 attach-node $node(1257)
$ns at 316 "$BGP1257 command \"show ip bgp\""

#puts "Creating Router 1263"
set node(1263) [$ns node]
set BGP1263 [new Application/Route/Bgp]
$BGP1263 register  $r

$BGP1263 config-file $opt(dir)/bgpd1263.conf
$BGP1263 attach-node $node(1263)
$ns at 316 "$BGP1263 command \"show ip bgp\""

#puts "Creating Router 1267"
set node(1267) [$ns node]
set BGP1267 [new Application/Route/Bgp]
$BGP1267 register  $r

$BGP1267 config-file $opt(dir)/bgpd1267.conf
$BGP1267 attach-node $node(1267)
$ns at 316 "$BGP1267 command \"show ip bgp\""

#puts "Creating Router 1270"
set node(1270) [$ns node]
set BGP1270 [new Application/Route/Bgp]
$BGP1270 register  $r

$BGP1270 config-file $opt(dir)/bgpd1270.conf
$BGP1270 attach-node $node(1270)
$ns at 316 "$BGP1270 command \"show ip bgp\""

#puts "Creating Router 1273"
set node(1273) [$ns node]
set BGP1273 [new Application/Route/Bgp]
$BGP1273 register  $r

$BGP1273 config-file $opt(dir)/bgpd1273.conf
$BGP1273 attach-node $node(1273)
$ns at 316 "$BGP1273 command \"show ip bgp\""

#puts "Creating Router 1275"
set node(1275) [$ns node]
set BGP1275 [new Application/Route/Bgp]
$BGP1275 register  $r

$BGP1275 config-file $opt(dir)/bgpd1275.conf
$BGP1275 attach-node $node(1275)
$ns at 316 "$BGP1275 command \"show ip bgp\""

#puts "Creating Router 1280"
set node(1280) [$ns node]
set BGP1280 [new Application/Route/Bgp]
$BGP1280 register  $r

$BGP1280 config-file $opt(dir)/bgpd1280.conf
$BGP1280 attach-node $node(1280)
$ns at 316 "$BGP1280 command \"show ip bgp\""

#puts "Creating Router 1290"
set node(1290) [$ns node]
set BGP1290 [new Application/Route/Bgp]
$BGP1290 register  $r

$BGP1290 config-file $opt(dir)/bgpd1290.conf
$BGP1290 attach-node $node(1290)
$ns at 316 "$BGP1290 command \"show ip bgp\""

#puts "Creating Router 1292"
set node(1292) [$ns node]
set BGP1292 [new Application/Route/Bgp]
$BGP1292 register  $r

$BGP1292 config-file $opt(dir)/bgpd1292.conf
$BGP1292 attach-node $node(1292)
$ns at 316 "$BGP1292 command \"show ip bgp\""

#puts "Creating Router 1299"
set node(1299) [$ns node]
set BGP1299 [new Application/Route/Bgp]
$BGP1299 register  $r

$BGP1299 config-file $opt(dir)/bgpd1299.conf
$BGP1299 attach-node $node(1299)
$ns at 316 "$BGP1299 command \"show ip bgp\""

#puts "Creating Router 13"
set node(13) [$ns node]
set BGP13 [new Application/Route/Bgp]
$BGP13 register  $r

$BGP13 config-file $opt(dir)/bgpd13.conf
$BGP13 attach-node $node(13)
$ns at 316 "$BGP13 command \"show ip bgp\""

#puts "Creating Router 1312"
set node(1312) [$ns node]
set BGP1312 [new Application/Route/Bgp]
$BGP1312 register  $r

$BGP1312 config-file $opt(dir)/bgpd1312.conf
$BGP1312 attach-node $node(1312)
$ns at 316 "$BGP1312 command \"show ip bgp\""

#puts "Creating Router 132"
set node(132) [$ns node]
set BGP132 [new Application/Route/Bgp]
$BGP132 register  $r

$BGP132 config-file $opt(dir)/bgpd132.conf
$BGP132 attach-node $node(132)
$ns at 316 "$BGP132 command \"show ip bgp\""

#puts "Creating Router 1321"
set node(1321) [$ns node]
set BGP1321 [new Application/Route/Bgp]
$BGP1321 register  $r

$BGP1321 config-file $opt(dir)/bgpd1321.conf
$BGP1321 attach-node $node(1321)
$ns at 316 "$BGP1321 command \"show ip bgp\""

#puts "Creating Router 1322"
set node(1322) [$ns node]
set BGP1322 [new Application/Route/Bgp]
$BGP1322 register  $r

$BGP1322 config-file $opt(dir)/bgpd1322.conf
$BGP1322 attach-node $node(1322)
$ns at 316 "$BGP1322 command \"show ip bgp\""

#puts "Creating Router 1323"
set node(1323) [$ns node]
set BGP1323 [new Application/Route/Bgp]
$BGP1323 register  $r

$BGP1323 config-file $opt(dir)/bgpd1323.conf
$BGP1323 attach-node $node(1323)
$ns at 316 "$BGP1323 command \"show ip bgp\""

#puts "Creating Router 1324"
set node(1324) [$ns node]
set BGP1324 [new Application/Route/Bgp]
$BGP1324 register  $r

$BGP1324 config-file $opt(dir)/bgpd1324.conf
$BGP1324 attach-node $node(1324)
$ns at 316 "$BGP1324 command \"show ip bgp\""

#puts "Creating Router 1325"
set node(1325) [$ns node]
set BGP1325 [new Application/Route/Bgp]
$BGP1325 register  $r

$BGP1325 config-file $opt(dir)/bgpd1325.conf
$BGP1325 attach-node $node(1325)
$ns at 316 "$BGP1325 command \"show ip bgp\""

#puts "Creating Router 1326"
set node(1326) [$ns node]
set BGP1326 [new Application/Route/Bgp]
$BGP1326 register  $r

$BGP1326 config-file $opt(dir)/bgpd1326.conf
$BGP1326 attach-node $node(1326)
$ns at 316 "$BGP1326 command \"show ip bgp\""

#puts "Creating Router 1327"
set node(1327) [$ns node]
set BGP1327 [new Application/Route/Bgp]
$BGP1327 register  $r

$BGP1327 config-file $opt(dir)/bgpd1327.conf
$BGP1327 attach-node $node(1327)
$ns at 316 "$BGP1327 command \"show ip bgp\""

#puts "Creating Router 1328"
set node(1328) [$ns node]
set BGP1328 [new Application/Route/Bgp]
$BGP1328 register  $r

$BGP1328 config-file $opt(dir)/bgpd1328.conf
$BGP1328 attach-node $node(1328)
$ns at 316 "$BGP1328 command \"show ip bgp\""

#puts "Creating Router 1330"
set node(1330) [$ns node]
set BGP1330 [new Application/Route/Bgp]
$BGP1330 register  $r

$BGP1330 config-file $opt(dir)/bgpd1330.conf
$BGP1330 attach-node $node(1330)
$ns at 316 "$BGP1330 command \"show ip bgp\""

#puts "Creating Router 1331"
set node(1331) [$ns node]
set BGP1331 [new Application/Route/Bgp]
$BGP1331 register  $r

$BGP1331 config-file $opt(dir)/bgpd1331.conf
$BGP1331 attach-node $node(1331)
$ns at 316 "$BGP1331 command \"show ip bgp\""

#puts "Creating Router 1332"
set node(1332) [$ns node]
set BGP1332 [new Application/Route/Bgp]
$BGP1332 register  $r

$BGP1332 config-file $opt(dir)/bgpd1332.conf
$BGP1332 attach-node $node(1332)
$ns at 316 "$BGP1332 command \"show ip bgp\""

#puts "Creating Router 1333"
set node(1333) [$ns node]
set BGP1333 [new Application/Route/Bgp]
$BGP1333 register  $r

$BGP1333 config-file $opt(dir)/bgpd1333.conf
$BGP1333 attach-node $node(1333)
$ns at 316 "$BGP1333 command \"show ip bgp\""

#puts "Creating Router 1334"
set node(1334) [$ns node]
set BGP1334 [new Application/Route/Bgp]
$BGP1334 register  $r

$BGP1334 config-file $opt(dir)/bgpd1334.conf
$BGP1334 attach-node $node(1334)
$ns at 316 "$BGP1334 command \"show ip bgp\""

#puts "Creating Router 1335"
set node(1335) [$ns node]
set BGP1335 [new Application/Route/Bgp]
$BGP1335 register  $r

$BGP1335 config-file $opt(dir)/bgpd1335.conf
$BGP1335 attach-node $node(1335)
$ns at 316 "$BGP1335 command \"show ip bgp\""

#puts "Creating Router 1347"
set node(1347) [$ns node]
set BGP1347 [new Application/Route/Bgp]
$BGP1347 register  $r

$BGP1347 config-file $opt(dir)/bgpd1347.conf
$BGP1347 attach-node $node(1347)
$ns at 316 "$BGP1347 command \"show ip bgp\""

#puts "Creating Router 137"
set node(137) [$ns node]
set BGP137 [new Application/Route/Bgp]
$BGP137 register  $r

$BGP137 config-file $opt(dir)/bgpd137.conf
$BGP137 attach-node $node(137)
$ns at 316 "$BGP137 command \"show ip bgp\""

#puts "Creating Router 145"
set node(145) [$ns node]
set BGP145 [new Application/Route/Bgp]
$BGP145 register  $r

$BGP145 config-file $opt(dir)/bgpd145.conf
$BGP145 attach-node $node(145)
$ns at 316 "$BGP145 command \"show ip bgp\""

#puts "Creating Router 146"
set node(146) [$ns node]
set BGP146 [new Application/Route/Bgp]
$BGP146 register  $r

$BGP146 config-file $opt(dir)/bgpd146.conf
$BGP146 attach-node $node(146)
$ns at 316 "$BGP146 command \"show ip bgp\""

#puts "Creating Router 160"
set node(160) [$ns node]
set BGP160 [new Application/Route/Bgp]
$BGP160 register  $r

$BGP160 config-file $opt(dir)/bgpd160.conf
$BGP160 attach-node $node(160)
$ns at 316 "$BGP160 command \"show ip bgp\""

#puts "Creating Router 1653"
set node(1653) [$ns node]
set BGP1653 [new Application/Route/Bgp]
$BGP1653 register  $r

$BGP1653 config-file $opt(dir)/bgpd1653.conf
$BGP1653 attach-node $node(1653)
$ns at 316 "$BGP1653 command \"show ip bgp\""

#puts "Creating Router 1662"
set node(1662) [$ns node]
set BGP1662 [new Application/Route/Bgp]
$BGP1662 register  $r

$BGP1662 config-file $opt(dir)/bgpd1662.conf
$BGP1662 attach-node $node(1662)
$ns at 316 "$BGP1662 command \"show ip bgp\""

#puts "Creating Router 1664"
set node(1664) [$ns node]
set BGP1664 [new Application/Route/Bgp]
$BGP1664 register  $r

$BGP1664 config-file $opt(dir)/bgpd1664.conf
$BGP1664 attach-node $node(1664)
$ns at 316 "$BGP1664 command \"show ip bgp\""

#puts "Creating Router 1667"
set node(1667) [$ns node]
set BGP1667 [new Application/Route/Bgp]
$BGP1667 register  $r

$BGP1667 config-file $opt(dir)/bgpd1667.conf
$BGP1667 attach-node $node(1667)
$ns at 316 "$BGP1667 command \"show ip bgp\""

#puts "Creating Router 1670"
set node(1670) [$ns node]
set BGP1670 [new Application/Route/Bgp]
$BGP1670 register  $r

$BGP1670 config-file $opt(dir)/bgpd1670.conf
$BGP1670 attach-node $node(1670)
$ns at 316 "$BGP1670 command \"show ip bgp\""

#puts "Creating Router 1673"
set node(1673) [$ns node]
set BGP1673 [new Application/Route/Bgp]
$BGP1673 register  $r

$BGP1673 config-file $opt(dir)/bgpd1673.conf
$BGP1673 attach-node $node(1673)
$ns at 316 "$BGP1673 command \"show ip bgp\""

#puts "Creating Router 1675"
set node(1675) [$ns node]
set BGP1675 [new Application/Route/Bgp]
$BGP1675 register  $r

$BGP1675 config-file $opt(dir)/bgpd1675.conf
$BGP1675 attach-node $node(1675)
$ns at 316 "$BGP1675 command \"show ip bgp\""

#puts "Creating Router 1677"
set node(1677) [$ns node]
set BGP1677 [new Application/Route/Bgp]
$BGP1677 register  $r

$BGP1677 config-file $opt(dir)/bgpd1677.conf
$BGP1677 attach-node $node(1677)
$ns at 316 "$BGP1677 command \"show ip bgp\""

#puts "Creating Router 1686"
set node(1686) [$ns node]
set BGP1686 [new Application/Route/Bgp]
$BGP1686 register  $r

$BGP1686 config-file $opt(dir)/bgpd1686.conf
$BGP1686 attach-node $node(1686)
$ns at 316 "$BGP1686 command \"show ip bgp\""

#puts "Creating Router 1691"
set node(1691) [$ns node]
set BGP1691 [new Application/Route/Bgp]
$BGP1691 register  $r

$BGP1691 config-file $opt(dir)/bgpd1691.conf
$BGP1691 attach-node $node(1691)
$ns at 316 "$BGP1691 command \"show ip bgp\""

#puts "Creating Router 1694"
set node(1694) [$ns node]
set BGP1694 [new Application/Route/Bgp]
$BGP1694 register  $r

$BGP1694 config-file $opt(dir)/bgpd1694.conf
$BGP1694 attach-node $node(1694)
$ns at 316 "$BGP1694 command \"show ip bgp\""

#puts "Creating Router 1699"
set node(1699) [$ns node]
set BGP1699 [new Application/Route/Bgp]
$BGP1699 register  $r

$BGP1699 config-file $opt(dir)/bgpd1699.conf
$BGP1699 attach-node $node(1699)
$ns at 316 "$BGP1699 command \"show ip bgp\""

#puts "Creating Router 17"
set node(17) [$ns node]
set BGP17 [new Application/Route/Bgp]
$BGP17 register  $r

$BGP17 config-file $opt(dir)/bgpd17.conf
$BGP17 attach-node $node(17)
$ns at 316 "$BGP17 command \"show ip bgp\""

#puts "Creating Router 1717"
set node(1717) [$ns node]
set BGP1717 [new Application/Route/Bgp]
$BGP1717 register  $r

$BGP1717 config-file $opt(dir)/bgpd1717.conf
$BGP1717 attach-node $node(1717)
$ns at 316 "$BGP1717 command \"show ip bgp\""

#puts "Creating Router 174"
set node(174) [$ns node]
set BGP174 [new Application/Route/Bgp]
$BGP174 register  $r

$BGP174 config-file $opt(dir)/bgpd174.conf
$BGP174 attach-node $node(174)
$ns at 316 "$BGP174 command \"show ip bgp\""

#puts "Creating Router 1740"
set node(1740) [$ns node]
set BGP1740 [new Application/Route/Bgp]
$BGP1740 register  $r

$BGP1740 config-file $opt(dir)/bgpd1740.conf
$BGP1740 attach-node $node(1740)
$ns at 316 "$BGP1740 command \"show ip bgp\""

#puts "Creating Router 1741"
set node(1741) [$ns node]
set BGP1741 [new Application/Route/Bgp]
$BGP1741 register  $r

$BGP1741 config-file $opt(dir)/bgpd1741.conf
$BGP1741 attach-node $node(1741)
$ns at 316 "$BGP1741 command \"show ip bgp\""

#puts "Creating Router 1742"
set node(1742) [$ns node]
set BGP1742 [new Application/Route/Bgp]
$BGP1742 register  $r

$BGP1742 config-file $opt(dir)/bgpd1742.conf
$BGP1742 attach-node $node(1742)
$ns at 316 "$BGP1742 command \"show ip bgp\""

#puts "Creating Router 1746"
set node(1746) [$ns node]
set BGP1746 [new Application/Route/Bgp]
$BGP1746 register  $r

$BGP1746 config-file $opt(dir)/bgpd1746.conf
$BGP1746 attach-node $node(1746)
$ns at 316 "$BGP1746 command \"show ip bgp\""

#puts "Creating Router 1755"
set node(1755) [$ns node]
set BGP1755 [new Application/Route/Bgp]
$BGP1755 register  $r

$BGP1755 config-file $opt(dir)/bgpd1755.conf
$BGP1755 attach-node $node(1755)
$ns at 316 "$BGP1755 command \"show ip bgp\""

#puts "Creating Router 1759"
set node(1759) [$ns node]
set BGP1759 [new Application/Route/Bgp]
$BGP1759 register  $r

$BGP1759 config-file $opt(dir)/bgpd1759.conf
$BGP1759 attach-node $node(1759)
$ns at 316 "$BGP1759 command \"show ip bgp\""

#puts "Creating Router 1760"
set node(1760) [$ns node]
set BGP1760 [new Application/Route/Bgp]
$BGP1760 register  $r

$BGP1760 config-file $opt(dir)/bgpd1760.conf
$BGP1760 attach-node $node(1760)
$ns at 316 "$BGP1760 command \"show ip bgp\""

#puts "Creating Router 1761"
set node(1761) [$ns node]
set BGP1761 [new Application/Route/Bgp]
$BGP1761 register  $r

$BGP1761 config-file $opt(dir)/bgpd1761.conf
$BGP1761 attach-node $node(1761)
$ns at 316 "$BGP1761 command \"show ip bgp\""

#puts "Creating Router 1767"
set node(1767) [$ns node]
set BGP1767 [new Application/Route/Bgp]
$BGP1767 register  $r

$BGP1767 config-file $opt(dir)/bgpd1767.conf
$BGP1767 attach-node $node(1767)
$ns at 316 "$BGP1767 command \"show ip bgp\""

#puts "Creating Router 1778"
set node(1778) [$ns node]
set BGP1778 [new Application/Route/Bgp]
$BGP1778 register  $r

$BGP1778 config-file $opt(dir)/bgpd1778.conf
$BGP1778 attach-node $node(1778)
$ns at 316 "$BGP1778 command \"show ip bgp\""

#puts "Creating Router 1784"
set node(1784) [$ns node]
set BGP1784 [new Application/Route/Bgp]
$BGP1784 register  $r

$BGP1784 config-file $opt(dir)/bgpd1784.conf
$BGP1784 attach-node $node(1784)
$ns at 316 "$BGP1784 command \"show ip bgp\""

#puts "Creating Router 1785"
set node(1785) [$ns node]
set BGP1785 [new Application/Route/Bgp]
$BGP1785 register  $r

$BGP1785 config-file $opt(dir)/bgpd1785.conf
$BGP1785 attach-node $node(1785)
$ns at 316 "$BGP1785 command \"show ip bgp\""

#puts "Creating Router 1797"
set node(1797) [$ns node]
set BGP1797 [new Application/Route/Bgp]
$BGP1797 register  $r

$BGP1797 config-file $opt(dir)/bgpd1797.conf
$BGP1797 attach-node $node(1797)
$ns at 316 "$BGP1797 command \"show ip bgp\""

#puts "Creating Router 1798"
set node(1798) [$ns node]
set BGP1798 [new Application/Route/Bgp]
$BGP1798 register  $r

$BGP1798 config-file $opt(dir)/bgpd1798.conf
$BGP1798 attach-node $node(1798)
$ns at 316 "$BGP1798 command \"show ip bgp\""

#puts "Creating Router 1800"
set node(1800) [$ns node]
set BGP1800 [new Application/Route/Bgp]
$BGP1800 register  $r

$BGP1800 config-file $opt(dir)/bgpd1800.conf
$BGP1800 attach-node $node(1800)
$ns at 316 "$BGP1800 command \"show ip bgp\""

#puts "Creating Router 1808"
set node(1808) [$ns node]
set BGP1808 [new Application/Route/Bgp]
$BGP1808 register  $r

$BGP1808 config-file $opt(dir)/bgpd1808.conf
$BGP1808 attach-node $node(1808)
$ns at 316 "$BGP1808 command \"show ip bgp\""

#puts "Creating Router 1829"
set node(1829) [$ns node]
set BGP1829 [new Application/Route/Bgp]
$BGP1829 register  $r

$BGP1829 config-file $opt(dir)/bgpd1829.conf
$BGP1829 attach-node $node(1829)
$ns at 316 "$BGP1829 command \"show ip bgp\""

#puts "Creating Router 1830"
set node(1830) [$ns node]
set BGP1830 [new Application/Route/Bgp]
$BGP1830 register  $r

$BGP1830 config-file $opt(dir)/bgpd1830.conf
$BGP1830 attach-node $node(1830)
$ns at 316 "$BGP1830 command \"show ip bgp\""

#puts "Creating Router 1831"
set node(1831) [$ns node]
set BGP1831 [new Application/Route/Bgp]
$BGP1831 register  $r

$BGP1831 config-file $opt(dir)/bgpd1831.conf
$BGP1831 attach-node $node(1831)
$ns at 316 "$BGP1831 command \"show ip bgp\""

#puts "Creating Router 1833"
set node(1833) [$ns node]
set BGP1833 [new Application/Route/Bgp]
$BGP1833 register  $r

$BGP1833 config-file $opt(dir)/bgpd1833.conf
$BGP1833 attach-node $node(1833)
$ns at 316 "$BGP1833 command \"show ip bgp\""

#puts "Creating Router 1835"
set node(1835) [$ns node]
set BGP1835 [new Application/Route/Bgp]
$BGP1835 register  $r

$BGP1835 config-file $opt(dir)/bgpd1835.conf
$BGP1835 attach-node $node(1835)
$ns at 316 "$BGP1835 command \"show ip bgp\""

#puts "Creating Router 1849"
set node(1849) [$ns node]
set BGP1849 [new Application/Route/Bgp]
$BGP1849 register  $r

$BGP1849 config-file $opt(dir)/bgpd1849.conf
$BGP1849 attach-node $node(1849)
$ns at 316 "$BGP1849 command \"show ip bgp\""

#puts "Creating Router 1850"
set node(1850) [$ns node]
set BGP1850 [new Application/Route/Bgp]
$BGP1850 register  $r

$BGP1850 config-file $opt(dir)/bgpd1850.conf
$BGP1850 attach-node $node(1850)
$ns at 316 "$BGP1850 command \"show ip bgp\""

#puts "Creating Router 1852"
set node(1852) [$ns node]
set BGP1852 [new Application/Route/Bgp]
$BGP1852 register  $r

$BGP1852 config-file $opt(dir)/bgpd1852.conf
$BGP1852 attach-node $node(1852)
$ns at 316 "$BGP1852 command \"show ip bgp\""

#puts "Creating Router 1853"
set node(1853) [$ns node]
set BGP1853 [new Application/Route/Bgp]
$BGP1853 register  $r

$BGP1853 config-file $opt(dir)/bgpd1853.conf
$BGP1853 attach-node $node(1853)
$ns at 316 "$BGP1853 command \"show ip bgp\""

#puts "Creating Router 1880"
set node(1880) [$ns node]
set BGP1880 [new Application/Route/Bgp]
$BGP1880 register  $r

$BGP1880 config-file $opt(dir)/bgpd1880.conf
$BGP1880 attach-node $node(1880)
$ns at 316 "$BGP1880 command \"show ip bgp\""

#puts "Creating Router 1887"
set node(1887) [$ns node]
set BGP1887 [new Application/Route/Bgp]
$BGP1887 register  $r

$BGP1887 config-file $opt(dir)/bgpd1887.conf
$BGP1887 attach-node $node(1887)
$ns at 316 "$BGP1887 command \"show ip bgp\""

#puts "Creating Router 1890"
set node(1890) [$ns node]
set BGP1890 [new Application/Route/Bgp]
$BGP1890 register  $r

$BGP1890 config-file $opt(dir)/bgpd1890.conf
$BGP1890 attach-node $node(1890)
$ns at 316 "$BGP1890 command \"show ip bgp\""

#puts "Creating Router 1891"
set node(1891) [$ns node]
set BGP1891 [new Application/Route/Bgp]
$BGP1891 register  $r

$BGP1891 config-file $opt(dir)/bgpd1891.conf
$BGP1891 attach-node $node(1891)
$ns at 316 "$BGP1891 command \"show ip bgp\""

#puts "Creating Router 1899"
set node(1899) [$ns node]
set BGP1899 [new Application/Route/Bgp]
$BGP1899 register  $r

$BGP1899 config-file $opt(dir)/bgpd1899.conf
$BGP1899 attach-node $node(1899)
$ns at 316 "$BGP1899 command \"show ip bgp\""

#puts "Creating Router 1901"
set node(1901) [$ns node]
set BGP1901 [new Application/Route/Bgp]
$BGP1901 register  $r

$BGP1901 config-file $opt(dir)/bgpd1901.conf
$BGP1901 attach-node $node(1901)
$ns at 316 "$BGP1901 command \"show ip bgp\""

#puts "Creating Router 1902"
set node(1902) [$ns node]
set BGP1902 [new Application/Route/Bgp]
$BGP1902 register  $r

$BGP1902 config-file $opt(dir)/bgpd1902.conf
$BGP1902 attach-node $node(1902)
$ns at 316 "$BGP1902 command \"show ip bgp\""

#puts "Creating Router 1913"
set node(1913) [$ns node]
set BGP1913 [new Application/Route/Bgp]
$BGP1913 register  $r

$BGP1913 config-file $opt(dir)/bgpd1913.conf
$BGP1913 attach-node $node(1913)
$ns at 316 "$BGP1913 command \"show ip bgp\""

#puts "Creating Router 1916"
set node(1916) [$ns node]
set BGP1916 [new Application/Route/Bgp]
$BGP1916 register  $r

$BGP1916 config-file $opt(dir)/bgpd1916.conf
$BGP1916 attach-node $node(1916)
$ns at 316 "$BGP1916 command \"show ip bgp\""

#puts "Creating Router 1930"
set node(1930) [$ns node]
set BGP1930 [new Application/Route/Bgp]
$BGP1930 register  $r

$BGP1930 config-file $opt(dir)/bgpd1930.conf
$BGP1930 attach-node $node(1930)
$ns at 316 "$BGP1930 command \"show ip bgp\""

#puts "Creating Router 1932"
set node(1932) [$ns node]
set BGP1932 [new Application/Route/Bgp]
$BGP1932 register  $r

$BGP1932 config-file $opt(dir)/bgpd1932.conf
$BGP1932 attach-node $node(1932)
$ns at 316 "$BGP1932 command \"show ip bgp\""

#puts "Creating Router 194"
set node(194) [$ns node]
set BGP194 [new Application/Route/Bgp]
$BGP194 register  $r

$BGP194 config-file $opt(dir)/bgpd194.conf
$BGP194 attach-node $node(194)
$ns at 316 "$BGP194 command \"show ip bgp\""

#puts "Creating Router 195"
set node(195) [$ns node]
set BGP195 [new Application/Route/Bgp]
$BGP195 register  $r

$BGP195 config-file $opt(dir)/bgpd195.conf
$BGP195 attach-node $node(195)
$ns at 316 "$BGP195 command \"show ip bgp\""

#puts "Creating Router 1967"
set node(1967) [$ns node]
set BGP1967 [new Application/Route/Bgp]
$BGP1967 register  $r

$BGP1967 config-file $opt(dir)/bgpd1967.conf
$BGP1967 attach-node $node(1967)
$ns at 316 "$BGP1967 command \"show ip bgp\""

#puts "Creating Router 1970"
set node(1970) [$ns node]
set BGP1970 [new Application/Route/Bgp]
$BGP1970 register  $r

$BGP1970 config-file $opt(dir)/bgpd1970.conf
$BGP1970 attach-node $node(1970)
$ns at 316 "$BGP1970 command \"show ip bgp\""

#puts "Creating Router 1975"
set node(1975) [$ns node]
set BGP1975 [new Application/Route/Bgp]
$BGP1975 register  $r

$BGP1975 config-file $opt(dir)/bgpd1975.conf
$BGP1975 attach-node $node(1975)
$ns at 316 "$BGP1975 command \"show ip bgp\""

#puts "Creating Router 1982"
set node(1982) [$ns node]
set BGP1982 [new Application/Route/Bgp]
$BGP1982 register  $r

$BGP1982 config-file $opt(dir)/bgpd1982.conf
$BGP1982 attach-node $node(1982)
$ns at 316 "$BGP1982 command \"show ip bgp\""

#puts "Creating Router 1998"
set node(1998) [$ns node]
set BGP1998 [new Application/Route/Bgp]
$BGP1998 register  $r

$BGP1998 config-file $opt(dir)/bgpd1998.conf
$BGP1998 attach-node $node(1998)
$ns at 316 "$BGP1998 command \"show ip bgp\""

#puts "Creating Router 201"
set node(201) [$ns node]
set BGP201 [new Application/Route/Bgp]
$BGP201 register  $r

$BGP201 config-file $opt(dir)/bgpd201.conf
$BGP201 attach-node $node(201)
$ns at 316 "$BGP201 command \"show ip bgp\""

#puts "Creating Router 2012"
set node(2012) [$ns node]
set BGP2012 [new Application/Route/Bgp]
$BGP2012 register  $r

$BGP2012 config-file $opt(dir)/bgpd2012.conf
$BGP2012 attach-node $node(2012)
$ns at 316 "$BGP2012 command \"show ip bgp\""

#puts "Creating Router 2015"
set node(2015) [$ns node]
set BGP2015 [new Application/Route/Bgp]
$BGP2015 register  $r

$BGP2015 config-file $opt(dir)/bgpd2015.conf
$BGP2015 attach-node $node(2015)
$ns at 316 "$BGP2015 command \"show ip bgp\""

#puts "Creating Router 2018"
set node(2018) [$ns node]
set BGP2018 [new Application/Route/Bgp]
$BGP2018 register  $r

$BGP2018 config-file $opt(dir)/bgpd2018.conf
$BGP2018 attach-node $node(2018)
$ns at 316 "$BGP2018 command \"show ip bgp\""

#puts "Creating Router 2024"
set node(2024) [$ns node]
set BGP2024 [new Application/Route/Bgp]
$BGP2024 register  $r

$BGP2024 config-file $opt(dir)/bgpd2024.conf
$BGP2024 attach-node $node(2024)
$ns at 316 "$BGP2024 command \"show ip bgp\""

#puts "Creating Router 2033"
set node(2033) [$ns node]
set BGP2033 [new Application/Route/Bgp]
$BGP2033 register  $r

$BGP2033 config-file $opt(dir)/bgpd2033.conf
$BGP2033 attach-node $node(2033)
$ns at 316 "$BGP2033 command \"show ip bgp\""

#puts "Creating Router 204"
set node(204) [$ns node]
set BGP204 [new Application/Route/Bgp]
$BGP204 register  $r

$BGP204 config-file $opt(dir)/bgpd204.conf
$BGP204 attach-node $node(204)
$ns at 316 "$BGP204 command \"show ip bgp\""

#puts "Creating Router 2041"
set node(2041) [$ns node]
set BGP2041 [new Application/Route/Bgp]
$BGP2041 register  $r

$BGP2041 config-file $opt(dir)/bgpd2041.conf
$BGP2041 attach-node $node(2041)
$ns at 316 "$BGP2041 command \"show ip bgp\""

#puts "Creating Router 2042"
set node(2042) [$ns node]
set BGP2042 [new Application/Route/Bgp]
$BGP2042 register  $r

$BGP2042 config-file $opt(dir)/bgpd2042.conf
$BGP2042 attach-node $node(2042)
$ns at 316 "$BGP2042 command \"show ip bgp\""

#puts "Creating Router 2044"
set node(2044) [$ns node]
set BGP2044 [new Application/Route/Bgp]
$BGP2044 register  $r

$BGP2044 config-file $opt(dir)/bgpd2044.conf
$BGP2044 attach-node $node(2044)
$ns at 316 "$BGP2044 command \"show ip bgp\""

#puts "Creating Router 2048"
set node(2048) [$ns node]
set BGP2048 [new Application/Route/Bgp]
$BGP2048 register  $r

$BGP2048 config-file $opt(dir)/bgpd2048.conf
$BGP2048 attach-node $node(2048)
$ns at 316 "$BGP2048 command \"show ip bgp\""

#puts "Creating Router 2052"
set node(2052) [$ns node]
set BGP2052 [new Application/Route/Bgp]
$BGP2052 register  $r

$BGP2052 config-file $opt(dir)/bgpd2052.conf
$BGP2052 attach-node $node(2052)
$ns at 316 "$BGP2052 command \"show ip bgp\""

#puts "Creating Router 209"
set node(209) [$ns node]
set BGP209 [new Application/Route/Bgp]
$BGP209 register  $r

$BGP209 config-file $opt(dir)/bgpd209.conf
$BGP209 attach-node $node(209)
$ns at 316 "$BGP209 command \"show ip bgp\""

#puts "Creating Router 2107"
set node(2107) [$ns node]
set BGP2107 [new Application/Route/Bgp]
$BGP2107 register  $r

$BGP2107 config-file $opt(dir)/bgpd2107.conf
$BGP2107 attach-node $node(2107)
$ns at 316 "$BGP2107 command \"show ip bgp\""

#puts "Creating Router 2108"
set node(2108) [$ns node]
set BGP2108 [new Application/Route/Bgp]
$BGP2108 register  $r

$BGP2108 config-file $opt(dir)/bgpd2108.conf
$BGP2108 attach-node $node(2108)
$ns at 316 "$BGP2108 command \"show ip bgp\""

#puts "Creating Router 2109"
set node(2109) [$ns node]
set BGP2109 [new Application/Route/Bgp]
$BGP2109 register  $r

$BGP2109 config-file $opt(dir)/bgpd2109.conf
$BGP2109 attach-node $node(2109)
$ns at 316 "$BGP2109 command \"show ip bgp\""

#puts "Creating Router 2118"
set node(2118) [$ns node]
set BGP2118 [new Application/Route/Bgp]
$BGP2118 register  $r

$BGP2118 config-file $opt(dir)/bgpd2118.conf
$BGP2118 attach-node $node(2118)
$ns at 316 "$BGP2118 command \"show ip bgp\""

#puts "Creating Router 2150"
set node(2150) [$ns node]
set BGP2150 [new Application/Route/Bgp]
$BGP2150 register  $r

$BGP2150 config-file $opt(dir)/bgpd2150.conf
$BGP2150 attach-node $node(2150)
$ns at 316 "$BGP2150 command \"show ip bgp\""

#puts "Creating Router 217"
set node(217) [$ns node]
set BGP217 [new Application/Route/Bgp]
$BGP217 register  $r

$BGP217 config-file $opt(dir)/bgpd217.conf
$BGP217 attach-node $node(217)
$ns at 316 "$BGP217 command \"show ip bgp\""

#puts "Creating Router 22"
set node(22) [$ns node]
set BGP22 [new Application/Route/Bgp]
$BGP22 register  $r

$BGP22 config-file $opt(dir)/bgpd22.conf
$BGP22 attach-node $node(22)
$ns at 316 "$BGP22 command \"show ip bgp\""

#puts "Creating Router 224"
set node(224) [$ns node]
set BGP224 [new Application/Route/Bgp]
$BGP224 register  $r

$BGP224 config-file $opt(dir)/bgpd224.conf
$BGP224 attach-node $node(224)
$ns at 316 "$BGP224 command \"show ip bgp\""

#puts "Creating Router 225"
set node(225) [$ns node]
set BGP225 [new Application/Route/Bgp]
$BGP225 register  $r

$BGP225 config-file $opt(dir)/bgpd225.conf
$BGP225 attach-node $node(225)
$ns at 316 "$BGP225 command \"show ip bgp\""

#puts "Creating Router 226"
set node(226) [$ns node]
set BGP226 [new Application/Route/Bgp]
$BGP226 register  $r

$BGP226 config-file $opt(dir)/bgpd226.conf
$BGP226 attach-node $node(226)
$ns at 316 "$BGP226 command \"show ip bgp\""

#puts "Creating Router 2276"
set node(2276) [$ns node]
set BGP2276 [new Application/Route/Bgp]
$BGP2276 register  $r

$BGP2276 config-file $opt(dir)/bgpd2276.conf
$BGP2276 attach-node $node(2276)
$ns at 316 "$BGP2276 command \"show ip bgp\""

#puts "Creating Router 237"
set node(237) [$ns node]
set BGP237 [new Application/Route/Bgp]
$BGP237 register  $r

$BGP237 config-file $opt(dir)/bgpd237.conf
$BGP237 attach-node $node(237)
$ns at 316 "$BGP237 command \"show ip bgp\""

#puts "Creating Router 2379"
set node(2379) [$ns node]
set BGP2379 [new Application/Route/Bgp]
$BGP2379 register  $r

$BGP2379 config-file $opt(dir)/bgpd2379.conf
$BGP2379 attach-node $node(2379)
$ns at 316 "$BGP2379 command \"show ip bgp\""

#puts "Creating Router 2380"
set node(2380) [$ns node]
set BGP2380 [new Application/Route/Bgp]
$BGP2380 register  $r

$BGP2380 config-file $opt(dir)/bgpd2380.conf
$BGP2380 attach-node $node(2380)
$ns at 316 "$BGP2380 command \"show ip bgp\""

#puts "Creating Router 2381"
set node(2381) [$ns node]
set BGP2381 [new Application/Route/Bgp]
$BGP2381 register  $r

$BGP2381 config-file $opt(dir)/bgpd2381.conf
$BGP2381 attach-node $node(2381)
$ns at 316 "$BGP2381 command \"show ip bgp\""

#puts "Creating Router 2493"
set node(2493) [$ns node]
set BGP2493 [new Application/Route/Bgp]
$BGP2493 register  $r

$BGP2493 config-file $opt(dir)/bgpd2493.conf
$BGP2493 attach-node $node(2493)
$ns at 316 "$BGP2493 command \"show ip bgp\""

#puts "Creating Router 2497"
set node(2497) [$ns node]
set BGP2497 [new Application/Route/Bgp]
$BGP2497 register  $r

$BGP2497 config-file $opt(dir)/bgpd2497.conf
$BGP2497 attach-node $node(2497)
$ns at 316 "$BGP2497 command \"show ip bgp\""

#puts "Creating Router 25"
set node(25) [$ns node]
set BGP25 [new Application/Route/Bgp]
$BGP25 register  $r

$BGP25 config-file $opt(dir)/bgpd25.conf
$BGP25 attach-node $node(25)
$ns at 316 "$BGP25 command \"show ip bgp\""

#puts "Creating Router 2500"
set node(2500) [$ns node]
set BGP2500 [new Application/Route/Bgp]
$BGP2500 register  $r

$BGP2500 config-file $opt(dir)/bgpd2500.conf
$BGP2500 attach-node $node(2500)
$ns at 316 "$BGP2500 command \"show ip bgp\""

#puts "Creating Router 2505"
set node(2505) [$ns node]
set BGP2505 [new Application/Route/Bgp]
$BGP2505 register  $r

$BGP2505 config-file $opt(dir)/bgpd2505.conf
$BGP2505 attach-node $node(2505)
$ns at 316 "$BGP2505 command \"show ip bgp\""

#puts "Creating Router 2506"
set node(2506) [$ns node]
set BGP2506 [new Application/Route/Bgp]
$BGP2506 register  $r

$BGP2506 config-file $opt(dir)/bgpd2506.conf
$BGP2506 attach-node $node(2506)
$ns at 316 "$BGP2506 command \"show ip bgp\""

#puts "Creating Router 2510"
set node(2510) [$ns node]
set BGP2510 [new Application/Route/Bgp]
$BGP2510 register  $r

$BGP2510 config-file $opt(dir)/bgpd2510.conf
$BGP2510 attach-node $node(2510)
$ns at 316 "$BGP2510 command \"show ip bgp\""

#puts "Creating Router 2512"
set node(2512) [$ns node]
set BGP2512 [new Application/Route/Bgp]
$BGP2512 register  $r

$BGP2512 config-file $opt(dir)/bgpd2512.conf
$BGP2512 attach-node $node(2512)
$ns at 316 "$BGP2512 command \"show ip bgp\""

#puts "Creating Router 2513"
set node(2513) [$ns node]
set BGP2513 [new Application/Route/Bgp]
$BGP2513 register  $r

$BGP2513 config-file $opt(dir)/bgpd2513.conf
$BGP2513 attach-node $node(2513)
$ns at 316 "$BGP2513 command \"show ip bgp\""

#puts "Creating Router 2514"
set node(2514) [$ns node]
set BGP2514 [new Application/Route/Bgp]
$BGP2514 register  $r

$BGP2514 config-file $opt(dir)/bgpd2514.conf
$BGP2514 attach-node $node(2514)
$ns at 316 "$BGP2514 command \"show ip bgp\""

#puts "Creating Router 2516"
set node(2516) [$ns node]
set BGP2516 [new Application/Route/Bgp]
$BGP2516 register  $r

$BGP2516 config-file $opt(dir)/bgpd2516.conf
$BGP2516 attach-node $node(2516)
$ns at 316 "$BGP2516 command \"show ip bgp\""

#puts "Creating Router 2519"
set node(2519) [$ns node]
set BGP2519 [new Application/Route/Bgp]
$BGP2519 register  $r

$BGP2519 config-file $opt(dir)/bgpd2519.conf
$BGP2519 attach-node $node(2519)
$ns at 316 "$BGP2519 command \"show ip bgp\""

#puts "Creating Router 2521"
set node(2521) [$ns node]
set BGP2521 [new Application/Route/Bgp]
$BGP2521 register  $r

$BGP2521 config-file $opt(dir)/bgpd2521.conf
$BGP2521 attach-node $node(2521)
$ns at 316 "$BGP2521 command \"show ip bgp\""

#puts "Creating Router 2527"
set node(2527) [$ns node]
set BGP2527 [new Application/Route/Bgp]
$BGP2527 register  $r

$BGP2527 config-file $opt(dir)/bgpd2527.conf
$BGP2527 attach-node $node(2527)
$ns at 316 "$BGP2527 command \"show ip bgp\""

#puts "Creating Router 2529"
set node(2529) [$ns node]
set BGP2529 [new Application/Route/Bgp]
$BGP2529 register  $r

$BGP2529 config-file $opt(dir)/bgpd2529.conf
$BGP2529 attach-node $node(2529)
$ns at 316 "$BGP2529 command \"show ip bgp\""

#puts "Creating Router 2532"
set node(2532) [$ns node]
set BGP2532 [new Application/Route/Bgp]
$BGP2532 register  $r

$BGP2532 config-file $opt(dir)/bgpd2532.conf
$BGP2532 attach-node $node(2532)
$ns at 316 "$BGP2532 command \"show ip bgp\""

#puts "Creating Router 2546"
set node(2546) [$ns node]
set BGP2546 [new Application/Route/Bgp]
$BGP2546 register  $r

$BGP2546 config-file $opt(dir)/bgpd2546.conf
$BGP2546 attach-node $node(2546)
$ns at 316 "$BGP2546 command \"show ip bgp\""

#puts "Creating Router 2548"
set node(2548) [$ns node]
set BGP2548 [new Application/Route/Bgp]
$BGP2548 register  $r

$BGP2548 config-file $opt(dir)/bgpd2548.conf
$BGP2548 attach-node $node(2548)
$ns at 316 "$BGP2548 command \"show ip bgp\""

#puts "Creating Router 2549"
set node(2549) [$ns node]
set BGP2549 [new Application/Route/Bgp]
$BGP2549 register  $r

$BGP2549 config-file $opt(dir)/bgpd2549.conf
$BGP2549 attach-node $node(2549)
$ns at 316 "$BGP2549 command \"show ip bgp\""

#puts "Creating Router 2551"
set node(2551) [$ns node]
set BGP2551 [new Application/Route/Bgp]
$BGP2551 register  $r

$BGP2551 config-file $opt(dir)/bgpd2551.conf
$BGP2551 attach-node $node(2551)
$ns at 316 "$BGP2551 command \"show ip bgp\""

#puts "Creating Router 2568"
set node(2568) [$ns node]
set BGP2568 [new Application/Route/Bgp]
$BGP2568 register  $r

$BGP2568 config-file $opt(dir)/bgpd2568.conf
$BGP2568 attach-node $node(2568)
$ns at 316 "$BGP2568 command \"show ip bgp\""

#puts "Creating Router 2572"
set node(2572) [$ns node]
set BGP2572 [new Application/Route/Bgp]
$BGP2572 register  $r

$BGP2572 config-file $opt(dir)/bgpd2572.conf
$BGP2572 attach-node $node(2572)
$ns at 316 "$BGP2572 command \"show ip bgp\""

#puts "Creating Router 2578"
set node(2578) [$ns node]
set BGP2578 [new Application/Route/Bgp]
$BGP2578 register  $r

$BGP2578 config-file $opt(dir)/bgpd2578.conf
$BGP2578 attach-node $node(2578)
$ns at 316 "$BGP2578 command \"show ip bgp\""

#puts "Creating Router 2588"
set node(2588) [$ns node]
set BGP2588 [new Application/Route/Bgp]
$BGP2588 register  $r

$BGP2588 config-file $opt(dir)/bgpd2588.conf
$BGP2588 attach-node $node(2588)
$ns at 316 "$BGP2588 command \"show ip bgp\""

#puts "Creating Router 2592"
set node(2592) [$ns node]
set BGP2592 [new Application/Route/Bgp]
$BGP2592 register  $r

$BGP2592 config-file $opt(dir)/bgpd2592.conf
$BGP2592 attach-node $node(2592)
$ns at 316 "$BGP2592 command \"show ip bgp\""

#puts "Creating Router 2593"
set node(2593) [$ns node]
set BGP2593 [new Application/Route/Bgp]
$BGP2593 register  $r

$BGP2593 config-file $opt(dir)/bgpd2593.conf
$BGP2593 attach-node $node(2593)
$ns at 316 "$BGP2593 command \"show ip bgp\""

#puts "Creating Router 2598"
set node(2598) [$ns node]
set BGP2598 [new Application/Route/Bgp]
$BGP2598 register  $r

$BGP2598 config-file $opt(dir)/bgpd2598.conf
$BGP2598 attach-node $node(2598)
$ns at 316 "$BGP2598 command \"show ip bgp\""

#puts "Creating Router 2602"
set node(2602) [$ns node]
set BGP2602 [new Application/Route/Bgp]
$BGP2602 register  $r

$BGP2602 config-file $opt(dir)/bgpd2602.conf
$BGP2602 attach-node $node(2602)
$ns at 316 "$BGP2602 command \"show ip bgp\""

#puts "Creating Router 2603"
set node(2603) [$ns node]
set BGP2603 [new Application/Route/Bgp]
$BGP2603 register  $r

$BGP2603 config-file $opt(dir)/bgpd2603.conf
$BGP2603 attach-node $node(2603)
$ns at 316 "$BGP2603 command \"show ip bgp\""

#puts "Creating Router 2609"
set node(2609) [$ns node]
set BGP2609 [new Application/Route/Bgp]
$BGP2609 register  $r

$BGP2609 config-file $opt(dir)/bgpd2609.conf
$BGP2609 attach-node $node(2609)
$ns at 316 "$BGP2609 command \"show ip bgp\""

#puts "Creating Router 2611"
set node(2611) [$ns node]
set BGP2611 [new Application/Route/Bgp]
$BGP2611 register  $r

$BGP2611 config-file $opt(dir)/bgpd2611.conf
$BGP2611 attach-node $node(2611)
$ns at 316 "$BGP2611 command \"show ip bgp\""

#puts "Creating Router 2614"
set node(2614) [$ns node]
set BGP2614 [new Application/Route/Bgp]
$BGP2614 register  $r

$BGP2614 config-file $opt(dir)/bgpd2614.conf
$BGP2614 attach-node $node(2614)
$ns at 316 "$BGP2614 command \"show ip bgp\""

#puts "Creating Router 2637"
set node(2637) [$ns node]
set BGP2637 [new Application/Route/Bgp]
$BGP2637 register  $r

$BGP2637 config-file $opt(dir)/bgpd2637.conf
$BGP2637 attach-node $node(2637)
$ns at 316 "$BGP2637 command \"show ip bgp\""

#puts "Creating Router 2638"
set node(2638) [$ns node]
set BGP2638 [new Application/Route/Bgp]
$BGP2638 register  $r

$BGP2638 config-file $opt(dir)/bgpd2638.conf
$BGP2638 attach-node $node(2638)
$ns at 316 "$BGP2638 command \"show ip bgp\""

#puts "Creating Router 2652"
set node(2652) [$ns node]
set BGP2652 [new Application/Route/Bgp]
$BGP2652 register  $r

$BGP2652 config-file $opt(dir)/bgpd2652.conf
$BGP2652 attach-node $node(2652)
$ns at 316 "$BGP2652 command \"show ip bgp\""

#puts "Creating Router 266"
set node(266) [$ns node]
set BGP266 [new Application/Route/Bgp]
$BGP266 register  $r

$BGP266 config-file $opt(dir)/bgpd266.conf
$BGP266 attach-node $node(266)
$ns at 316 "$BGP266 command \"show ip bgp\""

#puts "Creating Router 2683"
set node(2683) [$ns node]
set BGP2683 [new Application/Route/Bgp]
$BGP2683 register  $r

$BGP2683 config-file $opt(dir)/bgpd2683.conf
$BGP2683 attach-node $node(2683)
$ns at 316 "$BGP2683 command \"show ip bgp\""

#puts "Creating Router 2685"
set node(2685) [$ns node]
set BGP2685 [new Application/Route/Bgp]
$BGP2685 register  $r

$BGP2685 config-file $opt(dir)/bgpd2685.conf
$BGP2685 attach-node $node(2685)
$ns at 316 "$BGP2685 command \"show ip bgp\""

#puts "Creating Router 2686"
set node(2686) [$ns node]
set BGP2686 [new Application/Route/Bgp]
$BGP2686 register  $r

$BGP2686 config-file $opt(dir)/bgpd2686.conf
$BGP2686 attach-node $node(2686)
$ns at 316 "$BGP2686 command \"show ip bgp\""

#puts "Creating Router 2687"
set node(2687) [$ns node]
set BGP2687 [new Application/Route/Bgp]
$BGP2687 register  $r

$BGP2687 config-file $opt(dir)/bgpd2687.conf
$BGP2687 attach-node $node(2687)
$ns at 316 "$BGP2687 command \"show ip bgp\""

#puts "Creating Router 2688"
set node(2688) [$ns node]
set BGP2688 [new Application/Route/Bgp]
$BGP2688 register  $r

$BGP2688 config-file $opt(dir)/bgpd2688.conf
$BGP2688 attach-node $node(2688)
$ns at 316 "$BGP2688 command \"show ip bgp\""

#puts "Creating Router 2697"
set node(2697) [$ns node]
set BGP2697 [new Application/Route/Bgp]
$BGP2697 register  $r

$BGP2697 config-file $opt(dir)/bgpd2697.conf
$BGP2697 attach-node $node(2697)
$ns at 316 "$BGP2697 command \"show ip bgp\""

#puts "Creating Router 2698"
set node(2698) [$ns node]
set BGP2698 [new Application/Route/Bgp]
$BGP2698 register  $r

$BGP2698 config-file $opt(dir)/bgpd2698.conf
$BGP2698 attach-node $node(2698)
$ns at 316 "$BGP2698 command \"show ip bgp\""

#puts "Creating Router 2706"
set node(2706) [$ns node]
set BGP2706 [new Application/Route/Bgp]
$BGP2706 register  $r

$BGP2706 config-file $opt(dir)/bgpd2706.conf
$BGP2706 attach-node $node(2706)
$ns at 316 "$BGP2706 command \"show ip bgp\""

#puts "Creating Router 2713"
set node(2713) [$ns node]
set BGP2713 [new Application/Route/Bgp]
$BGP2713 register  $r

$BGP2713 config-file $opt(dir)/bgpd2713.conf
$BGP2713 attach-node $node(2713)
$ns at 316 "$BGP2713 command \"show ip bgp\""

#puts "Creating Router 2764"
set node(2764) [$ns node]
set BGP2764 [new Application/Route/Bgp]
$BGP2764 register  $r

$BGP2764 config-file $opt(dir)/bgpd2764.conf
$BGP2764 attach-node $node(2764)
$ns at 316 "$BGP2764 command \"show ip bgp\""

#puts "Creating Router 2766"
set node(2766) [$ns node]
set BGP2766 [new Application/Route/Bgp]
$BGP2766 register  $r

$BGP2766 config-file $opt(dir)/bgpd2766.conf
$BGP2766 attach-node $node(2766)
$ns at 316 "$BGP2766 command \"show ip bgp\""

#puts "Creating Router 2767"
set node(2767) [$ns node]
set BGP2767 [new Application/Route/Bgp]
$BGP2767 register  $r

$BGP2767 config-file $opt(dir)/bgpd2767.conf
$BGP2767 attach-node $node(2767)
$ns at 316 "$BGP2767 command \"show ip bgp\""

#puts "Creating Router 278"
set node(278) [$ns node]
set BGP278 [new Application/Route/Bgp]
$BGP278 register  $r

$BGP278 config-file $opt(dir)/bgpd278.conf
$BGP278 attach-node $node(278)
$ns at 316 "$BGP278 command \"show ip bgp\""

#puts "Creating Router 2792"
set node(2792) [$ns node]
set BGP2792 [new Application/Route/Bgp]
$BGP2792 register  $r

$BGP2792 config-file $opt(dir)/bgpd2792.conf
$BGP2792 attach-node $node(2792)
$ns at 316 "$BGP2792 command \"show ip bgp\""

#puts "Creating Router 2820"
set node(2820) [$ns node]
set BGP2820 [new Application/Route/Bgp]
$BGP2820 register  $r

$BGP2820 config-file $opt(dir)/bgpd2820.conf
$BGP2820 attach-node $node(2820)
$ns at 316 "$BGP2820 command \"show ip bgp\""

#puts "Creating Router 2828"
set node(2828) [$ns node]
set BGP2828 [new Application/Route/Bgp]
$BGP2828 register  $r

$BGP2828 config-file $opt(dir)/bgpd2828.conf
$BGP2828 attach-node $node(2828)
$ns at 316 "$BGP2828 command \"show ip bgp\""

#puts "Creating Router 2832"
set node(2832) [$ns node]
set BGP2832 [new Application/Route/Bgp]
$BGP2832 register  $r

$BGP2832 config-file $opt(dir)/bgpd2832.conf
$BGP2832 attach-node $node(2832)
$ns at 316 "$BGP2832 command \"show ip bgp\""

#puts "Creating Router 2836"
set node(2836) [$ns node]
set BGP2836 [new Application/Route/Bgp]
$BGP2836 register  $r

$BGP2836 config-file $opt(dir)/bgpd2836.conf
$BGP2836 attach-node $node(2836)
$ns at 316 "$BGP2836 command \"show ip bgp\""

#puts "Creating Router 284"
set node(284) [$ns node]
set BGP284 [new Application/Route/Bgp]
$BGP284 register  $r

$BGP284 config-file $opt(dir)/bgpd284.conf
$BGP284 attach-node $node(284)
$ns at 316 "$BGP284 command \"show ip bgp\""

#puts "Creating Router 2840"
set node(2840) [$ns node]
set BGP2840 [new Application/Route/Bgp]
$BGP2840 register  $r

$BGP2840 config-file $opt(dir)/bgpd2840.conf
$BGP2840 attach-node $node(2840)
$ns at 316 "$BGP2840 command \"show ip bgp\""

#puts "Creating Router 2843"
set node(2843) [$ns node]
set BGP2843 [new Application/Route/Bgp]
$BGP2843 register  $r

$BGP2843 config-file $opt(dir)/bgpd2843.conf
$BGP2843 attach-node $node(2843)
$ns at 316 "$BGP2843 command \"show ip bgp\""

#puts "Creating Router 2848"
set node(2848) [$ns node]
set BGP2848 [new Application/Route/Bgp]
$BGP2848 register  $r

$BGP2848 config-file $opt(dir)/bgpd2848.conf
$BGP2848 attach-node $node(2848)
$ns at 316 "$BGP2848 command \"show ip bgp\""

#puts "Creating Router 2852"
set node(2852) [$ns node]
set BGP2852 [new Application/Route/Bgp]
$BGP2852 register  $r

$BGP2852 config-file $opt(dir)/bgpd2852.conf
$BGP2852 attach-node $node(2852)
$ns at 316 "$BGP2852 command \"show ip bgp\""

#puts "Creating Router 2853"
set node(2853) [$ns node]
set BGP2853 [new Application/Route/Bgp]
$BGP2853 register  $r

$BGP2853 config-file $opt(dir)/bgpd2853.conf
$BGP2853 attach-node $node(2853)
$ns at 316 "$BGP2853 command \"show ip bgp\""

#puts "Creating Router 2854"
set node(2854) [$ns node]
set BGP2854 [new Application/Route/Bgp]
$BGP2854 register  $r

$BGP2854 config-file $opt(dir)/bgpd2854.conf
$BGP2854 attach-node $node(2854)
$ns at 316 "$BGP2854 command \"show ip bgp\""

#puts "Creating Router 2856"
set node(2856) [$ns node]
set BGP2856 [new Application/Route/Bgp]
$BGP2856 register  $r

$BGP2856 config-file $opt(dir)/bgpd2856.conf
$BGP2856 attach-node $node(2856)
$ns at 316 "$BGP2856 command \"show ip bgp\""

#puts "Creating Router 286"
set node(286) [$ns node]
set BGP286 [new Application/Route/Bgp]
$BGP286 register  $r

$BGP286 config-file $opt(dir)/bgpd286.conf
$BGP286 attach-node $node(286)
$ns at 316 "$BGP286 command \"show ip bgp\""

#puts "Creating Router 2860"
set node(2860) [$ns node]
set BGP2860 [new Application/Route/Bgp]
$BGP2860 register  $r

$BGP2860 config-file $opt(dir)/bgpd2860.conf
$BGP2860 attach-node $node(2860)
$ns at 316 "$BGP2860 command \"show ip bgp\""

#puts "Creating Router 2871"
set node(2871) [$ns node]
set BGP2871 [new Application/Route/Bgp]
$BGP2871 register  $r

$BGP2871 config-file $opt(dir)/bgpd2871.conf
$BGP2871 attach-node $node(2871)
$ns at 316 "$BGP2871 command \"show ip bgp\""

#puts "Creating Router 2874"
set node(2874) [$ns node]
set BGP2874 [new Application/Route/Bgp]
$BGP2874 register  $r

$BGP2874 config-file $opt(dir)/bgpd2874.conf
$BGP2874 attach-node $node(2874)
$ns at 316 "$BGP2874 command \"show ip bgp\""

#puts "Creating Router 288"
set node(288) [$ns node]
set BGP288 [new Application/Route/Bgp]
$BGP288 register  $r

$BGP288 config-file $opt(dir)/bgpd288.conf
$BGP288 attach-node $node(288)
$ns at 316 "$BGP288 command \"show ip bgp\""

#puts "Creating Router 2895"
set node(2895) [$ns node]
set BGP2895 [new Application/Route/Bgp]
$BGP2895 register  $r

$BGP2895 config-file $opt(dir)/bgpd2895.conf
$BGP2895 attach-node $node(2895)
$ns at 316 "$BGP2895 command \"show ip bgp\""

#puts "Creating Router 2900"
set node(2900) [$ns node]
set BGP2900 [new Application/Route/Bgp]
$BGP2900 register  $r

$BGP2900 config-file $opt(dir)/bgpd2900.conf
$BGP2900 attach-node $node(2900)
$ns at 316 "$BGP2900 command \"show ip bgp\""

#puts "Creating Router 2905"
set node(2905) [$ns node]
set BGP2905 [new Application/Route/Bgp]
$BGP2905 register  $r

$BGP2905 config-file $opt(dir)/bgpd2905.conf
$BGP2905 attach-node $node(2905)
$ns at 316 "$BGP2905 command \"show ip bgp\""

#puts "Creating Router 2907"
set node(2907) [$ns node]
set BGP2907 [new Application/Route/Bgp]
$BGP2907 register  $r

$BGP2907 config-file $opt(dir)/bgpd2907.conf
$BGP2907 attach-node $node(2907)
$ns at 316 "$BGP2907 command \"show ip bgp\""

#puts "Creating Router 2914"
set node(2914) [$ns node]
set BGP2914 [new Application/Route/Bgp]
$BGP2914 register  $r

$BGP2914 config-file $opt(dir)/bgpd2914.conf
$BGP2914 attach-node $node(2914)
$ns at 316 "$BGP2914 command \"show ip bgp\""

#puts "Creating Router 2915"
set node(2915) [$ns node]
set BGP2915 [new Application/Route/Bgp]
$BGP2915 register  $r

$BGP2915 config-file $opt(dir)/bgpd2915.conf
$BGP2915 attach-node $node(2915)
$ns at 316 "$BGP2915 command \"show ip bgp\""

#puts "Creating Router 2917"
set node(2917) [$ns node]
set BGP2917 [new Application/Route/Bgp]
$BGP2917 register  $r

$BGP2917 config-file $opt(dir)/bgpd2917.conf
$BGP2917 attach-node $node(2917)
$ns at 316 "$BGP2917 command \"show ip bgp\""

#puts "Creating Router 293"
set node(293) [$ns node]
set BGP293 [new Application/Route/Bgp]
$BGP293 register  $r

$BGP293 config-file $opt(dir)/bgpd293.conf
$BGP293 attach-node $node(293)
$ns at 316 "$BGP293 command \"show ip bgp\""

#puts "Creating Router 2933"
set node(2933) [$ns node]
set BGP2933 [new Application/Route/Bgp]
$BGP2933 register  $r

$BGP2933 config-file $opt(dir)/bgpd2933.conf
$BGP2933 attach-node $node(2933)
$ns at 316 "$BGP2933 command \"show ip bgp\""

#puts "Creating Router 2966"
set node(2966) [$ns node]
set BGP2966 [new Application/Route/Bgp]
$BGP2966 register  $r

$BGP2966 config-file $opt(dir)/bgpd2966.conf
$BGP2966 attach-node $node(2966)
$ns at 316 "$BGP2966 command \"show ip bgp\""

#puts "Creating Router 297"
set node(297) [$ns node]
set BGP297 [new Application/Route/Bgp]
$BGP297 register  $r

$BGP297 config-file $opt(dir)/bgpd297.conf
$BGP297 attach-node $node(297)
$ns at 316 "$BGP297 command \"show ip bgp\""

#puts "Creating Router 298"
set node(298) [$ns node]
set BGP298 [new Application/Route/Bgp]
$BGP298 register  $r

$BGP298 config-file $opt(dir)/bgpd298.conf
$BGP298 attach-node $node(298)
$ns at 316 "$BGP298 command \"show ip bgp\""

#puts "Creating Router 3058"
set node(3058) [$ns node]
set BGP3058 [new Application/Route/Bgp]
$BGP3058 register  $r

$BGP3058 config-file $opt(dir)/bgpd3058.conf
$BGP3058 attach-node $node(3058)
$ns at 316 "$BGP3058 command \"show ip bgp\""

#puts "Creating Router 3064"
set node(3064) [$ns node]
set BGP3064 [new Application/Route/Bgp]
$BGP3064 register  $r

$BGP3064 config-file $opt(dir)/bgpd3064.conf
$BGP3064 attach-node $node(3064)
$ns at 316 "$BGP3064 command \"show ip bgp\""

#puts "Creating Router 3066"
set node(3066) [$ns node]
set BGP3066 [new Application/Route/Bgp]
$BGP3066 register  $r

$BGP3066 config-file $opt(dir)/bgpd3066.conf
$BGP3066 attach-node $node(3066)
$ns at 316 "$BGP3066 command \"show ip bgp\""

#puts "Creating Router 3128"
set node(3128) [$ns node]
set BGP3128 [new Application/Route/Bgp]
$BGP3128 register  $r

$BGP3128 config-file $opt(dir)/bgpd3128.conf
$BGP3128 attach-node $node(3128)
$ns at 316 "$BGP3128 command \"show ip bgp\""

#puts "Creating Router 3142"
set node(3142) [$ns node]
set BGP3142 [new Application/Route/Bgp]
$BGP3142 register  $r

$BGP3142 config-file $opt(dir)/bgpd3142.conf
$BGP3142 attach-node $node(3142)
$ns at 316 "$BGP3142 command \"show ip bgp\""

#puts "Creating Router 3149"
set node(3149) [$ns node]
set BGP3149 [new Application/Route/Bgp]
$BGP3149 register  $r

$BGP3149 config-file $opt(dir)/bgpd3149.conf
$BGP3149 attach-node $node(3149)
$ns at 316 "$BGP3149 command \"show ip bgp\""

#puts "Creating Router 3150"
set node(3150) [$ns node]
set BGP3150 [new Application/Route/Bgp]
$BGP3150 register  $r

$BGP3150 config-file $opt(dir)/bgpd3150.conf
$BGP3150 attach-node $node(3150)
$ns at 316 "$BGP3150 command \"show ip bgp\""

#puts "Creating Router 3152"
set node(3152) [$ns node]
set BGP3152 [new Application/Route/Bgp]
$BGP3152 register  $r

$BGP3152 config-file $opt(dir)/bgpd3152.conf
$BGP3152 attach-node $node(3152)
$ns at 316 "$BGP3152 command \"show ip bgp\""

#puts "Creating Router 3208"
set node(3208) [$ns node]
set BGP3208 [new Application/Route/Bgp]
$BGP3208 register  $r

$BGP3208 config-file $opt(dir)/bgpd3208.conf
$BGP3208 attach-node $node(3208)
$ns at 316 "$BGP3208 command \"show ip bgp\""

#puts "Creating Router 3215"
set node(3215) [$ns node]
set BGP3215 [new Application/Route/Bgp]
$BGP3215 register  $r

$BGP3215 config-file $opt(dir)/bgpd3215.conf
$BGP3215 attach-node $node(3215)
$ns at 316 "$BGP3215 command \"show ip bgp\""

#puts "Creating Router 3216"
set node(3216) [$ns node]
set BGP3216 [new Application/Route/Bgp]
$BGP3216 register  $r

$BGP3216 config-file $opt(dir)/bgpd3216.conf
$BGP3216 attach-node $node(3216)
$ns at 316 "$BGP3216 command \"show ip bgp\""

#puts "Creating Router 3220"
set node(3220) [$ns node]
set BGP3220 [new Application/Route/Bgp]
$BGP3220 register  $r

$BGP3220 config-file $opt(dir)/bgpd3220.conf
$BGP3220 attach-node $node(3220)
$ns at 316 "$BGP3220 command \"show ip bgp\""

#puts "Creating Router 3228"
set node(3228) [$ns node]
set BGP3228 [new Application/Route/Bgp]
$BGP3228 register  $r

$BGP3228 config-file $opt(dir)/bgpd3228.conf
$BGP3228 attach-node $node(3228)
$ns at 316 "$BGP3228 command \"show ip bgp\""

#puts "Creating Router 3230"
set node(3230) [$ns node]
set BGP3230 [new Application/Route/Bgp]
$BGP3230 register  $r

$BGP3230 config-file $opt(dir)/bgpd3230.conf
$BGP3230 attach-node $node(3230)
$ns at 316 "$BGP3230 command \"show ip bgp\""

#puts "Creating Router 3242"
set node(3242) [$ns node]
set BGP3242 [new Application/Route/Bgp]
$BGP3242 register  $r

$BGP3242 config-file $opt(dir)/bgpd3242.conf
$BGP3242 attach-node $node(3242)
$ns at 316 "$BGP3242 command \"show ip bgp\""

#puts "Creating Router 3243"
set node(3243) [$ns node]
set BGP3243 [new Application/Route/Bgp]
$BGP3243 register  $r

$BGP3243 config-file $opt(dir)/bgpd3243.conf
$BGP3243 attach-node $node(3243)
$ns at 316 "$BGP3243 command \"show ip bgp\""

#puts "Creating Router 3244"
set node(3244) [$ns node]
set BGP3244 [new Application/Route/Bgp]
$BGP3244 register  $r

$BGP3244 config-file $opt(dir)/bgpd3244.conf
$BGP3244 attach-node $node(3244)
$ns at 316 "$BGP3244 command \"show ip bgp\""

#puts "Creating Router 3245"
set node(3245) [$ns node]
set BGP3245 [new Application/Route/Bgp]
$BGP3245 register  $r

$BGP3245 config-file $opt(dir)/bgpd3245.conf
$BGP3245 attach-node $node(3245)
$ns at 316 "$BGP3245 command \"show ip bgp\""

#puts "Creating Router 3246"
set node(3246) [$ns node]
set BGP3246 [new Application/Route/Bgp]
$BGP3246 register  $r

$BGP3246 config-file $opt(dir)/bgpd3246.conf
$BGP3246 attach-node $node(3246)
$ns at 316 "$BGP3246 command \"show ip bgp\""

#puts "Creating Router 3248"
set node(3248) [$ns node]
set BGP3248 [new Application/Route/Bgp]
$BGP3248 register  $r

$BGP3248 config-file $opt(dir)/bgpd3248.conf
$BGP3248 attach-node $node(3248)
$ns at 316 "$BGP3248 command \"show ip bgp\""

#puts "Creating Router 3249"
set node(3249) [$ns node]
set BGP3249 [new Application/Route/Bgp]
$BGP3249 register  $r

$BGP3249 config-file $opt(dir)/bgpd3249.conf
$BGP3249 attach-node $node(3249)
$ns at 316 "$BGP3249 command \"show ip bgp\""

#puts "Creating Router 3252"
set node(3252) [$ns node]
set BGP3252 [new Application/Route/Bgp]
$BGP3252 register  $r

$BGP3252 config-file $opt(dir)/bgpd3252.conf
$BGP3252 attach-node $node(3252)
$ns at 316 "$BGP3252 command \"show ip bgp\""

#puts "Creating Router 3254"
set node(3254) [$ns node]
set BGP3254 [new Application/Route/Bgp]
$BGP3254 register  $r

$BGP3254 config-file $opt(dir)/bgpd3254.conf
$BGP3254 attach-node $node(3254)
$ns at 316 "$BGP3254 command \"show ip bgp\""

#puts "Creating Router 3255"
set node(3255) [$ns node]
set BGP3255 [new Application/Route/Bgp]
$BGP3255 register  $r

$BGP3255 config-file $opt(dir)/bgpd3255.conf
$BGP3255 attach-node $node(3255)
$ns at 316 "$BGP3255 command \"show ip bgp\""

#puts "Creating Router 3256"
set node(3256) [$ns node]
set BGP3256 [new Application/Route/Bgp]
$BGP3256 register  $r

$BGP3256 config-file $opt(dir)/bgpd3256.conf
$BGP3256 attach-node $node(3256)
$ns at 316 "$BGP3256 command \"show ip bgp\""

#puts "Creating Router 3257"
set node(3257) [$ns node]
set BGP3257 [new Application/Route/Bgp]
$BGP3257 register  $r

$BGP3257 config-file $opt(dir)/bgpd3257.conf
$BGP3257 attach-node $node(3257)
$ns at 316 "$BGP3257 command \"show ip bgp\""

#puts "Creating Router 3258"
set node(3258) [$ns node]
set BGP3258 [new Application/Route/Bgp]
$BGP3258 register  $r

$BGP3258 config-file $opt(dir)/bgpd3258.conf
$BGP3258 attach-node $node(3258)
$ns at 316 "$BGP3258 command \"show ip bgp\""

#puts "Creating Router 3260"
set node(3260) [$ns node]
set BGP3260 [new Application/Route/Bgp]
$BGP3260 register  $r

$BGP3260 config-file $opt(dir)/bgpd3260.conf
$BGP3260 attach-node $node(3260)
$ns at 316 "$BGP3260 command \"show ip bgp\""

#puts "Creating Router 3261"
set node(3261) [$ns node]
set BGP3261 [new Application/Route/Bgp]
$BGP3261 register  $r

$BGP3261 config-file $opt(dir)/bgpd3261.conf
$BGP3261 attach-node $node(3261)
$ns at 316 "$BGP3261 command \"show ip bgp\""

#puts "Creating Router 3265"
set node(3265) [$ns node]
set BGP3265 [new Application/Route/Bgp]
$BGP3265 register  $r

$BGP3265 config-file $opt(dir)/bgpd3265.conf
$BGP3265 attach-node $node(3265)
$ns at 316 "$BGP3265 command \"show ip bgp\""

#puts "Creating Router 3268"
set node(3268) [$ns node]
set BGP3268 [new Application/Route/Bgp]
$BGP3268 register  $r

$BGP3268 config-file $opt(dir)/bgpd3268.conf
$BGP3268 attach-node $node(3268)
$ns at 316 "$BGP3268 command \"show ip bgp\""

#puts "Creating Router 3269"
set node(3269) [$ns node]
set BGP3269 [new Application/Route/Bgp]
$BGP3269 register  $r

$BGP3269 config-file $opt(dir)/bgpd3269.conf
$BGP3269 attach-node $node(3269)
$ns at 316 "$BGP3269 command \"show ip bgp\""

#puts "Creating Router 3273"
set node(3273) [$ns node]
set BGP3273 [new Application/Route/Bgp]
$BGP3273 register  $r

$BGP3273 config-file $opt(dir)/bgpd3273.conf
$BGP3273 attach-node $node(3273)
$ns at 316 "$BGP3273 command \"show ip bgp\""

#puts "Creating Router 3286"
set node(3286) [$ns node]
set BGP3286 [new Application/Route/Bgp]
$BGP3286 register  $r

$BGP3286 config-file $opt(dir)/bgpd3286.conf
$BGP3286 attach-node $node(3286)
$ns at 316 "$BGP3286 command \"show ip bgp\""

#puts "Creating Router 3291"
set node(3291) [$ns node]
set BGP3291 [new Application/Route/Bgp]
$BGP3291 register  $r

$BGP3291 config-file $opt(dir)/bgpd3291.conf
$BGP3291 attach-node $node(3291)
$ns at 316 "$BGP3291 command \"show ip bgp\""

#puts "Creating Router 3292"
set node(3292) [$ns node]
set BGP3292 [new Application/Route/Bgp]
$BGP3292 register  $r

$BGP3292 config-file $opt(dir)/bgpd3292.conf
$BGP3292 attach-node $node(3292)
$ns at 316 "$BGP3292 command \"show ip bgp\""

#puts "Creating Router 33"
set node(33) [$ns node]
set BGP33 [new Application/Route/Bgp]
$BGP33 register  $r

$BGP33 config-file $opt(dir)/bgpd33.conf
$BGP33 attach-node $node(33)
$ns at 316 "$BGP33 command \"show ip bgp\""

#puts "Creating Router 3300"
set node(3300) [$ns node]
set BGP3300 [new Application/Route/Bgp]
$BGP3300 register  $r

$BGP3300 config-file $opt(dir)/bgpd3300.conf
$BGP3300 attach-node $node(3300)
$ns at 316 "$BGP3300 command \"show ip bgp\""

#puts "Creating Router 3301"
set node(3301) [$ns node]
set BGP3301 [new Application/Route/Bgp]
$BGP3301 register  $r

$BGP3301 config-file $opt(dir)/bgpd3301.conf
$BGP3301 attach-node $node(3301)
$ns at 316 "$BGP3301 command \"show ip bgp\""

#puts "Creating Router 3302"
set node(3302) [$ns node]
set BGP3302 [new Application/Route/Bgp]
$BGP3302 register  $r

$BGP3302 config-file $opt(dir)/bgpd3302.conf
$BGP3302 attach-node $node(3302)
$ns at 316 "$BGP3302 command \"show ip bgp\""

#puts "Creating Router 3303"
set node(3303) [$ns node]
set BGP3303 [new Application/Route/Bgp]
$BGP3303 register  $r

$BGP3303 config-file $opt(dir)/bgpd3303.conf
$BGP3303 attach-node $node(3303)
$ns at 316 "$BGP3303 command \"show ip bgp\""

#puts "Creating Router 3304"
set node(3304) [$ns node]
set BGP3304 [new Application/Route/Bgp]
$BGP3304 register  $r

$BGP3304 config-file $opt(dir)/bgpd3304.conf
$BGP3304 attach-node $node(3304)
$ns at 316 "$BGP3304 command \"show ip bgp\""

#puts "Creating Router 3305"
set node(3305) [$ns node]
set BGP3305 [new Application/Route/Bgp]
$BGP3305 register  $r

$BGP3305 config-file $opt(dir)/bgpd3305.conf
$BGP3305 attach-node $node(3305)
$ns at 316 "$BGP3305 command \"show ip bgp\""

#puts "Creating Router 3306"
set node(3306) [$ns node]
set BGP3306 [new Application/Route/Bgp]
$BGP3306 register  $r

$BGP3306 config-file $opt(dir)/bgpd3306.conf
$BGP3306 attach-node $node(3306)
$ns at 316 "$BGP3306 command \"show ip bgp\""

#puts "Creating Router 3307"
set node(3307) [$ns node]
set BGP3307 [new Application/Route/Bgp]
$BGP3307 register  $r

$BGP3307 config-file $opt(dir)/bgpd3307.conf
$BGP3307 attach-node $node(3307)
$ns at 316 "$BGP3307 command \"show ip bgp\""

#puts "Creating Router 3308"
set node(3308) [$ns node]
set BGP3308 [new Application/Route/Bgp]
$BGP3308 register  $r

$BGP3308 config-file $opt(dir)/bgpd3308.conf
$BGP3308 attach-node $node(3308)
$ns at 316 "$BGP3308 command \"show ip bgp\""

#puts "Creating Router 3312"
set node(3312) [$ns node]
set BGP3312 [new Application/Route/Bgp]
$BGP3312 register  $r

$BGP3312 config-file $opt(dir)/bgpd3312.conf
$BGP3312 attach-node $node(3312)
$ns at 316 "$BGP3312 command \"show ip bgp\""

#puts "Creating Router 3313"
set node(3313) [$ns node]
set BGP3313 [new Application/Route/Bgp]
$BGP3313 register  $r

$BGP3313 config-file $opt(dir)/bgpd3313.conf
$BGP3313 attach-node $node(3313)
$ns at 316 "$BGP3313 command \"show ip bgp\""

#puts "Creating Router 3315"
set node(3315) [$ns node]
set BGP3315 [new Application/Route/Bgp]
$BGP3315 register  $r

$BGP3315 config-file $opt(dir)/bgpd3315.conf
$BGP3315 attach-node $node(3315)
$ns at 316 "$BGP3315 command \"show ip bgp\""

#puts "Creating Router 3316"
set node(3316) [$ns node]
set BGP3316 [new Application/Route/Bgp]
$BGP3316 register  $r

$BGP3316 config-file $opt(dir)/bgpd3316.conf
$BGP3316 attach-node $node(3316)
$ns at 316 "$BGP3316 command \"show ip bgp\""

#puts "Creating Router 3320"
set node(3320) [$ns node]
set BGP3320 [new Application/Route/Bgp]
$BGP3320 register  $r

$BGP3320 config-file $opt(dir)/bgpd3320.conf
$BGP3320 attach-node $node(3320)
$ns at 316 "$BGP3320 command \"show ip bgp\""

#puts "Creating Router 3323"
set node(3323) [$ns node]
set BGP3323 [new Application/Route/Bgp]
$BGP3323 register  $r

$BGP3323 config-file $opt(dir)/bgpd3323.conf
$BGP3323 attach-node $node(3323)
$ns at 316 "$BGP3323 command \"show ip bgp\""

#puts "Creating Router 3324"
set node(3324) [$ns node]
set BGP3324 [new Application/Route/Bgp]
$BGP3324 register  $r

$BGP3324 config-file $opt(dir)/bgpd3324.conf
$BGP3324 attach-node $node(3324)
$ns at 316 "$BGP3324 command \"show ip bgp\""

#puts "Creating Router 3327"
set node(3327) [$ns node]
set BGP3327 [new Application/Route/Bgp]
$BGP3327 register  $r

$BGP3327 config-file $opt(dir)/bgpd3327.conf
$BGP3327 attach-node $node(3327)
$ns at 316 "$BGP3327 command \"show ip bgp\""

#puts "Creating Router 3328"
set node(3328) [$ns node]
set BGP3328 [new Application/Route/Bgp]
$BGP3328 register  $r

$BGP3328 config-file $opt(dir)/bgpd3328.conf
$BGP3328 attach-node $node(3328)
$ns at 316 "$BGP3328 command \"show ip bgp\""

#puts "Creating Router 3330"
set node(3330) [$ns node]
set BGP3330 [new Application/Route/Bgp]
$BGP3330 register  $r

$BGP3330 config-file $opt(dir)/bgpd3330.conf
$BGP3330 attach-node $node(3330)
$ns at 316 "$BGP3330 command \"show ip bgp\""

#puts "Creating Router 3333"
set node(3333) [$ns node]
set BGP3333 [new Application/Route/Bgp]
$BGP3333 register  $r

$BGP3333 config-file $opt(dir)/bgpd3333.conf
$BGP3333 attach-node $node(3333)
$ns at 316 "$BGP3333 command \"show ip bgp\""

#puts "Creating Router 3334"
set node(3334) [$ns node]
set BGP3334 [new Application/Route/Bgp]
$BGP3334 register  $r

$BGP3334 config-file $opt(dir)/bgpd3334.conf
$BGP3334 attach-node $node(3334)
$ns at 316 "$BGP3334 command \"show ip bgp\""

#puts "Creating Router 3335"
set node(3335) [$ns node]
set BGP3335 [new Application/Route/Bgp]
$BGP3335 register  $r

$BGP3335 config-file $opt(dir)/bgpd3335.conf
$BGP3335 attach-node $node(3335)
$ns at 316 "$BGP3335 command \"show ip bgp\""

#puts "Creating Router 3336"
set node(3336) [$ns node]
set BGP3336 [new Application/Route/Bgp]
$BGP3336 register  $r

$BGP3336 config-file $opt(dir)/bgpd3336.conf
$BGP3336 attach-node $node(3336)
$ns at 316 "$BGP3336 command \"show ip bgp\""

#puts "Creating Router 3339"
set node(3339) [$ns node]
set BGP3339 [new Application/Route/Bgp]
$BGP3339 register  $r

$BGP3339 config-file $opt(dir)/bgpd3339.conf
$BGP3339 attach-node $node(3339)
$ns at 316 "$BGP3339 command \"show ip bgp\""

#puts "Creating Router 3340"
set node(3340) [$ns node]
set BGP3340 [new Application/Route/Bgp]
$BGP3340 register  $r

$BGP3340 config-file $opt(dir)/bgpd3340.conf
$BGP3340 attach-node $node(3340)
$ns at 316 "$BGP3340 command \"show ip bgp\""

#puts "Creating Router 3343"
set node(3343) [$ns node]
set BGP3343 [new Application/Route/Bgp]
$BGP3343 register  $r

$BGP3343 config-file $opt(dir)/bgpd3343.conf
$BGP3343 attach-node $node(3343)
$ns at 316 "$BGP3343 command \"show ip bgp\""

#puts "Creating Router 3344"
set node(3344) [$ns node]
set BGP3344 [new Application/Route/Bgp]
$BGP3344 register  $r

$BGP3344 config-file $opt(dir)/bgpd3344.conf
$BGP3344 attach-node $node(3344)
$ns at 316 "$BGP3344 command \"show ip bgp\""

#puts "Creating Router 3352"
set node(3352) [$ns node]
set BGP3352 [new Application/Route/Bgp]
$BGP3352 register  $r

$BGP3352 config-file $opt(dir)/bgpd3352.conf
$BGP3352 attach-node $node(3352)
$ns at 316 "$BGP3352 command \"show ip bgp\""

#puts "Creating Router 3354"
set node(3354) [$ns node]
set BGP3354 [new Application/Route/Bgp]
$BGP3354 register  $r

$BGP3354 config-file $opt(dir)/bgpd3354.conf
$BGP3354 attach-node $node(3354)
$ns at 316 "$BGP3354 command \"show ip bgp\""

#puts "Creating Router 3356"
set node(3356) [$ns node]
set BGP3356 [new Application/Route/Bgp]
$BGP3356 register  $r

$BGP3356 config-file $opt(dir)/bgpd3356.conf
$BGP3356 attach-node $node(3356)
$ns at 316 "$BGP3356 command \"show ip bgp\""

#puts "Creating Router 3360"
set node(3360) [$ns node]
set BGP3360 [new Application/Route/Bgp]
$BGP3360 register  $r

$BGP3360 config-file $opt(dir)/bgpd3360.conf
$BGP3360 attach-node $node(3360)
$ns at 316 "$BGP3360 command \"show ip bgp\""

#puts "Creating Router 3361"
set node(3361) [$ns node]
set BGP3361 [new Application/Route/Bgp]
$BGP3361 register  $r

$BGP3361 config-file $opt(dir)/bgpd3361.conf
$BGP3361 attach-node $node(3361)
$ns at 316 "$BGP3361 command \"show ip bgp\""

#puts "Creating Router 3363"
set node(3363) [$ns node]
set BGP3363 [new Application/Route/Bgp]
$BGP3363 register  $r

$BGP3363 config-file $opt(dir)/bgpd3363.conf
$BGP3363 attach-node $node(3363)
$ns at 316 "$BGP3363 command \"show ip bgp\""

#puts "Creating Router 3365"
set node(3365) [$ns node]
set BGP3365 [new Application/Route/Bgp]
$BGP3365 register  $r

$BGP3365 config-file $opt(dir)/bgpd3365.conf
$BGP3365 attach-node $node(3365)
$ns at 316 "$BGP3365 command \"show ip bgp\""

#puts "Creating Router 3381"
set node(3381) [$ns node]
set BGP3381 [new Application/Route/Bgp]
$BGP3381 register  $r

$BGP3381 config-file $opt(dir)/bgpd3381.conf
$BGP3381 attach-node $node(3381)
$ns at 316 "$BGP3381 command \"show ip bgp\""

#puts "Creating Router 3384"
set node(3384) [$ns node]
set BGP3384 [new Application/Route/Bgp]
$BGP3384 register  $r

$BGP3384 config-file $opt(dir)/bgpd3384.conf
$BGP3384 attach-node $node(3384)
$ns at 316 "$BGP3384 command \"show ip bgp\""

#puts "Creating Router 3393"
set node(3393) [$ns node]
set BGP3393 [new Application/Route/Bgp]
$BGP3393 register  $r

$BGP3393 config-file $opt(dir)/bgpd3393.conf
$BGP3393 attach-node $node(3393)
$ns at 316 "$BGP3393 command \"show ip bgp\""

#puts "Creating Router 3404"
set node(3404) [$ns node]
set BGP3404 [new Application/Route/Bgp]
$BGP3404 register  $r

$BGP3404 config-file $opt(dir)/bgpd3404.conf
$BGP3404 attach-node $node(3404)
$ns at 316 "$BGP3404 command \"show ip bgp\""

#puts "Creating Router 3407"
set node(3407) [$ns node]
set BGP3407 [new Application/Route/Bgp]
$BGP3407 register  $r

$BGP3407 config-file $opt(dir)/bgpd3407.conf
$BGP3407 attach-node $node(3407)
$ns at 316 "$BGP3407 command \"show ip bgp\""

#puts "Creating Router 3409"
set node(3409) [$ns node]
set BGP3409 [new Application/Route/Bgp]
$BGP3409 register  $r

$BGP3409 config-file $opt(dir)/bgpd3409.conf
$BGP3409 attach-node $node(3409)
$ns at 316 "$BGP3409 command \"show ip bgp\""

#puts "Creating Router 3426"
set node(3426) [$ns node]
set BGP3426 [new Application/Route/Bgp]
$BGP3426 register  $r

$BGP3426 config-file $opt(dir)/bgpd3426.conf
$BGP3426 attach-node $node(3426)
$ns at 316 "$BGP3426 command \"show ip bgp\""

#puts "Creating Router 3429"
set node(3429) [$ns node]
set BGP3429 [new Application/Route/Bgp]
$BGP3429 register  $r

$BGP3429 config-file $opt(dir)/bgpd3429.conf
$BGP3429 attach-node $node(3429)
$ns at 316 "$BGP3429 command \"show ip bgp\""

#puts "Creating Router 3447"
set node(3447) [$ns node]
set BGP3447 [new Application/Route/Bgp]
$BGP3447 register  $r

$BGP3447 config-file $opt(dir)/bgpd3447.conf
$BGP3447 attach-node $node(3447)
$ns at 316 "$BGP3447 command \"show ip bgp\""

#puts "Creating Router 3449"
set node(3449) [$ns node]
set BGP3449 [new Application/Route/Bgp]
$BGP3449 register  $r

$BGP3449 config-file $opt(dir)/bgpd3449.conf
$BGP3449 attach-node $node(3449)
$ns at 316 "$BGP3449 command \"show ip bgp\""

#puts "Creating Router 3462"
set node(3462) [$ns node]
set BGP3462 [new Application/Route/Bgp]
$BGP3462 register  $r

$BGP3462 config-file $opt(dir)/bgpd3462.conf
$BGP3462 attach-node $node(3462)
$ns at 316 "$BGP3462 command \"show ip bgp\""

#puts "Creating Router 3463"
set node(3463) [$ns node]
set BGP3463 [new Application/Route/Bgp]
$BGP3463 register  $r

$BGP3463 config-file $opt(dir)/bgpd3463.conf
$BGP3463 attach-node $node(3463)
$ns at 316 "$BGP3463 command \"show ip bgp\""

#puts "Creating Router 3464"
set node(3464) [$ns node]
set BGP3464 [new Application/Route/Bgp]
$BGP3464 register  $r

$BGP3464 config-file $opt(dir)/bgpd3464.conf
$BGP3464 attach-node $node(3464)
$ns at 316 "$BGP3464 command \"show ip bgp\""

#puts "Creating Router 3479"
set node(3479) [$ns node]
set BGP3479 [new Application/Route/Bgp]
$BGP3479 register  $r

$BGP3479 config-file $opt(dir)/bgpd3479.conf
$BGP3479 attach-node $node(3479)
$ns at 316 "$BGP3479 command \"show ip bgp\""

#puts "Creating Router 3484"
set node(3484) [$ns node]
set BGP3484 [new Application/Route/Bgp]
$BGP3484 register  $r

$BGP3484 config-file $opt(dir)/bgpd3484.conf
$BGP3484 attach-node $node(3484)
$ns at 316 "$BGP3484 command \"show ip bgp\""

#puts "Creating Router 3491"
set node(3491) [$ns node]
set BGP3491 [new Application/Route/Bgp]
$BGP3491 register  $r

$BGP3491 config-file $opt(dir)/bgpd3491.conf
$BGP3491 attach-node $node(3491)
$ns at 316 "$BGP3491 command \"show ip bgp\""

#puts "Creating Router 3493"
set node(3493) [$ns node]
set BGP3493 [new Application/Route/Bgp]
$BGP3493 register  $r

$BGP3493 config-file $opt(dir)/bgpd3493.conf
$BGP3493 attach-node $node(3493)
$ns at 316 "$BGP3493 command \"show ip bgp\""

#puts "Creating Router 35"
set node(35) [$ns node]
set BGP35 [new Application/Route/Bgp]
$BGP35 register  $r

$BGP35 config-file $opt(dir)/bgpd35.conf
$BGP35 attach-node $node(35)
$ns at 316 "$BGP35 command \"show ip bgp\""

#puts "Creating Router 3505"
set node(3505) [$ns node]
set BGP3505 [new Application/Route/Bgp]
$BGP3505 register  $r

$BGP3505 config-file $opt(dir)/bgpd3505.conf
$BGP3505 attach-node $node(3505)
$ns at 316 "$BGP3505 command \"show ip bgp\""

#puts "Creating Router 3506"
set node(3506) [$ns node]
set BGP3506 [new Application/Route/Bgp]
$BGP3506 register  $r

$BGP3506 config-file $opt(dir)/bgpd3506.conf
$BGP3506 attach-node $node(3506)
$ns at 316 "$BGP3506 command \"show ip bgp\""

#puts "Creating Router 3508"
set node(3508) [$ns node]
set BGP3508 [new Application/Route/Bgp]
$BGP3508 register  $r

$BGP3508 config-file $opt(dir)/bgpd3508.conf
$BGP3508 attach-node $node(3508)
$ns at 316 "$BGP3508 command \"show ip bgp\""

#puts "Creating Router 3513"
set node(3513) [$ns node]
set BGP3513 [new Application/Route/Bgp]
$BGP3513 register  $r

$BGP3513 config-file $opt(dir)/bgpd3513.conf
$BGP3513 attach-node $node(3513)
$ns at 316 "$BGP3513 command \"show ip bgp\""

#puts "Creating Router 3527"
set node(3527) [$ns node]
set BGP3527 [new Application/Route/Bgp]
$BGP3527 register  $r

$BGP3527 config-file $opt(dir)/bgpd3527.conf
$BGP3527 attach-node $node(3527)
$ns at 316 "$BGP3527 command \"show ip bgp\""

#puts "Creating Router 3549"
set node(3549) [$ns node]
set BGP3549 [new Application/Route/Bgp]
$BGP3549 register  $r

$BGP3549 config-file $opt(dir)/bgpd3549.conf
$BGP3549 attach-node $node(3549)
$ns at 316 "$BGP3549 command \"show ip bgp\""

#puts "Creating Router 3550"
set node(3550) [$ns node]
set BGP3550 [new Application/Route/Bgp]
$BGP3550 register  $r

$BGP3550 config-file $opt(dir)/bgpd3550.conf
$BGP3550 attach-node $node(3550)
$ns at 316 "$BGP3550 command \"show ip bgp\""

#puts "Creating Router 3554"
set node(3554) [$ns node]
set BGP3554 [new Application/Route/Bgp]
$BGP3554 register  $r

$BGP3554 config-file $opt(dir)/bgpd3554.conf
$BGP3554 attach-node $node(3554)
$ns at 316 "$BGP3554 command \"show ip bgp\""

#puts "Creating Router 3557"
set node(3557) [$ns node]
set BGP3557 [new Application/Route/Bgp]
$BGP3557 register  $r

$BGP3557 config-file $opt(dir)/bgpd3557.conf
$BGP3557 attach-node $node(3557)
$ns at 316 "$BGP3557 command \"show ip bgp\""

#puts "Creating Router 3559"
set node(3559) [$ns node]
set BGP3559 [new Application/Route/Bgp]
$BGP3559 register  $r

$BGP3559 config-file $opt(dir)/bgpd3559.conf
$BGP3559 attach-node $node(3559)
$ns at 316 "$BGP3559 command \"show ip bgp\""

#puts "Creating Router 3561"
set node(3561) [$ns node]
set BGP3561 [new Application/Route/Bgp]
$BGP3561 register  $r

$BGP3561 config-file $opt(dir)/bgpd3561.conf
$BGP3561 attach-node $node(3561)
$ns at 316 "$BGP3561 command \"show ip bgp\""

#puts "Creating Router 3564"
set node(3564) [$ns node]
set BGP3564 [new Application/Route/Bgp]
$BGP3564 register  $r

$BGP3564 config-file $opt(dir)/bgpd3564.conf
$BGP3564 attach-node $node(3564)
$ns at 316 "$BGP3564 command \"show ip bgp\""

#puts "Creating Router 3566"
set node(3566) [$ns node]
set BGP3566 [new Application/Route/Bgp]
$BGP3566 register  $r

$BGP3566 config-file $opt(dir)/bgpd3566.conf
$BGP3566 attach-node $node(3566)
$ns at 316 "$BGP3566 command \"show ip bgp\""

#puts "Creating Router 3575"
set node(3575) [$ns node]
set BGP3575 [new Application/Route/Bgp]
$BGP3575 register  $r

$BGP3575 config-file $opt(dir)/bgpd3575.conf
$BGP3575 attach-node $node(3575)
$ns at 316 "$BGP3575 command \"show ip bgp\""

#puts "Creating Router 3576"
set node(3576) [$ns node]
set BGP3576 [new Application/Route/Bgp]
$BGP3576 register  $r

$BGP3576 config-file $opt(dir)/bgpd3576.conf
$BGP3576 attach-node $node(3576)
$ns at 316 "$BGP3576 command \"show ip bgp\""

#puts "Creating Router 3577"
set node(3577) [$ns node]
set BGP3577 [new Application/Route/Bgp]
$BGP3577 register  $r

$BGP3577 config-file $opt(dir)/bgpd3577.conf
$BGP3577 attach-node $node(3577)
$ns at 316 "$BGP3577 command \"show ip bgp\""

#puts "Creating Router 3578"
set node(3578) [$ns node]
set BGP3578 [new Application/Route/Bgp]
$BGP3578 register  $r

$BGP3578 config-file $opt(dir)/bgpd3578.conf
$BGP3578 attach-node $node(3578)
$ns at 316 "$BGP3578 command \"show ip bgp\""

#puts "Creating Router 3586"
set node(3586) [$ns node]
set BGP3586 [new Application/Route/Bgp]
$BGP3586 register  $r

$BGP3586 config-file $opt(dir)/bgpd3586.conf
$BGP3586 attach-node $node(3586)
$ns at 316 "$BGP3586 command \"show ip bgp\""

#puts "Creating Router 3602"
set node(3602) [$ns node]
set BGP3602 [new Application/Route/Bgp]
$BGP3602 register  $r

$BGP3602 config-file $opt(dir)/bgpd3602.conf
$BGP3602 attach-node $node(3602)
$ns at 316 "$BGP3602 command \"show ip bgp\""

#puts "Creating Router 3603"
set node(3603) [$ns node]
set BGP3603 [new Application/Route/Bgp]
$BGP3603 register  $r

$BGP3603 config-file $opt(dir)/bgpd3603.conf
$BGP3603 attach-node $node(3603)
$ns at 316 "$BGP3603 command \"show ip bgp\""

#puts "Creating Router 3608"
set node(3608) [$ns node]
set BGP3608 [new Application/Route/Bgp]
$BGP3608 register  $r

$BGP3608 config-file $opt(dir)/bgpd3608.conf
$BGP3608 attach-node $node(3608)
$ns at 316 "$BGP3608 command \"show ip bgp\""

#puts "Creating Router 3615"
set node(3615) [$ns node]
set BGP3615 [new Application/Route/Bgp]
$BGP3615 register  $r

$BGP3615 config-file $opt(dir)/bgpd3615.conf
$BGP3615 attach-node $node(3615)
$ns at 316 "$BGP3615 command \"show ip bgp\""

#puts "Creating Router 3632"
set node(3632) [$ns node]
set BGP3632 [new Application/Route/Bgp]
$BGP3632 register  $r

$BGP3632 config-file $opt(dir)/bgpd3632.conf
$BGP3632 attach-node $node(3632)
$ns at 316 "$BGP3632 command \"show ip bgp\""

#puts "Creating Router 3640"
set node(3640) [$ns node]
set BGP3640 [new Application/Route/Bgp]
$BGP3640 register  $r

$BGP3640 config-file $opt(dir)/bgpd3640.conf
$BGP3640 attach-node $node(3640)
$ns at 316 "$BGP3640 command \"show ip bgp\""

#puts "Creating Router 3662"
set node(3662) [$ns node]
set BGP3662 [new Application/Route/Bgp]
$BGP3662 register  $r

$BGP3662 config-file $opt(dir)/bgpd3662.conf
$BGP3662 attach-node $node(3662)
$ns at 316 "$BGP3662 command \"show ip bgp\""

#puts "Creating Router 3669"
set node(3669) [$ns node]
set BGP3669 [new Application/Route/Bgp]
$BGP3669 register  $r

$BGP3669 config-file $opt(dir)/bgpd3669.conf
$BGP3669 attach-node $node(3669)
$ns at 316 "$BGP3669 command \"show ip bgp\""

#puts "Creating Router 3672"
set node(3672) [$ns node]
set BGP3672 [new Application/Route/Bgp]
$BGP3672 register  $r

$BGP3672 config-file $opt(dir)/bgpd3672.conf
$BGP3672 attach-node $node(3672)
$ns at 316 "$BGP3672 command \"show ip bgp\""

#puts "Creating Router 3676"
set node(3676) [$ns node]
set BGP3676 [new Application/Route/Bgp]
$BGP3676 register  $r

$BGP3676 config-file $opt(dir)/bgpd3676.conf
$BGP3676 attach-node $node(3676)
$ns at 316 "$BGP3676 command \"show ip bgp\""

#puts "Creating Router 3701"
set node(3701) [$ns node]
set BGP3701 [new Application/Route/Bgp]
$BGP3701 register  $r

$BGP3701 config-file $opt(dir)/bgpd3701.conf
$BGP3701 attach-node $node(3701)
$ns at 316 "$BGP3701 command \"show ip bgp\""

#puts "Creating Router 3714"
set node(3714) [$ns node]
set BGP3714 [new Application/Route/Bgp]
$BGP3714 register  $r

$BGP3714 config-file $opt(dir)/bgpd3714.conf
$BGP3714 attach-node $node(3714)
$ns at 316 "$BGP3714 command \"show ip bgp\""

#puts "Creating Router 3720"
set node(3720) [$ns node]
set BGP3720 [new Application/Route/Bgp]
$BGP3720 register  $r

$BGP3720 config-file $opt(dir)/bgpd3720.conf
$BGP3720 attach-node $node(3720)
$ns at 316 "$BGP3720 command \"show ip bgp\""

#puts "Creating Router 3722"
set node(3722) [$ns node]
set BGP3722 [new Application/Route/Bgp]
$BGP3722 register  $r

$BGP3722 config-file $opt(dir)/bgpd3722.conf
$BGP3722 attach-node $node(3722)
$ns at 316 "$BGP3722 command \"show ip bgp\""

#puts "Creating Router 3727"
set node(3727) [$ns node]
set BGP3727 [new Application/Route/Bgp]
$BGP3727 register  $r

$BGP3727 config-file $opt(dir)/bgpd3727.conf
$BGP3727 attach-node $node(3727)
$ns at 316 "$BGP3727 command \"show ip bgp\""

#puts "Creating Router 3734"
set node(3734) [$ns node]
set BGP3734 [new Application/Route/Bgp]
$BGP3734 register  $r

$BGP3734 config-file $opt(dir)/bgpd3734.conf
$BGP3734 attach-node $node(3734)
$ns at 316 "$BGP3734 command \"show ip bgp\""

#puts "Creating Router 3739"
set node(3739) [$ns node]
set BGP3739 [new Application/Route/Bgp]
$BGP3739 register  $r

$BGP3739 config-file $opt(dir)/bgpd3739.conf
$BGP3739 attach-node $node(3739)
$ns at 316 "$BGP3739 command \"show ip bgp\""

#puts "Creating Router 3741"
set node(3741) [$ns node]
set BGP3741 [new Application/Route/Bgp]
$BGP3741 register  $r

$BGP3741 config-file $opt(dir)/bgpd3741.conf
$BGP3741 attach-node $node(3741)
$ns at 316 "$BGP3741 command \"show ip bgp\""

#puts "Creating Router 3742"
set node(3742) [$ns node]
set BGP3742 [new Application/Route/Bgp]
$BGP3742 register  $r

$BGP3742 config-file $opt(dir)/bgpd3742.conf
$BGP3742 attach-node $node(3742)
$ns at 316 "$BGP3742 command \"show ip bgp\""

#puts "Creating Router 3743"
set node(3743) [$ns node]
set BGP3743 [new Application/Route/Bgp]
$BGP3743 register  $r

$BGP3743 config-file $opt(dir)/bgpd3743.conf
$BGP3743 attach-node $node(3743)
$ns at 316 "$BGP3743 command \"show ip bgp\""

#puts "Creating Router 3749"
set node(3749) [$ns node]
set BGP3749 [new Application/Route/Bgp]
$BGP3749 register  $r

$BGP3749 config-file $opt(dir)/bgpd3749.conf
$BGP3749 attach-node $node(3749)
$ns at 316 "$BGP3749 command \"show ip bgp\""

#puts "Creating Router 3758"
set node(3758) [$ns node]
set BGP3758 [new Application/Route/Bgp]
$BGP3758 register  $r

$BGP3758 config-file $opt(dir)/bgpd3758.conf
$BGP3758 attach-node $node(3758)
$ns at 316 "$BGP3758 command \"show ip bgp\""

#puts "Creating Router 376"
set node(376) [$ns node]
set BGP376 [new Application/Route/Bgp]
$BGP376 register  $r

$BGP376 config-file $opt(dir)/bgpd376.conf
$BGP376 attach-node $node(376)
$ns at 316 "$BGP376 command \"show ip bgp\""

#puts "Creating Router 3761"
set node(3761) [$ns node]
set BGP3761 [new Application/Route/Bgp]
$BGP3761 register  $r

$BGP3761 config-file $opt(dir)/bgpd3761.conf
$BGP3761 attach-node $node(3761)
$ns at 316 "$BGP3761 command \"show ip bgp\""

#puts "Creating Router 3764"
set node(3764) [$ns node]
set BGP3764 [new Application/Route/Bgp]
$BGP3764 register  $r

$BGP3764 config-file $opt(dir)/bgpd3764.conf
$BGP3764 attach-node $node(3764)
$ns at 316 "$BGP3764 command \"show ip bgp\""

#puts "Creating Router 3768"
set node(3768) [$ns node]
set BGP3768 [new Application/Route/Bgp]
$BGP3768 register  $r

$BGP3768 config-file $opt(dir)/bgpd3768.conf
$BGP3768 attach-node $node(3768)
$ns at 316 "$BGP3768 command \"show ip bgp\""

#puts "Creating Router 3770"
set node(3770) [$ns node]
set BGP3770 [new Application/Route/Bgp]
$BGP3770 register  $r

$BGP3770 config-file $opt(dir)/bgpd3770.conf
$BGP3770 attach-node $node(3770)
$ns at 316 "$BGP3770 command \"show ip bgp\""

#puts "Creating Router 3776"
set node(3776) [$ns node]
set BGP3776 [new Application/Route/Bgp]
$BGP3776 register  $r

$BGP3776 config-file $opt(dir)/bgpd3776.conf
$BGP3776 attach-node $node(3776)
$ns at 316 "$BGP3776 command \"show ip bgp\""

#puts "Creating Router 3786"
set node(3786) [$ns node]
set BGP3786 [new Application/Route/Bgp]
$BGP3786 register  $r

$BGP3786 config-file $opt(dir)/bgpd3786.conf
$BGP3786 attach-node $node(3786)
$ns at 316 "$BGP3786 command \"show ip bgp\""

#puts "Creating Router 3789"
set node(3789) [$ns node]
set BGP3789 [new Application/Route/Bgp]
$BGP3789 register  $r

$BGP3789 config-file $opt(dir)/bgpd3789.conf
$BGP3789 attach-node $node(3789)
$ns at 316 "$BGP3789 command \"show ip bgp\""

#puts "Creating Router 3790"
set node(3790) [$ns node]
set BGP3790 [new Application/Route/Bgp]
$BGP3790 register  $r

$BGP3790 config-file $opt(dir)/bgpd3790.conf
$BGP3790 attach-node $node(3790)
$ns at 316 "$BGP3790 command \"show ip bgp\""

#puts "Creating Router 3796"
set node(3796) [$ns node]
set BGP3796 [new Application/Route/Bgp]
$BGP3796 register  $r

$BGP3796 config-file $opt(dir)/bgpd3796.conf
$BGP3796 attach-node $node(3796)
$ns at 316 "$BGP3796 command \"show ip bgp\""

#puts "Creating Router 38"
set node(38) [$ns node]
set BGP38 [new Application/Route/Bgp]
$BGP38 register  $r

$BGP38 config-file $opt(dir)/bgpd38.conf
$BGP38 attach-node $node(38)
$ns at 316 "$BGP38 command \"show ip bgp\""

#puts "Creating Router 3801"
set node(3801) [$ns node]
set BGP3801 [new Application/Route/Bgp]
$BGP3801 register  $r

$BGP3801 config-file $opt(dir)/bgpd3801.conf
$BGP3801 attach-node $node(3801)
$ns at 316 "$BGP3801 command \"show ip bgp\""

#puts "Creating Router 3803"
set node(3803) [$ns node]
set BGP3803 [new Application/Route/Bgp]
$BGP3803 register  $r

$BGP3803 config-file $opt(dir)/bgpd3803.conf
$BGP3803 attach-node $node(3803)
$ns at 316 "$BGP3803 command \"show ip bgp\""

#puts "Creating Router 3804"
set node(3804) [$ns node]
set BGP3804 [new Application/Route/Bgp]
$BGP3804 register  $r

$BGP3804 config-file $opt(dir)/bgpd3804.conf
$BGP3804 attach-node $node(3804)
$ns at 316 "$BGP3804 command \"show ip bgp\""

#puts "Creating Router 3812"
set node(3812) [$ns node]
set BGP3812 [new Application/Route/Bgp]
$BGP3812 register  $r

$BGP3812 config-file $opt(dir)/bgpd3812.conf
$BGP3812 attach-node $node(3812)
$ns at 316 "$BGP3812 command \"show ip bgp\""

#puts "Creating Router 3817"
set node(3817) [$ns node]
set BGP3817 [new Application/Route/Bgp]
$BGP3817 register  $r

$BGP3817 config-file $opt(dir)/bgpd3817.conf
$BGP3817 attach-node $node(3817)
$ns at 316 "$BGP3817 command \"show ip bgp\""

#puts "Creating Router 3819"
set node(3819) [$ns node]
set BGP3819 [new Application/Route/Bgp]
$BGP3819 register  $r

$BGP3819 config-file $opt(dir)/bgpd3819.conf
$BGP3819 attach-node $node(3819)
$ns at 316 "$BGP3819 command \"show ip bgp\""

#puts "Creating Router 3820"
set node(3820) [$ns node]
set BGP3820 [new Application/Route/Bgp]
$BGP3820 register  $r

$BGP3820 config-file $opt(dir)/bgpd3820.conf
$BGP3820 attach-node $node(3820)
$ns at 316 "$BGP3820 command \"show ip bgp\""

#puts "Creating Router 3831"
set node(3831) [$ns node]
set BGP3831 [new Application/Route/Bgp]
$BGP3831 register  $r

$BGP3831 config-file $opt(dir)/bgpd3831.conf
$BGP3831 attach-node $node(3831)
$ns at 316 "$BGP3831 command \"show ip bgp\""

#puts "Creating Router 3838"
set node(3838) [$ns node]
set BGP3838 [new Application/Route/Bgp]
$BGP3838 register  $r

$BGP3838 config-file $opt(dir)/bgpd3838.conf
$BGP3838 attach-node $node(3838)
$ns at 316 "$BGP3838 command \"show ip bgp\""

#puts "Creating Router 3839"
set node(3839) [$ns node]
set BGP3839 [new Application/Route/Bgp]
$BGP3839 register  $r

$BGP3839 config-file $opt(dir)/bgpd3839.conf
$BGP3839 attach-node $node(3839)
$ns at 316 "$BGP3839 command \"show ip bgp\""

#puts "Creating Router 3844"
set node(3844) [$ns node]
set BGP3844 [new Application/Route/Bgp]
$BGP3844 register  $r

$BGP3844 config-file $opt(dir)/bgpd3844.conf
$BGP3844 attach-node $node(3844)
$ns at 316 "$BGP3844 command \"show ip bgp\""

#puts "Creating Router 3847"
set node(3847) [$ns node]
set BGP3847 [new Application/Route/Bgp]
$BGP3847 register  $r

$BGP3847 config-file $opt(dir)/bgpd3847.conf
$BGP3847 attach-node $node(3847)
$ns at 316 "$BGP3847 command \"show ip bgp\""

#puts "Creating Router 3857"
set node(3857) [$ns node]
set BGP3857 [new Application/Route/Bgp]
$BGP3857 register  $r

$BGP3857 config-file $opt(dir)/bgpd3857.conf
$BGP3857 attach-node $node(3857)
$ns at 316 "$BGP3857 command \"show ip bgp\""

#puts "Creating Router 3900"
set node(3900) [$ns node]
set BGP3900 [new Application/Route/Bgp]
$BGP3900 register  $r

$BGP3900 config-file $opt(dir)/bgpd3900.conf
$BGP3900 attach-node $node(3900)
$ns at 316 "$BGP3900 command \"show ip bgp\""

#puts "Creating Router 3905"
set node(3905) [$ns node]
set BGP3905 [new Application/Route/Bgp]
$BGP3905 register  $r

$BGP3905 config-file $opt(dir)/bgpd3905.conf
$BGP3905 attach-node $node(3905)
$ns at 316 "$BGP3905 command \"show ip bgp\""

#puts "Creating Router 3909"
set node(3909) [$ns node]
set BGP3909 [new Application/Route/Bgp]
$BGP3909 register  $r

$BGP3909 config-file $opt(dir)/bgpd3909.conf
$BGP3909 attach-node $node(3909)
$ns at 316 "$BGP3909 command \"show ip bgp\""

#puts "Creating Router 3914"
set node(3914) [$ns node]
set BGP3914 [new Application/Route/Bgp]
$BGP3914 register  $r

$BGP3914 config-file $opt(dir)/bgpd3914.conf
$BGP3914 attach-node $node(3914)
$ns at 316 "$BGP3914 command \"show ip bgp\""

#puts "Creating Router 3915"
set node(3915) [$ns node]
set BGP3915 [new Application/Route/Bgp]
$BGP3915 register  $r

$BGP3915 config-file $opt(dir)/bgpd3915.conf
$BGP3915 attach-node $node(3915)
$ns at 316 "$BGP3915 command \"show ip bgp\""

#puts "Creating Router 3932"
set node(3932) [$ns node]
set BGP3932 [new Application/Route/Bgp]
$BGP3932 register  $r

$BGP3932 config-file $opt(dir)/bgpd3932.conf
$BGP3932 attach-node $node(3932)
$ns at 316 "$BGP3932 command \"show ip bgp\""

#puts "Creating Router 3940"
set node(3940) [$ns node]
set BGP3940 [new Application/Route/Bgp]
$BGP3940 register  $r

$BGP3940 config-file $opt(dir)/bgpd3940.conf
$BGP3940 attach-node $node(3940)
$ns at 316 "$BGP3940 command \"show ip bgp\""

#puts "Creating Router 3951"
set node(3951) [$ns node]
set BGP3951 [new Application/Route/Bgp]
$BGP3951 register  $r

$BGP3951 config-file $opt(dir)/bgpd3951.conf
$BGP3951 attach-node $node(3951)
$ns at 316 "$BGP3951 command \"show ip bgp\""

#puts "Creating Router 3963"
set node(3963) [$ns node]
set BGP3963 [new Application/Route/Bgp]
$BGP3963 register  $r

$BGP3963 config-file $opt(dir)/bgpd3963.conf
$BGP3963 attach-node $node(3963)
$ns at 316 "$BGP3963 command \"show ip bgp\""

#puts "Creating Router 3967"
set node(3967) [$ns node]
set BGP3967 [new Application/Route/Bgp]
$BGP3967 register  $r

$BGP3967 config-file $opt(dir)/bgpd3967.conf
$BGP3967 attach-node $node(3967)
$ns at 316 "$BGP3967 command \"show ip bgp\""

#puts "Creating Router 3976"
set node(3976) [$ns node]
set BGP3976 [new Application/Route/Bgp]
$BGP3976 register  $r

$BGP3976 config-file $opt(dir)/bgpd3976.conf
$BGP3976 attach-node $node(3976)
$ns at 316 "$BGP3976 command \"show ip bgp\""

#puts "Creating Router 3999"
set node(3999) [$ns node]
set BGP3999 [new Application/Route/Bgp]
$BGP3999 register  $r

$BGP3999 config-file $opt(dir)/bgpd3999.conf
$BGP3999 attach-node $node(3999)
$ns at 316 "$BGP3999 command \"show ip bgp\""

#puts "Creating Router 4000"
set node(4000) [$ns node]
set BGP4000 [new Application/Route/Bgp]
$BGP4000 register  $r

$BGP4000 config-file $opt(dir)/bgpd4000.conf
$BGP4000 attach-node $node(4000)
$ns at 316 "$BGP4000 command \"show ip bgp\""

#puts "Creating Router 4001"
set node(4001) [$ns node]
set BGP4001 [new Application/Route/Bgp]
$BGP4001 register  $r

$BGP4001 config-file $opt(dir)/bgpd4001.conf
$BGP4001 attach-node $node(4001)
$ns at 316 "$BGP4001 command \"show ip bgp\""

#puts "Creating Router 4002"
set node(4002) [$ns node]
set BGP4002 [new Application/Route/Bgp]
$BGP4002 register  $r

$BGP4002 config-file $opt(dir)/bgpd4002.conf
$BGP4002 attach-node $node(4002)
$ns at 316 "$BGP4002 command \"show ip bgp\""

#puts "Creating Router 4003"
set node(4003) [$ns node]
set BGP4003 [new Application/Route/Bgp]
$BGP4003 register  $r

$BGP4003 config-file $opt(dir)/bgpd4003.conf
$BGP4003 attach-node $node(4003)
$ns at 316 "$BGP4003 command \"show ip bgp\""

#puts "Creating Router 4004"
set node(4004) [$ns node]
set BGP4004 [new Application/Route/Bgp]
$BGP4004 register  $r

$BGP4004 config-file $opt(dir)/bgpd4004.conf
$BGP4004 attach-node $node(4004)
$ns at 316 "$BGP4004 command \"show ip bgp\""

#puts "Creating Router 4005"
set node(4005) [$ns node]
set BGP4005 [new Application/Route/Bgp]
$BGP4005 register  $r

$BGP4005 config-file $opt(dir)/bgpd4005.conf
$BGP4005 attach-node $node(4005)
$ns at 316 "$BGP4005 command \"show ip bgp\""

#puts "Creating Router 4006"
set node(4006) [$ns node]
set BGP4006 [new Application/Route/Bgp]
$BGP4006 register  $r

$BGP4006 config-file $opt(dir)/bgpd4006.conf
$BGP4006 attach-node $node(4006)
$ns at 316 "$BGP4006 command \"show ip bgp\""

#puts "Creating Router 4010"
set node(4010) [$ns node]
set BGP4010 [new Application/Route/Bgp]
$BGP4010 register  $r

$BGP4010 config-file $opt(dir)/bgpd4010.conf
$BGP4010 attach-node $node(4010)
$ns at 316 "$BGP4010 command \"show ip bgp\""

#puts "Creating Router 4040"
set node(4040) [$ns node]
set BGP4040 [new Application/Route/Bgp]
$BGP4040 register  $r

$BGP4040 config-file $opt(dir)/bgpd4040.conf
$BGP4040 attach-node $node(4040)
$ns at 316 "$BGP4040 command \"show ip bgp\""

#puts "Creating Router 4058"
set node(4058) [$ns node]
set BGP4058 [new Application/Route/Bgp]
$BGP4058 register  $r

$BGP4058 config-file $opt(dir)/bgpd4058.conf
$BGP4058 attach-node $node(4058)
$ns at 316 "$BGP4058 command \"show ip bgp\""

#puts "Creating Router 4060"
set node(4060) [$ns node]
set BGP4060 [new Application/Route/Bgp]
$BGP4060 register  $r

$BGP4060 config-file $opt(dir)/bgpd4060.conf
$BGP4060 attach-node $node(4060)
$ns at 316 "$BGP4060 command \"show ip bgp\""

#puts "Creating Router 4130"
set node(4130) [$ns node]
set BGP4130 [new Application/Route/Bgp]
$BGP4130 register  $r

$BGP4130 config-file $opt(dir)/bgpd4130.conf
$BGP4130 attach-node $node(4130)
$ns at 316 "$BGP4130 command \"show ip bgp\""

#puts "Creating Router 4133"
set node(4133) [$ns node]
set BGP4133 [new Application/Route/Bgp]
$BGP4133 register  $r

$BGP4133 config-file $opt(dir)/bgpd4133.conf
$BGP4133 attach-node $node(4133)
$ns at 316 "$BGP4133 command \"show ip bgp\""

#puts "Creating Router 4134"
set node(4134) [$ns node]
set BGP4134 [new Application/Route/Bgp]
$BGP4134 register  $r

$BGP4134 config-file $opt(dir)/bgpd4134.conf
$BGP4134 attach-node $node(4134)
$ns at 316 "$BGP4134 command \"show ip bgp\""

#puts "Creating Router 4151"
set node(4151) [$ns node]
set BGP4151 [new Application/Route/Bgp]
$BGP4151 register  $r

$BGP4151 config-file $opt(dir)/bgpd4151.conf
$BGP4151 attach-node $node(4151)
$ns at 316 "$BGP4151 command \"show ip bgp\""

#puts "Creating Router 4167"
set node(4167) [$ns node]
set BGP4167 [new Application/Route/Bgp]
$BGP4167 register  $r

$BGP4167 config-file $opt(dir)/bgpd4167.conf
$BGP4167 attach-node $node(4167)
$ns at 316 "$BGP4167 command \"show ip bgp\""

#puts "Creating Router 4178"
set node(4178) [$ns node]
set BGP4178 [new Application/Route/Bgp]
$BGP4178 register  $r

$BGP4178 config-file $opt(dir)/bgpd4178.conf
$BGP4178 attach-node $node(4178)
$ns at 316 "$BGP4178 command \"show ip bgp\""

#puts "Creating Router 4183"
set node(4183) [$ns node]
set BGP4183 [new Application/Route/Bgp]
$BGP4183 register  $r

$BGP4183 config-file $opt(dir)/bgpd4183.conf
$BGP4183 attach-node $node(4183)
$ns at 316 "$BGP4183 command \"show ip bgp\""

#puts "Creating Router 4189"
set node(4189) [$ns node]
set BGP4189 [new Application/Route/Bgp]
$BGP4189 register  $r

$BGP4189 config-file $opt(dir)/bgpd4189.conf
$BGP4189 attach-node $node(4189)
$ns at 316 "$BGP4189 command \"show ip bgp\""

#puts "Creating Router 419"
set node(419) [$ns node]
set BGP419 [new Application/Route/Bgp]
$BGP419 register  $r

$BGP419 config-file $opt(dir)/bgpd419.conf
$BGP419 attach-node $node(419)
$ns at 316 "$BGP419 command \"show ip bgp\""

#puts "Creating Router 4195"
set node(4195) [$ns node]
set BGP4195 [new Application/Route/Bgp]
$BGP4195 register  $r

$BGP4195 config-file $opt(dir)/bgpd4195.conf
$BGP4195 attach-node $node(4195)
$ns at 316 "$BGP4195 command \"show ip bgp\""

#puts "Creating Router 4197"
set node(4197) [$ns node]
set BGP4197 [new Application/Route/Bgp]
$BGP4197 register  $r

$BGP4197 config-file $opt(dir)/bgpd4197.conf
$BGP4197 attach-node $node(4197)
$ns at 316 "$BGP4197 command \"show ip bgp\""

#puts "Creating Router 4200"
set node(4200) [$ns node]
set BGP4200 [new Application/Route/Bgp]
$BGP4200 register  $r

$BGP4200 config-file $opt(dir)/bgpd4200.conf
$BGP4200 attach-node $node(4200)
$ns at 316 "$BGP4200 command \"show ip bgp\""

#puts "Creating Router 4203"
set node(4203) [$ns node]
set BGP4203 [new Application/Route/Bgp]
$BGP4203 register  $r

$BGP4203 config-file $opt(dir)/bgpd4203.conf
$BGP4203 attach-node $node(4203)
$ns at 316 "$BGP4203 command \"show ip bgp\""

#puts "Creating Router 4205"
set node(4205) [$ns node]
set BGP4205 [new Application/Route/Bgp]
$BGP4205 register  $r

$BGP4205 config-file $opt(dir)/bgpd4205.conf
$BGP4205 attach-node $node(4205)
$ns at 316 "$BGP4205 command \"show ip bgp\""

#puts "Creating Router 4211"
set node(4211) [$ns node]
set BGP4211 [new Application/Route/Bgp]
$BGP4211 register  $r

$BGP4211 config-file $opt(dir)/bgpd4211.conf
$BGP4211 attach-node $node(4211)
$ns at 316 "$BGP4211 command \"show ip bgp\""

#puts "Creating Router 4222"
set node(4222) [$ns node]
set BGP4222 [new Application/Route/Bgp]
$BGP4222 register  $r

$BGP4222 config-file $opt(dir)/bgpd4222.conf
$BGP4222 attach-node $node(4222)
$ns at 316 "$BGP4222 command \"show ip bgp\""

#puts "Creating Router 4230"
set node(4230) [$ns node]
set BGP4230 [new Application/Route/Bgp]
$BGP4230 register  $r

$BGP4230 config-file $opt(dir)/bgpd4230.conf
$BGP4230 attach-node $node(4230)
$ns at 316 "$BGP4230 command \"show ip bgp\""

#puts "Creating Router 4231"
set node(4231) [$ns node]
set BGP4231 [new Application/Route/Bgp]
$BGP4231 register  $r

$BGP4231 config-file $opt(dir)/bgpd4231.conf
$BGP4231 attach-node $node(4231)
$ns at 316 "$BGP4231 command \"show ip bgp\""

#puts "Creating Router 4232"
set node(4232) [$ns node]
set BGP4232 [new Application/Route/Bgp]
$BGP4232 register  $r

$BGP4232 config-file $opt(dir)/bgpd4232.conf
$BGP4232 attach-node $node(4232)
$ns at 316 "$BGP4232 command \"show ip bgp\""

#puts "Creating Router 4247"
set node(4247) [$ns node]
set BGP4247 [new Application/Route/Bgp]
$BGP4247 register  $r

$BGP4247 config-file $opt(dir)/bgpd4247.conf
$BGP4247 attach-node $node(4247)
$ns at 316 "$BGP4247 command \"show ip bgp\""

#puts "Creating Router 4251"
set node(4251) [$ns node]
set BGP4251 [new Application/Route/Bgp]
$BGP4251 register  $r

$BGP4251 config-file $opt(dir)/bgpd4251.conf
$BGP4251 attach-node $node(4251)
$ns at 316 "$BGP4251 command \"show ip bgp\""

#puts "Creating Router 4259"
set node(4259) [$ns node]
set BGP4259 [new Application/Route/Bgp]
$BGP4259 register  $r

$BGP4259 config-file $opt(dir)/bgpd4259.conf
$BGP4259 attach-node $node(4259)
$ns at 316 "$BGP4259 command \"show ip bgp\""

#puts "Creating Router 4261"
set node(4261) [$ns node]
set BGP4261 [new Application/Route/Bgp]
$BGP4261 register  $r

$BGP4261 config-file $opt(dir)/bgpd4261.conf
$BGP4261 attach-node $node(4261)
$ns at 316 "$BGP4261 command \"show ip bgp\""

#puts "Creating Router 4270"
set node(4270) [$ns node]
set BGP4270 [new Application/Route/Bgp]
$BGP4270 register  $r

$BGP4270 config-file $opt(dir)/bgpd4270.conf
$BGP4270 attach-node $node(4270)
$ns at 316 "$BGP4270 command \"show ip bgp\""

#puts "Creating Router 4274"
set node(4274) [$ns node]
set BGP4274 [new Application/Route/Bgp]
$BGP4274 register  $r

$BGP4274 config-file $opt(dir)/bgpd4274.conf
$BGP4274 attach-node $node(4274)
$ns at 316 "$BGP4274 command \"show ip bgp\""

#puts "Creating Router 4314"
set node(4314) [$ns node]
set BGP4314 [new Application/Route/Bgp]
$BGP4314 register  $r

$BGP4314 config-file $opt(dir)/bgpd4314.conf
$BGP4314 attach-node $node(4314)
$ns at 316 "$BGP4314 command \"show ip bgp\""

#puts "Creating Router 4352"
set node(4352) [$ns node]
set BGP4352 [new Application/Route/Bgp]
$BGP4352 register  $r

$BGP4352 config-file $opt(dir)/bgpd4352.conf
$BGP4352 attach-node $node(4352)
$ns at 316 "$BGP4352 command \"show ip bgp\""

#puts "Creating Router 4358"
set node(4358) [$ns node]
set BGP4358 [new Application/Route/Bgp]
$BGP4358 register  $r

$BGP4358 config-file $opt(dir)/bgpd4358.conf
$BGP4358 attach-node $node(4358)
$ns at 316 "$BGP4358 command \"show ip bgp\""

#puts "Creating Router 4376"
set node(4376) [$ns node]
set BGP4376 [new Application/Route/Bgp]
$BGP4376 register  $r

$BGP4376 config-file $opt(dir)/bgpd4376.conf
$BGP4376 attach-node $node(4376)
$ns at 316 "$BGP4376 command \"show ip bgp\""

#puts "Creating Router 4387"
set node(4387) [$ns node]
set BGP4387 [new Application/Route/Bgp]
$BGP4387 register  $r

$BGP4387 config-file $opt(dir)/bgpd4387.conf
$BGP4387 attach-node $node(4387)
$ns at 316 "$BGP4387 command \"show ip bgp\""

#puts "Creating Router 4390"
set node(4390) [$ns node]
set BGP4390 [new Application/Route/Bgp]
$BGP4390 register  $r

$BGP4390 config-file $opt(dir)/bgpd4390.conf
$BGP4390 attach-node $node(4390)
$ns at 316 "$BGP4390 command \"show ip bgp\""

#puts "Creating Router 4433"
set node(4433) [$ns node]
set BGP4433 [new Application/Route/Bgp]
$BGP4433 register  $r

$BGP4433 config-file $opt(dir)/bgpd4433.conf
$BGP4433 attach-node $node(4433)
$ns at 316 "$BGP4433 command \"show ip bgp\""

#puts "Creating Router 4434"
set node(4434) [$ns node]
set BGP4434 [new Application/Route/Bgp]
$BGP4434 register  $r

$BGP4434 config-file $opt(dir)/bgpd4434.conf
$BGP4434 attach-node $node(4434)
$ns at 316 "$BGP4434 command \"show ip bgp\""

#puts "Creating Router 4436"
set node(4436) [$ns node]
set BGP4436 [new Application/Route/Bgp]
$BGP4436 register  $r

$BGP4436 config-file $opt(dir)/bgpd4436.conf
$BGP4436 attach-node $node(4436)
$ns at 316 "$BGP4436 command \"show ip bgp\""

#puts "Creating Router 4454"
set node(4454) [$ns node]
set BGP4454 [new Application/Route/Bgp]
$BGP4454 register  $r

$BGP4454 config-file $opt(dir)/bgpd4454.conf
$BGP4454 attach-node $node(4454)
$ns at 316 "$BGP4454 command \"show ip bgp\""

#puts "Creating Router 4459"
set node(4459) [$ns node]
set BGP4459 [new Application/Route/Bgp]
$BGP4459 register  $r

$BGP4459 config-file $opt(dir)/bgpd4459.conf
$BGP4459 attach-node $node(4459)
$ns at 316 "$BGP4459 command \"show ip bgp\""

#puts "Creating Router 4470"
set node(4470) [$ns node]
set BGP4470 [new Application/Route/Bgp]
$BGP4470 register  $r

$BGP4470 config-file $opt(dir)/bgpd4470.conf
$BGP4470 attach-node $node(4470)
$ns at 316 "$BGP4470 command \"show ip bgp\""

#puts "Creating Router 4472"
set node(4472) [$ns node]
set BGP4472 [new Application/Route/Bgp]
$BGP4472 register  $r

$BGP4472 config-file $opt(dir)/bgpd4472.conf
$BGP4472 attach-node $node(4472)
$ns at 316 "$BGP4472 command \"show ip bgp\""

#puts "Creating Router 4492"
set node(4492) [$ns node]
set BGP4492 [new Application/Route/Bgp]
$BGP4492 register  $r

$BGP4492 config-file $opt(dir)/bgpd4492.conf
$BGP4492 attach-node $node(4492)
$ns at 316 "$BGP4492 command \"show ip bgp\""

#puts "Creating Router 4495"
set node(4495) [$ns node]
set BGP4495 [new Application/Route/Bgp]
$BGP4495 register  $r

$BGP4495 config-file $opt(dir)/bgpd4495.conf
$BGP4495 attach-node $node(4495)
$ns at 316 "$BGP4495 command \"show ip bgp\""

#puts "Creating Router 4496"
set node(4496) [$ns node]
set BGP4496 [new Application/Route/Bgp]
$BGP4496 register  $r

$BGP4496 config-file $opt(dir)/bgpd4496.conf
$BGP4496 attach-node $node(4496)
$ns at 316 "$BGP4496 command \"show ip bgp\""

#puts "Creating Router 450"
set node(450) [$ns node]
set BGP450 [new Application/Route/Bgp]
$BGP450 register  $r

$BGP450 config-file $opt(dir)/bgpd450.conf
$BGP450 attach-node $node(450)
$ns at 316 "$BGP450 command \"show ip bgp\""

#puts "Creating Router 4509"
set node(4509) [$ns node]
set BGP4509 [new Application/Route/Bgp]
$BGP4509 register  $r

$BGP4509 config-file $opt(dir)/bgpd4509.conf
$BGP4509 attach-node $node(4509)
$ns at 316 "$BGP4509 command \"show ip bgp\""

#puts "Creating Router 4513"
set node(4513) [$ns node]
set BGP4513 [new Application/Route/Bgp]
$BGP4513 register  $r

$BGP4513 config-file $opt(dir)/bgpd4513.conf
$BGP4513 attach-node $node(4513)
$ns at 316 "$BGP4513 command \"show ip bgp\""

#puts "Creating Router 4515"
set node(4515) [$ns node]
set BGP4515 [new Application/Route/Bgp]
$BGP4515 register  $r

$BGP4515 config-file $opt(dir)/bgpd4515.conf
$BGP4515 attach-node $node(4515)
$ns at 316 "$BGP4515 command \"show ip bgp\""

#puts "Creating Router 4527"
set node(4527) [$ns node]
set BGP4527 [new Application/Route/Bgp]
$BGP4527 register  $r

$BGP4527 config-file $opt(dir)/bgpd4527.conf
$BGP4527 attach-node $node(4527)
$ns at 316 "$BGP4527 command \"show ip bgp\""

#puts "Creating Router 4534"
set node(4534) [$ns node]
set BGP4534 [new Application/Route/Bgp]
$BGP4534 register  $r

$BGP4534 config-file $opt(dir)/bgpd4534.conf
$BGP4534 attach-node $node(4534)
$ns at 316 "$BGP4534 command \"show ip bgp\""

#puts "Creating Router 4535"
set node(4535) [$ns node]
set BGP4535 [new Application/Route/Bgp]
$BGP4535 register  $r

$BGP4535 config-file $opt(dir)/bgpd4535.conf
$BGP4535 attach-node $node(4535)
$ns at 316 "$BGP4535 command \"show ip bgp\""

#puts "Creating Router 4544"
set node(4544) [$ns node]
set BGP4544 [new Application/Route/Bgp]
$BGP4544 register  $r

$BGP4544 config-file $opt(dir)/bgpd4544.conf
$BGP4544 attach-node $node(4544)
$ns at 316 "$BGP4544 command \"show ip bgp\""

#puts "Creating Router 4550"
set node(4550) [$ns node]
set BGP4550 [new Application/Route/Bgp]
$BGP4550 register  $r

$BGP4550 config-file $opt(dir)/bgpd4550.conf
$BGP4550 attach-node $node(4550)
$ns at 316 "$BGP4550 command \"show ip bgp\""

#puts "Creating Router 4557"
set node(4557) [$ns node]
set BGP4557 [new Application/Route/Bgp]
$BGP4557 register  $r

$BGP4557 config-file $opt(dir)/bgpd4557.conf
$BGP4557 attach-node $node(4557)
$ns at 316 "$BGP4557 command \"show ip bgp\""

#puts "Creating Router 4565"
set node(4565) [$ns node]
set BGP4565 [new Application/Route/Bgp]
$BGP4565 register  $r

$BGP4565 config-file $opt(dir)/bgpd4565.conf
$BGP4565 attach-node $node(4565)
$ns at 316 "$BGP4565 command \"show ip bgp\""

#puts "Creating Router 4589"
set node(4589) [$ns node]
set BGP4589 [new Application/Route/Bgp]
$BGP4589 register  $r

$BGP4589 config-file $opt(dir)/bgpd4589.conf
$BGP4589 attach-node $node(4589)
$ns at 316 "$BGP4589 command \"show ip bgp\""

#puts "Creating Router 4600"
set node(4600) [$ns node]
set BGP4600 [new Application/Route/Bgp]
$BGP4600 register  $r

$BGP4600 config-file $opt(dir)/bgpd4600.conf
$BGP4600 attach-node $node(4600)
$ns at 316 "$BGP4600 command \"show ip bgp\""

#puts "Creating Router 4609"
set node(4609) [$ns node]
set BGP4609 [new Application/Route/Bgp]
$BGP4609 register  $r

$BGP4609 config-file $opt(dir)/bgpd4609.conf
$BGP4609 attach-node $node(4609)
$ns at 316 "$BGP4609 command \"show ip bgp\""

#puts "Creating Router 4618"
set node(4618) [$ns node]
set BGP4618 [new Application/Route/Bgp]
$BGP4618 register  $r

$BGP4618 config-file $opt(dir)/bgpd4618.conf
$BGP4618 attach-node $node(4618)
$ns at 316 "$BGP4618 command \"show ip bgp\""

#puts "Creating Router 4621"
set node(4621) [$ns node]
set BGP4621 [new Application/Route/Bgp]
$BGP4621 register  $r

$BGP4621 config-file $opt(dir)/bgpd4621.conf
$BGP4621 attach-node $node(4621)
$ns at 316 "$BGP4621 command \"show ip bgp\""

#puts "Creating Router 4622"
set node(4622) [$ns node]
set BGP4622 [new Application/Route/Bgp]
$BGP4622 register  $r

$BGP4622 config-file $opt(dir)/bgpd4622.conf
$BGP4622 attach-node $node(4622)
$ns at 316 "$BGP4622 command \"show ip bgp\""

#puts "Creating Router 4623"
set node(4623) [$ns node]
set BGP4623 [new Application/Route/Bgp]
$BGP4623 register  $r

$BGP4623 config-file $opt(dir)/bgpd4623.conf
$BGP4623 attach-node $node(4623)
$ns at 316 "$BGP4623 command \"show ip bgp\""

#puts "Creating Router 4628"
set node(4628) [$ns node]
set BGP4628 [new Application/Route/Bgp]
$BGP4628 register  $r

$BGP4628 config-file $opt(dir)/bgpd4628.conf
$BGP4628 attach-node $node(4628)
$ns at 316 "$BGP4628 command \"show ip bgp\""

#puts "Creating Router 4630"
set node(4630) [$ns node]
set BGP4630 [new Application/Route/Bgp]
$BGP4630 register  $r

$BGP4630 config-file $opt(dir)/bgpd4630.conf
$BGP4630 attach-node $node(4630)
$ns at 316 "$BGP4630 command \"show ip bgp\""

#puts "Creating Router 4631"
set node(4631) [$ns node]
set BGP4631 [new Application/Route/Bgp]
$BGP4631 register  $r

$BGP4631 config-file $opt(dir)/bgpd4631.conf
$BGP4631 attach-node $node(4631)
$ns at 316 "$BGP4631 command \"show ip bgp\""

#puts "Creating Router 4637"
set node(4637) [$ns node]
set BGP4637 [new Application/Route/Bgp]
$BGP4637 register  $r

$BGP4637 config-file $opt(dir)/bgpd4637.conf
$BGP4637 attach-node $node(4637)
$ns at 316 "$BGP4637 command \"show ip bgp\""

#puts "Creating Router 4648"
set node(4648) [$ns node]
set BGP4648 [new Application/Route/Bgp]
$BGP4648 register  $r

$BGP4648 config-file $opt(dir)/bgpd4648.conf
$BGP4648 attach-node $node(4648)
$ns at 316 "$BGP4648 command \"show ip bgp\""

#puts "Creating Router 4651"
set node(4651) [$ns node]
set BGP4651 [new Application/Route/Bgp]
$BGP4651 register  $r

$BGP4651 config-file $opt(dir)/bgpd4651.conf
$BGP4651 attach-node $node(4651)
$ns at 316 "$BGP4651 command \"show ip bgp\""

#puts "Creating Router 4652"
set node(4652) [$ns node]
set BGP4652 [new Application/Route/Bgp]
$BGP4652 register  $r

$BGP4652 config-file $opt(dir)/bgpd4652.conf
$BGP4652 attach-node $node(4652)
$ns at 316 "$BGP4652 command \"show ip bgp\""

#puts "Creating Router 4657"
set node(4657) [$ns node]
set BGP4657 [new Application/Route/Bgp]
$BGP4657 register  $r

$BGP4657 config-file $opt(dir)/bgpd4657.conf
$BGP4657 attach-node $node(4657)
$ns at 316 "$BGP4657 command \"show ip bgp\""

#puts "Creating Router 4660"
set node(4660) [$ns node]
set BGP4660 [new Application/Route/Bgp]
$BGP4660 register  $r

$BGP4660 config-file $opt(dir)/bgpd4660.conf
$BGP4660 attach-node $node(4660)
$ns at 316 "$BGP4660 command \"show ip bgp\""

#puts "Creating Router 4662"
set node(4662) [$ns node]
set BGP4662 [new Application/Route/Bgp]
$BGP4662 register  $r

$BGP4662 config-file $opt(dir)/bgpd4662.conf
$BGP4662 attach-node $node(4662)
$ns at 316 "$BGP4662 command \"show ip bgp\""

#puts "Creating Router 4663"
set node(4663) [$ns node]
set BGP4663 [new Application/Route/Bgp]
$BGP4663 register  $r

$BGP4663 config-file $opt(dir)/bgpd4663.conf
$BGP4663 attach-node $node(4663)
$ns at 316 "$BGP4663 command \"show ip bgp\""

#puts "Creating Router 4668"
set node(4668) [$ns node]
set BGP4668 [new Application/Route/Bgp]
$BGP4668 register  $r

$BGP4668 config-file $opt(dir)/bgpd4668.conf
$BGP4668 attach-node $node(4668)
$ns at 316 "$BGP4668 command \"show ip bgp\""

#puts "Creating Router 4673"
set node(4673) [$ns node]
set BGP4673 [new Application/Route/Bgp]
$BGP4673 register  $r

$BGP4673 config-file $opt(dir)/bgpd4673.conf
$BGP4673 attach-node $node(4673)
$ns at 316 "$BGP4673 command \"show ip bgp\""

#puts "Creating Router 4677"
set node(4677) [$ns node]
set BGP4677 [new Application/Route/Bgp]
$BGP4677 register  $r

$BGP4677 config-file $opt(dir)/bgpd4677.conf
$BGP4677 attach-node $node(4677)
$ns at 316 "$BGP4677 command \"show ip bgp\""

#puts "Creating Router 4678"
set node(4678) [$ns node]
set BGP4678 [new Application/Route/Bgp]
$BGP4678 register  $r

$BGP4678 config-file $opt(dir)/bgpd4678.conf
$BGP4678 attach-node $node(4678)
$ns at 316 "$BGP4678 command \"show ip bgp\""

#puts "Creating Router 4681"
set node(4681) [$ns node]
set BGP4681 [new Application/Route/Bgp]
$BGP4681 register  $r

$BGP4681 config-file $opt(dir)/bgpd4681.conf
$BGP4681 attach-node $node(4681)
$ns at 316 "$BGP4681 command \"show ip bgp\""

#puts "Creating Router 4682"
set node(4682) [$ns node]
set BGP4682 [new Application/Route/Bgp]
$BGP4682 register  $r

$BGP4682 config-file $opt(dir)/bgpd4682.conf
$BGP4682 attach-node $node(4682)
$ns at 316 "$BGP4682 command \"show ip bgp\""

#puts "Creating Router 4686"
set node(4686) [$ns node]
set BGP4686 [new Application/Route/Bgp]
$BGP4686 register  $r

$BGP4686 config-file $opt(dir)/bgpd4686.conf
$BGP4686 attach-node $node(4686)
$ns at 316 "$BGP4686 command \"show ip bgp\""

#puts "Creating Router 4691"
set node(4691) [$ns node]
set BGP4691 [new Application/Route/Bgp]
$BGP4691 register  $r

$BGP4691 config-file $opt(dir)/bgpd4691.conf
$BGP4691 attach-node $node(4691)
$ns at 316 "$BGP4691 command \"show ip bgp\""

#puts "Creating Router 4692"
set node(4692) [$ns node]
set BGP4692 [new Application/Route/Bgp]
$BGP4692 register  $r

$BGP4692 config-file $opt(dir)/bgpd4692.conf
$BGP4692 attach-node $node(4692)
$ns at 316 "$BGP4692 command \"show ip bgp\""

#puts "Creating Router 4694"
set node(4694) [$ns node]
set BGP4694 [new Application/Route/Bgp]
$BGP4694 register  $r

$BGP4694 config-file $opt(dir)/bgpd4694.conf
$BGP4694 attach-node $node(4694)
$ns at 316 "$BGP4694 command \"show ip bgp\""

#puts "Creating Router 4700"
set node(4700) [$ns node]
set BGP4700 [new Application/Route/Bgp]
$BGP4700 register  $r

$BGP4700 config-file $opt(dir)/bgpd4700.conf
$BGP4700 attach-node $node(4700)
$ns at 316 "$BGP4700 command \"show ip bgp\""

#puts "Creating Router 4704"
set node(4704) [$ns node]
set BGP4704 [new Application/Route/Bgp]
$BGP4704 register  $r

$BGP4704 config-file $opt(dir)/bgpd4704.conf
$BGP4704 attach-node $node(4704)
$ns at 316 "$BGP4704 command \"show ip bgp\""

#puts "Creating Router 4708"
set node(4708) [$ns node]
set BGP4708 [new Application/Route/Bgp]
$BGP4708 register  $r

$BGP4708 config-file $opt(dir)/bgpd4708.conf
$BGP4708 attach-node $node(4708)
$ns at 316 "$BGP4708 command \"show ip bgp\""

#puts "Creating Router 4710"
set node(4710) [$ns node]
set BGP4710 [new Application/Route/Bgp]
$BGP4710 register  $r

$BGP4710 config-file $opt(dir)/bgpd4710.conf
$BGP4710 attach-node $node(4710)
$ns at 316 "$BGP4710 command \"show ip bgp\""

#puts "Creating Router 4711"
set node(4711) [$ns node]
set BGP4711 [new Application/Route/Bgp]
$BGP4711 register  $r

$BGP4711 config-file $opt(dir)/bgpd4711.conf
$BGP4711 attach-node $node(4711)
$ns at 316 "$BGP4711 command \"show ip bgp\""

#puts "Creating Router 4713"
set node(4713) [$ns node]
set BGP4713 [new Application/Route/Bgp]
$BGP4713 register  $r

$BGP4713 config-file $opt(dir)/bgpd4713.conf
$BGP4713 attach-node $node(4713)
$ns at 316 "$BGP4713 command \"show ip bgp\""

#puts "Creating Router 4716"
set node(4716) [$ns node]
set BGP4716 [new Application/Route/Bgp]
$BGP4716 register  $r

$BGP4716 config-file $opt(dir)/bgpd4716.conf
$BGP4716 attach-node $node(4716)
$ns at 316 "$BGP4716 command \"show ip bgp\""

#puts "Creating Router 4717"
set node(4717) [$ns node]
set BGP4717 [new Application/Route/Bgp]
$BGP4717 register  $r

$BGP4717 config-file $opt(dir)/bgpd4717.conf
$BGP4717 attach-node $node(4717)
$ns at 316 "$BGP4717 command \"show ip bgp\""

#puts "Creating Router 4720"
set node(4720) [$ns node]
set BGP4720 [new Application/Route/Bgp]
$BGP4720 register  $r

$BGP4720 config-file $opt(dir)/bgpd4720.conf
$BGP4720 attach-node $node(4720)
$ns at 316 "$BGP4720 command \"show ip bgp\""

#puts "Creating Router 4722"
set node(4722) [$ns node]
set BGP4722 [new Application/Route/Bgp]
$BGP4722 register  $r

$BGP4722 config-file $opt(dir)/bgpd4722.conf
$BGP4722 attach-node $node(4722)
$ns at 316 "$BGP4722 command \"show ip bgp\""

#puts "Creating Router 4725"
set node(4725) [$ns node]
set BGP4725 [new Application/Route/Bgp]
$BGP4725 register  $r

$BGP4725 config-file $opt(dir)/bgpd4725.conf
$BGP4725 attach-node $node(4725)
$ns at 316 "$BGP4725 command \"show ip bgp\""

#puts "Creating Router 4727"
set node(4727) [$ns node]
set BGP4727 [new Application/Route/Bgp]
$BGP4727 register  $r

$BGP4727 config-file $opt(dir)/bgpd4727.conf
$BGP4727 attach-node $node(4727)
$ns at 316 "$BGP4727 command \"show ip bgp\""

#puts "Creating Router 4728"
set node(4728) [$ns node]
set BGP4728 [new Application/Route/Bgp]
$BGP4728 register  $r

$BGP4728 config-file $opt(dir)/bgpd4728.conf
$BGP4728 attach-node $node(4728)
$ns at 316 "$BGP4728 command \"show ip bgp\""

#puts "Creating Router 4736"
set node(4736) [$ns node]
set BGP4736 [new Application/Route/Bgp]
$BGP4736 register  $r

$BGP4736 config-file $opt(dir)/bgpd4736.conf
$BGP4736 attach-node $node(4736)
$ns at 316 "$BGP4736 command \"show ip bgp\""

#puts "Creating Router 4738"
set node(4738) [$ns node]
set BGP4738 [new Application/Route/Bgp]
$BGP4738 register  $r

$BGP4738 config-file $opt(dir)/bgpd4738.conf
$BGP4738 attach-node $node(4738)
$ns at 316 "$BGP4738 command \"show ip bgp\""

#puts "Creating Router 4740"
set node(4740) [$ns node]
set BGP4740 [new Application/Route/Bgp]
$BGP4740 register  $r

$BGP4740 config-file $opt(dir)/bgpd4740.conf
$BGP4740 attach-node $node(4740)
$ns at 316 "$BGP4740 command \"show ip bgp\""

#puts "Creating Router 4742"
set node(4742) [$ns node]
set BGP4742 [new Application/Route/Bgp]
$BGP4742 register  $r

$BGP4742 config-file $opt(dir)/bgpd4742.conf
$BGP4742 attach-node $node(4742)
$ns at 316 "$BGP4742 command \"show ip bgp\""

#puts "Creating Router 4744"
set node(4744) [$ns node]
set BGP4744 [new Application/Route/Bgp]
$BGP4744 register  $r

$BGP4744 config-file $opt(dir)/bgpd4744.conf
$BGP4744 attach-node $node(4744)
$ns at 316 "$BGP4744 command \"show ip bgp\""

#puts "Creating Router 4755"
set node(4755) [$ns node]
set BGP4755 [new Application/Route/Bgp]
$BGP4755 register  $r

$BGP4755 config-file $opt(dir)/bgpd4755.conf
$BGP4755 attach-node $node(4755)
$ns at 316 "$BGP4755 command \"show ip bgp\""

#puts "Creating Router 4760"
set node(4760) [$ns node]
set BGP4760 [new Application/Route/Bgp]
$BGP4760 register  $r

$BGP4760 config-file $opt(dir)/bgpd4760.conf
$BGP4760 attach-node $node(4760)
$ns at 316 "$BGP4760 command \"show ip bgp\""

#puts "Creating Router 4761"
set node(4761) [$ns node]
set BGP4761 [new Application/Route/Bgp]
$BGP4761 register  $r

$BGP4761 config-file $opt(dir)/bgpd4761.conf
$BGP4761 attach-node $node(4761)
$ns at 316 "$BGP4761 command \"show ip bgp\""

#puts "Creating Router 4762"
set node(4762) [$ns node]
set BGP4762 [new Application/Route/Bgp]
$BGP4762 register  $r

$BGP4762 config-file $opt(dir)/bgpd4762.conf
$BGP4762 attach-node $node(4762)
$ns at 316 "$BGP4762 command \"show ip bgp\""

#puts "Creating Router 4763"
set node(4763) [$ns node]
set BGP4763 [new Application/Route/Bgp]
$BGP4763 register  $r

$BGP4763 config-file $opt(dir)/bgpd4763.conf
$BGP4763 attach-node $node(4763)
$ns at 316 "$BGP4763 command \"show ip bgp\""

#puts "Creating Router 4765"
set node(4765) [$ns node]
set BGP4765 [new Application/Route/Bgp]
$BGP4765 register  $r

$BGP4765 config-file $opt(dir)/bgpd4765.conf
$BGP4765 attach-node $node(4765)
$ns at 316 "$BGP4765 command \"show ip bgp\""

#puts "Creating Router 4766"
set node(4766) [$ns node]
set BGP4766 [new Application/Route/Bgp]
$BGP4766 register  $r

$BGP4766 config-file $opt(dir)/bgpd4766.conf
$BGP4766 attach-node $node(4766)
$ns at 316 "$BGP4766 command \"show ip bgp\""

#puts "Creating Router 4767"
set node(4767) [$ns node]
set BGP4767 [new Application/Route/Bgp]
$BGP4767 register  $r

$BGP4767 config-file $opt(dir)/bgpd4767.conf
$BGP4767 attach-node $node(4767)
$ns at 316 "$BGP4767 command \"show ip bgp\""

#puts "Creating Router 4768"
set node(4768) [$ns node]
set BGP4768 [new Application/Route/Bgp]
$BGP4768 register  $r

$BGP4768 config-file $opt(dir)/bgpd4768.conf
$BGP4768 attach-node $node(4768)
$ns at 316 "$BGP4768 command \"show ip bgp\""

#puts "Creating Router 4774"
set node(4774) [$ns node]
set BGP4774 [new Application/Route/Bgp]
$BGP4774 register  $r

$BGP4774 config-file $opt(dir)/bgpd4774.conf
$BGP4774 attach-node $node(4774)
$ns at 316 "$BGP4774 command \"show ip bgp\""

#puts "Creating Router 4775"
set node(4775) [$ns node]
set BGP4775 [new Application/Route/Bgp]
$BGP4775 register  $r

$BGP4775 config-file $opt(dir)/bgpd4775.conf
$BGP4775 attach-node $node(4775)
$ns at 316 "$BGP4775 command \"show ip bgp\""

#puts "Creating Router 4776"
set node(4776) [$ns node]
set BGP4776 [new Application/Route/Bgp]
$BGP4776 register  $r

$BGP4776 config-file $opt(dir)/bgpd4776.conf
$BGP4776 attach-node $node(4776)
$ns at 316 "$BGP4776 command \"show ip bgp\""

#puts "Creating Router 4778"
set node(4778) [$ns node]
set BGP4778 [new Application/Route/Bgp]
$BGP4778 register  $r

$BGP4778 config-file $opt(dir)/bgpd4778.conf
$BGP4778 attach-node $node(4778)
$ns at 316 "$BGP4778 command \"show ip bgp\""

#puts "Creating Router 4779"
set node(4779) [$ns node]
set BGP4779 [new Application/Route/Bgp]
$BGP4779 register  $r

$BGP4779 config-file $opt(dir)/bgpd4779.conf
$BGP4779 attach-node $node(4779)
$ns at 316 "$BGP4779 command \"show ip bgp\""

#puts "Creating Router 4780"
set node(4780) [$ns node]
set BGP4780 [new Application/Route/Bgp]
$BGP4780 register  $r

$BGP4780 config-file $opt(dir)/bgpd4780.conf
$BGP4780 attach-node $node(4780)
$ns at 316 "$BGP4780 command \"show ip bgp\""

#puts "Creating Router 4783"
set node(4783) [$ns node]
set BGP4783 [new Application/Route/Bgp]
$BGP4783 register  $r

$BGP4783 config-file $opt(dir)/bgpd4783.conf
$BGP4783 attach-node $node(4783)
$ns at 316 "$BGP4783 command \"show ip bgp\""

#puts "Creating Router 4786"
set node(4786) [$ns node]
set BGP4786 [new Application/Route/Bgp]
$BGP4786 register  $r

$BGP4786 config-file $opt(dir)/bgpd4786.conf
$BGP4786 attach-node $node(4786)
$ns at 316 "$BGP4786 command \"show ip bgp\""

#puts "Creating Router 4788"
set node(4788) [$ns node]
set BGP4788 [new Application/Route/Bgp]
$BGP4788 register  $r

$BGP4788 config-file $opt(dir)/bgpd4788.conf
$BGP4788 attach-node $node(4788)
$ns at 316 "$BGP4788 command \"show ip bgp\""

#puts "Creating Router 4792"
set node(4792) [$ns node]
set BGP4792 [new Application/Route/Bgp]
$BGP4792 register  $r

$BGP4792 config-file $opt(dir)/bgpd4792.conf
$BGP4792 attach-node $node(4792)
$ns at 316 "$BGP4792 command \"show ip bgp\""

#puts "Creating Router 4793"
set node(4793) [$ns node]
set BGP4793 [new Application/Route/Bgp]
$BGP4793 register  $r

$BGP4793 config-file $opt(dir)/bgpd4793.conf
$BGP4793 attach-node $node(4793)
$ns at 316 "$BGP4793 command \"show ip bgp\""

#puts "Creating Router 4794"
set node(4794) [$ns node]
set BGP4794 [new Application/Route/Bgp]
$BGP4794 register  $r

$BGP4794 config-file $opt(dir)/bgpd4794.conf
$BGP4794 attach-node $node(4794)
$ns at 316 "$BGP4794 command \"show ip bgp\""

#puts "Creating Router 4795"
set node(4795) [$ns node]
set BGP4795 [new Application/Route/Bgp]
$BGP4795 register  $r

$BGP4795 config-file $opt(dir)/bgpd4795.conf
$BGP4795 attach-node $node(4795)
$ns at 316 "$BGP4795 command \"show ip bgp\""

#puts "Creating Router 4796"
set node(4796) [$ns node]
set BGP4796 [new Application/Route/Bgp]
$BGP4796 register  $r

$BGP4796 config-file $opt(dir)/bgpd4796.conf
$BGP4796 attach-node $node(4796)
$ns at 316 "$BGP4796 command \"show ip bgp\""

#puts "Creating Router 4800"
set node(4800) [$ns node]
set BGP4800 [new Application/Route/Bgp]
$BGP4800 register  $r

$BGP4800 config-file $opt(dir)/bgpd4800.conf
$BGP4800 attach-node $node(4800)
$ns at 316 "$BGP4800 command \"show ip bgp\""

#puts "Creating Router 4803"
set node(4803) [$ns node]
set BGP4803 [new Application/Route/Bgp]
$BGP4803 register  $r

$BGP4803 config-file $opt(dir)/bgpd4803.conf
$BGP4803 attach-node $node(4803)
$ns at 316 "$BGP4803 command \"show ip bgp\""

#puts "Creating Router 4805"
set node(4805) [$ns node]
set BGP4805 [new Application/Route/Bgp]
$BGP4805 register  $r

$BGP4805 config-file $opt(dir)/bgpd4805.conf
$BGP4805 attach-node $node(4805)
$ns at 316 "$BGP4805 command \"show ip bgp\""

#puts "Creating Router 4855"
set node(4855) [$ns node]
set BGP4855 [new Application/Route/Bgp]
$BGP4855 register  $r

$BGP4855 config-file $opt(dir)/bgpd4855.conf
$BGP4855 attach-node $node(4855)
$ns at 316 "$BGP4855 command \"show ip bgp\""

#puts "Creating Router 4861"
set node(4861) [$ns node]
set BGP4861 [new Application/Route/Bgp]
$BGP4861 register  $r

$BGP4861 config-file $opt(dir)/bgpd4861.conf
$BGP4861 attach-node $node(4861)
$ns at 316 "$BGP4861 command \"show ip bgp\""

#puts "Creating Router 4911"
set node(4911) [$ns node]
set BGP4911 [new Application/Route/Bgp]
$BGP4911 register  $r

$BGP4911 config-file $opt(dir)/bgpd4911.conf
$BGP4911 attach-node $node(4911)
$ns at 316 "$BGP4911 command \"show ip bgp\""

#puts "Creating Router 4913"
set node(4913) [$ns node]
set BGP4913 [new Application/Route/Bgp]
$BGP4913 register  $r

$BGP4913 config-file $opt(dir)/bgpd4913.conf
$BGP4913 attach-node $node(4913)
$ns at 316 "$BGP4913 command \"show ip bgp\""

#puts "Creating Router 4923"
set node(4923) [$ns node]
set BGP4923 [new Application/Route/Bgp]
$BGP4923 register  $r

$BGP4923 config-file $opt(dir)/bgpd4923.conf
$BGP4923 attach-node $node(4923)
$ns at 316 "$BGP4923 command \"show ip bgp\""

#puts "Creating Router 4926"
set node(4926) [$ns node]
set BGP4926 [new Application/Route/Bgp]
$BGP4926 register  $r

$BGP4926 config-file $opt(dir)/bgpd4926.conf
$BGP4926 attach-node $node(4926)
$ns at 316 "$BGP4926 command \"show ip bgp\""

#puts "Creating Router 4957"
set node(4957) [$ns node]
set BGP4957 [new Application/Route/Bgp]
$BGP4957 register  $r

$BGP4957 config-file $opt(dir)/bgpd4957.conf
$BGP4957 attach-node $node(4957)
$ns at 316 "$BGP4957 command \"show ip bgp\""

#puts "Creating Router 4958"
set node(4958) [$ns node]
set BGP4958 [new Application/Route/Bgp]
$BGP4958 register  $r

$BGP4958 config-file $opt(dir)/bgpd4958.conf
$BGP4958 attach-node $node(4958)
$ns at 316 "$BGP4958 command \"show ip bgp\""

#puts "Creating Router 4963"
set node(4963) [$ns node]
set BGP4963 [new Application/Route/Bgp]
$BGP4963 register  $r

$BGP4963 config-file $opt(dir)/bgpd4963.conf
$BGP4963 attach-node $node(4963)
$ns at 316 "$BGP4963 command \"show ip bgp\""

#puts "Creating Router 4967"
set node(4967) [$ns node]
set BGP4967 [new Application/Route/Bgp]
$BGP4967 register  $r

$BGP4967 config-file $opt(dir)/bgpd4967.conf
$BGP4967 attach-node $node(4967)
$ns at 316 "$BGP4967 command \"show ip bgp\""

#puts "Creating Router 4969"
set node(4969) [$ns node]
set BGP4969 [new Application/Route/Bgp]
$BGP4969 register  $r

$BGP4969 config-file $opt(dir)/bgpd4969.conf
$BGP4969 attach-node $node(4969)
$ns at 316 "$BGP4969 command \"show ip bgp\""

#puts "Creating Router 4982"
set node(4982) [$ns node]
set BGP4982 [new Application/Route/Bgp]
$BGP4982 register  $r

$BGP4982 config-file $opt(dir)/bgpd4982.conf
$BGP4982 attach-node $node(4982)
$ns at 316 "$BGP4982 command \"show ip bgp\""

#puts "Creating Router 50"
set node(50) [$ns node]
set BGP50 [new Application/Route/Bgp]
$BGP50 register  $r

$BGP50 config-file $opt(dir)/bgpd50.conf
$BGP50 attach-node $node(50)
$ns at 316 "$BGP50 command \"show ip bgp\""

#puts "Creating Router 5000"
set node(5000) [$ns node]
set BGP5000 [new Application/Route/Bgp]
$BGP5000 register  $r

$BGP5000 config-file $opt(dir)/bgpd5000.conf
$BGP5000 attach-node $node(5000)
$ns at 316 "$BGP5000 command \"show ip bgp\""

#puts "Creating Router 5002"
set node(5002) [$ns node]
set BGP5002 [new Application/Route/Bgp]
$BGP5002 register  $r

$BGP5002 config-file $opt(dir)/bgpd5002.conf
$BGP5002 attach-node $node(5002)
$ns at 316 "$BGP5002 command \"show ip bgp\""

#puts "Creating Router 5003"
set node(5003) [$ns node]
set BGP5003 [new Application/Route/Bgp]
$BGP5003 register  $r

$BGP5003 config-file $opt(dir)/bgpd5003.conf
$BGP5003 attach-node $node(5003)
$ns at 316 "$BGP5003 command \"show ip bgp\""

#puts "Creating Router 5006"
set node(5006) [$ns node]
set BGP5006 [new Application/Route/Bgp]
$BGP5006 register  $r

$BGP5006 config-file $opt(dir)/bgpd5006.conf
$BGP5006 attach-node $node(5006)
$ns at 316 "$BGP5006 command \"show ip bgp\""

#puts "Creating Router 5009"
set node(5009) [$ns node]
set BGP5009 [new Application/Route/Bgp]
$BGP5009 register  $r

$BGP5009 config-file $opt(dir)/bgpd5009.conf
$BGP5009 attach-node $node(5009)
$ns at 316 "$BGP5009 command \"show ip bgp\""

#puts "Creating Router 5048"
set node(5048) [$ns node]
set BGP5048 [new Application/Route/Bgp]
$BGP5048 register  $r

$BGP5048 config-file $opt(dir)/bgpd5048.conf
$BGP5048 attach-node $node(5048)
$ns at 316 "$BGP5048 command \"show ip bgp\""

#puts "Creating Router 5050"
set node(5050) [$ns node]
set BGP5050 [new Application/Route/Bgp]
$BGP5050 register  $r

$BGP5050 config-file $opt(dir)/bgpd5050.conf
$BGP5050 attach-node $node(5050)
$ns at 316 "$BGP5050 command \"show ip bgp\""

#puts "Creating Router 5051"
set node(5051) [$ns node]
set BGP5051 [new Application/Route/Bgp]
$BGP5051 register  $r

$BGP5051 config-file $opt(dir)/bgpd5051.conf
$BGP5051 attach-node $node(5051)
$ns at 316 "$BGP5051 command \"show ip bgp\""

#puts "Creating Router 5072"
set node(5072) [$ns node]
set BGP5072 [new Application/Route/Bgp]
$BGP5072 register  $r

$BGP5072 config-file $opt(dir)/bgpd5072.conf
$BGP5072 attach-node $node(5072)
$ns at 316 "$BGP5072 command \"show ip bgp\""

#puts "Creating Router 5074"
set node(5074) [$ns node]
set BGP5074 [new Application/Route/Bgp]
$BGP5074 register  $r

$BGP5074 config-file $opt(dir)/bgpd5074.conf
$BGP5074 attach-node $node(5074)
$ns at 316 "$BGP5074 command \"show ip bgp\""

#puts "Creating Router 5075"
set node(5075) [$ns node]
set BGP5075 [new Application/Route/Bgp]
$BGP5075 register  $r

$BGP5075 config-file $opt(dir)/bgpd5075.conf
$BGP5075 attach-node $node(5075)
$ns at 316 "$BGP5075 command \"show ip bgp\""

#puts "Creating Router 5076"
set node(5076) [$ns node]
set BGP5076 [new Application/Route/Bgp]
$BGP5076 register  $r

$BGP5076 config-file $opt(dir)/bgpd5076.conf
$BGP5076 attach-node $node(5076)
$ns at 316 "$BGP5076 command \"show ip bgp\""

#puts "Creating Router 5078"
set node(5078) [$ns node]
set BGP5078 [new Application/Route/Bgp]
$BGP5078 register  $r

$BGP5078 config-file $opt(dir)/bgpd5078.conf
$BGP5078 attach-node $node(5078)
$ns at 316 "$BGP5078 command \"show ip bgp\""

#puts "Creating Router 5089"
set node(5089) [$ns node]
set BGP5089 [new Application/Route/Bgp]
$BGP5089 register  $r

$BGP5089 config-file $opt(dir)/bgpd5089.conf
$BGP5089 attach-node $node(5089)
$ns at 316 "$BGP5089 command \"show ip bgp\""

#puts "Creating Router 5097"
set node(5097) [$ns node]
set BGP5097 [new Application/Route/Bgp]
$BGP5097 register  $r

$BGP5097 config-file $opt(dir)/bgpd5097.conf
$BGP5097 attach-node $node(5097)
$ns at 316 "$BGP5097 command \"show ip bgp\""

#puts "Creating Router 5109"
set node(5109) [$ns node]
set BGP5109 [new Application/Route/Bgp]
$BGP5109 register  $r

$BGP5109 config-file $opt(dir)/bgpd5109.conf
$BGP5109 attach-node $node(5109)
$ns at 316 "$BGP5109 command \"show ip bgp\""

#puts "Creating Router 5119"
set node(5119) [$ns node]
set BGP5119 [new Application/Route/Bgp]
$BGP5119 register  $r

$BGP5119 config-file $opt(dir)/bgpd5119.conf
$BGP5119 attach-node $node(5119)
$ns at 316 "$BGP5119 command \"show ip bgp\""

#puts "Creating Router 513"
set node(513) [$ns node]
set BGP513 [new Application/Route/Bgp]
$BGP513 register  $r

$BGP513 config-file $opt(dir)/bgpd513.conf
$BGP513 attach-node $node(513)
$ns at 316 "$BGP513 command \"show ip bgp\""

#puts "Creating Router 517"
set node(517) [$ns node]
set BGP517 [new Application/Route/Bgp]
$BGP517 register  $r

$BGP517 config-file $opt(dir)/bgpd517.conf
$BGP517 attach-node $node(517)
$ns at 316 "$BGP517 command \"show ip bgp\""

#puts "Creating Router 52"
set node(52) [$ns node]
set BGP52 [new Application/Route/Bgp]
$BGP52 register  $r

$BGP52 config-file $opt(dir)/bgpd52.conf
$BGP52 attach-node $node(52)
$ns at 316 "$BGP52 command \"show ip bgp\""

#puts "Creating Router 5203"
set node(5203) [$ns node]
set BGP5203 [new Application/Route/Bgp]
$BGP5203 register  $r

$BGP5203 config-file $opt(dir)/bgpd5203.conf
$BGP5203 attach-node $node(5203)
$ns at 316 "$BGP5203 command \"show ip bgp\""

#puts "Creating Router 523"
set node(523) [$ns node]
set BGP523 [new Application/Route/Bgp]
$BGP523 register  $r

$BGP523 config-file $opt(dir)/bgpd523.conf
$BGP523 attach-node $node(523)
$ns at 316 "$BGP523 command \"show ip bgp\""

#puts "Creating Router 5248"
set node(5248) [$ns node]
set BGP5248 [new Application/Route/Bgp]
$BGP5248 register  $r

$BGP5248 config-file $opt(dir)/bgpd5248.conf
$BGP5248 attach-node $node(5248)
$ns at 316 "$BGP5248 command \"show ip bgp\""

#puts "Creating Router 5377"
set node(5377) [$ns node]
set BGP5377 [new Application/Route/Bgp]
$BGP5377 register  $r

$BGP5377 config-file $opt(dir)/bgpd5377.conf
$BGP5377 attach-node $node(5377)
$ns at 316 "$BGP5377 command \"show ip bgp\""

#puts "Creating Router 5378"
set node(5378) [$ns node]
set BGP5378 [new Application/Route/Bgp]
$BGP5378 register  $r

$BGP5378 config-file $opt(dir)/bgpd5378.conf
$BGP5378 attach-node $node(5378)
$ns at 316 "$BGP5378 command \"show ip bgp\""

#puts "Creating Router 5380"
set node(5380) [$ns node]
set BGP5380 [new Application/Route/Bgp]
$BGP5380 register  $r

$BGP5380 config-file $opt(dir)/bgpd5380.conf
$BGP5380 attach-node $node(5380)
$ns at 316 "$BGP5380 command \"show ip bgp\""

#puts "Creating Router 5382"
set node(5382) [$ns node]
set BGP5382 [new Application/Route/Bgp]
$BGP5382 register  $r

$BGP5382 config-file $opt(dir)/bgpd5382.conf
$BGP5382 attach-node $node(5382)
$ns at 316 "$BGP5382 command \"show ip bgp\""

#puts "Creating Router 5385"
set node(5385) [$ns node]
set BGP5385 [new Application/Route/Bgp]
$BGP5385 register  $r

$BGP5385 config-file $opt(dir)/bgpd5385.conf
$BGP5385 attach-node $node(5385)
$ns at 316 "$BGP5385 command \"show ip bgp\""

#puts "Creating Router 5387"
set node(5387) [$ns node]
set BGP5387 [new Application/Route/Bgp]
$BGP5387 register  $r

$BGP5387 config-file $opt(dir)/bgpd5387.conf
$BGP5387 attach-node $node(5387)
$ns at 316 "$BGP5387 command \"show ip bgp\""

#puts "Creating Router 5388"
set node(5388) [$ns node]
set BGP5388 [new Application/Route/Bgp]
$BGP5388 register  $r

$BGP5388 config-file $opt(dir)/bgpd5388.conf
$BGP5388 attach-node $node(5388)
$ns at 316 "$BGP5388 command \"show ip bgp\""

#puts "Creating Router 5389"
set node(5389) [$ns node]
set BGP5389 [new Application/Route/Bgp]
$BGP5389 register  $r

$BGP5389 config-file $opt(dir)/bgpd5389.conf
$BGP5389 attach-node $node(5389)
$ns at 316 "$BGP5389 command \"show ip bgp\""

#puts "Creating Router 5390"
set node(5390) [$ns node]
set BGP5390 [new Application/Route/Bgp]
$BGP5390 register  $r

$BGP5390 config-file $opt(dir)/bgpd5390.conf
$BGP5390 attach-node $node(5390)
$ns at 316 "$BGP5390 command \"show ip bgp\""

#puts "Creating Router 5391"
set node(5391) [$ns node]
set BGP5391 [new Application/Route/Bgp]
$BGP5391 register  $r

$BGP5391 config-file $opt(dir)/bgpd5391.conf
$BGP5391 attach-node $node(5391)
$ns at 316 "$BGP5391 command \"show ip bgp\""

#puts "Creating Router 5393"
set node(5393) [$ns node]
set BGP5393 [new Application/Route/Bgp]
$BGP5393 register  $r

$BGP5393 config-file $opt(dir)/bgpd5393.conf
$BGP5393 attach-node $node(5393)
$ns at 316 "$BGP5393 command \"show ip bgp\""

#puts "Creating Router 5394"
set node(5394) [$ns node]
set BGP5394 [new Application/Route/Bgp]
$BGP5394 register  $r

$BGP5394 config-file $opt(dir)/bgpd5394.conf
$BGP5394 attach-node $node(5394)
$ns at 316 "$BGP5394 command \"show ip bgp\""

#puts "Creating Router 5395"
set node(5395) [$ns node]
set BGP5395 [new Application/Route/Bgp]
$BGP5395 register  $r

$BGP5395 config-file $opt(dir)/bgpd5395.conf
$BGP5395 attach-node $node(5395)
$ns at 316 "$BGP5395 command \"show ip bgp\""

#puts "Creating Router 5396"
set node(5396) [$ns node]
set BGP5396 [new Application/Route/Bgp]
$BGP5396 register  $r

$BGP5396 config-file $opt(dir)/bgpd5396.conf
$BGP5396 attach-node $node(5396)
$ns at 316 "$BGP5396 command \"show ip bgp\""

#puts "Creating Router 5397"
set node(5397) [$ns node]
set BGP5397 [new Application/Route/Bgp]
$BGP5397 register  $r

$BGP5397 config-file $opt(dir)/bgpd5397.conf
$BGP5397 attach-node $node(5397)
$ns at 316 "$BGP5397 command \"show ip bgp\""

#puts "Creating Router 5398"
set node(5398) [$ns node]
set BGP5398 [new Application/Route/Bgp]
$BGP5398 register  $r

$BGP5398 config-file $opt(dir)/bgpd5398.conf
$BGP5398 attach-node $node(5398)
$ns at 316 "$BGP5398 command \"show ip bgp\""

#puts "Creating Router 5400"
set node(5400) [$ns node]
set BGP5400 [new Application/Route/Bgp]
$BGP5400 register  $r

$BGP5400 config-file $opt(dir)/bgpd5400.conf
$BGP5400 attach-node $node(5400)
$ns at 316 "$BGP5400 command \"show ip bgp\""

#puts "Creating Router 5402"
set node(5402) [$ns node]
set BGP5402 [new Application/Route/Bgp]
$BGP5402 register  $r

$BGP5402 config-file $opt(dir)/bgpd5402.conf
$BGP5402 attach-node $node(5402)
$ns at 316 "$BGP5402 command \"show ip bgp\""

#puts "Creating Router 5403"
set node(5403) [$ns node]
set BGP5403 [new Application/Route/Bgp]
$BGP5403 register  $r

$BGP5403 config-file $opt(dir)/bgpd5403.conf
$BGP5403 attach-node $node(5403)
$ns at 316 "$BGP5403 command \"show ip bgp\""

#puts "Creating Router 5405"
set node(5405) [$ns node]
set BGP5405 [new Application/Route/Bgp]
$BGP5405 register  $r

$BGP5405 config-file $opt(dir)/bgpd5405.conf
$BGP5405 attach-node $node(5405)
$ns at 316 "$BGP5405 command \"show ip bgp\""

#puts "Creating Router 5407"
set node(5407) [$ns node]
set BGP5407 [new Application/Route/Bgp]
$BGP5407 register  $r

$BGP5407 config-file $opt(dir)/bgpd5407.conf
$BGP5407 attach-node $node(5407)
$ns at 316 "$BGP5407 command \"show ip bgp\""

#puts "Creating Router 5408"
set node(5408) [$ns node]
set BGP5408 [new Application/Route/Bgp]
$BGP5408 register  $r

$BGP5408 config-file $opt(dir)/bgpd5408.conf
$BGP5408 attach-node $node(5408)
$ns at 316 "$BGP5408 command \"show ip bgp\""

#puts "Creating Router 5409"
set node(5409) [$ns node]
set BGP5409 [new Application/Route/Bgp]
$BGP5409 register  $r

$BGP5409 config-file $opt(dir)/bgpd5409.conf
$BGP5409 attach-node $node(5409)
$ns at 316 "$BGP5409 command \"show ip bgp\""

#puts "Creating Router 5412"
set node(5412) [$ns node]
set BGP5412 [new Application/Route/Bgp]
$BGP5412 register  $r

$BGP5412 config-file $opt(dir)/bgpd5412.conf
$BGP5412 attach-node $node(5412)
$ns at 316 "$BGP5412 command \"show ip bgp\""

#puts "Creating Router 5413"
set node(5413) [$ns node]
set BGP5413 [new Application/Route/Bgp]
$BGP5413 register  $r

$BGP5413 config-file $opt(dir)/bgpd5413.conf
$BGP5413 attach-node $node(5413)
$ns at 316 "$BGP5413 command \"show ip bgp\""

#puts "Creating Router 5414"
set node(5414) [$ns node]
set BGP5414 [new Application/Route/Bgp]
$BGP5414 register  $r

$BGP5414 config-file $opt(dir)/bgpd5414.conf
$BGP5414 attach-node $node(5414)
$ns at 316 "$BGP5414 command \"show ip bgp\""

#puts "Creating Router 5415"
set node(5415) [$ns node]
set BGP5415 [new Application/Route/Bgp]
$BGP5415 register  $r

$BGP5415 config-file $opt(dir)/bgpd5415.conf
$BGP5415 attach-node $node(5415)
$ns at 316 "$BGP5415 command \"show ip bgp\""

#puts "Creating Router 5416"
set node(5416) [$ns node]
set BGP5416 [new Application/Route/Bgp]
$BGP5416 register  $r

$BGP5416 config-file $opt(dir)/bgpd5416.conf
$BGP5416 attach-node $node(5416)
$ns at 316 "$BGP5416 command \"show ip bgp\""

#puts "Creating Router 5417"
set node(5417) [$ns node]
set BGP5417 [new Application/Route/Bgp]
$BGP5417 register  $r

$BGP5417 config-file $opt(dir)/bgpd5417.conf
$BGP5417 attach-node $node(5417)
$ns at 316 "$BGP5417 command \"show ip bgp\""

#puts "Creating Router 5418"
set node(5418) [$ns node]
set BGP5418 [new Application/Route/Bgp]
$BGP5418 register  $r

$BGP5418 config-file $opt(dir)/bgpd5418.conf
$BGP5418 attach-node $node(5418)
$ns at 316 "$BGP5418 command \"show ip bgp\""

#puts "Creating Router 5422"
set node(5422) [$ns node]
set BGP5422 [new Application/Route/Bgp]
$BGP5422 register  $r

$BGP5422 config-file $opt(dir)/bgpd5422.conf
$BGP5422 attach-node $node(5422)
$ns at 316 "$BGP5422 command \"show ip bgp\""

#puts "Creating Router 5423"
set node(5423) [$ns node]
set BGP5423 [new Application/Route/Bgp]
$BGP5423 register  $r

$BGP5423 config-file $opt(dir)/bgpd5423.conf
$BGP5423 attach-node $node(5423)
$ns at 316 "$BGP5423 command \"show ip bgp\""

#puts "Creating Router 5426"
set node(5426) [$ns node]
set BGP5426 [new Application/Route/Bgp]
$BGP5426 register  $r

$BGP5426 config-file $opt(dir)/bgpd5426.conf
$BGP5426 attach-node $node(5426)
$ns at 316 "$BGP5426 command \"show ip bgp\""

#puts "Creating Router 5428"
set node(5428) [$ns node]
set BGP5428 [new Application/Route/Bgp]
$BGP5428 register  $r

$BGP5428 config-file $opt(dir)/bgpd5428.conf
$BGP5428 attach-node $node(5428)
$ns at 316 "$BGP5428 command \"show ip bgp\""

#puts "Creating Router 5429"
set node(5429) [$ns node]
set BGP5429 [new Application/Route/Bgp]
$BGP5429 register  $r

$BGP5429 config-file $opt(dir)/bgpd5429.conf
$BGP5429 attach-node $node(5429)
$ns at 316 "$BGP5429 command \"show ip bgp\""

#puts "Creating Router 5430"
set node(5430) [$ns node]
set BGP5430 [new Application/Route/Bgp]
$BGP5430 register  $r

$BGP5430 config-file $opt(dir)/bgpd5430.conf
$BGP5430 attach-node $node(5430)
$ns at 316 "$BGP5430 command \"show ip bgp\""

#puts "Creating Router 5432"
set node(5432) [$ns node]
set BGP5432 [new Application/Route/Bgp]
$BGP5432 register  $r

$BGP5432 config-file $opt(dir)/bgpd5432.conf
$BGP5432 attach-node $node(5432)
$ns at 316 "$BGP5432 command \"show ip bgp\""

#puts "Creating Router 5434"
set node(5434) [$ns node]
set BGP5434 [new Application/Route/Bgp]
$BGP5434 register  $r

$BGP5434 config-file $opt(dir)/bgpd5434.conf
$BGP5434 attach-node $node(5434)
$ns at 316 "$BGP5434 command \"show ip bgp\""

#puts "Creating Router 5436"
set node(5436) [$ns node]
set BGP5436 [new Application/Route/Bgp]
$BGP5436 register  $r

$BGP5436 config-file $opt(dir)/bgpd5436.conf
$BGP5436 attach-node $node(5436)
$ns at 316 "$BGP5436 command \"show ip bgp\""

#puts "Creating Router 5441"
set node(5441) [$ns node]
set BGP5441 [new Application/Route/Bgp]
$BGP5441 register  $r

$BGP5441 config-file $opt(dir)/bgpd5441.conf
$BGP5441 attach-node $node(5441)
$ns at 316 "$BGP5441 command \"show ip bgp\""

#puts "Creating Router 5442"
set node(5442) [$ns node]
set BGP5442 [new Application/Route/Bgp]
$BGP5442 register  $r

$BGP5442 config-file $opt(dir)/bgpd5442.conf
$BGP5442 attach-node $node(5442)
$ns at 316 "$BGP5442 command \"show ip bgp\""

#puts "Creating Router 5443"
set node(5443) [$ns node]
set BGP5443 [new Application/Route/Bgp]
$BGP5443 register  $r

$BGP5443 config-file $opt(dir)/bgpd5443.conf
$BGP5443 attach-node $node(5443)
$ns at 316 "$BGP5443 command \"show ip bgp\""

#puts "Creating Router 5444"
set node(5444) [$ns node]
set BGP5444 [new Application/Route/Bgp]
$BGP5444 register  $r

$BGP5444 config-file $opt(dir)/bgpd5444.conf
$BGP5444 attach-node $node(5444)
$ns at 316 "$BGP5444 command \"show ip bgp\""

#puts "Creating Router 5445"
set node(5445) [$ns node]
set BGP5445 [new Application/Route/Bgp]
$BGP5445 register  $r

$BGP5445 config-file $opt(dir)/bgpd5445.conf
$BGP5445 attach-node $node(5445)
$ns at 316 "$BGP5445 command \"show ip bgp\""

#puts "Creating Router 5446"
set node(5446) [$ns node]
set BGP5446 [new Application/Route/Bgp]
$BGP5446 register  $r

$BGP5446 config-file $opt(dir)/bgpd5446.conf
$BGP5446 attach-node $node(5446)
$ns at 316 "$BGP5446 command \"show ip bgp\""

#puts "Creating Router 5447"
set node(5447) [$ns node]
set BGP5447 [new Application/Route/Bgp]
$BGP5447 register  $r

$BGP5447 config-file $opt(dir)/bgpd5447.conf
$BGP5447 attach-node $node(5447)
$ns at 316 "$BGP5447 command \"show ip bgp\""

#puts "Creating Router 5448"
set node(5448) [$ns node]
set BGP5448 [new Application/Route/Bgp]
$BGP5448 register  $r

$BGP5448 config-file $opt(dir)/bgpd5448.conf
$BGP5448 attach-node $node(5448)
$ns at 316 "$BGP5448 command \"show ip bgp\""

#puts "Creating Router 5449"
set node(5449) [$ns node]
set BGP5449 [new Application/Route/Bgp]
$BGP5449 register  $r

$BGP5449 config-file $opt(dir)/bgpd5449.conf
$BGP5449 attach-node $node(5449)
$ns at 316 "$BGP5449 command \"show ip bgp\""

#puts "Creating Router 5450"
set node(5450) [$ns node]
set BGP5450 [new Application/Route/Bgp]
$BGP5450 register  $r

$BGP5450 config-file $opt(dir)/bgpd5450.conf
$BGP5450 attach-node $node(5450)
$ns at 316 "$BGP5450 command \"show ip bgp\""

#puts "Creating Router 5451"
set node(5451) [$ns node]
set BGP5451 [new Application/Route/Bgp]
$BGP5451 register  $r

$BGP5451 config-file $opt(dir)/bgpd5451.conf
$BGP5451 attach-node $node(5451)
$ns at 316 "$BGP5451 command \"show ip bgp\""

#puts "Creating Router 5455"
set node(5455) [$ns node]
set BGP5455 [new Application/Route/Bgp]
$BGP5455 register  $r

$BGP5455 config-file $opt(dir)/bgpd5455.conf
$BGP5455 attach-node $node(5455)
$ns at 316 "$BGP5455 command \"show ip bgp\""

#puts "Creating Router 5456"
set node(5456) [$ns node]
set BGP5456 [new Application/Route/Bgp]
$BGP5456 register  $r

$BGP5456 config-file $opt(dir)/bgpd5456.conf
$BGP5456 attach-node $node(5456)
$ns at 316 "$BGP5456 command \"show ip bgp\""

#puts "Creating Router 5457"
set node(5457) [$ns node]
set BGP5457 [new Application/Route/Bgp]
$BGP5457 register  $r

$BGP5457 config-file $opt(dir)/bgpd5457.conf
$BGP5457 attach-node $node(5457)
$ns at 316 "$BGP5457 command \"show ip bgp\""

#puts "Creating Router 5459"
set node(5459) [$ns node]
set BGP5459 [new Application/Route/Bgp]
$BGP5459 register  $r

$BGP5459 config-file $opt(dir)/bgpd5459.conf
$BGP5459 attach-node $node(5459)
$ns at 316 "$BGP5459 command \"show ip bgp\""

#puts "Creating Router 5462"
set node(5462) [$ns node]
set BGP5462 [new Application/Route/Bgp]
$BGP5462 register  $r

$BGP5462 config-file $opt(dir)/bgpd5462.conf
$BGP5462 attach-node $node(5462)
$ns at 316 "$BGP5462 command \"show ip bgp\""

#puts "Creating Router 5463"
set node(5463) [$ns node]
set BGP5463 [new Application/Route/Bgp]
$BGP5463 register  $r

$BGP5463 config-file $opt(dir)/bgpd5463.conf
$BGP5463 attach-node $node(5463)
$ns at 316 "$BGP5463 command \"show ip bgp\""

#puts "Creating Router 5466"
set node(5466) [$ns node]
set BGP5466 [new Application/Route/Bgp]
$BGP5466 register  $r

$BGP5466 config-file $opt(dir)/bgpd5466.conf
$BGP5466 attach-node $node(5466)
$ns at 316 "$BGP5466 command \"show ip bgp\""

#puts "Creating Router 5468"
set node(5468) [$ns node]
set BGP5468 [new Application/Route/Bgp]
$BGP5468 register  $r

$BGP5468 config-file $opt(dir)/bgpd5468.conf
$BGP5468 attach-node $node(5468)
$ns at 316 "$BGP5468 command \"show ip bgp\""

#puts "Creating Router 5470"
set node(5470) [$ns node]
set BGP5470 [new Application/Route/Bgp]
$BGP5470 register  $r

$BGP5470 config-file $opt(dir)/bgpd5470.conf
$BGP5470 attach-node $node(5470)
$ns at 316 "$BGP5470 command \"show ip bgp\""

#puts "Creating Router 5471"
set node(5471) [$ns node]
set BGP5471 [new Application/Route/Bgp]
$BGP5471 register  $r

$BGP5471 config-file $opt(dir)/bgpd5471.conf
$BGP5471 attach-node $node(5471)
$ns at 316 "$BGP5471 command \"show ip bgp\""

#puts "Creating Router 5479"
set node(5479) [$ns node]
set BGP5479 [new Application/Route/Bgp]
$BGP5479 register  $r

$BGP5479 config-file $opt(dir)/bgpd5479.conf
$BGP5479 attach-node $node(5479)
$ns at 316 "$BGP5479 command \"show ip bgp\""

#puts "Creating Router 5482"
set node(5482) [$ns node]
set BGP5482 [new Application/Route/Bgp]
$BGP5482 register  $r

$BGP5482 config-file $opt(dir)/bgpd5482.conf
$BGP5482 attach-node $node(5482)
$ns at 316 "$BGP5482 command \"show ip bgp\""

#puts "Creating Router 5483"
set node(5483) [$ns node]
set BGP5483 [new Application/Route/Bgp]
$BGP5483 register  $r

$BGP5483 config-file $opt(dir)/bgpd5483.conf
$BGP5483 attach-node $node(5483)
$ns at 316 "$BGP5483 command \"show ip bgp\""

#puts "Creating Router 5484"
set node(5484) [$ns node]
set BGP5484 [new Application/Route/Bgp]
$BGP5484 register  $r

$BGP5484 config-file $opt(dir)/bgpd5484.conf
$BGP5484 attach-node $node(5484)
$ns at 316 "$BGP5484 command \"show ip bgp\""

#puts "Creating Router 549"
set node(549) [$ns node]
set BGP549 [new Application/Route/Bgp]
$BGP549 register  $r

$BGP549 config-file $opt(dir)/bgpd549.conf
$BGP549 attach-node $node(549)
$ns at 316 "$BGP549 command \"show ip bgp\""

#puts "Creating Router 5491"
set node(5491) [$ns node]
set BGP5491 [new Application/Route/Bgp]
$BGP5491 register  $r

$BGP5491 config-file $opt(dir)/bgpd5491.conf
$BGP5491 attach-node $node(5491)
$ns at 316 "$BGP5491 command \"show ip bgp\""

#puts "Creating Router 5492"
set node(5492) [$ns node]
set BGP5492 [new Application/Route/Bgp]
$BGP5492 register  $r

$BGP5492 config-file $opt(dir)/bgpd5492.conf
$BGP5492 attach-node $node(5492)
$ns at 316 "$BGP5492 command \"show ip bgp\""

#puts "Creating Router 5496"
set node(5496) [$ns node]
set BGP5496 [new Application/Route/Bgp]
$BGP5496 register  $r

$BGP5496 config-file $opt(dir)/bgpd5496.conf
$BGP5496 attach-node $node(5496)
$ns at 316 "$BGP5496 command \"show ip bgp\""

#puts "Creating Router 5498"
set node(5498) [$ns node]
set BGP5498 [new Application/Route/Bgp]
$BGP5498 register  $r

$BGP5498 config-file $opt(dir)/bgpd5498.conf
$BGP5498 attach-node $node(5498)
$ns at 316 "$BGP5498 command \"show ip bgp\""

#puts "Creating Router 5499"
set node(5499) [$ns node]
set BGP5499 [new Application/Route/Bgp]
$BGP5499 register  $r

$BGP5499 config-file $opt(dir)/bgpd5499.conf
$BGP5499 attach-node $node(5499)
$ns at 316 "$BGP5499 command \"show ip bgp\""

#puts "Creating Router 55"
set node(55) [$ns node]
set BGP55 [new Application/Route/Bgp]
$BGP55 register  $r

$BGP55 config-file $opt(dir)/bgpd55.conf
$BGP55 attach-node $node(55)
$ns at 316 "$BGP55 command \"show ip bgp\""

#puts "Creating Router 5500"
set node(5500) [$ns node]
set BGP5500 [new Application/Route/Bgp]
$BGP5500 register  $r

$BGP5500 config-file $opt(dir)/bgpd5500.conf
$BGP5500 attach-node $node(5500)
$ns at 316 "$BGP5500 command \"show ip bgp\""

#puts "Creating Router 5503"
set node(5503) [$ns node]
set BGP5503 [new Application/Route/Bgp]
$BGP5503 register  $r

$BGP5503 config-file $opt(dir)/bgpd5503.conf
$BGP5503 attach-node $node(5503)
$ns at 316 "$BGP5503 command \"show ip bgp\""

#puts "Creating Router 5505"
set node(5505) [$ns node]
set BGP5505 [new Application/Route/Bgp]
$BGP5505 register  $r

$BGP5505 config-file $opt(dir)/bgpd5505.conf
$BGP5505 attach-node $node(5505)
$ns at 316 "$BGP5505 command \"show ip bgp\""

#puts "Creating Router 5509"
set node(5509) [$ns node]
set BGP5509 [new Application/Route/Bgp]
$BGP5509 register  $r

$BGP5509 config-file $opt(dir)/bgpd5509.conf
$BGP5509 attach-node $node(5509)
$ns at 316 "$BGP5509 command \"show ip bgp\""

#puts "Creating Router 5510"
set node(5510) [$ns node]
set BGP5510 [new Application/Route/Bgp]
$BGP5510 register  $r

$BGP5510 config-file $opt(dir)/bgpd5510.conf
$BGP5510 attach-node $node(5510)
$ns at 316 "$BGP5510 command \"show ip bgp\""

#puts "Creating Router 5511"
set node(5511) [$ns node]
set BGP5511 [new Application/Route/Bgp]
$BGP5511 register  $r

$BGP5511 config-file $opt(dir)/bgpd5511.conf
$BGP5511 attach-node $node(5511)
$ns at 316 "$BGP5511 command \"show ip bgp\""

#puts "Creating Router 5512"
set node(5512) [$ns node]
set BGP5512 [new Application/Route/Bgp]
$BGP5512 register  $r

$BGP5512 config-file $opt(dir)/bgpd5512.conf
$BGP5512 attach-node $node(5512)
$ns at 316 "$BGP5512 command \"show ip bgp\""

#puts "Creating Router 5513"
set node(5513) [$ns node]
set BGP5513 [new Application/Route/Bgp]
$BGP5513 register  $r

$BGP5513 config-file $opt(dir)/bgpd5513.conf
$BGP5513 attach-node $node(5513)
$ns at 316 "$BGP5513 command \"show ip bgp\""

#puts "Creating Router 5519"
set node(5519) [$ns node]
set BGP5519 [new Application/Route/Bgp]
$BGP5519 register  $r

$BGP5519 config-file $opt(dir)/bgpd5519.conf
$BGP5519 attach-node $node(5519)
$ns at 316 "$BGP5519 command \"show ip bgp\""

#puts "Creating Router 5522"
set node(5522) [$ns node]
set BGP5522 [new Application/Route/Bgp]
$BGP5522 register  $r

$BGP5522 config-file $opt(dir)/bgpd5522.conf
$BGP5522 attach-node $node(5522)
$ns at 316 "$BGP5522 command \"show ip bgp\""

#puts "Creating Router 5532"
set node(5532) [$ns node]
set BGP5532 [new Application/Route/Bgp]
$BGP5532 register  $r

$BGP5532 config-file $opt(dir)/bgpd5532.conf
$BGP5532 attach-node $node(5532)
$ns at 316 "$BGP5532 command \"show ip bgp\""

#puts "Creating Router 5533"
set node(5533) [$ns node]
set BGP5533 [new Application/Route/Bgp]
$BGP5533 register  $r

$BGP5533 config-file $opt(dir)/bgpd5533.conf
$BGP5533 attach-node $node(5533)
$ns at 316 "$BGP5533 command \"show ip bgp\""

#puts "Creating Router 5539"
set node(5539) [$ns node]
set BGP5539 [new Application/Route/Bgp]
$BGP5539 register  $r

$BGP5539 config-file $opt(dir)/bgpd5539.conf
$BGP5539 attach-node $node(5539)
$ns at 316 "$BGP5539 command \"show ip bgp\""

#puts "Creating Router 5548"
set node(5548) [$ns node]
set BGP5548 [new Application/Route/Bgp]
$BGP5548 register  $r

$BGP5548 config-file $opt(dir)/bgpd5548.conf
$BGP5548 attach-node $node(5548)
$ns at 316 "$BGP5548 command \"show ip bgp\""

#puts "Creating Router 5549"
set node(5549) [$ns node]
set BGP5549 [new Application/Route/Bgp]
$BGP5549 register  $r

$BGP5549 config-file $opt(dir)/bgpd5549.conf
$BGP5549 attach-node $node(5549)
$ns at 316 "$BGP5549 command \"show ip bgp\""

#puts "Creating Router 5551"
set node(5551) [$ns node]
set BGP5551 [new Application/Route/Bgp]
$BGP5551 register  $r

$BGP5551 config-file $opt(dir)/bgpd5551.conf
$BGP5551 attach-node $node(5551)
$ns at 316 "$BGP5551 command \"show ip bgp\""

#puts "Creating Router 5554"
set node(5554) [$ns node]
set BGP5554 [new Application/Route/Bgp]
$BGP5554 register  $r

$BGP5554 config-file $opt(dir)/bgpd5554.conf
$BGP5554 attach-node $node(5554)
$ns at 316 "$BGP5554 command \"show ip bgp\""

#puts "Creating Router 5556"
set node(5556) [$ns node]
set BGP5556 [new Application/Route/Bgp]
$BGP5556 register  $r

$BGP5556 config-file $opt(dir)/bgpd5556.conf
$BGP5556 attach-node $node(5556)
$ns at 316 "$BGP5556 command \"show ip bgp\""

#puts "Creating Router 5557"
set node(5557) [$ns node]
set BGP5557 [new Application/Route/Bgp]
$BGP5557 register  $r

$BGP5557 config-file $opt(dir)/bgpd5557.conf
$BGP5557 attach-node $node(5557)
$ns at 316 "$BGP5557 command \"show ip bgp\""

#puts "Creating Router 5559"
set node(5559) [$ns node]
set BGP5559 [new Application/Route/Bgp]
$BGP5559 register  $r

$BGP5559 config-file $opt(dir)/bgpd5559.conf
$BGP5559 attach-node $node(5559)
$ns at 316 "$BGP5559 command \"show ip bgp\""

#puts "Creating Router 5560"
set node(5560) [$ns node]
set BGP5560 [new Application/Route/Bgp]
$BGP5560 register  $r

$BGP5560 config-file $opt(dir)/bgpd5560.conf
$BGP5560 attach-node $node(5560)
$ns at 316 "$BGP5560 command \"show ip bgp\""

#puts "Creating Router 5561"
set node(5561) [$ns node]
set BGP5561 [new Application/Route/Bgp]
$BGP5561 register  $r

$BGP5561 config-file $opt(dir)/bgpd5561.conf
$BGP5561 attach-node $node(5561)
$ns at 316 "$BGP5561 command \"show ip bgp\""

#puts "Creating Router 5564"
set node(5564) [$ns node]
set BGP5564 [new Application/Route/Bgp]
$BGP5564 register  $r

$BGP5564 config-file $opt(dir)/bgpd5564.conf
$BGP5564 attach-node $node(5564)
$ns at 316 "$BGP5564 command \"show ip bgp\""

#puts "Creating Router 5568"
set node(5568) [$ns node]
set BGP5568 [new Application/Route/Bgp]
$BGP5568 register  $r

$BGP5568 config-file $opt(dir)/bgpd5568.conf
$BGP5568 attach-node $node(5568)
$ns at 316 "$BGP5568 command \"show ip bgp\""

#puts "Creating Router 5571"
set node(5571) [$ns node]
set BGP5571 [new Application/Route/Bgp]
$BGP5571 register  $r

$BGP5571 config-file $opt(dir)/bgpd5571.conf
$BGP5571 attach-node $node(5571)
$ns at 316 "$BGP5571 command \"show ip bgp\""

#puts "Creating Router 5573"
set node(5573) [$ns node]
set BGP5573 [new Application/Route/Bgp]
$BGP5573 register  $r

$BGP5573 config-file $opt(dir)/bgpd5573.conf
$BGP5573 attach-node $node(5573)
$ns at 316 "$BGP5573 command \"show ip bgp\""

#puts "Creating Router 5578"
set node(5578) [$ns node]
set BGP5578 [new Application/Route/Bgp]
$BGP5578 register  $r

$BGP5578 config-file $opt(dir)/bgpd5578.conf
$BGP5578 attach-node $node(5578)
$ns at 316 "$BGP5578 command \"show ip bgp\""

#puts "Creating Router 5580"
set node(5580) [$ns node]
set BGP5580 [new Application/Route/Bgp]
$BGP5580 register  $r

$BGP5580 config-file $opt(dir)/bgpd5580.conf
$BGP5580 attach-node $node(5580)
$ns at 316 "$BGP5580 command \"show ip bgp\""

#puts "Creating Router 5583"
set node(5583) [$ns node]
set BGP5583 [new Application/Route/Bgp]
$BGP5583 register  $r

$BGP5583 config-file $opt(dir)/bgpd5583.conf
$BGP5583 attach-node $node(5583)
$ns at 316 "$BGP5583 command \"show ip bgp\""

#puts "Creating Router 559"
set node(559) [$ns node]
set BGP559 [new Application/Route/Bgp]
$BGP559 register  $r

$BGP559 config-file $opt(dir)/bgpd559.conf
$BGP559 attach-node $node(559)
$ns at 316 "$BGP559 command \"show ip bgp\""

#puts "Creating Router 5590"
set node(5590) [$ns node]
set BGP5590 [new Application/Route/Bgp]
$BGP5590 register  $r

$BGP5590 config-file $opt(dir)/bgpd5590.conf
$BGP5590 attach-node $node(5590)
$ns at 316 "$BGP5590 command \"show ip bgp\""

#puts "Creating Router 5594"
set node(5594) [$ns node]
set BGP5594 [new Application/Route/Bgp]
$BGP5594 register  $r

$BGP5594 config-file $opt(dir)/bgpd5594.conf
$BGP5594 attach-node $node(5594)
$ns at 316 "$BGP5594 command \"show ip bgp\""

#puts "Creating Router 5596"
set node(5596) [$ns node]
set BGP5596 [new Application/Route/Bgp]
$BGP5596 register  $r

$BGP5596 config-file $opt(dir)/bgpd5596.conf
$BGP5596 attach-node $node(5596)
$ns at 316 "$BGP5596 command \"show ip bgp\""

#puts "Creating Router 5597"
set node(5597) [$ns node]
set BGP5597 [new Application/Route/Bgp]
$BGP5597 register  $r

$BGP5597 config-file $opt(dir)/bgpd5597.conf
$BGP5597 attach-node $node(5597)
$ns at 316 "$BGP5597 command \"show ip bgp\""

#puts "Creating Router 5599"
set node(5599) [$ns node]
set BGP5599 [new Application/Route/Bgp]
$BGP5599 register  $r

$BGP5599 config-file $opt(dir)/bgpd5599.conf
$BGP5599 attach-node $node(5599)
$ns at 316 "$BGP5599 command \"show ip bgp\""

#puts "Creating Router 5600"
set node(5600) [$ns node]
set BGP5600 [new Application/Route/Bgp]
$BGP5600 register  $r

$BGP5600 config-file $opt(dir)/bgpd5600.conf
$BGP5600 attach-node $node(5600)
$ns at 316 "$BGP5600 command \"show ip bgp\""

#puts "Creating Router 5603"
set node(5603) [$ns node]
set BGP5603 [new Application/Route/Bgp]
$BGP5603 register  $r

$BGP5603 config-file $opt(dir)/bgpd5603.conf
$BGP5603 attach-node $node(5603)
$ns at 316 "$BGP5603 command \"show ip bgp\""

#puts "Creating Router 5604"
set node(5604) [$ns node]
set BGP5604 [new Application/Route/Bgp]
$BGP5604 register  $r

$BGP5604 config-file $opt(dir)/bgpd5604.conf
$BGP5604 attach-node $node(5604)
$ns at 316 "$BGP5604 command \"show ip bgp\""

#puts "Creating Router 5607"
set node(5607) [$ns node]
set BGP5607 [new Application/Route/Bgp]
$BGP5607 register  $r

$BGP5607 config-file $opt(dir)/bgpd5607.conf
$BGP5607 attach-node $node(5607)
$ns at 316 "$BGP5607 command \"show ip bgp\""

#puts "Creating Router 5609"
set node(5609) [$ns node]
set BGP5609 [new Application/Route/Bgp]
$BGP5609 register  $r

$BGP5609 config-file $opt(dir)/bgpd5609.conf
$BGP5609 attach-node $node(5609)
$ns at 316 "$BGP5609 command \"show ip bgp\""

#puts "Creating Router 5611"
set node(5611) [$ns node]
set BGP5611 [new Application/Route/Bgp]
$BGP5611 register  $r

$BGP5611 config-file $opt(dir)/bgpd5611.conf
$BGP5611 attach-node $node(5611)
$ns at 316 "$BGP5611 command \"show ip bgp\""

#puts "Creating Router 5615"
set node(5615) [$ns node]
set BGP5615 [new Application/Route/Bgp]
$BGP5615 register  $r

$BGP5615 config-file $opt(dir)/bgpd5615.conf
$BGP5615 attach-node $node(5615)
$ns at 316 "$BGP5615 command \"show ip bgp\""

#puts "Creating Router 5617"
set node(5617) [$ns node]
set BGP5617 [new Application/Route/Bgp]
$BGP5617 register  $r

$BGP5617 config-file $opt(dir)/bgpd5617.conf
$BGP5617 attach-node $node(5617)
$ns at 316 "$BGP5617 command \"show ip bgp\""

#puts "Creating Router 5618"
set node(5618) [$ns node]
set BGP5618 [new Application/Route/Bgp]
$BGP5618 register  $r

$BGP5618 config-file $opt(dir)/bgpd5618.conf
$BGP5618 attach-node $node(5618)
$ns at 316 "$BGP5618 command \"show ip bgp\""

#puts "Creating Router 5620"
set node(5620) [$ns node]
set BGP5620 [new Application/Route/Bgp]
$BGP5620 register  $r

$BGP5620 config-file $opt(dir)/bgpd5620.conf
$BGP5620 attach-node $node(5620)
$ns at 316 "$BGP5620 command \"show ip bgp\""

#puts "Creating Router 5621"
set node(5621) [$ns node]
set BGP5621 [new Application/Route/Bgp]
$BGP5621 register  $r

$BGP5621 config-file $opt(dir)/bgpd5621.conf
$BGP5621 attach-node $node(5621)
$ns at 316 "$BGP5621 command \"show ip bgp\""

#puts "Creating Router 5622"
set node(5622) [$ns node]
set BGP5622 [new Application/Route/Bgp]
$BGP5622 register  $r

$BGP5622 config-file $opt(dir)/bgpd5622.conf
$BGP5622 attach-node $node(5622)
$ns at 316 "$BGP5622 command \"show ip bgp\""

#puts "Creating Router 5623"
set node(5623) [$ns node]
set BGP5623 [new Application/Route/Bgp]
$BGP5623 register  $r

$BGP5623 config-file $opt(dir)/bgpd5623.conf
$BGP5623 attach-node $node(5623)
$ns at 316 "$BGP5623 command \"show ip bgp\""

#puts "Creating Router 5625"
set node(5625) [$ns node]
set BGP5625 [new Application/Route/Bgp]
$BGP5625 register  $r

$BGP5625 config-file $opt(dir)/bgpd5625.conf
$BGP5625 attach-node $node(5625)
$ns at 316 "$BGP5625 command \"show ip bgp\""

#puts "Creating Router 5628"
set node(5628) [$ns node]
set BGP5628 [new Application/Route/Bgp]
$BGP5628 register  $r

$BGP5628 config-file $opt(dir)/bgpd5628.conf
$BGP5628 attach-node $node(5628)
$ns at 316 "$BGP5628 command \"show ip bgp\""

#puts "Creating Router 5630"
set node(5630) [$ns node]
set BGP5630 [new Application/Route/Bgp]
$BGP5630 register  $r

$BGP5630 config-file $opt(dir)/bgpd5630.conf
$BGP5630 attach-node $node(5630)
$ns at 316 "$BGP5630 command \"show ip bgp\""

#puts "Creating Router 5632"
set node(5632) [$ns node]
set BGP5632 [new Application/Route/Bgp]
$BGP5632 register  $r

$BGP5632 config-file $opt(dir)/bgpd5632.conf
$BGP5632 attach-node $node(5632)
$ns at 316 "$BGP5632 command \"show ip bgp\""

#puts "Creating Router 5637"
set node(5637) [$ns node]
set BGP5637 [new Application/Route/Bgp]
$BGP5637 register  $r

$BGP5637 config-file $opt(dir)/bgpd5637.conf
$BGP5637 attach-node $node(5637)
$ns at 316 "$BGP5637 command \"show ip bgp\""

#puts "Creating Router 5639"
set node(5639) [$ns node]
set BGP5639 [new Application/Route/Bgp]
$BGP5639 register  $r

$BGP5639 config-file $opt(dir)/bgpd5639.conf
$BGP5639 attach-node $node(5639)
$ns at 316 "$BGP5639 command \"show ip bgp\""

#puts "Creating Router 5641"
set node(5641) [$ns node]
set BGP5641 [new Application/Route/Bgp]
$BGP5641 register  $r

$BGP5641 config-file $opt(dir)/bgpd5641.conf
$BGP5641 attach-node $node(5641)
$ns at 316 "$BGP5641 command \"show ip bgp\""

#puts "Creating Router 5645"
set node(5645) [$ns node]
set BGP5645 [new Application/Route/Bgp]
$BGP5645 register  $r

$BGP5645 config-file $opt(dir)/bgpd5645.conf
$BGP5645 attach-node $node(5645)
$ns at 316 "$BGP5645 command \"show ip bgp\""

#puts "Creating Router 5646"
set node(5646) [$ns node]
set BGP5646 [new Application/Route/Bgp]
$BGP5646 register  $r

$BGP5646 config-file $opt(dir)/bgpd5646.conf
$BGP5646 attach-node $node(5646)
$ns at 316 "$BGP5646 command \"show ip bgp\""

#puts "Creating Router 5648"
set node(5648) [$ns node]
set BGP5648 [new Application/Route/Bgp]
$BGP5648 register  $r

$BGP5648 config-file $opt(dir)/bgpd5648.conf
$BGP5648 attach-node $node(5648)
$ns at 316 "$BGP5648 command \"show ip bgp\""

#puts "Creating Router 5650"
set node(5650) [$ns node]
set BGP5650 [new Application/Route/Bgp]
$BGP5650 register  $r

$BGP5650 config-file $opt(dir)/bgpd5650.conf
$BGP5650 attach-node $node(5650)
$ns at 316 "$BGP5650 command \"show ip bgp\""

#puts "Creating Router 5651"
set node(5651) [$ns node]
set BGP5651 [new Application/Route/Bgp]
$BGP5651 register  $r

$BGP5651 config-file $opt(dir)/bgpd5651.conf
$BGP5651 attach-node $node(5651)
$ns at 316 "$BGP5651 command \"show ip bgp\""

#puts "Creating Router 5656"
set node(5656) [$ns node]
set BGP5656 [new Application/Route/Bgp]
$BGP5656 register  $r

$BGP5656 config-file $opt(dir)/bgpd5656.conf
$BGP5656 attach-node $node(5656)
$ns at 316 "$BGP5656 command \"show ip bgp\""

#puts "Creating Router 5666"
set node(5666) [$ns node]
set BGP5666 [new Application/Route/Bgp]
$BGP5666 register  $r

$BGP5666 config-file $opt(dir)/bgpd5666.conf
$BGP5666 attach-node $node(5666)
$ns at 316 "$BGP5666 command \"show ip bgp\""

#puts "Creating Router 5669"
set node(5669) [$ns node]
set BGP5669 [new Application/Route/Bgp]
$BGP5669 register  $r

$BGP5669 config-file $opt(dir)/bgpd5669.conf
$BGP5669 attach-node $node(5669)
$ns at 316 "$BGP5669 command \"show ip bgp\""

#puts "Creating Router 5671"
set node(5671) [$ns node]
set BGP5671 [new Application/Route/Bgp]
$BGP5671 register  $r

$BGP5671 config-file $opt(dir)/bgpd5671.conf
$BGP5671 attach-node $node(5671)
$ns at 316 "$BGP5671 command \"show ip bgp\""

#puts "Creating Router 5672"
set node(5672) [$ns node]
set BGP5672 [new Application/Route/Bgp]
$BGP5672 register  $r

$BGP5672 config-file $opt(dir)/bgpd5672.conf
$BGP5672 attach-node $node(5672)
$ns at 316 "$BGP5672 command \"show ip bgp\""

#puts "Creating Router 5673"
set node(5673) [$ns node]
set BGP5673 [new Application/Route/Bgp]
$BGP5673 register  $r

$BGP5673 config-file $opt(dir)/bgpd5673.conf
$BGP5673 attach-node $node(5673)
$ns at 316 "$BGP5673 command \"show ip bgp\""

#puts "Creating Router 5676"
set node(5676) [$ns node]
set BGP5676 [new Application/Route/Bgp]
$BGP5676 register  $r

$BGP5676 config-file $opt(dir)/bgpd5676.conf
$BGP5676 attach-node $node(5676)
$ns at 316 "$BGP5676 command \"show ip bgp\""

#puts "Creating Router 5678"
set node(5678) [$ns node]
set BGP5678 [new Application/Route/Bgp]
$BGP5678 register  $r

$BGP5678 config-file $opt(dir)/bgpd5678.conf
$BGP5678 attach-node $node(5678)
$ns at 316 "$BGP5678 command \"show ip bgp\""

#puts "Creating Router 568"
set node(568) [$ns node]
set BGP568 [new Application/Route/Bgp]
$BGP568 register  $r

$BGP568 config-file $opt(dir)/bgpd568.conf
$BGP568 attach-node $node(568)
$ns at 316 "$BGP568 command \"show ip bgp\""

#puts "Creating Router 5683"
set node(5683) [$ns node]
set BGP5683 [new Application/Route/Bgp]
$BGP5683 register  $r

$BGP5683 config-file $opt(dir)/bgpd5683.conf
$BGP5683 attach-node $node(5683)
$ns at 316 "$BGP5683 command \"show ip bgp\""

#puts "Creating Router 5687"
set node(5687) [$ns node]
set BGP5687 [new Application/Route/Bgp]
$BGP5687 register  $r

$BGP5687 config-file $opt(dir)/bgpd5687.conf
$BGP5687 attach-node $node(5687)
$ns at 316 "$BGP5687 command \"show ip bgp\""

#puts "Creating Router 5691"
set node(5691) [$ns node]
set BGP5691 [new Application/Route/Bgp]
$BGP5691 register  $r

$BGP5691 config-file $opt(dir)/bgpd5691.conf
$BGP5691 attach-node $node(5691)
$ns at 316 "$BGP5691 command \"show ip bgp\""

#puts "Creating Router 5692"
set node(5692) [$ns node]
set BGP5692 [new Application/Route/Bgp]
$BGP5692 register  $r

$BGP5692 config-file $opt(dir)/bgpd5692.conf
$BGP5692 attach-node $node(5692)
$ns at 316 "$BGP5692 command \"show ip bgp\""

#puts "Creating Router 5693"
set node(5693) [$ns node]
set BGP5693 [new Application/Route/Bgp]
$BGP5693 register  $r

$BGP5693 config-file $opt(dir)/bgpd5693.conf
$BGP5693 attach-node $node(5693)
$ns at 316 "$BGP5693 command \"show ip bgp\""

#puts "Creating Router 5696"
set node(5696) [$ns node]
set BGP5696 [new Application/Route/Bgp]
$BGP5696 register  $r

$BGP5696 config-file $opt(dir)/bgpd5696.conf
$BGP5696 attach-node $node(5696)
$ns at 316 "$BGP5696 command \"show ip bgp\""

#puts "Creating Router 5697"
set node(5697) [$ns node]
set BGP5697 [new Application/Route/Bgp]
$BGP5697 register  $r

$BGP5697 config-file $opt(dir)/bgpd5697.conf
$BGP5697 attach-node $node(5697)
$ns at 316 "$BGP5697 command \"show ip bgp\""

#puts "Creating Router 5698"
set node(5698) [$ns node]
set BGP5698 [new Application/Route/Bgp]
$BGP5698 register  $r

$BGP5698 config-file $opt(dir)/bgpd5698.conf
$BGP5698 attach-node $node(5698)
$ns at 316 "$BGP5698 command \"show ip bgp\""

#puts "Creating Router 5700"
set node(5700) [$ns node]
set BGP5700 [new Application/Route/Bgp]
$BGP5700 register  $r

$BGP5700 config-file $opt(dir)/bgpd5700.conf
$BGP5700 attach-node $node(5700)
$ns at 316 "$BGP5700 command \"show ip bgp\""

#puts "Creating Router 5702"
set node(5702) [$ns node]
set BGP5702 [new Application/Route/Bgp]
$BGP5702 register  $r

$BGP5702 config-file $opt(dir)/bgpd5702.conf
$BGP5702 attach-node $node(5702)
$ns at 316 "$BGP5702 command \"show ip bgp\""

#puts "Creating Router 5710"
set node(5710) [$ns node]
set BGP5710 [new Application/Route/Bgp]
$BGP5710 register  $r

$BGP5710 config-file $opt(dir)/bgpd5710.conf
$BGP5710 attach-node $node(5710)
$ns at 316 "$BGP5710 command \"show ip bgp\""

#puts "Creating Router 5713"
set node(5713) [$ns node]
set BGP5713 [new Application/Route/Bgp]
$BGP5713 register  $r

$BGP5713 config-file $opt(dir)/bgpd5713.conf
$BGP5713 attach-node $node(5713)
$ns at 316 "$BGP5713 command \"show ip bgp\""

#puts "Creating Router 5715"
set node(5715) [$ns node]
set BGP5715 [new Application/Route/Bgp]
$BGP5715 register  $r

$BGP5715 config-file $opt(dir)/bgpd5715.conf
$BGP5715 attach-node $node(5715)
$ns at 316 "$BGP5715 command \"show ip bgp\""

#puts "Creating Router 5726"
set node(5726) [$ns node]
set BGP5726 [new Application/Route/Bgp]
$BGP5726 register  $r

$BGP5726 config-file $opt(dir)/bgpd5726.conf
$BGP5726 attach-node $node(5726)
$ns at 316 "$BGP5726 command \"show ip bgp\""

#puts "Creating Router 5727"
set node(5727) [$ns node]
set BGP5727 [new Application/Route/Bgp]
$BGP5727 register  $r

$BGP5727 config-file $opt(dir)/bgpd5727.conf
$BGP5727 attach-node $node(5727)
$ns at 316 "$BGP5727 command \"show ip bgp\""

#puts "Creating Router 5730"
set node(5730) [$ns node]
set BGP5730 [new Application/Route/Bgp]
$BGP5730 register  $r

$BGP5730 config-file $opt(dir)/bgpd5730.conf
$BGP5730 attach-node $node(5730)
$ns at 316 "$BGP5730 command \"show ip bgp\""

#puts "Creating Router 5736"
set node(5736) [$ns node]
set BGP5736 [new Application/Route/Bgp]
$BGP5736 register  $r

$BGP5736 config-file $opt(dir)/bgpd5736.conf
$BGP5736 attach-node $node(5736)
$ns at 316 "$BGP5736 command \"show ip bgp\""

#puts "Creating Router 5737"
set node(5737) [$ns node]
set BGP5737 [new Application/Route/Bgp]
$BGP5737 register  $r

$BGP5737 config-file $opt(dir)/bgpd5737.conf
$BGP5737 attach-node $node(5737)
$ns at 316 "$BGP5737 command \"show ip bgp\""

#puts "Creating Router 5746"
set node(5746) [$ns node]
set BGP5746 [new Application/Route/Bgp]
$BGP5746 register  $r

$BGP5746 config-file $opt(dir)/bgpd5746.conf
$BGP5746 attach-node $node(5746)
$ns at 316 "$BGP5746 command \"show ip bgp\""

#puts "Creating Router 5749"
set node(5749) [$ns node]
set BGP5749 [new Application/Route/Bgp]
$BGP5749 register  $r

$BGP5749 config-file $opt(dir)/bgpd5749.conf
$BGP5749 attach-node $node(5749)
$ns at 316 "$BGP5749 command \"show ip bgp\""

#puts "Creating Router 5754"
set node(5754) [$ns node]
set BGP5754 [new Application/Route/Bgp]
$BGP5754 register  $r

$BGP5754 config-file $opt(dir)/bgpd5754.conf
$BGP5754 attach-node $node(5754)
$ns at 316 "$BGP5754 command \"show ip bgp\""

#puts "Creating Router 5756"
set node(5756) [$ns node]
set BGP5756 [new Application/Route/Bgp]
$BGP5756 register  $r

$BGP5756 config-file $opt(dir)/bgpd5756.conf
$BGP5756 attach-node $node(5756)
$ns at 316 "$BGP5756 command \"show ip bgp\""

#puts "Creating Router 5760"
set node(5760) [$ns node]
set BGP5760 [new Application/Route/Bgp]
$BGP5760 register  $r

$BGP5760 config-file $opt(dir)/bgpd5760.conf
$BGP5760 attach-node $node(5760)
$ns at 316 "$BGP5760 command \"show ip bgp\""

#puts "Creating Router 5767"
set node(5767) [$ns node]
set BGP5767 [new Application/Route/Bgp]
$BGP5767 register  $r

$BGP5767 config-file $opt(dir)/bgpd5767.conf
$BGP5767 attach-node $node(5767)
$ns at 316 "$BGP5767 command \"show ip bgp\""

#puts "Creating Router 5768"
set node(5768) [$ns node]
set BGP5768 [new Application/Route/Bgp]
$BGP5768 register  $r

$BGP5768 config-file $opt(dir)/bgpd5768.conf
$BGP5768 attach-node $node(5768)
$ns at 316 "$BGP5768 command \"show ip bgp\""

#puts "Creating Router 577"
set node(577) [$ns node]
set BGP577 [new Application/Route/Bgp]
$BGP577 register  $r

$BGP577 config-file $opt(dir)/bgpd577.conf
$BGP577 attach-node $node(577)
$ns at 316 "$BGP577 command \"show ip bgp\""

#puts "Creating Router 5771"
set node(5771) [$ns node]
set BGP5771 [new Application/Route/Bgp]
$BGP5771 register  $r

$BGP5771 config-file $opt(dir)/bgpd5771.conf
$BGP5771 attach-node $node(5771)
$ns at 316 "$BGP5771 command \"show ip bgp\""

#puts "Creating Router 5773"
set node(5773) [$ns node]
set BGP5773 [new Application/Route/Bgp]
$BGP5773 register  $r

$BGP5773 config-file $opt(dir)/bgpd5773.conf
$BGP5773 attach-node $node(5773)
$ns at 316 "$BGP5773 command \"show ip bgp\""

#puts "Creating Router 5778"
set node(5778) [$ns node]
set BGP5778 [new Application/Route/Bgp]
$BGP5778 register  $r

$BGP5778 config-file $opt(dir)/bgpd5778.conf
$BGP5778 attach-node $node(5778)
$ns at 316 "$BGP5778 command \"show ip bgp\""

#puts "Creating Router 5788"
set node(5788) [$ns node]
set BGP5788 [new Application/Route/Bgp]
$BGP5788 register  $r

$BGP5788 config-file $opt(dir)/bgpd5788.conf
$BGP5788 attach-node $node(5788)
$ns at 316 "$BGP5788 command \"show ip bgp\""

#puts "Creating Router 5792"
set node(5792) [$ns node]
set BGP5792 [new Application/Route/Bgp]
$BGP5792 register  $r

$BGP5792 config-file $opt(dir)/bgpd5792.conf
$BGP5792 attach-node $node(5792)
$ns at 316 "$BGP5792 command \"show ip bgp\""

#puts "Creating Router 5922"
set node(5922) [$ns node]
set BGP5922 [new Application/Route/Bgp]
$BGP5922 register  $r

$BGP5922 config-file $opt(dir)/bgpd5922.conf
$BGP5922 attach-node $node(5922)
$ns at 316 "$BGP5922 command \"show ip bgp\""

#puts "Creating Router 600"
set node(600) [$ns node]
set BGP600 [new Application/Route/Bgp]
$BGP600 register  $r

$BGP600 config-file $opt(dir)/bgpd600.conf
$BGP600 attach-node $node(600)
$ns at 316 "$BGP600 command \"show ip bgp\""

#puts "Creating Router 6057"
set node(6057) [$ns node]
set BGP6057 [new Application/Route/Bgp]
$BGP6057 register  $r

$BGP6057 config-file $opt(dir)/bgpd6057.conf
$BGP6057 attach-node $node(6057)
$ns at 316 "$BGP6057 command \"show ip bgp\""

#puts "Creating Router 6062"
set node(6062) [$ns node]
set BGP6062 [new Application/Route/Bgp]
$BGP6062 register  $r

$BGP6062 config-file $opt(dir)/bgpd6062.conf
$BGP6062 attach-node $node(6062)
$ns at 316 "$BGP6062 command \"show ip bgp\""

#puts "Creating Router 6064"
set node(6064) [$ns node]
set BGP6064 [new Application/Route/Bgp]
$BGP6064 register  $r

$BGP6064 config-file $opt(dir)/bgpd6064.conf
$BGP6064 attach-node $node(6064)
$ns at 316 "$BGP6064 command \"show ip bgp\""

#puts "Creating Router 6065"
set node(6065) [$ns node]
set BGP6065 [new Application/Route/Bgp]
$BGP6065 register  $r

$BGP6065 config-file $opt(dir)/bgpd6065.conf
$BGP6065 attach-node $node(6065)
$ns at 316 "$BGP6065 command \"show ip bgp\""

#puts "Creating Router 6066"
set node(6066) [$ns node]
set BGP6066 [new Application/Route/Bgp]
$BGP6066 register  $r

$BGP6066 config-file $opt(dir)/bgpd6066.conf
$BGP6066 attach-node $node(6066)
$ns at 316 "$BGP6066 command \"show ip bgp\""

#puts "Creating Router 6067"
set node(6067) [$ns node]
set BGP6067 [new Application/Route/Bgp]
$BGP6067 register  $r

$BGP6067 config-file $opt(dir)/bgpd6067.conf
$BGP6067 attach-node $node(6067)
$ns at 316 "$BGP6067 command \"show ip bgp\""

#puts "Creating Router 6071"
set node(6071) [$ns node]
set BGP6071 [new Application/Route/Bgp]
$BGP6071 register  $r

$BGP6071 config-file $opt(dir)/bgpd6071.conf
$BGP6071 attach-node $node(6071)
$ns at 316 "$BGP6071 command \"show ip bgp\""

#puts "Creating Router 6072"
set node(6072) [$ns node]
set BGP6072 [new Application/Route/Bgp]
$BGP6072 register  $r

$BGP6072 config-file $opt(dir)/bgpd6072.conf
$BGP6072 attach-node $node(6072)
$ns at 316 "$BGP6072 command \"show ip bgp\""

#puts "Creating Router 6073"
set node(6073) [$ns node]
set BGP6073 [new Application/Route/Bgp]
$BGP6073 register  $r

$BGP6073 config-file $opt(dir)/bgpd6073.conf
$BGP6073 attach-node $node(6073)
$ns at 316 "$BGP6073 command \"show ip bgp\""

#puts "Creating Router 6078"
set node(6078) [$ns node]
set BGP6078 [new Application/Route/Bgp]
$BGP6078 register  $r

$BGP6078 config-file $opt(dir)/bgpd6078.conf
$BGP6078 attach-node $node(6078)
$ns at 316 "$BGP6078 command \"show ip bgp\""

#puts "Creating Router 6079"
set node(6079) [$ns node]
set BGP6079 [new Application/Route/Bgp]
$BGP6079 register  $r

$BGP6079 config-file $opt(dir)/bgpd6079.conf
$BGP6079 attach-node $node(6079)
$ns at 316 "$BGP6079 command \"show ip bgp\""

#puts "Creating Router 6081"
set node(6081) [$ns node]
set BGP6081 [new Application/Route/Bgp]
$BGP6081 register  $r

$BGP6081 config-file $opt(dir)/bgpd6081.conf
$BGP6081 attach-node $node(6081)
$ns at 316 "$BGP6081 command \"show ip bgp\""

#puts "Creating Router 6082"
set node(6082) [$ns node]
set BGP6082 [new Application/Route/Bgp]
$BGP6082 register  $r

$BGP6082 config-file $opt(dir)/bgpd6082.conf
$BGP6082 attach-node $node(6082)
$ns at 316 "$BGP6082 command \"show ip bgp\""

#puts "Creating Router 6083"
set node(6083) [$ns node]
set BGP6083 [new Application/Route/Bgp]
$BGP6083 register  $r

$BGP6083 config-file $opt(dir)/bgpd6083.conf
$BGP6083 attach-node $node(6083)
$ns at 316 "$BGP6083 command \"show ip bgp\""

#puts "Creating Router 6089"
set node(6089) [$ns node]
set BGP6089 [new Application/Route/Bgp]
$BGP6089 register  $r

$BGP6089 config-file $opt(dir)/bgpd6089.conf
$BGP6089 attach-node $node(6089)
$ns at 316 "$BGP6089 command \"show ip bgp\""

#puts "Creating Router 6095"
set node(6095) [$ns node]
set BGP6095 [new Application/Route/Bgp]
$BGP6095 register  $r

$BGP6095 config-file $opt(dir)/bgpd6095.conf
$BGP6095 attach-node $node(6095)
$ns at 316 "$BGP6095 command \"show ip bgp\""

#puts "Creating Router 6112"
set node(6112) [$ns node]
set BGP6112 [new Application/Route/Bgp]
$BGP6112 register  $r

$BGP6112 config-file $opt(dir)/bgpd6112.conf
$BGP6112 attach-node $node(6112)
$ns at 316 "$BGP6112 command \"show ip bgp\""

#puts "Creating Router 6113"
set node(6113) [$ns node]
set BGP6113 [new Application/Route/Bgp]
$BGP6113 register  $r

$BGP6113 config-file $opt(dir)/bgpd6113.conf
$BGP6113 attach-node $node(6113)
$ns at 316 "$BGP6113 command \"show ip bgp\""

#puts "Creating Router 6114"
set node(6114) [$ns node]
set BGP6114 [new Application/Route/Bgp]
$BGP6114 register  $r

$BGP6114 config-file $opt(dir)/bgpd6114.conf
$BGP6114 attach-node $node(6114)
$ns at 316 "$BGP6114 command \"show ip bgp\""

#puts "Creating Router 6115"
set node(6115) [$ns node]
set BGP6115 [new Application/Route/Bgp]
$BGP6115 register  $r

$BGP6115 config-file $opt(dir)/bgpd6115.conf
$BGP6115 attach-node $node(6115)
$ns at 316 "$BGP6115 command \"show ip bgp\""

#puts "Creating Router 6122"
set node(6122) [$ns node]
set BGP6122 [new Application/Route/Bgp]
$BGP6122 register  $r

$BGP6122 config-file $opt(dir)/bgpd6122.conf
$BGP6122 attach-node $node(6122)
$ns at 316 "$BGP6122 command \"show ip bgp\""

#puts "Creating Router 613"
set node(613) [$ns node]
set BGP613 [new Application/Route/Bgp]
$BGP613 register  $r

$BGP613 config-file $opt(dir)/bgpd613.conf
$BGP613 attach-node $node(613)
$ns at 316 "$BGP613 command \"show ip bgp\""

#puts "Creating Router 6136"
set node(6136) [$ns node]
set BGP6136 [new Application/Route/Bgp]
$BGP6136 register  $r

$BGP6136 config-file $opt(dir)/bgpd6136.conf
$BGP6136 attach-node $node(6136)
$ns at 316 "$BGP6136 command \"show ip bgp\""

#puts "Creating Router 6138"
set node(6138) [$ns node]
set BGP6138 [new Application/Route/Bgp]
$BGP6138 register  $r

$BGP6138 config-file $opt(dir)/bgpd6138.conf
$BGP6138 attach-node $node(6138)
$ns at 316 "$BGP6138 command \"show ip bgp\""

#puts "Creating Router 6140"
set node(6140) [$ns node]
set BGP6140 [new Application/Route/Bgp]
$BGP6140 register  $r

$BGP6140 config-file $opt(dir)/bgpd6140.conf
$BGP6140 attach-node $node(6140)
$ns at 316 "$BGP6140 command \"show ip bgp\""

#puts "Creating Router 6144"
set node(6144) [$ns node]
set BGP6144 [new Application/Route/Bgp]
$BGP6144 register  $r

$BGP6144 config-file $opt(dir)/bgpd6144.conf
$BGP6144 attach-node $node(6144)
$ns at 316 "$BGP6144 command \"show ip bgp\""

#puts "Creating Router 6147"
set node(6147) [$ns node]
set BGP6147 [new Application/Route/Bgp]
$BGP6147 register  $r

$BGP6147 config-file $opt(dir)/bgpd6147.conf
$BGP6147 attach-node $node(6147)
$ns at 316 "$BGP6147 command \"show ip bgp\""

#puts "Creating Router 6172"
set node(6172) [$ns node]
set BGP6172 [new Application/Route/Bgp]
$BGP6172 register  $r

$BGP6172 config-file $opt(dir)/bgpd6172.conf
$BGP6172 attach-node $node(6172)
$ns at 316 "$BGP6172 command \"show ip bgp\""

#puts "Creating Router 6180"
set node(6180) [$ns node]
set BGP6180 [new Application/Route/Bgp]
$BGP6180 register  $r

$BGP6180 config-file $opt(dir)/bgpd6180.conf
$BGP6180 attach-node $node(6180)
$ns at 316 "$BGP6180 command \"show ip bgp\""

#puts "Creating Router 6187"
set node(6187) [$ns node]
set BGP6187 [new Application/Route/Bgp]
$BGP6187 register  $r

$BGP6187 config-file $opt(dir)/bgpd6187.conf
$BGP6187 attach-node $node(6187)
$ns at 316 "$BGP6187 command \"show ip bgp\""

#puts "Creating Router 6188"
set node(6188) [$ns node]
set BGP6188 [new Application/Route/Bgp]
$BGP6188 register  $r

$BGP6188 config-file $opt(dir)/bgpd6188.conf
$BGP6188 attach-node $node(6188)
$ns at 316 "$BGP6188 command \"show ip bgp\""

#puts "Creating Router 6196"
set node(6196) [$ns node]
set BGP6196 [new Application/Route/Bgp]
$BGP6196 register  $r

$BGP6196 config-file $opt(dir)/bgpd6196.conf
$BGP6196 attach-node $node(6196)
$ns at 316 "$BGP6196 command \"show ip bgp\""

#puts "Creating Router 6197"
set node(6197) [$ns node]
set BGP6197 [new Application/Route/Bgp]
$BGP6197 register  $r

$BGP6197 config-file $opt(dir)/bgpd6197.conf
$BGP6197 attach-node $node(6197)
$ns at 316 "$BGP6197 command \"show ip bgp\""

#puts "Creating Router 6198"
set node(6198) [$ns node]
set BGP6198 [new Application/Route/Bgp]
$BGP6198 register  $r

$BGP6198 config-file $opt(dir)/bgpd6198.conf
$BGP6198 attach-node $node(6198)
$ns at 316 "$BGP6198 command \"show ip bgp\""

#puts "Creating Router 6200"
set node(6200) [$ns node]
set BGP6200 [new Application/Route/Bgp]
$BGP6200 register  $r

$BGP6200 config-file $opt(dir)/bgpd6200.conf
$BGP6200 attach-node $node(6200)
$ns at 316 "$BGP6200 command \"show ip bgp\""

#puts "Creating Router 6203"
set node(6203) [$ns node]
set BGP6203 [new Application/Route/Bgp]
$BGP6203 register  $r

$BGP6203 config-file $opt(dir)/bgpd6203.conf
$BGP6203 attach-node $node(6203)
$ns at 316 "$BGP6203 command \"show ip bgp\""

#puts "Creating Router 6205"
set node(6205) [$ns node]
set BGP6205 [new Application/Route/Bgp]
$BGP6205 register  $r

$BGP6205 config-file $opt(dir)/bgpd6205.conf
$BGP6205 attach-node $node(6205)
$ns at 316 "$BGP6205 command \"show ip bgp\""

#puts "Creating Router 6214"
set node(6214) [$ns node]
set BGP6214 [new Application/Route/Bgp]
$BGP6214 register  $r

$BGP6214 config-file $opt(dir)/bgpd6214.conf
$BGP6214 attach-node $node(6214)
$ns at 316 "$BGP6214 command \"show ip bgp\""

#puts "Creating Router 6217"
set node(6217) [$ns node]
set BGP6217 [new Application/Route/Bgp]
$BGP6217 register  $r

$BGP6217 config-file $opt(dir)/bgpd6217.conf
$BGP6217 attach-node $node(6217)
$ns at 316 "$BGP6217 command \"show ip bgp\""

#puts "Creating Router 6218"
set node(6218) [$ns node]
set BGP6218 [new Application/Route/Bgp]
$BGP6218 register  $r

$BGP6218 config-file $opt(dir)/bgpd6218.conf
$BGP6218 attach-node $node(6218)
$ns at 316 "$BGP6218 command \"show ip bgp\""

#puts "Creating Router 6226"
set node(6226) [$ns node]
set BGP6226 [new Application/Route/Bgp]
$BGP6226 register  $r

$BGP6226 config-file $opt(dir)/bgpd6226.conf
$BGP6226 attach-node $node(6226)
$ns at 316 "$BGP6226 command \"show ip bgp\""

#puts "Creating Router 6233"
set node(6233) [$ns node]
set BGP6233 [new Application/Route/Bgp]
$BGP6233 register  $r

$BGP6233 config-file $opt(dir)/bgpd6233.conf
$BGP6233 attach-node $node(6233)
$ns at 316 "$BGP6233 command \"show ip bgp\""

#puts "Creating Router 6235"
set node(6235) [$ns node]
set BGP6235 [new Application/Route/Bgp]
$BGP6235 register  $r

$BGP6235 config-file $opt(dir)/bgpd6235.conf
$BGP6235 attach-node $node(6235)
$ns at 316 "$BGP6235 command \"show ip bgp\""

#puts "Creating Router 6239"
set node(6239) [$ns node]
set BGP6239 [new Application/Route/Bgp]
$BGP6239 register  $r

$BGP6239 config-file $opt(dir)/bgpd6239.conf
$BGP6239 attach-node $node(6239)
$ns at 316 "$BGP6239 command \"show ip bgp\""

#puts "Creating Router 6245"
set node(6245) [$ns node]
set BGP6245 [new Application/Route/Bgp]
$BGP6245 register  $r

$BGP6245 config-file $opt(dir)/bgpd6245.conf
$BGP6245 attach-node $node(6245)
$ns at 316 "$BGP6245 command \"show ip bgp\""

#puts "Creating Router 6251"
set node(6251) [$ns node]
set BGP6251 [new Application/Route/Bgp]
$BGP6251 register  $r

$BGP6251 config-file $opt(dir)/bgpd6251.conf
$BGP6251 attach-node $node(6251)
$ns at 316 "$BGP6251 command \"show ip bgp\""

#puts "Creating Router 6255"
set node(6255) [$ns node]
set BGP6255 [new Application/Route/Bgp]
$BGP6255 register  $r

$BGP6255 config-file $opt(dir)/bgpd6255.conf
$BGP6255 attach-node $node(6255)
$ns at 316 "$BGP6255 command \"show ip bgp\""

#puts "Creating Router 6259"
set node(6259) [$ns node]
set BGP6259 [new Application/Route/Bgp]
$BGP6259 register  $r

$BGP6259 config-file $opt(dir)/bgpd6259.conf
$BGP6259 attach-node $node(6259)
$ns at 316 "$BGP6259 command \"show ip bgp\""

#puts "Creating Router 6261"
set node(6261) [$ns node]
set BGP6261 [new Application/Route/Bgp]
$BGP6261 register  $r

$BGP6261 config-file $opt(dir)/bgpd6261.conf
$BGP6261 attach-node $node(6261)
$ns at 316 "$BGP6261 command \"show ip bgp\""

#puts "Creating Router 6269"
set node(6269) [$ns node]
set BGP6269 [new Application/Route/Bgp]
$BGP6269 register  $r

$BGP6269 config-file $opt(dir)/bgpd6269.conf
$BGP6269 attach-node $node(6269)
$ns at 316 "$BGP6269 command \"show ip bgp\""

#puts "Creating Router 6287"
set node(6287) [$ns node]
set BGP6287 [new Application/Route/Bgp]
$BGP6287 register  $r

$BGP6287 config-file $opt(dir)/bgpd6287.conf
$BGP6287 attach-node $node(6287)
$ns at 316 "$BGP6287 command \"show ip bgp\""

#puts "Creating Router 6292"
set node(6292) [$ns node]
set BGP6292 [new Application/Route/Bgp]
$BGP6292 register  $r

$BGP6292 config-file $opt(dir)/bgpd6292.conf
$BGP6292 attach-node $node(6292)
$ns at 316 "$BGP6292 command \"show ip bgp\""

#puts "Creating Router 6297"
set node(6297) [$ns node]
set BGP6297 [new Application/Route/Bgp]
$BGP6297 register  $r

$BGP6297 config-file $opt(dir)/bgpd6297.conf
$BGP6297 attach-node $node(6297)
$ns at 316 "$BGP6297 command \"show ip bgp\""

#puts "Creating Router 6299"
set node(6299) [$ns node]
set BGP6299 [new Application/Route/Bgp]
$BGP6299 register  $r

$BGP6299 config-file $opt(dir)/bgpd6299.conf
$BGP6299 attach-node $node(6299)
$ns at 316 "$BGP6299 command \"show ip bgp\""

#puts "Creating Router 6302"
set node(6302) [$ns node]
set BGP6302 [new Application/Route/Bgp]
$BGP6302 register  $r

$BGP6302 config-file $opt(dir)/bgpd6302.conf
$BGP6302 attach-node $node(6302)
$ns at 316 "$BGP6302 command \"show ip bgp\""

#puts "Creating Router 6306"
set node(6306) [$ns node]
set BGP6306 [new Application/Route/Bgp]
$BGP6306 register  $r

$BGP6306 config-file $opt(dir)/bgpd6306.conf
$BGP6306 attach-node $node(6306)
$ns at 316 "$BGP6306 command \"show ip bgp\""

#puts "Creating Router 6308"
set node(6308) [$ns node]
set BGP6308 [new Application/Route/Bgp]
$BGP6308 register  $r

$BGP6308 config-file $opt(dir)/bgpd6308.conf
$BGP6308 attach-node $node(6308)
$ns at 316 "$BGP6308 command \"show ip bgp\""

#puts "Creating Router 6315"
set node(6315) [$ns node]
set BGP6315 [new Application/Route/Bgp]
$BGP6315 register  $r

$BGP6315 config-file $opt(dir)/bgpd6315.conf
$BGP6315 attach-node $node(6315)
$ns at 316 "$BGP6315 command \"show ip bgp\""

#puts "Creating Router 6320"
set node(6320) [$ns node]
set BGP6320 [new Application/Route/Bgp]
$BGP6320 register  $r

$BGP6320 config-file $opt(dir)/bgpd6320.conf
$BGP6320 attach-node $node(6320)
$ns at 316 "$BGP6320 command \"show ip bgp\""

#puts "Creating Router 6322"
set node(6322) [$ns node]
set BGP6322 [new Application/Route/Bgp]
$BGP6322 register  $r

$BGP6322 config-file $opt(dir)/bgpd6322.conf
$BGP6322 attach-node $node(6322)
$ns at 316 "$BGP6322 command \"show ip bgp\""

#puts "Creating Router 6325"
set node(6325) [$ns node]
set BGP6325 [new Application/Route/Bgp]
$BGP6325 register  $r

$BGP6325 config-file $opt(dir)/bgpd6325.conf
$BGP6325 attach-node $node(6325)
$ns at 316 "$BGP6325 command \"show ip bgp\""

#puts "Creating Router 6327"
set node(6327) [$ns node]
set BGP6327 [new Application/Route/Bgp]
$BGP6327 register  $r

$BGP6327 config-file $opt(dir)/bgpd6327.conf
$BGP6327 attach-node $node(6327)
$ns at 316 "$BGP6327 command \"show ip bgp\""

#puts "Creating Router 6331"
set node(6331) [$ns node]
set BGP6331 [new Application/Route/Bgp]
$BGP6331 register  $r

$BGP6331 config-file $opt(dir)/bgpd6331.conf
$BGP6331 attach-node $node(6331)
$ns at 316 "$BGP6331 command \"show ip bgp\""

#puts "Creating Router 6332"
set node(6332) [$ns node]
set BGP6332 [new Application/Route/Bgp]
$BGP6332 register  $r

$BGP6332 config-file $opt(dir)/bgpd6332.conf
$BGP6332 attach-node $node(6332)
$ns at 316 "$BGP6332 command \"show ip bgp\""

#puts "Creating Router 6335"
set node(6335) [$ns node]
set BGP6335 [new Application/Route/Bgp]
$BGP6335 register  $r

$BGP6335 config-file $opt(dir)/bgpd6335.conf
$BGP6335 attach-node $node(6335)
$ns at 316 "$BGP6335 command \"show ip bgp\""

#puts "Creating Router 6342"
set node(6342) [$ns node]
set BGP6342 [new Application/Route/Bgp]
$BGP6342 register  $r

$BGP6342 config-file $opt(dir)/bgpd6342.conf
$BGP6342 attach-node $node(6342)
$ns at 316 "$BGP6342 command \"show ip bgp\""

#puts "Creating Router 6345"
set node(6345) [$ns node]
set BGP6345 [new Application/Route/Bgp]
$BGP6345 register  $r

$BGP6345 config-file $opt(dir)/bgpd6345.conf
$BGP6345 attach-node $node(6345)
$ns at 316 "$BGP6345 command \"show ip bgp\""

#puts "Creating Router 6347"
set node(6347) [$ns node]
set BGP6347 [new Application/Route/Bgp]
$BGP6347 register  $r

$BGP6347 config-file $opt(dir)/bgpd6347.conf
$BGP6347 attach-node $node(6347)
$ns at 316 "$BGP6347 command \"show ip bgp\""

#puts "Creating Router 6349"
set node(6349) [$ns node]
set BGP6349 [new Application/Route/Bgp]
$BGP6349 register  $r

$BGP6349 config-file $opt(dir)/bgpd6349.conf
$BGP6349 attach-node $node(6349)
$ns at 316 "$BGP6349 command \"show ip bgp\""

#puts "Creating Router 6350"
set node(6350) [$ns node]
set BGP6350 [new Application/Route/Bgp]
$BGP6350 register  $r

$BGP6350 config-file $opt(dir)/bgpd6350.conf
$BGP6350 attach-node $node(6350)
$ns at 316 "$BGP6350 command \"show ip bgp\""

#puts "Creating Router 6357"
set node(6357) [$ns node]
set BGP6357 [new Application/Route/Bgp]
$BGP6357 register  $r

$BGP6357 config-file $opt(dir)/bgpd6357.conf
$BGP6357 attach-node $node(6357)
$ns at 316 "$BGP6357 command \"show ip bgp\""

#puts "Creating Router 6362"
set node(6362) [$ns node]
set BGP6362 [new Application/Route/Bgp]
$BGP6362 register  $r

$BGP6362 config-file $opt(dir)/bgpd6362.conf
$BGP6362 attach-node $node(6362)
$ns at 316 "$BGP6362 command \"show ip bgp\""

#puts "Creating Router 6365"
set node(6365) [$ns node]
set BGP6365 [new Application/Route/Bgp]
$BGP6365 register  $r

$BGP6365 config-file $opt(dir)/bgpd6365.conf
$BGP6365 attach-node $node(6365)
$ns at 316 "$BGP6365 command \"show ip bgp\""

#puts "Creating Router 6369"
set node(6369) [$ns node]
set BGP6369 [new Application/Route/Bgp]
$BGP6369 register  $r

$BGP6369 config-file $opt(dir)/bgpd6369.conf
$BGP6369 attach-node $node(6369)
$ns at 316 "$BGP6369 command \"show ip bgp\""

#puts "Creating Router 6371"
set node(6371) [$ns node]
set BGP6371 [new Application/Route/Bgp]
$BGP6371 register  $r

$BGP6371 config-file $opt(dir)/bgpd6371.conf
$BGP6371 attach-node $node(6371)
$ns at 316 "$BGP6371 command \"show ip bgp\""

#puts "Creating Router 6373"
set node(6373) [$ns node]
set BGP6373 [new Application/Route/Bgp]
$BGP6373 register  $r

$BGP6373 config-file $opt(dir)/bgpd6373.conf
$BGP6373 attach-node $node(6373)
$ns at 316 "$BGP6373 command \"show ip bgp\""

#puts "Creating Router 6375"
set node(6375) [$ns node]
set BGP6375 [new Application/Route/Bgp]
$BGP6375 register  $r

$BGP6375 config-file $opt(dir)/bgpd6375.conf
$BGP6375 attach-node $node(6375)
$ns at 316 "$BGP6375 command \"show ip bgp\""

#puts "Creating Router 6379"
set node(6379) [$ns node]
set BGP6379 [new Application/Route/Bgp]
$BGP6379 register  $r

$BGP6379 config-file $opt(dir)/bgpd6379.conf
$BGP6379 attach-node $node(6379)
$ns at 316 "$BGP6379 command \"show ip bgp\""

#puts "Creating Router 6380"
set node(6380) [$ns node]
set BGP6380 [new Application/Route/Bgp]
$BGP6380 register  $r

$BGP6380 config-file $opt(dir)/bgpd6380.conf
$BGP6380 attach-node $node(6380)
$ns at 316 "$BGP6380 command \"show ip bgp\""

#puts "Creating Router 6381"
set node(6381) [$ns node]
set BGP6381 [new Application/Route/Bgp]
$BGP6381 register  $r

$BGP6381 config-file $opt(dir)/bgpd6381.conf
$BGP6381 attach-node $node(6381)
$ns at 316 "$BGP6381 command \"show ip bgp\""

#puts "Creating Router 6382"
set node(6382) [$ns node]
set BGP6382 [new Application/Route/Bgp]
$BGP6382 register  $r

$BGP6382 config-file $opt(dir)/bgpd6382.conf
$BGP6382 attach-node $node(6382)
$ns at 316 "$BGP6382 command \"show ip bgp\""

#puts "Creating Router 6383"
set node(6383) [$ns node]
set BGP6383 [new Application/Route/Bgp]
$BGP6383 register  $r

$BGP6383 config-file $opt(dir)/bgpd6383.conf
$BGP6383 attach-node $node(6383)
$ns at 316 "$BGP6383 command \"show ip bgp\""

#puts "Creating Router 6384"
set node(6384) [$ns node]
set BGP6384 [new Application/Route/Bgp]
$BGP6384 register  $r

$BGP6384 config-file $opt(dir)/bgpd6384.conf
$BGP6384 attach-node $node(6384)
$ns at 316 "$BGP6384 command \"show ip bgp\""

#puts "Creating Router 6385"
set node(6385) [$ns node]
set BGP6385 [new Application/Route/Bgp]
$BGP6385 register  $r

$BGP6385 config-file $opt(dir)/bgpd6385.conf
$BGP6385 attach-node $node(6385)
$ns at 316 "$BGP6385 command \"show ip bgp\""

#puts "Creating Router 6386"
set node(6386) [$ns node]
set BGP6386 [new Application/Route/Bgp]
$BGP6386 register  $r

$BGP6386 config-file $opt(dir)/bgpd6386.conf
$BGP6386 attach-node $node(6386)
$ns at 316 "$BGP6386 command \"show ip bgp\""

#puts "Creating Router 6387"
set node(6387) [$ns node]
set BGP6387 [new Application/Route/Bgp]
$BGP6387 register  $r

$BGP6387 config-file $opt(dir)/bgpd6387.conf
$BGP6387 attach-node $node(6387)
$ns at 316 "$BGP6387 command \"show ip bgp\""

#puts "Creating Router 6388"
set node(6388) [$ns node]
set BGP6388 [new Application/Route/Bgp]
$BGP6388 register  $r

$BGP6388 config-file $opt(dir)/bgpd6388.conf
$BGP6388 attach-node $node(6388)
$ns at 316 "$BGP6388 command \"show ip bgp\""

#puts "Creating Router 6391"
set node(6391) [$ns node]
set BGP6391 [new Application/Route/Bgp]
$BGP6391 register  $r

$BGP6391 config-file $opt(dir)/bgpd6391.conf
$BGP6391 attach-node $node(6391)
$ns at 316 "$BGP6391 command \"show ip bgp\""

#puts "Creating Router 6392"
set node(6392) [$ns node]
set BGP6392 [new Application/Route/Bgp]
$BGP6392 register  $r

$BGP6392 config-file $opt(dir)/bgpd6392.conf
$BGP6392 attach-node $node(6392)
$ns at 316 "$BGP6392 command \"show ip bgp\""

#puts "Creating Router 6401"
set node(6401) [$ns node]
set BGP6401 [new Application/Route/Bgp]
$BGP6401 register  $r

$BGP6401 config-file $opt(dir)/bgpd6401.conf
$BGP6401 attach-node $node(6401)
$ns at 316 "$BGP6401 command \"show ip bgp\""

#puts "Creating Router 6402"
set node(6402) [$ns node]
set BGP6402 [new Application/Route/Bgp]
$BGP6402 register  $r

$BGP6402 config-file $opt(dir)/bgpd6402.conf
$BGP6402 attach-node $node(6402)
$ns at 316 "$BGP6402 command \"show ip bgp\""

#puts "Creating Router 6419"
set node(6419) [$ns node]
set BGP6419 [new Application/Route/Bgp]
$BGP6419 register  $r

$BGP6419 config-file $opt(dir)/bgpd6419.conf
$BGP6419 attach-node $node(6419)
$ns at 316 "$BGP6419 command \"show ip bgp\""

#puts "Creating Router 6427"
set node(6427) [$ns node]
set BGP6427 [new Application/Route/Bgp]
$BGP6427 register  $r

$BGP6427 config-file $opt(dir)/bgpd6427.conf
$BGP6427 attach-node $node(6427)
$ns at 316 "$BGP6427 command \"show ip bgp\""

#puts "Creating Router 6428"
set node(6428) [$ns node]
set BGP6428 [new Application/Route/Bgp]
$BGP6428 register  $r

$BGP6428 config-file $opt(dir)/bgpd6428.conf
$BGP6428 attach-node $node(6428)
$ns at 316 "$BGP6428 command \"show ip bgp\""

#puts "Creating Router 6433"
set node(6433) [$ns node]
set BGP6433 [new Application/Route/Bgp]
$BGP6433 register  $r

$BGP6433 config-file $opt(dir)/bgpd6433.conf
$BGP6433 attach-node $node(6433)
$ns at 316 "$BGP6433 command \"show ip bgp\""

#puts "Creating Router 6434"
set node(6434) [$ns node]
set BGP6434 [new Application/Route/Bgp]
$BGP6434 register  $r

$BGP6434 config-file $opt(dir)/bgpd6434.conf
$BGP6434 attach-node $node(6434)
$ns at 316 "$BGP6434 command \"show ip bgp\""

#puts "Creating Router 6441"
set node(6441) [$ns node]
set BGP6441 [new Application/Route/Bgp]
$BGP6441 register  $r

$BGP6441 config-file $opt(dir)/bgpd6441.conf
$BGP6441 attach-node $node(6441)
$ns at 316 "$BGP6441 command \"show ip bgp\""

#puts "Creating Router 6448"
set node(6448) [$ns node]
set BGP6448 [new Application/Route/Bgp]
$BGP6448 register  $r

$BGP6448 config-file $opt(dir)/bgpd6448.conf
$BGP6448 attach-node $node(6448)
$ns at 316 "$BGP6448 command \"show ip bgp\""

#puts "Creating Router 6450"
set node(6450) [$ns node]
set BGP6450 [new Application/Route/Bgp]
$BGP6450 register  $r

$BGP6450 config-file $opt(dir)/bgpd6450.conf
$BGP6450 attach-node $node(6450)
$ns at 316 "$BGP6450 command \"show ip bgp\""

#puts "Creating Router 6453"
set node(6453) [$ns node]
set BGP6453 [new Application/Route/Bgp]
$BGP6453 register  $r

$BGP6453 config-file $opt(dir)/bgpd6453.conf
$BGP6453 attach-node $node(6453)
$ns at 316 "$BGP6453 command \"show ip bgp\""

#puts "Creating Router 6458"
set node(6458) [$ns node]
set BGP6458 [new Application/Route/Bgp]
$BGP6458 register  $r

$BGP6458 config-file $opt(dir)/bgpd6458.conf
$BGP6458 attach-node $node(6458)
$ns at 316 "$BGP6458 command \"show ip bgp\""

#puts "Creating Router 6461"
set node(6461) [$ns node]
set BGP6461 [new Application/Route/Bgp]
$BGP6461 register  $r

$BGP6461 config-file $opt(dir)/bgpd6461.conf
$BGP6461 attach-node $node(6461)
$ns at 316 "$BGP6461 command \"show ip bgp\""

#puts "Creating Router 6463"
set node(6463) [$ns node]
set BGP6463 [new Application/Route/Bgp]
$BGP6463 register  $r

$BGP6463 config-file $opt(dir)/bgpd6463.conf
$BGP6463 attach-node $node(6463)
$ns at 316 "$BGP6463 command \"show ip bgp\""

#puts "Creating Router 6467"
set node(6467) [$ns node]
set BGP6467 [new Application/Route/Bgp]
$BGP6467 register  $r

$BGP6467 config-file $opt(dir)/bgpd6467.conf
$BGP6467 attach-node $node(6467)
$ns at 316 "$BGP6467 command \"show ip bgp\""

#puts "Creating Router 6471"
set node(6471) [$ns node]
set BGP6471 [new Application/Route/Bgp]
$BGP6471 register  $r

$BGP6471 config-file $opt(dir)/bgpd6471.conf
$BGP6471 attach-node $node(6471)
$ns at 316 "$BGP6471 command \"show ip bgp\""

#puts "Creating Router 6472"
set node(6472) [$ns node]
set BGP6472 [new Application/Route/Bgp]
$BGP6472 register  $r

$BGP6472 config-file $opt(dir)/bgpd6472.conf
$BGP6472 attach-node $node(6472)
$ns at 316 "$BGP6472 command \"show ip bgp\""

#puts "Creating Router 6474"
set node(6474) [$ns node]
set BGP6474 [new Application/Route/Bgp]
$BGP6474 register  $r

$BGP6474 config-file $opt(dir)/bgpd6474.conf
$BGP6474 attach-node $node(6474)
$ns at 316 "$BGP6474 command \"show ip bgp\""

#puts "Creating Router 6478"
set node(6478) [$ns node]
set BGP6478 [new Application/Route/Bgp]
$BGP6478 register  $r

$BGP6478 config-file $opt(dir)/bgpd6478.conf
$BGP6478 attach-node $node(6478)
$ns at 316 "$BGP6478 command \"show ip bgp\""

#puts "Creating Router 6484"
set node(6484) [$ns node]
set BGP6484 [new Application/Route/Bgp]
$BGP6484 register  $r

$BGP6484 config-file $opt(dir)/bgpd6484.conf
$BGP6484 attach-node $node(6484)
$ns at 316 "$BGP6484 command \"show ip bgp\""

#puts "Creating Router 6487"
set node(6487) [$ns node]
set BGP6487 [new Application/Route/Bgp]
$BGP6487 register  $r

$BGP6487 config-file $opt(dir)/bgpd6487.conf
$BGP6487 attach-node $node(6487)
$ns at 316 "$BGP6487 command \"show ip bgp\""

#puts "Creating Router 6493"
set node(6493) [$ns node]
set BGP6493 [new Application/Route/Bgp]
$BGP6493 register  $r

$BGP6493 config-file $opt(dir)/bgpd6493.conf
$BGP6493 attach-node $node(6493)
$ns at 316 "$BGP6493 command \"show ip bgp\""

#puts "Creating Router 6494"
set node(6494) [$ns node]
set BGP6494 [new Application/Route/Bgp]
$BGP6494 register  $r

$BGP6494 config-file $opt(dir)/bgpd6494.conf
$BGP6494 attach-node $node(6494)
$ns at 316 "$BGP6494 command \"show ip bgp\""

#puts "Creating Router 6495"
set node(6495) [$ns node]
set BGP6495 [new Application/Route/Bgp]
$BGP6495 register  $r

$BGP6495 config-file $opt(dir)/bgpd6495.conf
$BGP6495 attach-node $node(6495)
$ns at 316 "$BGP6495 command \"show ip bgp\""

#puts "Creating Router 6496"
set node(6496) [$ns node]
set BGP6496 [new Application/Route/Bgp]
$BGP6496 register  $r

$BGP6496 config-file $opt(dir)/bgpd6496.conf
$BGP6496 attach-node $node(6496)
$ns at 316 "$BGP6496 command \"show ip bgp\""

#puts "Creating Router 6499"
set node(6499) [$ns node]
set BGP6499 [new Application/Route/Bgp]
$BGP6499 register  $r

$BGP6499 config-file $opt(dir)/bgpd6499.conf
$BGP6499 attach-node $node(6499)
$ns at 316 "$BGP6499 command \"show ip bgp\""

#puts "Creating Router 6503"
set node(6503) [$ns node]
set BGP6503 [new Application/Route/Bgp]
$BGP6503 register  $r

$BGP6503 config-file $opt(dir)/bgpd6503.conf
$BGP6503 attach-node $node(6503)
$ns at 316 "$BGP6503 command \"show ip bgp\""

#puts "Creating Router 6505"
set node(6505) [$ns node]
set BGP6505 [new Application/Route/Bgp]
$BGP6505 register  $r

$BGP6505 config-file $opt(dir)/bgpd6505.conf
$BGP6505 attach-node $node(6505)
$ns at 316 "$BGP6505 command \"show ip bgp\""

#puts "Creating Router 6509"
set node(6509) [$ns node]
set BGP6509 [new Application/Route/Bgp]
$BGP6509 register  $r

$BGP6509 config-file $opt(dir)/bgpd6509.conf
$BGP6509 attach-node $node(6509)
$ns at 316 "$BGP6509 command \"show ip bgp\""

#puts "Creating Router 6521"
set node(6521) [$ns node]
set BGP6521 [new Application/Route/Bgp]
$BGP6521 register  $r

$BGP6521 config-file $opt(dir)/bgpd6521.conf
$BGP6521 attach-node $node(6521)
$ns at 316 "$BGP6521 command \"show ip bgp\""

#puts "Creating Router 6525"
set node(6525) [$ns node]
set BGP6525 [new Application/Route/Bgp]
$BGP6525 register  $r

$BGP6525 config-file $opt(dir)/bgpd6525.conf
$BGP6525 attach-node $node(6525)
$ns at 316 "$BGP6525 command \"show ip bgp\""

#puts "Creating Router 6540"
set node(6540) [$ns node]
set BGP6540 [new Application/Route/Bgp]
$BGP6540 register  $r

$BGP6540 config-file $opt(dir)/bgpd6540.conf
$BGP6540 attach-node $node(6540)
$ns at 316 "$BGP6540 command \"show ip bgp\""

#puts "Creating Router 6541"
set node(6541) [$ns node]
set BGP6541 [new Application/Route/Bgp]
$BGP6541 register  $r

$BGP6541 config-file $opt(dir)/bgpd6541.conf
$BGP6541 attach-node $node(6541)
$ns at 316 "$BGP6541 command \"show ip bgp\""

#puts "Creating Router 6542"
set node(6542) [$ns node]
set BGP6542 [new Application/Route/Bgp]
$BGP6542 register  $r

$BGP6542 config-file $opt(dir)/bgpd6542.conf
$BGP6542 attach-node $node(6542)
$ns at 316 "$BGP6542 command \"show ip bgp\""

#puts "Creating Router 6543"
set node(6543) [$ns node]
set BGP6543 [new Application/Route/Bgp]
$BGP6543 register  $r

$BGP6543 config-file $opt(dir)/bgpd6543.conf
$BGP6543 attach-node $node(6543)
$ns at 316 "$BGP6543 command \"show ip bgp\""

#puts "Creating Router 6547"
set node(6547) [$ns node]
set BGP6547 [new Application/Route/Bgp]
$BGP6547 register  $r

$BGP6547 config-file $opt(dir)/bgpd6547.conf
$BGP6547 attach-node $node(6547)
$ns at 316 "$BGP6547 command \"show ip bgp\""

#puts "Creating Router 6553"
set node(6553) [$ns node]
set BGP6553 [new Application/Route/Bgp]
$BGP6553 register  $r

$BGP6553 config-file $opt(dir)/bgpd6553.conf
$BGP6553 attach-node $node(6553)
$ns at 316 "$BGP6553 command \"show ip bgp\""

#puts "Creating Router 6555"
set node(6555) [$ns node]
set BGP6555 [new Application/Route/Bgp]
$BGP6555 register  $r

$BGP6555 config-file $opt(dir)/bgpd6555.conf
$BGP6555 attach-node $node(6555)
$ns at 316 "$BGP6555 command \"show ip bgp\""

#puts "Creating Router 6561"
set node(6561) [$ns node]
set BGP6561 [new Application/Route/Bgp]
$BGP6561 register  $r

$BGP6561 config-file $opt(dir)/bgpd6561.conf
$BGP6561 attach-node $node(6561)
$ns at 316 "$BGP6561 command \"show ip bgp\""

#puts "Creating Router 6568"
set node(6568) [$ns node]
set BGP6568 [new Application/Route/Bgp]
$BGP6568 register  $r

$BGP6568 config-file $opt(dir)/bgpd6568.conf
$BGP6568 attach-node $node(6568)
$ns at 316 "$BGP6568 command \"show ip bgp\""

#puts "Creating Router 6571"
set node(6571) [$ns node]
set BGP6571 [new Application/Route/Bgp]
$BGP6571 register  $r

$BGP6571 config-file $opt(dir)/bgpd6571.conf
$BGP6571 attach-node $node(6571)
$ns at 316 "$BGP6571 command \"show ip bgp\""

#puts "Creating Router 6576"
set node(6576) [$ns node]
set BGP6576 [new Application/Route/Bgp]
$BGP6576 register  $r

$BGP6576 config-file $opt(dir)/bgpd6576.conf
$BGP6576 attach-node $node(6576)
$ns at 316 "$BGP6576 command \"show ip bgp\""

#puts "Creating Router 6582"
set node(6582) [$ns node]
set BGP6582 [new Application/Route/Bgp]
$BGP6582 register  $r

$BGP6582 config-file $opt(dir)/bgpd6582.conf
$BGP6582 attach-node $node(6582)
$ns at 316 "$BGP6582 command \"show ip bgp\""

#puts "Creating Router 6583"
set node(6583) [$ns node]
set BGP6583 [new Application/Route/Bgp]
$BGP6583 register  $r

$BGP6583 config-file $opt(dir)/bgpd6583.conf
$BGP6583 attach-node $node(6583)
$ns at 316 "$BGP6583 command \"show ip bgp\""

#puts "Creating Router 6590"
set node(6590) [$ns node]
set BGP6590 [new Application/Route/Bgp]
$BGP6590 register  $r

$BGP6590 config-file $opt(dir)/bgpd6590.conf
$BGP6590 attach-node $node(6590)
$ns at 316 "$BGP6590 command \"show ip bgp\""

#puts "Creating Router 6597"
set node(6597) [$ns node]
set BGP6597 [new Application/Route/Bgp]
$BGP6597 register  $r

$BGP6597 config-file $opt(dir)/bgpd6597.conf
$BGP6597 attach-node $node(6597)
$ns at 316 "$BGP6597 command \"show ip bgp\""

#puts "Creating Router 6598"
set node(6598) [$ns node]
set BGP6598 [new Application/Route/Bgp]
$BGP6598 register  $r

$BGP6598 config-file $opt(dir)/bgpd6598.conf
$BGP6598 attach-node $node(6598)
$ns at 316 "$BGP6598 command \"show ip bgp\""

#puts "Creating Router 6602"
set node(6602) [$ns node]
set BGP6602 [new Application/Route/Bgp]
$BGP6602 register  $r

$BGP6602 config-file $opt(dir)/bgpd6602.conf
$BGP6602 attach-node $node(6602)
$ns at 316 "$BGP6602 command \"show ip bgp\""

#puts "Creating Router 6604"
set node(6604) [$ns node]
set BGP6604 [new Application/Route/Bgp]
$BGP6604 register  $r

$BGP6604 config-file $opt(dir)/bgpd6604.conf
$BGP6604 attach-node $node(6604)
$ns at 316 "$BGP6604 command \"show ip bgp\""

#puts "Creating Router 6618"
set node(6618) [$ns node]
set BGP6618 [new Application/Route/Bgp]
$BGP6618 register  $r

$BGP6618 config-file $opt(dir)/bgpd6618.conf
$BGP6618 attach-node $node(6618)
$ns at 316 "$BGP6618 command \"show ip bgp\""

#puts "Creating Router 6619"
set node(6619) [$ns node]
set BGP6619 [new Application/Route/Bgp]
$BGP6619 register  $r

$BGP6619 config-file $opt(dir)/bgpd6619.conf
$BGP6619 attach-node $node(6619)
$ns at 316 "$BGP6619 command \"show ip bgp\""

#puts "Creating Router 6620"
set node(6620) [$ns node]
set BGP6620 [new Application/Route/Bgp]
$BGP6620 register  $r

$BGP6620 config-file $opt(dir)/bgpd6620.conf
$BGP6620 attach-node $node(6620)
$ns at 316 "$BGP6620 command \"show ip bgp\""

#puts "Creating Router 6630"
set node(6630) [$ns node]
set BGP6630 [new Application/Route/Bgp]
$BGP6630 register  $r

$BGP6630 config-file $opt(dir)/bgpd6630.conf
$BGP6630 attach-node $node(6630)
$ns at 316 "$BGP6630 command \"show ip bgp\""

#puts "Creating Router 6633"
set node(6633) [$ns node]
set BGP6633 [new Application/Route/Bgp]
$BGP6633 register  $r

$BGP6633 config-file $opt(dir)/bgpd6633.conf
$BGP6633 attach-node $node(6633)
$ns at 316 "$BGP6633 command \"show ip bgp\""

#puts "Creating Router 6639"
set node(6639) [$ns node]
set BGP6639 [new Application/Route/Bgp]
$BGP6639 register  $r

$BGP6639 config-file $opt(dir)/bgpd6639.conf
$BGP6639 attach-node $node(6639)
$ns at 316 "$BGP6639 command \"show ip bgp\""

#puts "Creating Router 6648"
set node(6648) [$ns node]
set BGP6648 [new Application/Route/Bgp]
$BGP6648 register  $r

$BGP6648 config-file $opt(dir)/bgpd6648.conf
$BGP6648 attach-node $node(6648)
$ns at 316 "$BGP6648 command \"show ip bgp\""

#puts "Creating Router 6652"
set node(6652) [$ns node]
set BGP6652 [new Application/Route/Bgp]
$BGP6652 register  $r

$BGP6652 config-file $opt(dir)/bgpd6652.conf
$BGP6652 attach-node $node(6652)
$ns at 316 "$BGP6652 command \"show ip bgp\""

#puts "Creating Router 6656"
set node(6656) [$ns node]
set BGP6656 [new Application/Route/Bgp]
$BGP6656 register  $r

$BGP6656 config-file $opt(dir)/bgpd6656.conf
$BGP6656 attach-node $node(6656)
$ns at 316 "$BGP6656 command \"show ip bgp\""

#puts "Creating Router 6658"
set node(6658) [$ns node]
set BGP6658 [new Application/Route/Bgp]
$BGP6658 register  $r

$BGP6658 config-file $opt(dir)/bgpd6658.conf
$BGP6658 attach-node $node(6658)
$ns at 316 "$BGP6658 command \"show ip bgp\""

#puts "Creating Router 6660"
set node(6660) [$ns node]
set BGP6660 [new Application/Route/Bgp]
$BGP6660 register  $r

$BGP6660 config-file $opt(dir)/bgpd6660.conf
$BGP6660 attach-node $node(6660)
$ns at 316 "$BGP6660 command \"show ip bgp\""

#puts "Creating Router 6661"
set node(6661) [$ns node]
set BGP6661 [new Application/Route/Bgp]
$BGP6661 register  $r

$BGP6661 config-file $opt(dir)/bgpd6661.conf
$BGP6661 attach-node $node(6661)
$ns at 316 "$BGP6661 command \"show ip bgp\""

#puts "Creating Router 6662"
set node(6662) [$ns node]
set BGP6662 [new Application/Route/Bgp]
$BGP6662 register  $r

$BGP6662 config-file $opt(dir)/bgpd6662.conf
$BGP6662 attach-node $node(6662)
$ns at 316 "$BGP6662 command \"show ip bgp\""

#puts "Creating Router 6664"
set node(6664) [$ns node]
set BGP6664 [new Application/Route/Bgp]
$BGP6664 register  $r

$BGP6664 config-file $opt(dir)/bgpd6664.conf
$BGP6664 attach-node $node(6664)
$ns at 316 "$BGP6664 command \"show ip bgp\""

#puts "Creating Router 6665"
set node(6665) [$ns node]
set BGP6665 [new Application/Route/Bgp]
$BGP6665 register  $r

$BGP6665 config-file $opt(dir)/bgpd6665.conf
$BGP6665 attach-node $node(6665)
$ns at 316 "$BGP6665 command \"show ip bgp\""

#puts "Creating Router 6667"
set node(6667) [$ns node]
set BGP6667 [new Application/Route/Bgp]
$BGP6667 register  $r

$BGP6667 config-file $opt(dir)/bgpd6667.conf
$BGP6667 attach-node $node(6667)
$ns at 316 "$BGP6667 command \"show ip bgp\""

#puts "Creating Router 6668"
set node(6668) [$ns node]
set BGP6668 [new Application/Route/Bgp]
$BGP6668 register  $r

$BGP6668 config-file $opt(dir)/bgpd6668.conf
$BGP6668 attach-node $node(6668)
$ns at 316 "$BGP6668 command \"show ip bgp\""

#puts "Creating Router 6669"
set node(6669) [$ns node]
set BGP6669 [new Application/Route/Bgp]
$BGP6669 register  $r

$BGP6669 config-file $opt(dir)/bgpd6669.conf
$BGP6669 attach-node $node(6669)
$ns at 316 "$BGP6669 command \"show ip bgp\""

#puts "Creating Router 6670"
set node(6670) [$ns node]
set BGP6670 [new Application/Route/Bgp]
$BGP6670 register  $r

$BGP6670 config-file $opt(dir)/bgpd6670.conf
$BGP6670 attach-node $node(6670)
$ns at 316 "$BGP6670 command \"show ip bgp\""

#puts "Creating Router 6671"
set node(6671) [$ns node]
set BGP6671 [new Application/Route/Bgp]
$BGP6671 register  $r

$BGP6671 config-file $opt(dir)/bgpd6671.conf
$BGP6671 attach-node $node(6671)
$ns at 316 "$BGP6671 command \"show ip bgp\""

#puts "Creating Router 6676"
set node(6676) [$ns node]
set BGP6676 [new Application/Route/Bgp]
$BGP6676 register  $r

$BGP6676 config-file $opt(dir)/bgpd6676.conf
$BGP6676 attach-node $node(6676)
$ns at 316 "$BGP6676 command \"show ip bgp\""

#puts "Creating Router 6677"
set node(6677) [$ns node]
set BGP6677 [new Application/Route/Bgp]
$BGP6677 register  $r

$BGP6677 config-file $opt(dir)/bgpd6677.conf
$BGP6677 attach-node $node(6677)
$ns at 316 "$BGP6677 command \"show ip bgp\""

#puts "Creating Router 6678"
set node(6678) [$ns node]
set BGP6678 [new Application/Route/Bgp]
$BGP6678 register  $r

$BGP6678 config-file $opt(dir)/bgpd6678.conf
$BGP6678 attach-node $node(6678)
$ns at 316 "$BGP6678 command \"show ip bgp\""

#puts "Creating Router 6679"
set node(6679) [$ns node]
set BGP6679 [new Application/Route/Bgp]
$BGP6679 register  $r

$BGP6679 config-file $opt(dir)/bgpd6679.conf
$BGP6679 attach-node $node(6679)
$ns at 316 "$BGP6679 command \"show ip bgp\""

#puts "Creating Router 668"
set node(668) [$ns node]
set BGP668 [new Application/Route/Bgp]
$BGP668 register  $r

$BGP668 config-file $opt(dir)/bgpd668.conf
$BGP668 attach-node $node(668)
$ns at 316 "$BGP668 command \"show ip bgp\""

#puts "Creating Router 6680"
set node(6680) [$ns node]
set BGP6680 [new Application/Route/Bgp]
$BGP6680 register  $r

$BGP6680 config-file $opt(dir)/bgpd6680.conf
$BGP6680 attach-node $node(6680)
$ns at 316 "$BGP6680 command \"show ip bgp\""

#puts "Creating Router 6681"
set node(6681) [$ns node]
set BGP6681 [new Application/Route/Bgp]
$BGP6681 register  $r

$BGP6681 config-file $opt(dir)/bgpd6681.conf
$BGP6681 attach-node $node(6681)
$ns at 316 "$BGP6681 command \"show ip bgp\""

#puts "Creating Router 6682"
set node(6682) [$ns node]
set BGP6682 [new Application/Route/Bgp]
$BGP6682 register  $r

$BGP6682 config-file $opt(dir)/bgpd6682.conf
$BGP6682 attach-node $node(6682)
$ns at 316 "$BGP6682 command \"show ip bgp\""

#puts "Creating Router 6683"
set node(6683) [$ns node]
set BGP6683 [new Application/Route/Bgp]
$BGP6683 register  $r

$BGP6683 config-file $opt(dir)/bgpd6683.conf
$BGP6683 attach-node $node(6683)
$ns at 316 "$BGP6683 command \"show ip bgp\""

#puts "Creating Router 6684"
set node(6684) [$ns node]
set BGP6684 [new Application/Route/Bgp]
$BGP6684 register  $r

$BGP6684 config-file $opt(dir)/bgpd6684.conf
$BGP6684 attach-node $node(6684)
$ns at 316 "$BGP6684 command \"show ip bgp\""

#puts "Creating Router 6685"
set node(6685) [$ns node]
set BGP6685 [new Application/Route/Bgp]
$BGP6685 register  $r

$BGP6685 config-file $opt(dir)/bgpd6685.conf
$BGP6685 attach-node $node(6685)
$ns at 316 "$BGP6685 command \"show ip bgp\""

#puts "Creating Router 6686"
set node(6686) [$ns node]
set BGP6686 [new Application/Route/Bgp]
$BGP6686 register  $r

$BGP6686 config-file $opt(dir)/bgpd6686.conf
$BGP6686 attach-node $node(6686)
$ns at 316 "$BGP6686 command \"show ip bgp\""

#puts "Creating Router 6687"
set node(6687) [$ns node]
set BGP6687 [new Application/Route/Bgp]
$BGP6687 register  $r

$BGP6687 config-file $opt(dir)/bgpd6687.conf
$BGP6687 attach-node $node(6687)
$ns at 316 "$BGP6687 command \"show ip bgp\""

#puts "Creating Router 6688"
set node(6688) [$ns node]
set BGP6688 [new Application/Route/Bgp]
$BGP6688 register  $r

$BGP6688 config-file $opt(dir)/bgpd6688.conf
$BGP6688 attach-node $node(6688)
$ns at 316 "$BGP6688 command \"show ip bgp\""

#puts "Creating Router 6689"
set node(6689) [$ns node]
set BGP6689 [new Application/Route/Bgp]
$BGP6689 register  $r

$BGP6689 config-file $opt(dir)/bgpd6689.conf
$BGP6689 attach-node $node(6689)
$ns at 316 "$BGP6689 command \"show ip bgp\""

#puts "Creating Router 6690"
set node(6690) [$ns node]
set BGP6690 [new Application/Route/Bgp]
$BGP6690 register  $r

$BGP6690 config-file $opt(dir)/bgpd6690.conf
$BGP6690 attach-node $node(6690)
$ns at 316 "$BGP6690 command \"show ip bgp\""

#puts "Creating Router 6691"
set node(6691) [$ns node]
set BGP6691 [new Application/Route/Bgp]
$BGP6691 register  $r

$BGP6691 config-file $opt(dir)/bgpd6691.conf
$BGP6691 attach-node $node(6691)
$ns at 316 "$BGP6691 command \"show ip bgp\""

#puts "Creating Router 6697"
set node(6697) [$ns node]
set BGP6697 [new Application/Route/Bgp]
$BGP6697 register  $r

$BGP6697 config-file $opt(dir)/bgpd6697.conf
$BGP6697 attach-node $node(6697)
$ns at 316 "$BGP6697 command \"show ip bgp\""

#puts "Creating Router 6703"
set node(6703) [$ns node]
set BGP6703 [new Application/Route/Bgp]
$BGP6703 register  $r

$BGP6703 config-file $opt(dir)/bgpd6703.conf
$BGP6703 attach-node $node(6703)
$ns at 316 "$BGP6703 command \"show ip bgp\""

#puts "Creating Router 6706"
set node(6706) [$ns node]
set BGP6706 [new Application/Route/Bgp]
$BGP6706 register  $r

$BGP6706 config-file $opt(dir)/bgpd6706.conf
$BGP6706 attach-node $node(6706)
$ns at 316 "$BGP6706 command \"show ip bgp\""

#puts "Creating Router 6708"
set node(6708) [$ns node]
set BGP6708 [new Application/Route/Bgp]
$BGP6708 register  $r

$BGP6708 config-file $opt(dir)/bgpd6708.conf
$BGP6708 attach-node $node(6708)
$ns at 316 "$BGP6708 command \"show ip bgp\""

#puts "Creating Router 6713"
set node(6713) [$ns node]
set BGP6713 [new Application/Route/Bgp]
$BGP6713 register  $r

$BGP6713 config-file $opt(dir)/bgpd6713.conf
$BGP6713 attach-node $node(6713)
$ns at 316 "$BGP6713 command \"show ip bgp\""

#puts "Creating Router 6714"
set node(6714) [$ns node]
set BGP6714 [new Application/Route/Bgp]
$BGP6714 register  $r

$BGP6714 config-file $opt(dir)/bgpd6714.conf
$BGP6714 attach-node $node(6714)
$ns at 316 "$BGP6714 command \"show ip bgp\""

#puts "Creating Router 6715"
set node(6715) [$ns node]
set BGP6715 [new Application/Route/Bgp]
$BGP6715 register  $r

$BGP6715 config-file $opt(dir)/bgpd6715.conf
$BGP6715 attach-node $node(6715)
$ns at 316 "$BGP6715 command \"show ip bgp\""

#puts "Creating Router 6716"
set node(6716) [$ns node]
set BGP6716 [new Application/Route/Bgp]
$BGP6716 register  $r

$BGP6716 config-file $opt(dir)/bgpd6716.conf
$BGP6716 attach-node $node(6716)
$ns at 316 "$BGP6716 command \"show ip bgp\""

#puts "Creating Router 6717"
set node(6717) [$ns node]
set BGP6717 [new Application/Route/Bgp]
$BGP6717 register  $r

$BGP6717 config-file $opt(dir)/bgpd6717.conf
$BGP6717 attach-node $node(6717)
$ns at 316 "$BGP6717 command \"show ip bgp\""

#puts "Creating Router 6718"
set node(6718) [$ns node]
set BGP6718 [new Application/Route/Bgp]
$BGP6718 register  $r

$BGP6718 config-file $opt(dir)/bgpd6718.conf
$BGP6718 attach-node $node(6718)
$ns at 316 "$BGP6718 command \"show ip bgp\""

#puts "Creating Router 6719"
set node(6719) [$ns node]
set BGP6719 [new Application/Route/Bgp]
$BGP6719 register  $r

$BGP6719 config-file $opt(dir)/bgpd6719.conf
$BGP6719 attach-node $node(6719)
$ns at 316 "$BGP6719 command \"show ip bgp\""

#puts "Creating Router 6722"
set node(6722) [$ns node]
set BGP6722 [new Application/Route/Bgp]
$BGP6722 register  $r

$BGP6722 config-file $opt(dir)/bgpd6722.conf
$BGP6722 attach-node $node(6722)
$ns at 316 "$BGP6722 command \"show ip bgp\""

#puts "Creating Router 6726"
set node(6726) [$ns node]
set BGP6726 [new Application/Route/Bgp]
$BGP6726 register  $r

$BGP6726 config-file $opt(dir)/bgpd6726.conf
$BGP6726 attach-node $node(6726)
$ns at 316 "$BGP6726 command \"show ip bgp\""

#puts "Creating Router 6727"
set node(6727) [$ns node]
set BGP6727 [new Application/Route/Bgp]
$BGP6727 register  $r

$BGP6727 config-file $opt(dir)/bgpd6727.conf
$BGP6727 attach-node $node(6727)
$ns at 316 "$BGP6727 command \"show ip bgp\""

#puts "Creating Router 6728"
set node(6728) [$ns node]
set BGP6728 [new Application/Route/Bgp]
$BGP6728 register  $r

$BGP6728 config-file $opt(dir)/bgpd6728.conf
$BGP6728 attach-node $node(6728)
$ns at 316 "$BGP6728 command \"show ip bgp\""

#puts "Creating Router 6730"
set node(6730) [$ns node]
set BGP6730 [new Application/Route/Bgp]
$BGP6730 register  $r

$BGP6730 config-file $opt(dir)/bgpd6730.conf
$BGP6730 attach-node $node(6730)
$ns at 316 "$BGP6730 command \"show ip bgp\""

#puts "Creating Router 6731"
set node(6731) [$ns node]
set BGP6731 [new Application/Route/Bgp]
$BGP6731 register  $r

$BGP6731 config-file $opt(dir)/bgpd6731.conf
$BGP6731 attach-node $node(6731)
$ns at 316 "$BGP6731 command \"show ip bgp\""

#puts "Creating Router 6732"
set node(6732) [$ns node]
set BGP6732 [new Application/Route/Bgp]
$BGP6732 register  $r

$BGP6732 config-file $opt(dir)/bgpd6732.conf
$BGP6732 attach-node $node(6732)
$ns at 316 "$BGP6732 command \"show ip bgp\""

#puts "Creating Router 6734"
set node(6734) [$ns node]
set BGP6734 [new Application/Route/Bgp]
$BGP6734 register  $r

$BGP6734 config-file $opt(dir)/bgpd6734.conf
$BGP6734 attach-node $node(6734)
$ns at 316 "$BGP6734 command \"show ip bgp\""

#puts "Creating Router 6735"
set node(6735) [$ns node]
set BGP6735 [new Application/Route/Bgp]
$BGP6735 register  $r

$BGP6735 config-file $opt(dir)/bgpd6735.conf
$BGP6735 attach-node $node(6735)
$ns at 316 "$BGP6735 command \"show ip bgp\""

#puts "Creating Router 6737"
set node(6737) [$ns node]
set BGP6737 [new Application/Route/Bgp]
$BGP6737 register  $r

$BGP6737 config-file $opt(dir)/bgpd6737.conf
$BGP6737 attach-node $node(6737)
$ns at 316 "$BGP6737 command \"show ip bgp\""

#puts "Creating Router 6740"
set node(6740) [$ns node]
set BGP6740 [new Application/Route/Bgp]
$BGP6740 register  $r

$BGP6740 config-file $opt(dir)/bgpd6740.conf
$BGP6740 attach-node $node(6740)
$ns at 316 "$BGP6740 command \"show ip bgp\""

#puts "Creating Router 6742"
set node(6742) [$ns node]
set BGP6742 [new Application/Route/Bgp]
$BGP6742 register  $r

$BGP6742 config-file $opt(dir)/bgpd6742.conf
$BGP6742 attach-node $node(6742)
$ns at 316 "$BGP6742 command \"show ip bgp\""

#puts "Creating Router 6744"
set node(6744) [$ns node]
set BGP6744 [new Application/Route/Bgp]
$BGP6744 register  $r

$BGP6744 config-file $opt(dir)/bgpd6744.conf
$BGP6744 attach-node $node(6744)
$ns at 316 "$BGP6744 command \"show ip bgp\""

#puts "Creating Router 6745"
set node(6745) [$ns node]
set BGP6745 [new Application/Route/Bgp]
$BGP6745 register  $r

$BGP6745 config-file $opt(dir)/bgpd6745.conf
$BGP6745 attach-node $node(6745)
$ns at 316 "$BGP6745 command \"show ip bgp\""

#puts "Creating Router 6746"
set node(6746) [$ns node]
set BGP6746 [new Application/Route/Bgp]
$BGP6746 register  $r

$BGP6746 config-file $opt(dir)/bgpd6746.conf
$BGP6746 attach-node $node(6746)
$ns at 316 "$BGP6746 command \"show ip bgp\""

#puts "Creating Router 6750"
set node(6750) [$ns node]
set BGP6750 [new Application/Route/Bgp]
$BGP6750 register  $r

$BGP6750 config-file $opt(dir)/bgpd6750.conf
$BGP6750 attach-node $node(6750)
$ns at 316 "$BGP6750 command \"show ip bgp\""

#puts "Creating Router 6751"
set node(6751) [$ns node]
set BGP6751 [new Application/Route/Bgp]
$BGP6751 register  $r

$BGP6751 config-file $opt(dir)/bgpd6751.conf
$BGP6751 attach-node $node(6751)
$ns at 316 "$BGP6751 command \"show ip bgp\""

#puts "Creating Router 6752"
set node(6752) [$ns node]
set BGP6752 [new Application/Route/Bgp]
$BGP6752 register  $r

$BGP6752 config-file $opt(dir)/bgpd6752.conf
$BGP6752 attach-node $node(6752)
$ns at 316 "$BGP6752 command \"show ip bgp\""

#puts "Creating Router 6753"
set node(6753) [$ns node]
set BGP6753 [new Application/Route/Bgp]
$BGP6753 register  $r

$BGP6753 config-file $opt(dir)/bgpd6753.conf
$BGP6753 attach-node $node(6753)
$ns at 316 "$BGP6753 command \"show ip bgp\""

#puts "Creating Router 6754"
set node(6754) [$ns node]
set BGP6754 [new Application/Route/Bgp]
$BGP6754 register  $r

$BGP6754 config-file $opt(dir)/bgpd6754.conf
$BGP6754 attach-node $node(6754)
$ns at 316 "$BGP6754 command \"show ip bgp\""

#puts "Creating Router 6756"
set node(6756) [$ns node]
set BGP6756 [new Application/Route/Bgp]
$BGP6756 register  $r

$BGP6756 config-file $opt(dir)/bgpd6756.conf
$BGP6756 attach-node $node(6756)
$ns at 316 "$BGP6756 command \"show ip bgp\""

#puts "Creating Router 6757"
set node(6757) [$ns node]
set BGP6757 [new Application/Route/Bgp]
$BGP6757 register  $r

$BGP6757 config-file $opt(dir)/bgpd6757.conf
$BGP6757 attach-node $node(6757)
$ns at 316 "$BGP6757 command \"show ip bgp\""

#puts "Creating Router 6760"
set node(6760) [$ns node]
set BGP6760 [new Application/Route/Bgp]
$BGP6760 register  $r

$BGP6760 config-file $opt(dir)/bgpd6760.conf
$BGP6760 attach-node $node(6760)
$ns at 316 "$BGP6760 command \"show ip bgp\""

#puts "Creating Router 6761"
set node(6761) [$ns node]
set BGP6761 [new Application/Route/Bgp]
$BGP6761 register  $r

$BGP6761 config-file $opt(dir)/bgpd6761.conf
$BGP6761 attach-node $node(6761)
$ns at 316 "$BGP6761 command \"show ip bgp\""

#puts "Creating Router 6762"
set node(6762) [$ns node]
set BGP6762 [new Application/Route/Bgp]
$BGP6762 register  $r

$BGP6762 config-file $opt(dir)/bgpd6762.conf
$BGP6762 attach-node $node(6762)
$ns at 316 "$BGP6762 command \"show ip bgp\""

#puts "Creating Router 6763"
set node(6763) [$ns node]
set BGP6763 [new Application/Route/Bgp]
$BGP6763 register  $r

$BGP6763 config-file $opt(dir)/bgpd6763.conf
$BGP6763 attach-node $node(6763)
$ns at 316 "$BGP6763 command \"show ip bgp\""

#puts "Creating Router 6764"
set node(6764) [$ns node]
set BGP6764 [new Application/Route/Bgp]
$BGP6764 register  $r

$BGP6764 config-file $opt(dir)/bgpd6764.conf
$BGP6764 attach-node $node(6764)
$ns at 316 "$BGP6764 command \"show ip bgp\""

#puts "Creating Router 6765"
set node(6765) [$ns node]
set BGP6765 [new Application/Route/Bgp]
$BGP6765 register  $r

$BGP6765 config-file $opt(dir)/bgpd6765.conf
$BGP6765 attach-node $node(6765)
$ns at 316 "$BGP6765 command \"show ip bgp\""

#puts "Creating Router 6769"
set node(6769) [$ns node]
set BGP6769 [new Application/Route/Bgp]
$BGP6769 register  $r

$BGP6769 config-file $opt(dir)/bgpd6769.conf
$BGP6769 attach-node $node(6769)
$ns at 316 "$BGP6769 command \"show ip bgp\""

#puts "Creating Router 6770"
set node(6770) [$ns node]
set BGP6770 [new Application/Route/Bgp]
$BGP6770 register  $r

$BGP6770 config-file $opt(dir)/bgpd6770.conf
$BGP6770 attach-node $node(6770)
$ns at 316 "$BGP6770 command \"show ip bgp\""

#puts "Creating Router 6771"
set node(6771) [$ns node]
set BGP6771 [new Application/Route/Bgp]
$BGP6771 register  $r

$BGP6771 config-file $opt(dir)/bgpd6771.conf
$BGP6771 attach-node $node(6771)
$ns at 316 "$BGP6771 command \"show ip bgp\""

#puts "Creating Router 6772"
set node(6772) [$ns node]
set BGP6772 [new Application/Route/Bgp]
$BGP6772 register  $r

$BGP6772 config-file $opt(dir)/bgpd6772.conf
$BGP6772 attach-node $node(6772)
$ns at 316 "$BGP6772 command \"show ip bgp\""

#puts "Creating Router 6774"
set node(6774) [$ns node]
set BGP6774 [new Application/Route/Bgp]
$BGP6774 register  $r

$BGP6774 config-file $opt(dir)/bgpd6774.conf
$BGP6774 attach-node $node(6774)
$ns at 316 "$BGP6774 command \"show ip bgp\""

#puts "Creating Router 6776"
set node(6776) [$ns node]
set BGP6776 [new Application/Route/Bgp]
$BGP6776 register  $r

$BGP6776 config-file $opt(dir)/bgpd6776.conf
$BGP6776 attach-node $node(6776)
$ns at 316 "$BGP6776 command \"show ip bgp\""

#puts "Creating Router 6778"
set node(6778) [$ns node]
set BGP6778 [new Application/Route/Bgp]
$BGP6778 register  $r

$BGP6778 config-file $opt(dir)/bgpd6778.conf
$BGP6778 attach-node $node(6778)
$ns at 316 "$BGP6778 command \"show ip bgp\""

#puts "Creating Router 6783"
set node(6783) [$ns node]
set BGP6783 [new Application/Route/Bgp]
$BGP6783 register  $r

$BGP6783 config-file $opt(dir)/bgpd6783.conf
$BGP6783 attach-node $node(6783)
$ns at 316 "$BGP6783 command \"show ip bgp\""

#puts "Creating Router 6784"
set node(6784) [$ns node]
set BGP6784 [new Application/Route/Bgp]
$BGP6784 register  $r

$BGP6784 config-file $opt(dir)/bgpd6784.conf
$BGP6784 attach-node $node(6784)
$ns at 316 "$BGP6784 command \"show ip bgp\""

#puts "Creating Router 6785"
set node(6785) [$ns node]
set BGP6785 [new Application/Route/Bgp]
$BGP6785 register  $r

$BGP6785 config-file $opt(dir)/bgpd6785.conf
$BGP6785 attach-node $node(6785)
$ns at 316 "$BGP6785 command \"show ip bgp\""

#puts "Creating Router 6787"
set node(6787) [$ns node]
set BGP6787 [new Application/Route/Bgp]
$BGP6787 register  $r

$BGP6787 config-file $opt(dir)/bgpd6787.conf
$BGP6787 attach-node $node(6787)
$ns at 316 "$BGP6787 command \"show ip bgp\""

#puts "Creating Router 6792"
set node(6792) [$ns node]
set BGP6792 [new Application/Route/Bgp]
$BGP6792 register  $r

$BGP6792 config-file $opt(dir)/bgpd6792.conf
$BGP6792 attach-node $node(6792)
$ns at 316 "$BGP6792 command \"show ip bgp\""

#puts "Creating Router 6793"
set node(6793) [$ns node]
set BGP6793 [new Application/Route/Bgp]
$BGP6793 register  $r

$BGP6793 config-file $opt(dir)/bgpd6793.conf
$BGP6793 attach-node $node(6793)
$ns at 316 "$BGP6793 command \"show ip bgp\""

#puts "Creating Router 6795"
set node(6795) [$ns node]
set BGP6795 [new Application/Route/Bgp]
$BGP6795 register  $r

$BGP6795 config-file $opt(dir)/bgpd6795.conf
$BGP6795 attach-node $node(6795)
$ns at 316 "$BGP6795 command \"show ip bgp\""

#puts "Creating Router 6798"
set node(6798) [$ns node]
set BGP6798 [new Application/Route/Bgp]
$BGP6798 register  $r

$BGP6798 config-file $opt(dir)/bgpd6798.conf
$BGP6798 attach-node $node(6798)
$ns at 316 "$BGP6798 command \"show ip bgp\""

#puts "Creating Router 6799"
set node(6799) [$ns node]
set BGP6799 [new Application/Route/Bgp]
$BGP6799 register  $r

$BGP6799 config-file $opt(dir)/bgpd6799.conf
$BGP6799 attach-node $node(6799)
$ns at 316 "$BGP6799 command \"show ip bgp\""

#puts "Creating Router 6803"
set node(6803) [$ns node]
set BGP6803 [new Application/Route/Bgp]
$BGP6803 register  $r

$BGP6803 config-file $opt(dir)/bgpd6803.conf
$BGP6803 attach-node $node(6803)
$ns at 316 "$BGP6803 command \"show ip bgp\""

#puts "Creating Router 6805"
set node(6805) [$ns node]
set BGP6805 [new Application/Route/Bgp]
$BGP6805 register  $r

$BGP6805 config-file $opt(dir)/bgpd6805.conf
$BGP6805 attach-node $node(6805)
$ns at 316 "$BGP6805 command \"show ip bgp\""

#puts "Creating Router 6806"
set node(6806) [$ns node]
set BGP6806 [new Application/Route/Bgp]
$BGP6806 register  $r

$BGP6806 config-file $opt(dir)/bgpd6806.conf
$BGP6806 attach-node $node(6806)
$ns at 316 "$BGP6806 command \"show ip bgp\""

#puts "Creating Router 6809"
set node(6809) [$ns node]
set BGP6809 [new Application/Route/Bgp]
$BGP6809 register  $r

$BGP6809 config-file $opt(dir)/bgpd6809.conf
$BGP6809 attach-node $node(6809)
$ns at 316 "$BGP6809 command \"show ip bgp\""

#puts "Creating Router 681"
set node(681) [$ns node]
set BGP681 [new Application/Route/Bgp]
$BGP681 register  $r

$BGP681 config-file $opt(dir)/bgpd681.conf
$BGP681 attach-node $node(681)
$ns at 316 "$BGP681 command \"show ip bgp\""

#puts "Creating Router 6813"
set node(6813) [$ns node]
set BGP6813 [new Application/Route/Bgp]
$BGP6813 register  $r

$BGP6813 config-file $opt(dir)/bgpd6813.conf
$BGP6813 attach-node $node(6813)
$ns at 316 "$BGP6813 command \"show ip bgp\""

#puts "Creating Router 6820"
set node(6820) [$ns node]
set BGP6820 [new Application/Route/Bgp]
$BGP6820 register  $r

$BGP6820 config-file $opt(dir)/bgpd6820.conf
$BGP6820 attach-node $node(6820)
$ns at 316 "$BGP6820 command \"show ip bgp\""

#puts "Creating Router 6821"
set node(6821) [$ns node]
set BGP6821 [new Application/Route/Bgp]
$BGP6821 register  $r

$BGP6821 config-file $opt(dir)/bgpd6821.conf
$BGP6821 attach-node $node(6821)
$ns at 316 "$BGP6821 command \"show ip bgp\""

#puts "Creating Router 6823"
set node(6823) [$ns node]
set BGP6823 [new Application/Route/Bgp]
$BGP6823 register  $r

$BGP6823 config-file $opt(dir)/bgpd6823.conf
$BGP6823 attach-node $node(6823)
$ns at 316 "$BGP6823 command \"show ip bgp\""

#puts "Creating Router 6827"
set node(6827) [$ns node]
set BGP6827 [new Application/Route/Bgp]
$BGP6827 register  $r

$BGP6827 config-file $opt(dir)/bgpd6827.conf
$BGP6827 attach-node $node(6827)
$ns at 316 "$BGP6827 command \"show ip bgp\""

#puts "Creating Router 6829"
set node(6829) [$ns node]
set BGP6829 [new Application/Route/Bgp]
$BGP6829 register  $r

$BGP6829 config-file $opt(dir)/bgpd6829.conf
$BGP6829 attach-node $node(6829)
$ns at 316 "$BGP6829 command \"show ip bgp\""

#puts "Creating Router 683"
set node(683) [$ns node]
set BGP683 [new Application/Route/Bgp]
$BGP683 register  $r

$BGP683 config-file $opt(dir)/bgpd683.conf
$BGP683 attach-node $node(683)
$ns at 316 "$BGP683 command \"show ip bgp\""

#puts "Creating Router 6830"
set node(6830) [$ns node]
set BGP6830 [new Application/Route/Bgp]
$BGP6830 register  $r

$BGP6830 config-file $opt(dir)/bgpd6830.conf
$BGP6830 attach-node $node(6830)
$ns at 316 "$BGP6830 command \"show ip bgp\""

#puts "Creating Router 6841"
set node(6841) [$ns node]
set BGP6841 [new Application/Route/Bgp]
$BGP6841 register  $r

$BGP6841 config-file $opt(dir)/bgpd6841.conf
$BGP6841 attach-node $node(6841)
$ns at 316 "$BGP6841 command \"show ip bgp\""

#puts "Creating Router 6844"
set node(6844) [$ns node]
set BGP6844 [new Application/Route/Bgp]
$BGP6844 register  $r

$BGP6844 config-file $opt(dir)/bgpd6844.conf
$BGP6844 attach-node $node(6844)
$ns at 316 "$BGP6844 command \"show ip bgp\""

#puts "Creating Router 6845"
set node(6845) [$ns node]
set BGP6845 [new Application/Route/Bgp]
$BGP6845 register  $r

$BGP6845 config-file $opt(dir)/bgpd6845.conf
$BGP6845 attach-node $node(6845)
$ns at 316 "$BGP6845 command \"show ip bgp\""

#puts "Creating Router 6846"
set node(6846) [$ns node]
set BGP6846 [new Application/Route/Bgp]
$BGP6846 register  $r

$BGP6846 config-file $opt(dir)/bgpd6846.conf
$BGP6846 attach-node $node(6846)
$ns at 316 "$BGP6846 command \"show ip bgp\""

#puts "Creating Router 6847"
set node(6847) [$ns node]
set BGP6847 [new Application/Route/Bgp]
$BGP6847 register  $r

$BGP6847 config-file $opt(dir)/bgpd6847.conf
$BGP6847 attach-node $node(6847)
$ns at 316 "$BGP6847 command \"show ip bgp\""

#puts "Creating Router 6848"
set node(6848) [$ns node]
set BGP6848 [new Application/Route/Bgp]
$BGP6848 register  $r

$BGP6848 config-file $opt(dir)/bgpd6848.conf
$BGP6848 attach-node $node(6848)
$ns at 316 "$BGP6848 command \"show ip bgp\""

#puts "Creating Router 6849"
set node(6849) [$ns node]
set BGP6849 [new Application/Route/Bgp]
$BGP6849 register  $r

$BGP6849 config-file $opt(dir)/bgpd6849.conf
$BGP6849 attach-node $node(6849)
$ns at 316 "$BGP6849 command \"show ip bgp\""

#puts "Creating Router 685"
set node(685) [$ns node]
set BGP685 [new Application/Route/Bgp]
$BGP685 register  $r

$BGP685 config-file $opt(dir)/bgpd685.conf
$BGP685 attach-node $node(685)
$ns at 316 "$BGP685 command \"show ip bgp\""

#puts "Creating Router 6850"
set node(6850) [$ns node]
set BGP6850 [new Application/Route/Bgp]
$BGP6850 register  $r

$BGP6850 config-file $opt(dir)/bgpd6850.conf
$BGP6850 attach-node $node(6850)
$ns at 316 "$BGP6850 command \"show ip bgp\""

#puts "Creating Router 6852"
set node(6852) [$ns node]
set BGP6852 [new Application/Route/Bgp]
$BGP6852 register  $r

$BGP6852 config-file $opt(dir)/bgpd6852.conf
$BGP6852 attach-node $node(6852)
$ns at 316 "$BGP6852 command \"show ip bgp\""

#puts "Creating Router 6853"
set node(6853) [$ns node]
set BGP6853 [new Application/Route/Bgp]
$BGP6853 register  $r

$BGP6853 config-file $opt(dir)/bgpd6853.conf
$BGP6853 attach-node $node(6853)
$ns at 316 "$BGP6853 command \"show ip bgp\""

#puts "Creating Router 6854"
set node(6854) [$ns node]
set BGP6854 [new Application/Route/Bgp]
$BGP6854 register  $r

$BGP6854 config-file $opt(dir)/bgpd6854.conf
$BGP6854 attach-node $node(6854)
$ns at 316 "$BGP6854 command \"show ip bgp\""

#puts "Creating Router 6855"
set node(6855) [$ns node]
set BGP6855 [new Application/Route/Bgp]
$BGP6855 register  $r

$BGP6855 config-file $opt(dir)/bgpd6855.conf
$BGP6855 attach-node $node(6855)
$ns at 316 "$BGP6855 command \"show ip bgp\""

#puts "Creating Router 6858"
set node(6858) [$ns node]
set BGP6858 [new Application/Route/Bgp]
$BGP6858 register  $r

$BGP6858 config-file $opt(dir)/bgpd6858.conf
$BGP6858 attach-node $node(6858)
$ns at 316 "$BGP6858 command \"show ip bgp\""

#puts "Creating Router 6859"
set node(6859) [$ns node]
set BGP6859 [new Application/Route/Bgp]
$BGP6859 register  $r

$BGP6859 config-file $opt(dir)/bgpd6859.conf
$BGP6859 attach-node $node(6859)
$ns at 316 "$BGP6859 command \"show ip bgp\""

#puts "Creating Router 6863"
set node(6863) [$ns node]
set BGP6863 [new Application/Route/Bgp]
$BGP6863 register  $r

$BGP6863 config-file $opt(dir)/bgpd6863.conf
$BGP6863 attach-node $node(6863)
$ns at 316 "$BGP6863 command \"show ip bgp\""

#puts "Creating Router 6864"
set node(6864) [$ns node]
set BGP6864 [new Application/Route/Bgp]
$BGP6864 register  $r

$BGP6864 config-file $opt(dir)/bgpd6864.conf
$BGP6864 attach-node $node(6864)
$ns at 316 "$BGP6864 command \"show ip bgp\""

#puts "Creating Router 6866"
set node(6866) [$ns node]
set BGP6866 [new Application/Route/Bgp]
$BGP6866 register  $r

$BGP6866 config-file $opt(dir)/bgpd6866.conf
$BGP6866 attach-node $node(6866)
$ns at 316 "$BGP6866 command \"show ip bgp\""

#puts "Creating Router 6867"
set node(6867) [$ns node]
set BGP6867 [new Application/Route/Bgp]
$BGP6867 register  $r

$BGP6867 config-file $opt(dir)/bgpd6867.conf
$BGP6867 attach-node $node(6867)
$ns at 316 "$BGP6867 command \"show ip bgp\""

#puts "Creating Router 6868"
set node(6868) [$ns node]
set BGP6868 [new Application/Route/Bgp]
$BGP6868 register  $r

$BGP6868 config-file $opt(dir)/bgpd6868.conf
$BGP6868 attach-node $node(6868)
$ns at 316 "$BGP6868 command \"show ip bgp\""

#puts "Creating Router 687"
set node(687) [$ns node]
set BGP687 [new Application/Route/Bgp]
$BGP687 register  $r

$BGP687 config-file $opt(dir)/bgpd687.conf
$BGP687 attach-node $node(687)
$ns at 316 "$BGP687 command \"show ip bgp\""

#puts "Creating Router 6870"
set node(6870) [$ns node]
set BGP6870 [new Application/Route/Bgp]
$BGP6870 register  $r

$BGP6870 config-file $opt(dir)/bgpd6870.conf
$BGP6870 attach-node $node(6870)
$ns at 316 "$BGP6870 command \"show ip bgp\""

#puts "Creating Router 6871"
set node(6871) [$ns node]
set BGP6871 [new Application/Route/Bgp]
$BGP6871 register  $r

$BGP6871 config-file $opt(dir)/bgpd6871.conf
$BGP6871 attach-node $node(6871)
$ns at 316 "$BGP6871 command \"show ip bgp\""

#puts "Creating Router 6873"
set node(6873) [$ns node]
set BGP6873 [new Application/Route/Bgp]
$BGP6873 register  $r

$BGP6873 config-file $opt(dir)/bgpd6873.conf
$BGP6873 attach-node $node(6873)
$ns at 316 "$BGP6873 command \"show ip bgp\""

#puts "Creating Router 6876"
set node(6876) [$ns node]
set BGP6876 [new Application/Route/Bgp]
$BGP6876 register  $r

$BGP6876 config-file $opt(dir)/bgpd6876.conf
$BGP6876 attach-node $node(6876)
$ns at 316 "$BGP6876 command \"show ip bgp\""

#puts "Creating Router 6878"
set node(6878) [$ns node]
set BGP6878 [new Application/Route/Bgp]
$BGP6878 register  $r

$BGP6878 config-file $opt(dir)/bgpd6878.conf
$BGP6878 attach-node $node(6878)
$ns at 316 "$BGP6878 command \"show ip bgp\""

#puts "Creating Router 6880"
set node(6880) [$ns node]
set BGP6880 [new Application/Route/Bgp]
$BGP6880 register  $r

$BGP6880 config-file $opt(dir)/bgpd6880.conf
$BGP6880 attach-node $node(6880)
$ns at 316 "$BGP6880 command \"show ip bgp\""

#puts "Creating Router 6881"
set node(6881) [$ns node]
set BGP6881 [new Application/Route/Bgp]
$BGP6881 register  $r

$BGP6881 config-file $opt(dir)/bgpd6881.conf
$BGP6881 attach-node $node(6881)
$ns at 316 "$BGP6881 command \"show ip bgp\""

#puts "Creating Router 6882"
set node(6882) [$ns node]
set BGP6882 [new Application/Route/Bgp]
$BGP6882 register  $r

$BGP6882 config-file $opt(dir)/bgpd6882.conf
$BGP6882 attach-node $node(6882)
$ns at 316 "$BGP6882 command \"show ip bgp\""

#puts "Creating Router 6883"
set node(6883) [$ns node]
set BGP6883 [new Application/Route/Bgp]
$BGP6883 register  $r

$BGP6883 config-file $opt(dir)/bgpd6883.conf
$BGP6883 attach-node $node(6883)
$ns at 316 "$BGP6883 command \"show ip bgp\""

#puts "Creating Router 6884"
set node(6884) [$ns node]
set BGP6884 [new Application/Route/Bgp]
$BGP6884 register  $r

$BGP6884 config-file $opt(dir)/bgpd6884.conf
$BGP6884 attach-node $node(6884)
$ns at 316 "$BGP6884 command \"show ip bgp\""

#puts "Creating Router 6886"
set node(6886) [$ns node]
set BGP6886 [new Application/Route/Bgp]
$BGP6886 register  $r

$BGP6886 config-file $opt(dir)/bgpd6886.conf
$BGP6886 attach-node $node(6886)
$ns at 316 "$BGP6886 command \"show ip bgp\""

#puts "Creating Router 6887"
set node(6887) [$ns node]
set BGP6887 [new Application/Route/Bgp]
$BGP6887 register  $r

$BGP6887 config-file $opt(dir)/bgpd6887.conf
$BGP6887 attach-node $node(6887)
$ns at 316 "$BGP6887 command \"show ip bgp\""

#puts "Creating Router 6888"
set node(6888) [$ns node]
set BGP6888 [new Application/Route/Bgp]
$BGP6888 register  $r

$BGP6888 config-file $opt(dir)/bgpd6888.conf
$BGP6888 attach-node $node(6888)
$ns at 316 "$BGP6888 command \"show ip bgp\""

#puts "Creating Router 6889"
set node(6889) [$ns node]
set BGP6889 [new Application/Route/Bgp]
$BGP6889 register  $r

$BGP6889 config-file $opt(dir)/bgpd6889.conf
$BGP6889 attach-node $node(6889)
$ns at 316 "$BGP6889 command \"show ip bgp\""

#puts "Creating Router 6893"
set node(6893) [$ns node]
set BGP6893 [new Application/Route/Bgp]
$BGP6893 register  $r

$BGP6893 config-file $opt(dir)/bgpd6893.conf
$BGP6893 attach-node $node(6893)
$ns at 316 "$BGP6893 command \"show ip bgp\""

#puts "Creating Router 6896"
set node(6896) [$ns node]
set BGP6896 [new Application/Route/Bgp]
$BGP6896 register  $r

$BGP6896 config-file $opt(dir)/bgpd6896.conf
$BGP6896 attach-node $node(6896)
$ns at 316 "$BGP6896 command \"show ip bgp\""

#puts "Creating Router 6897"
set node(6897) [$ns node]
set BGP6897 [new Application/Route/Bgp]
$BGP6897 register  $r

$BGP6897 config-file $opt(dir)/bgpd6897.conf
$BGP6897 attach-node $node(6897)
$ns at 316 "$BGP6897 command \"show ip bgp\""

#puts "Creating Router 6902"
set node(6902) [$ns node]
set BGP6902 [new Application/Route/Bgp]
$BGP6902 register  $r

$BGP6902 config-file $opt(dir)/bgpd6902.conf
$BGP6902 attach-node $node(6902)
$ns at 316 "$BGP6902 command \"show ip bgp\""

#puts "Creating Router 6903"
set node(6903) [$ns node]
set BGP6903 [new Application/Route/Bgp]
$BGP6903 register  $r

$BGP6903 config-file $opt(dir)/bgpd6903.conf
$BGP6903 attach-node $node(6903)
$ns at 316 "$BGP6903 command \"show ip bgp\""

#puts "Creating Router 6904"
set node(6904) [$ns node]
set BGP6904 [new Application/Route/Bgp]
$BGP6904 register  $r

$BGP6904 config-file $opt(dir)/bgpd6904.conf
$BGP6904 attach-node $node(6904)
$ns at 316 "$BGP6904 command \"show ip bgp\""

#puts "Creating Router 6905"
set node(6905) [$ns node]
set BGP6905 [new Application/Route/Bgp]
$BGP6905 register  $r

$BGP6905 config-file $opt(dir)/bgpd6905.conf
$BGP6905 attach-node $node(6905)
$ns at 316 "$BGP6905 command \"show ip bgp\""

#puts "Creating Router 6912"
set node(6912) [$ns node]
set BGP6912 [new Application/Route/Bgp]
$BGP6912 register  $r

$BGP6912 config-file $opt(dir)/bgpd6912.conf
$BGP6912 attach-node $node(6912)
$ns at 316 "$BGP6912 command \"show ip bgp\""

#puts "Creating Router 6913"
set node(6913) [$ns node]
set BGP6913 [new Application/Route/Bgp]
$BGP6913 register  $r

$BGP6913 config-file $opt(dir)/bgpd6913.conf
$BGP6913 attach-node $node(6913)
$ns at 316 "$BGP6913 command \"show ip bgp\""

#puts "Creating Router 6922"
set node(6922) [$ns node]
set BGP6922 [new Application/Route/Bgp]
$BGP6922 register  $r

$BGP6922 config-file $opt(dir)/bgpd6922.conf
$BGP6922 attach-node $node(6922)
$ns at 316 "$BGP6922 command \"show ip bgp\""

#puts "Creating Router 6924"
set node(6924) [$ns node]
set BGP6924 [new Application/Route/Bgp]
$BGP6924 register  $r

$BGP6924 config-file $opt(dir)/bgpd6924.conf
$BGP6924 attach-node $node(6924)
$ns at 316 "$BGP6924 command \"show ip bgp\""

#puts "Creating Router 693"
set node(693) [$ns node]
set BGP693 [new Application/Route/Bgp]
$BGP693 register  $r

$BGP693 config-file $opt(dir)/bgpd693.conf
$BGP693 attach-node $node(693)
$ns at 316 "$BGP693 command \"show ip bgp\""

#puts "Creating Router 6938"
set node(6938) [$ns node]
set BGP6938 [new Application/Route/Bgp]
$BGP6938 register  $r

$BGP6938 config-file $opt(dir)/bgpd6938.conf
$BGP6938 attach-node $node(6938)
$ns at 316 "$BGP6938 command \"show ip bgp\""

#puts "Creating Router 6939"
set node(6939) [$ns node]
set BGP6939 [new Application/Route/Bgp]
$BGP6939 register  $r

$BGP6939 config-file $opt(dir)/bgpd6939.conf
$BGP6939 attach-node $node(6939)
$ns at 316 "$BGP6939 command \"show ip bgp\""

#puts "Creating Router 6954"
set node(6954) [$ns node]
set BGP6954 [new Application/Route/Bgp]
$BGP6954 register  $r

$BGP6954 config-file $opt(dir)/bgpd6954.conf
$BGP6954 attach-node $node(6954)
$ns at 316 "$BGP6954 command \"show ip bgp\""

#puts "Creating Router 6955"
set node(6955) [$ns node]
set BGP6955 [new Application/Route/Bgp]
$BGP6955 register  $r

$BGP6955 config-file $opt(dir)/bgpd6955.conf
$BGP6955 attach-node $node(6955)
$ns at 316 "$BGP6955 command \"show ip bgp\""

#puts "Creating Router 6957"
set node(6957) [$ns node]
set BGP6957 [new Application/Route/Bgp]
$BGP6957 register  $r

$BGP6957 config-file $opt(dir)/bgpd6957.conf
$BGP6957 attach-node $node(6957)
$ns at 316 "$BGP6957 command \"show ip bgp\""

#puts "Creating Router 6968"
set node(6968) [$ns node]
set BGP6968 [new Application/Route/Bgp]
$BGP6968 register  $r

$BGP6968 config-file $opt(dir)/bgpd6968.conf
$BGP6968 attach-node $node(6968)
$ns at 316 "$BGP6968 command \"show ip bgp\""

#puts "Creating Router 6981"
set node(6981) [$ns node]
set BGP6981 [new Application/Route/Bgp]
$BGP6981 register  $r

$BGP6981 config-file $opt(dir)/bgpd6981.conf
$BGP6981 attach-node $node(6981)
$ns at 316 "$BGP6981 command \"show ip bgp\""

#puts "Creating Router 6983"
set node(6983) [$ns node]
set BGP6983 [new Application/Route/Bgp]
$BGP6983 register  $r

$BGP6983 config-file $opt(dir)/bgpd6983.conf
$BGP6983 attach-node $node(6983)
$ns at 316 "$BGP6983 command \"show ip bgp\""

#puts "Creating Router 6984"
set node(6984) [$ns node]
set BGP6984 [new Application/Route/Bgp]
$BGP6984 register  $r

$BGP6984 config-file $opt(dir)/bgpd6984.conf
$BGP6984 attach-node $node(6984)
$ns at 316 "$BGP6984 command \"show ip bgp\""

#puts "Creating Router 6986"
set node(6986) [$ns node]
set BGP6986 [new Application/Route/Bgp]
$BGP6986 register  $r

$BGP6986 config-file $opt(dir)/bgpd6986.conf
$BGP6986 attach-node $node(6986)
$ns at 316 "$BGP6986 command \"show ip bgp\""

#puts "Creating Router 6990"
set node(6990) [$ns node]
set BGP6990 [new Application/Route/Bgp]
$BGP6990 register  $r

$BGP6990 config-file $opt(dir)/bgpd6990.conf
$BGP6990 attach-node $node(6990)
$ns at 316 "$BGP6990 command \"show ip bgp\""

#puts "Creating Router 6993"
set node(6993) [$ns node]
set BGP6993 [new Application/Route/Bgp]
$BGP6993 register  $r

$BGP6993 config-file $opt(dir)/bgpd6993.conf
$BGP6993 attach-node $node(6993)
$ns at 316 "$BGP6993 command \"show ip bgp\""

#puts "Creating Router 6997"
set node(6997) [$ns node]
set BGP6997 [new Application/Route/Bgp]
$BGP6997 register  $r

$BGP6997 config-file $opt(dir)/bgpd6997.conf
$BGP6997 attach-node $node(6997)
$ns at 316 "$BGP6997 command \"show ip bgp\""

#puts "Creating Router 70"
set node(70) [$ns node]
set BGP70 [new Application/Route/Bgp]
$BGP70 register  $r

$BGP70 config-file $opt(dir)/bgpd70.conf
$BGP70 attach-node $node(70)
$ns at 316 "$BGP70 command \"show ip bgp\""

#puts "Creating Router 7001"
set node(7001) [$ns node]
set BGP7001 [new Application/Route/Bgp]
$BGP7001 register  $r

$BGP7001 config-file $opt(dir)/bgpd7001.conf
$BGP7001 attach-node $node(7001)
$ns at 316 "$BGP7001 command \"show ip bgp\""

#puts "Creating Router 7003"
set node(7003) [$ns node]
set BGP7003 [new Application/Route/Bgp]
$BGP7003 register  $r

$BGP7003 config-file $opt(dir)/bgpd7003.conf
$BGP7003 attach-node $node(7003)
$ns at 316 "$BGP7003 command \"show ip bgp\""

#puts "Creating Router 7006"
set node(7006) [$ns node]
set BGP7006 [new Application/Route/Bgp]
$BGP7006 register  $r

$BGP7006 config-file $opt(dir)/bgpd7006.conf
$BGP7006 attach-node $node(7006)
$ns at 316 "$BGP7006 command \"show ip bgp\""

#puts "Creating Router 701"
set node(701) [$ns node]
set BGP701 [new Application/Route/Bgp]
$BGP701 register  $r

$BGP701 config-file $opt(dir)/bgpd701.conf
$BGP701 attach-node $node(701)
$ns at 316 "$BGP701 command \"show ip bgp\""

#puts "Creating Router 7015"
set node(7015) [$ns node]
set BGP7015 [new Application/Route/Bgp]
$BGP7015 register  $r

$BGP7015 config-file $opt(dir)/bgpd7015.conf
$BGP7015 attach-node $node(7015)
$ns at 316 "$BGP7015 command \"show ip bgp\""

#puts "Creating Router 7017"
set node(7017) [$ns node]
set BGP7017 [new Application/Route/Bgp]
$BGP7017 register  $r

$BGP7017 config-file $opt(dir)/bgpd7017.conf
$BGP7017 attach-node $node(7017)
$ns at 316 "$BGP7017 command \"show ip bgp\""

#puts "Creating Router 7018"
set node(7018) [$ns node]
set BGP7018 [new Application/Route/Bgp]
$BGP7018 register  $r

$BGP7018 config-file $opt(dir)/bgpd7018.conf
$BGP7018 attach-node $node(7018)
$ns at 316 "$BGP7018 command \"show ip bgp\""

#puts "Creating Router 702"
set node(702) [$ns node]
set BGP702 [new Application/Route/Bgp]
$BGP702 register  $r

$BGP702 config-file $opt(dir)/bgpd702.conf
$BGP702 attach-node $node(702)
$ns at 316 "$BGP702 command \"show ip bgp\""

#puts "Creating Router 7020"
set node(7020) [$ns node]
set BGP7020 [new Application/Route/Bgp]
$BGP7020 register  $r

$BGP7020 config-file $opt(dir)/bgpd7020.conf
$BGP7020 attach-node $node(7020)
$ns at 316 "$BGP7020 command \"show ip bgp\""

#puts "Creating Router 7021"
set node(7021) [$ns node]
set BGP7021 [new Application/Route/Bgp]
$BGP7021 register  $r

$BGP7021 config-file $opt(dir)/bgpd7021.conf
$BGP7021 attach-node $node(7021)
$ns at 316 "$BGP7021 command \"show ip bgp\""

#puts "Creating Router 7022"
set node(7022) [$ns node]
set BGP7022 [new Application/Route/Bgp]
$BGP7022 register  $r

$BGP7022 config-file $opt(dir)/bgpd7022.conf
$BGP7022 attach-node $node(7022)
$ns at 316 "$BGP7022 command \"show ip bgp\""

#puts "Creating Router 703"
set node(703) [$ns node]
set BGP703 [new Application/Route/Bgp]
$BGP703 register  $r

$BGP703 config-file $opt(dir)/bgpd703.conf
$BGP703 attach-node $node(703)
$ns at 316 "$BGP703 command \"show ip bgp\""

#puts "Creating Router 7037"
set node(7037) [$ns node]
set BGP7037 [new Application/Route/Bgp]
$BGP7037 register  $r

$BGP7037 config-file $opt(dir)/bgpd7037.conf
$BGP7037 attach-node $node(7037)
$ns at 316 "$BGP7037 command \"show ip bgp\""

#puts "Creating Router 7038"
set node(7038) [$ns node]
set BGP7038 [new Application/Route/Bgp]
$BGP7038 register  $r

$BGP7038 config-file $opt(dir)/bgpd7038.conf
$BGP7038 attach-node $node(7038)
$ns at 316 "$BGP7038 command \"show ip bgp\""

#puts "Creating Router 7051"
set node(7051) [$ns node]
set BGP7051 [new Application/Route/Bgp]
$BGP7051 register  $r

$BGP7051 config-file $opt(dir)/bgpd7051.conf
$BGP7051 attach-node $node(7051)
$ns at 316 "$BGP7051 command \"show ip bgp\""

#puts "Creating Router 7055"
set node(7055) [$ns node]
set BGP7055 [new Application/Route/Bgp]
$BGP7055 register  $r

$BGP7055 config-file $opt(dir)/bgpd7055.conf
$BGP7055 attach-node $node(7055)
$ns at 316 "$BGP7055 command \"show ip bgp\""

#puts "Creating Router 7062"
set node(7062) [$ns node]
set BGP7062 [new Application/Route/Bgp]
$BGP7062 register  $r

$BGP7062 config-file $opt(dir)/bgpd7062.conf
$BGP7062 attach-node $node(7062)
$ns at 316 "$BGP7062 command \"show ip bgp\""

#puts "Creating Router 7065"
set node(7065) [$ns node]
set BGP7065 [new Application/Route/Bgp]
$BGP7065 register  $r

$BGP7065 config-file $opt(dir)/bgpd7065.conf
$BGP7065 attach-node $node(7065)
$ns at 316 "$BGP7065 command \"show ip bgp\""

#puts "Creating Router 7066"
set node(7066) [$ns node]
set BGP7066 [new Application/Route/Bgp]
$BGP7066 register  $r

$BGP7066 config-file $opt(dir)/bgpd7066.conf
$BGP7066 attach-node $node(7066)
$ns at 316 "$BGP7066 command \"show ip bgp\""

#puts "Creating Router 7080"
set node(7080) [$ns node]
set BGP7080 [new Application/Route/Bgp]
$BGP7080 register  $r

$BGP7080 config-file $opt(dir)/bgpd7080.conf
$BGP7080 attach-node $node(7080)
$ns at 316 "$BGP7080 command \"show ip bgp\""

#puts "Creating Router 7087"
set node(7087) [$ns node]
set BGP7087 [new Application/Route/Bgp]
$BGP7087 register  $r

$BGP7087 config-file $opt(dir)/bgpd7087.conf
$BGP7087 attach-node $node(7087)
$ns at 316 "$BGP7087 command \"show ip bgp\""

#puts "Creating Router 7091"
set node(7091) [$ns node]
set BGP7091 [new Application/Route/Bgp]
$BGP7091 register  $r

$BGP7091 config-file $opt(dir)/bgpd7091.conf
$BGP7091 attach-node $node(7091)
$ns at 316 "$BGP7091 command \"show ip bgp\""

#puts "Creating Router 7095"
set node(7095) [$ns node]
set BGP7095 [new Application/Route/Bgp]
$BGP7095 register  $r

$BGP7095 config-file $opt(dir)/bgpd7095.conf
$BGP7095 attach-node $node(7095)
$ns at 316 "$BGP7095 command \"show ip bgp\""

#puts "Creating Router 7096"
set node(7096) [$ns node]
set BGP7096 [new Application/Route/Bgp]
$BGP7096 register  $r

$BGP7096 config-file $opt(dir)/bgpd7096.conf
$BGP7096 attach-node $node(7096)
$ns at 316 "$BGP7096 command \"show ip bgp\""

#puts "Creating Router 7098"
set node(7098) [$ns node]
set BGP7098 [new Application/Route/Bgp]
$BGP7098 register  $r

$BGP7098 config-file $opt(dir)/bgpd7098.conf
$BGP7098 attach-node $node(7098)
$ns at 316 "$BGP7098 command \"show ip bgp\""

#puts "Creating Router 7106"
set node(7106) [$ns node]
set BGP7106 [new Application/Route/Bgp]
$BGP7106 register  $r

$BGP7106 config-file $opt(dir)/bgpd7106.conf
$BGP7106 attach-node $node(7106)
$ns at 316 "$BGP7106 command \"show ip bgp\""

#puts "Creating Router 7120"
set node(7120) [$ns node]
set BGP7120 [new Application/Route/Bgp]
$BGP7120 register  $r

$BGP7120 config-file $opt(dir)/bgpd7120.conf
$BGP7120 attach-node $node(7120)
$ns at 316 "$BGP7120 command \"show ip bgp\""

#puts "Creating Router 7125"
set node(7125) [$ns node]
set BGP7125 [new Application/Route/Bgp]
$BGP7125 register  $r

$BGP7125 config-file $opt(dir)/bgpd7125.conf
$BGP7125 attach-node $node(7125)
$ns at 316 "$BGP7125 command \"show ip bgp\""

#puts "Creating Router 7128"
set node(7128) [$ns node]
set BGP7128 [new Application/Route/Bgp]
$BGP7128 register  $r

$BGP7128 config-file $opt(dir)/bgpd7128.conf
$BGP7128 attach-node $node(7128)
$ns at 316 "$BGP7128 command \"show ip bgp\""

#puts "Creating Router 7137"
set node(7137) [$ns node]
set BGP7137 [new Application/Route/Bgp]
$BGP7137 register  $r

$BGP7137 config-file $opt(dir)/bgpd7137.conf
$BGP7137 attach-node $node(7137)
$ns at 316 "$BGP7137 command \"show ip bgp\""

#puts "Creating Router 7138"
set node(7138) [$ns node]
set BGP7138 [new Application/Route/Bgp]
$BGP7138 register  $r

$BGP7138 config-file $opt(dir)/bgpd7138.conf
$BGP7138 attach-node $node(7138)
$ns at 316 "$BGP7138 command \"show ip bgp\""

#puts "Creating Router 714"
set node(714) [$ns node]
set BGP714 [new Application/Route/Bgp]
$BGP714 register  $r

$BGP714 config-file $opt(dir)/bgpd714.conf
$BGP714 attach-node $node(714)
$ns at 316 "$BGP714 command \"show ip bgp\""

#puts "Creating Router 7140"
set node(7140) [$ns node]
set BGP7140 [new Application/Route/Bgp]
$BGP7140 register  $r

$BGP7140 config-file $opt(dir)/bgpd7140.conf
$BGP7140 attach-node $node(7140)
$ns at 316 "$BGP7140 command \"show ip bgp\""

#puts "Creating Router 7143"
set node(7143) [$ns node]
set BGP7143 [new Application/Route/Bgp]
$BGP7143 register  $r

$BGP7143 config-file $opt(dir)/bgpd7143.conf
$BGP7143 attach-node $node(7143)
$ns at 316 "$BGP7143 command \"show ip bgp\""

#puts "Creating Router 7148"
set node(7148) [$ns node]
set BGP7148 [new Application/Route/Bgp]
$BGP7148 register  $r

$BGP7148 config-file $opt(dir)/bgpd7148.conf
$BGP7148 attach-node $node(7148)
$ns at 316 "$BGP7148 command \"show ip bgp\""

#puts "Creating Router 715"
set node(715) [$ns node]
set BGP715 [new Application/Route/Bgp]
$BGP715 register  $r

$BGP715 config-file $opt(dir)/bgpd715.conf
$BGP715 attach-node $node(715)
$ns at 316 "$BGP715 command \"show ip bgp\""

#puts "Creating Router 7170"
set node(7170) [$ns node]
set BGP7170 [new Application/Route/Bgp]
$BGP7170 register  $r

$BGP7170 config-file $opt(dir)/bgpd7170.conf
$BGP7170 attach-node $node(7170)
$ns at 316 "$BGP7170 command \"show ip bgp\""

#puts "Creating Router 7176"
set node(7176) [$ns node]
set BGP7176 [new Application/Route/Bgp]
$BGP7176 register  $r

$BGP7176 config-file $opt(dir)/bgpd7176.conf
$BGP7176 attach-node $node(7176)
$ns at 316 "$BGP7176 command \"show ip bgp\""

#puts "Creating Router 7178"
set node(7178) [$ns node]
set BGP7178 [new Application/Route/Bgp]
$BGP7178 register  $r

$BGP7178 config-file $opt(dir)/bgpd7178.conf
$BGP7178 attach-node $node(7178)
$ns at 316 "$BGP7178 command \"show ip bgp\""

#puts "Creating Router 7181"
set node(7181) [$ns node]
set BGP7181 [new Application/Route/Bgp]
$BGP7181 register  $r

$BGP7181 config-file $opt(dir)/bgpd7181.conf
$BGP7181 attach-node $node(7181)
$ns at 316 "$BGP7181 command \"show ip bgp\""

#puts "Creating Router 7188"
set node(7188) [$ns node]
set BGP7188 [new Application/Route/Bgp]
$BGP7188 register  $r

$BGP7188 config-file $opt(dir)/bgpd7188.conf
$BGP7188 attach-node $node(7188)
$ns at 316 "$BGP7188 command \"show ip bgp\""

#puts "Creating Router 7189"
set node(7189) [$ns node]
set BGP7189 [new Application/Route/Bgp]
$BGP7189 register  $r

$BGP7189 config-file $opt(dir)/bgpd7189.conf
$BGP7189 attach-node $node(7189)
$ns at 316 "$BGP7189 command \"show ip bgp\""

#puts "Creating Router 719"
set node(719) [$ns node]
set BGP719 [new Application/Route/Bgp]
$BGP719 register  $r

$BGP719 config-file $opt(dir)/bgpd719.conf
$BGP719 attach-node $node(719)
$ns at 316 "$BGP719 command \"show ip bgp\""

#puts "Creating Router 7192"
set node(7192) [$ns node]
set BGP7192 [new Application/Route/Bgp]
$BGP7192 register  $r

$BGP7192 config-file $opt(dir)/bgpd7192.conf
$BGP7192 attach-node $node(7192)
$ns at 316 "$BGP7192 command \"show ip bgp\""

#puts "Creating Router 7194"
set node(7194) [$ns node]
set BGP7194 [new Application/Route/Bgp]
$BGP7194 register  $r

$BGP7194 config-file $opt(dir)/bgpd7194.conf
$BGP7194 attach-node $node(7194)
$ns at 316 "$BGP7194 command \"show ip bgp\""

#puts "Creating Router 7195"
set node(7195) [$ns node]
set BGP7195 [new Application/Route/Bgp]
$BGP7195 register  $r

$BGP7195 config-file $opt(dir)/bgpd7195.conf
$BGP7195 attach-node $node(7195)
$ns at 316 "$BGP7195 command \"show ip bgp\""

#puts "Creating Router 7199"
set node(7199) [$ns node]
set BGP7199 [new Application/Route/Bgp]
$BGP7199 register  $r

$BGP7199 config-file $opt(dir)/bgpd7199.conf
$BGP7199 attach-node $node(7199)
$ns at 316 "$BGP7199 command \"show ip bgp\""

#puts "Creating Router 72"
set node(72) [$ns node]
set BGP72 [new Application/Route/Bgp]
$BGP72 register  $r

$BGP72 config-file $opt(dir)/bgpd72.conf
$BGP72 attach-node $node(72)
$ns at 316 "$BGP72 command \"show ip bgp\""

#puts "Creating Router 7206"
set node(7206) [$ns node]
set BGP7206 [new Application/Route/Bgp]
$BGP7206 register  $r

$BGP7206 config-file $opt(dir)/bgpd7206.conf
$BGP7206 attach-node $node(7206)
$ns at 316 "$BGP7206 command \"show ip bgp\""

#puts "Creating Router 7207"
set node(7207) [$ns node]
set BGP7207 [new Application/Route/Bgp]
$BGP7207 register  $r

$BGP7207 config-file $opt(dir)/bgpd7207.conf
$BGP7207 attach-node $node(7207)
$ns at 316 "$BGP7207 command \"show ip bgp\""

#puts "Creating Router 7223"
set node(7223) [$ns node]
set BGP7223 [new Application/Route/Bgp]
$BGP7223 register  $r

$BGP7223 config-file $opt(dir)/bgpd7223.conf
$BGP7223 attach-node $node(7223)
$ns at 316 "$BGP7223 command \"show ip bgp\""

#puts "Creating Router 7224"
set node(7224) [$ns node]
set BGP7224 [new Application/Route/Bgp]
$BGP7224 register  $r

$BGP7224 config-file $opt(dir)/bgpd7224.conf
$BGP7224 attach-node $node(7224)
$ns at 316 "$BGP7224 command \"show ip bgp\""

#puts "Creating Router 7226"
set node(7226) [$ns node]
set BGP7226 [new Application/Route/Bgp]
$BGP7226 register  $r

$BGP7226 config-file $opt(dir)/bgpd7226.conf
$BGP7226 attach-node $node(7226)
$ns at 316 "$BGP7226 command \"show ip bgp\""

#puts "Creating Router 7236"
set node(7236) [$ns node]
set BGP7236 [new Application/Route/Bgp]
$BGP7236 register  $r

$BGP7236 config-file $opt(dir)/bgpd7236.conf
$BGP7236 attach-node $node(7236)
$ns at 316 "$BGP7236 command \"show ip bgp\""

#puts "Creating Router 7239"
set node(7239) [$ns node]
set BGP7239 [new Application/Route/Bgp]
$BGP7239 register  $r

$BGP7239 config-file $opt(dir)/bgpd7239.conf
$BGP7239 attach-node $node(7239)
$ns at 316 "$BGP7239 command \"show ip bgp\""

#puts "Creating Router 724"
set node(724) [$ns node]
set BGP724 [new Application/Route/Bgp]
$BGP724 register  $r

$BGP724 config-file $opt(dir)/bgpd724.conf
$BGP724 attach-node $node(724)
$ns at 316 "$BGP724 command \"show ip bgp\""

#puts "Creating Router 7252"
set node(7252) [$ns node]
set BGP7252 [new Application/Route/Bgp]
$BGP7252 register  $r

$BGP7252 config-file $opt(dir)/bgpd7252.conf
$BGP7252 attach-node $node(7252)
$ns at 316 "$BGP7252 command \"show ip bgp\""

#puts "Creating Router 7258"
set node(7258) [$ns node]
set BGP7258 [new Application/Route/Bgp]
$BGP7258 register  $r

$BGP7258 config-file $opt(dir)/bgpd7258.conf
$BGP7258 attach-node $node(7258)
$ns at 316 "$BGP7258 command \"show ip bgp\""

#puts "Creating Router 7260"
set node(7260) [$ns node]
set BGP7260 [new Application/Route/Bgp]
$BGP7260 register  $r

$BGP7260 config-file $opt(dir)/bgpd7260.conf
$BGP7260 attach-node $node(7260)
$ns at 316 "$BGP7260 command \"show ip bgp\""

#puts "Creating Router 7263"
set node(7263) [$ns node]
set BGP7263 [new Application/Route/Bgp]
$BGP7263 register  $r

$BGP7263 config-file $opt(dir)/bgpd7263.conf
$BGP7263 attach-node $node(7263)
$ns at 316 "$BGP7263 command \"show ip bgp\""

#puts "Creating Router 7268"
set node(7268) [$ns node]
set BGP7268 [new Application/Route/Bgp]
$BGP7268 register  $r

$BGP7268 config-file $opt(dir)/bgpd7268.conf
$BGP7268 attach-node $node(7268)
$ns at 316 "$BGP7268 command \"show ip bgp\""

#puts "Creating Router 7271"
set node(7271) [$ns node]
set BGP7271 [new Application/Route/Bgp]
$BGP7271 register  $r

$BGP7271 config-file $opt(dir)/bgpd7271.conf
$BGP7271 attach-node $node(7271)
$ns at 316 "$BGP7271 command \"show ip bgp\""

#puts "Creating Router 7272"
set node(7272) [$ns node]
set BGP7272 [new Application/Route/Bgp]
$BGP7272 register  $r

$BGP7272 config-file $opt(dir)/bgpd7272.conf
$BGP7272 attach-node $node(7272)
$ns at 316 "$BGP7272 command \"show ip bgp\""

#puts "Creating Router 7275"
set node(7275) [$ns node]
set BGP7275 [new Application/Route/Bgp]
$BGP7275 register  $r

$BGP7275 config-file $opt(dir)/bgpd7275.conf
$BGP7275 attach-node $node(7275)
$ns at 316 "$BGP7275 command \"show ip bgp\""

#puts "Creating Router 7283"
set node(7283) [$ns node]
set BGP7283 [new Application/Route/Bgp]
$BGP7283 register  $r

$BGP7283 config-file $opt(dir)/bgpd7283.conf
$BGP7283 attach-node $node(7283)
$ns at 316 "$BGP7283 command \"show ip bgp\""

#puts "Creating Router 7303"
set node(7303) [$ns node]
set BGP7303 [new Application/Route/Bgp]
$BGP7303 register  $r

$BGP7303 config-file $opt(dir)/bgpd7303.conf
$BGP7303 attach-node $node(7303)
$ns at 316 "$BGP7303 command \"show ip bgp\""

#puts "Creating Router 7306"
set node(7306) [$ns node]
set BGP7306 [new Application/Route/Bgp]
$BGP7306 register  $r

$BGP7306 config-file $opt(dir)/bgpd7306.conf
$BGP7306 attach-node $node(7306)
$ns at 316 "$BGP7306 command \"show ip bgp\""

#puts "Creating Router 7313"
set node(7313) [$ns node]
set BGP7313 [new Application/Route/Bgp]
$BGP7313 register  $r

$BGP7313 config-file $opt(dir)/bgpd7313.conf
$BGP7313 attach-node $node(7313)
$ns at 316 "$BGP7313 command \"show ip bgp\""

#puts "Creating Router 7314"
set node(7314) [$ns node]
set BGP7314 [new Application/Route/Bgp]
$BGP7314 register  $r

$BGP7314 config-file $opt(dir)/bgpd7314.conf
$BGP7314 attach-node $node(7314)
$ns at 316 "$BGP7314 command \"show ip bgp\""

#puts "Creating Router 7319"
set node(7319) [$ns node]
set BGP7319 [new Application/Route/Bgp]
$BGP7319 register  $r

$BGP7319 config-file $opt(dir)/bgpd7319.conf
$BGP7319 attach-node $node(7319)
$ns at 316 "$BGP7319 command \"show ip bgp\""

#puts "Creating Router 7333"
set node(7333) [$ns node]
set BGP7333 [new Application/Route/Bgp]
$BGP7333 register  $r

$BGP7333 config-file $opt(dir)/bgpd7333.conf
$BGP7333 attach-node $node(7333)
$ns at 316 "$BGP7333 command \"show ip bgp\""

#puts "Creating Router 7337"
set node(7337) [$ns node]
set BGP7337 [new Application/Route/Bgp]
$BGP7337 register  $r

$BGP7337 config-file $opt(dir)/bgpd7337.conf
$BGP7337 attach-node $node(7337)
$ns at 316 "$BGP7337 command \"show ip bgp\""

#puts "Creating Router 7338"
set node(7338) [$ns node]
set BGP7338 [new Application/Route/Bgp]
$BGP7338 register  $r

$BGP7338 config-file $opt(dir)/bgpd7338.conf
$BGP7338 attach-node $node(7338)
$ns at 316 "$BGP7338 command \"show ip bgp\""

#puts "Creating Router 7340"
set node(7340) [$ns node]
set BGP7340 [new Application/Route/Bgp]
$BGP7340 register  $r

$BGP7340 config-file $opt(dir)/bgpd7340.conf
$BGP7340 attach-node $node(7340)
$ns at 316 "$BGP7340 command \"show ip bgp\""

#puts "Creating Router 7344"
set node(7344) [$ns node]
set BGP7344 [new Application/Route/Bgp]
$BGP7344 register  $r

$BGP7344 config-file $opt(dir)/bgpd7344.conf
$BGP7344 attach-node $node(7344)
$ns at 316 "$BGP7344 command \"show ip bgp\""

#puts "Creating Router 7346"
set node(7346) [$ns node]
set BGP7346 [new Application/Route/Bgp]
$BGP7346 register  $r

$BGP7346 config-file $opt(dir)/bgpd7346.conf
$BGP7346 attach-node $node(7346)
$ns at 316 "$BGP7346 command \"show ip bgp\""

#puts "Creating Router 7349"
set node(7349) [$ns node]
set BGP7349 [new Application/Route/Bgp]
$BGP7349 register  $r

$BGP7349 config-file $opt(dir)/bgpd7349.conf
$BGP7349 attach-node $node(7349)
$ns at 316 "$BGP7349 command \"show ip bgp\""

#puts "Creating Router 7354"
set node(7354) [$ns node]
set BGP7354 [new Application/Route/Bgp]
$BGP7354 register  $r

$BGP7354 config-file $opt(dir)/bgpd7354.conf
$BGP7354 attach-node $node(7354)
$ns at 316 "$BGP7354 command \"show ip bgp\""

#puts "Creating Router 7359"
set node(7359) [$ns node]
set BGP7359 [new Application/Route/Bgp]
$BGP7359 register  $r

$BGP7359 config-file $opt(dir)/bgpd7359.conf
$BGP7359 attach-node $node(7359)
$ns at 316 "$BGP7359 command \"show ip bgp\""

#puts "Creating Router 7361"
set node(7361) [$ns node]
set BGP7361 [new Application/Route/Bgp]
$BGP7361 register  $r

$BGP7361 config-file $opt(dir)/bgpd7361.conf
$BGP7361 attach-node $node(7361)
$ns at 316 "$BGP7361 command \"show ip bgp\""

#puts "Creating Router 7369"
set node(7369) [$ns node]
set BGP7369 [new Application/Route/Bgp]
$BGP7369 register  $r

$BGP7369 config-file $opt(dir)/bgpd7369.conf
$BGP7369 attach-node $node(7369)
$ns at 316 "$BGP7369 command \"show ip bgp\""

#puts "Creating Router 7370"
set node(7370) [$ns node]
set BGP7370 [new Application/Route/Bgp]
$BGP7370 register  $r

$BGP7370 config-file $opt(dir)/bgpd7370.conf
$BGP7370 attach-node $node(7370)
$ns at 316 "$BGP7370 command \"show ip bgp\""

#puts "Creating Router 7372"
set node(7372) [$ns node]
set BGP7372 [new Application/Route/Bgp]
$BGP7372 register  $r

$BGP7372 config-file $opt(dir)/bgpd7372.conf
$BGP7372 attach-node $node(7372)
$ns at 316 "$BGP7372 command \"show ip bgp\""

#puts "Creating Router 7374"
set node(7374) [$ns node]
set BGP7374 [new Application/Route/Bgp]
$BGP7374 register  $r

$BGP7374 config-file $opt(dir)/bgpd7374.conf
$BGP7374 attach-node $node(7374)
$ns at 316 "$BGP7374 command \"show ip bgp\""

#puts "Creating Router 7385"
set node(7385) [$ns node]
set BGP7385 [new Application/Route/Bgp]
$BGP7385 register  $r

$BGP7385 config-file $opt(dir)/bgpd7385.conf
$BGP7385 attach-node $node(7385)
$ns at 316 "$BGP7385 command \"show ip bgp\""

#puts "Creating Router 7393"
set node(7393) [$ns node]
set BGP7393 [new Application/Route/Bgp]
$BGP7393 register  $r

$BGP7393 config-file $opt(dir)/bgpd7393.conf
$BGP7393 attach-node $node(7393)
$ns at 316 "$BGP7393 command \"show ip bgp\""

#puts "Creating Router 7395"
set node(7395) [$ns node]
set BGP7395 [new Application/Route/Bgp]
$BGP7395 register  $r

$BGP7395 config-file $opt(dir)/bgpd7395.conf
$BGP7395 attach-node $node(7395)
$ns at 316 "$BGP7395 command \"show ip bgp\""

#puts "Creating Router 7414"
set node(7414) [$ns node]
set BGP7414 [new Application/Route/Bgp]
$BGP7414 register  $r

$BGP7414 config-file $opt(dir)/bgpd7414.conf
$BGP7414 attach-node $node(7414)
$ns at 316 "$BGP7414 command \"show ip bgp\""

#puts "Creating Router 7417"
set node(7417) [$ns node]
set BGP7417 [new Application/Route/Bgp]
$BGP7417 register  $r

$BGP7417 config-file $opt(dir)/bgpd7417.conf
$BGP7417 attach-node $node(7417)
$ns at 316 "$BGP7417 command \"show ip bgp\""

#puts "Creating Router 7424"
set node(7424) [$ns node]
set BGP7424 [new Application/Route/Bgp]
$BGP7424 register  $r

$BGP7424 config-file $opt(dir)/bgpd7424.conf
$BGP7424 attach-node $node(7424)
$ns at 316 "$BGP7424 command \"show ip bgp\""

#puts "Creating Router 7431"
set node(7431) [$ns node]
set BGP7431 [new Application/Route/Bgp]
$BGP7431 register  $r

$BGP7431 config-file $opt(dir)/bgpd7431.conf
$BGP7431 attach-node $node(7431)
$ns at 316 "$BGP7431 command \"show ip bgp\""

#puts "Creating Router 7436"
set node(7436) [$ns node]
set BGP7436 [new Application/Route/Bgp]
$BGP7436 register  $r

$BGP7436 config-file $opt(dir)/bgpd7436.conf
$BGP7436 attach-node $node(7436)
$ns at 316 "$BGP7436 command \"show ip bgp\""

#puts "Creating Router 7438"
set node(7438) [$ns node]
set BGP7438 [new Application/Route/Bgp]
$BGP7438 register  $r

$BGP7438 config-file $opt(dir)/bgpd7438.conf
$BGP7438 attach-node $node(7438)
$ns at 316 "$BGP7438 command \"show ip bgp\""

#puts "Creating Router 7439"
set node(7439) [$ns node]
set BGP7439 [new Application/Route/Bgp]
$BGP7439 register  $r

$BGP7439 config-file $opt(dir)/bgpd7439.conf
$BGP7439 attach-node $node(7439)
$ns at 316 "$BGP7439 command \"show ip bgp\""

#puts "Creating Router 7445"
set node(7445) [$ns node]
set BGP7445 [new Application/Route/Bgp]
$BGP7445 register  $r

$BGP7445 config-file $opt(dir)/bgpd7445.conf
$BGP7445 attach-node $node(7445)
$ns at 316 "$BGP7445 command \"show ip bgp\""

#puts "Creating Router 745"
set node(745) [$ns node]
set BGP745 [new Application/Route/Bgp]
$BGP745 register  $r

$BGP745 config-file $opt(dir)/bgpd745.conf
$BGP745 attach-node $node(745)
$ns at 316 "$BGP745 command \"show ip bgp\""

#puts "Creating Router 7459"
set node(7459) [$ns node]
set BGP7459 [new Application/Route/Bgp]
$BGP7459 register  $r

$BGP7459 config-file $opt(dir)/bgpd7459.conf
$BGP7459 attach-node $node(7459)
$ns at 316 "$BGP7459 command \"show ip bgp\""

#puts "Creating Router 7460"
set node(7460) [$ns node]
set BGP7460 [new Application/Route/Bgp]
$BGP7460 register  $r

$BGP7460 config-file $opt(dir)/bgpd7460.conf
$BGP7460 attach-node $node(7460)
$ns at 316 "$BGP7460 command \"show ip bgp\""

#puts "Creating Router 7470"
set node(7470) [$ns node]
set BGP7470 [new Application/Route/Bgp]
$BGP7470 register  $r

$BGP7470 config-file $opt(dir)/bgpd7470.conf
$BGP7470 attach-node $node(7470)
$ns at 316 "$BGP7470 command \"show ip bgp\""

#puts "Creating Router 7473"
set node(7473) [$ns node]
set BGP7473 [new Application/Route/Bgp]
$BGP7473 register  $r

$BGP7473 config-file $opt(dir)/bgpd7473.conf
$BGP7473 attach-node $node(7473)
$ns at 316 "$BGP7473 command \"show ip bgp\""

#puts "Creating Router 7474"
set node(7474) [$ns node]
set BGP7474 [new Application/Route/Bgp]
$BGP7474 register  $r

$BGP7474 config-file $opt(dir)/bgpd7474.conf
$BGP7474 attach-node $node(7474)
$ns at 316 "$BGP7474 command \"show ip bgp\""

#puts "Creating Router 7476"
set node(7476) [$ns node]
set BGP7476 [new Application/Route/Bgp]
$BGP7476 register  $r

$BGP7476 config-file $opt(dir)/bgpd7476.conf
$BGP7476 attach-node $node(7476)
$ns at 316 "$BGP7476 command \"show ip bgp\""

#puts "Creating Router 7482"
set node(7482) [$ns node]
set BGP7482 [new Application/Route/Bgp]
$BGP7482 register  $r

$BGP7482 config-file $opt(dir)/bgpd7482.conf
$BGP7482 attach-node $node(7482)
$ns at 316 "$BGP7482 command \"show ip bgp\""

#puts "Creating Router 7485"
set node(7485) [$ns node]
set BGP7485 [new Application/Route/Bgp]
$BGP7485 register  $r

$BGP7485 config-file $opt(dir)/bgpd7485.conf
$BGP7485 attach-node $node(7485)
$ns at 316 "$BGP7485 command \"show ip bgp\""

#puts "Creating Router 7489"
set node(7489) [$ns node]
set BGP7489 [new Application/Route/Bgp]
$BGP7489 register  $r

$BGP7489 config-file $opt(dir)/bgpd7489.conf
$BGP7489 attach-node $node(7489)
$ns at 316 "$BGP7489 command \"show ip bgp\""

#puts "Creating Router 7501"
set node(7501) [$ns node]
set BGP7501 [new Application/Route/Bgp]
$BGP7501 register  $r

$BGP7501 config-file $opt(dir)/bgpd7501.conf
$BGP7501 attach-node $node(7501)
$ns at 316 "$BGP7501 command \"show ip bgp\""

#puts "Creating Router 7511"
set node(7511) [$ns node]
set BGP7511 [new Application/Route/Bgp]
$BGP7511 register  $r

$BGP7511 config-file $opt(dir)/bgpd7511.conf
$BGP7511 attach-node $node(7511)
$ns at 316 "$BGP7511 command \"show ip bgp\""

#puts "Creating Router 7512"
set node(7512) [$ns node]
set BGP7512 [new Application/Route/Bgp]
$BGP7512 register  $r

$BGP7512 config-file $opt(dir)/bgpd7512.conf
$BGP7512 attach-node $node(7512)
$ns at 316 "$BGP7512 command \"show ip bgp\""

#puts "Creating Router 7514"
set node(7514) [$ns node]
set BGP7514 [new Application/Route/Bgp]
$BGP7514 register  $r

$BGP7514 config-file $opt(dir)/bgpd7514.conf
$BGP7514 attach-node $node(7514)
$ns at 316 "$BGP7514 command \"show ip bgp\""

#puts "Creating Router 7515"
set node(7515) [$ns node]
set BGP7515 [new Application/Route/Bgp]
$BGP7515 register  $r

$BGP7515 config-file $opt(dir)/bgpd7515.conf
$BGP7515 attach-node $node(7515)
$ns at 316 "$BGP7515 command \"show ip bgp\""

#puts "Creating Router 7518"
set node(7518) [$ns node]
set BGP7518 [new Application/Route/Bgp]
$BGP7518 register  $r

$BGP7518 config-file $opt(dir)/bgpd7518.conf
$BGP7518 attach-node $node(7518)
$ns at 316 "$BGP7518 command \"show ip bgp\""

#puts "Creating Router 7525"
set node(7525) [$ns node]
set BGP7525 [new Application/Route/Bgp]
$BGP7525 register  $r

$BGP7525 config-file $opt(dir)/bgpd7525.conf
$BGP7525 attach-node $node(7525)
$ns at 316 "$BGP7525 command \"show ip bgp\""

#puts "Creating Router 7526"
set node(7526) [$ns node]
set BGP7526 [new Application/Route/Bgp]
$BGP7526 register  $r

$BGP7526 config-file $opt(dir)/bgpd7526.conf
$BGP7526 attach-node $node(7526)
$ns at 316 "$BGP7526 command \"show ip bgp\""

#puts "Creating Router 7533"
set node(7533) [$ns node]
set BGP7533 [new Application/Route/Bgp]
$BGP7533 register  $r

$BGP7533 config-file $opt(dir)/bgpd7533.conf
$BGP7533 attach-node $node(7533)
$ns at 316 "$BGP7533 command \"show ip bgp\""

#puts "Creating Router 7541"
set node(7541) [$ns node]
set BGP7541 [new Application/Route/Bgp]
$BGP7541 register  $r

$BGP7541 config-file $opt(dir)/bgpd7541.conf
$BGP7541 attach-node $node(7541)
$ns at 316 "$BGP7541 command \"show ip bgp\""

#puts "Creating Router 7543"
set node(7543) [$ns node]
set BGP7543 [new Application/Route/Bgp]
$BGP7543 register  $r

$BGP7543 config-file $opt(dir)/bgpd7543.conf
$BGP7543 attach-node $node(7543)
$ns at 316 "$BGP7543 command \"show ip bgp\""

#puts "Creating Router 7544"
set node(7544) [$ns node]
set BGP7544 [new Application/Route/Bgp]
$BGP7544 register  $r

$BGP7544 config-file $opt(dir)/bgpd7544.conf
$BGP7544 attach-node $node(7544)
$ns at 316 "$BGP7544 command \"show ip bgp\""

#puts "Creating Router 7545"
set node(7545) [$ns node]
set BGP7545 [new Application/Route/Bgp]
$BGP7545 register  $r

$BGP7545 config-file $opt(dir)/bgpd7545.conf
$BGP7545 attach-node $node(7545)
$ns at 316 "$BGP7545 command \"show ip bgp\""

#puts "Creating Router 7561"
set node(7561) [$ns node]
set BGP7561 [new Application/Route/Bgp]
$BGP7561 register  $r

$BGP7561 config-file $opt(dir)/bgpd7561.conf
$BGP7561 attach-node $node(7561)
$ns at 316 "$BGP7561 command \"show ip bgp\""

#puts "Creating Router 7565"
set node(7565) [$ns node]
set BGP7565 [new Application/Route/Bgp]
$BGP7565 register  $r

$BGP7565 config-file $opt(dir)/bgpd7565.conf
$BGP7565 attach-node $node(7565)
$ns at 316 "$BGP7565 command \"show ip bgp\""

#puts "Creating Router 7567"
set node(7567) [$ns node]
set BGP7567 [new Application/Route/Bgp]
$BGP7567 register  $r

$BGP7567 config-file $opt(dir)/bgpd7567.conf
$BGP7567 attach-node $node(7567)
$ns at 316 "$BGP7567 command \"show ip bgp\""

#puts "Creating Router 7569"
set node(7569) [$ns node]
set BGP7569 [new Application/Route/Bgp]
$BGP7569 register  $r

$BGP7569 config-file $opt(dir)/bgpd7569.conf
$BGP7569 attach-node $node(7569)
$ns at 316 "$BGP7569 command \"show ip bgp\""

#puts "Creating Router 7570"
set node(7570) [$ns node]
set BGP7570 [new Application/Route/Bgp]
$BGP7570 register  $r

$BGP7570 config-file $opt(dir)/bgpd7570.conf
$BGP7570 attach-node $node(7570)
$ns at 316 "$BGP7570 command \"show ip bgp\""

#puts "Creating Router 7571"
set node(7571) [$ns node]
set BGP7571 [new Application/Route/Bgp]
$BGP7571 register  $r

$BGP7571 config-file $opt(dir)/bgpd7571.conf
$BGP7571 attach-node $node(7571)
$ns at 316 "$BGP7571 command \"show ip bgp\""

#puts "Creating Router 7572"
set node(7572) [$ns node]
set BGP7572 [new Application/Route/Bgp]
$BGP7572 register  $r

$BGP7572 config-file $opt(dir)/bgpd7572.conf
$BGP7572 attach-node $node(7572)
$ns at 316 "$BGP7572 command \"show ip bgp\""

#puts "Creating Router 7573"
set node(7573) [$ns node]
set BGP7573 [new Application/Route/Bgp]
$BGP7573 register  $r

$BGP7573 config-file $opt(dir)/bgpd7573.conf
$BGP7573 attach-node $node(7573)
$ns at 316 "$BGP7573 command \"show ip bgp\""

#puts "Creating Router 7574"
set node(7574) [$ns node]
set BGP7574 [new Application/Route/Bgp]
$BGP7574 register  $r

$BGP7574 config-file $opt(dir)/bgpd7574.conf
$BGP7574 attach-node $node(7574)
$ns at 316 "$BGP7574 command \"show ip bgp\""

#puts "Creating Router 7585"
set node(7585) [$ns node]
set BGP7585 [new Application/Route/Bgp]
$BGP7585 register  $r

$BGP7585 config-file $opt(dir)/bgpd7585.conf
$BGP7585 attach-node $node(7585)
$ns at 316 "$BGP7585 command \"show ip bgp\""

#puts "Creating Router 7586"
set node(7586) [$ns node]
set BGP7586 [new Application/Route/Bgp]
$BGP7586 register  $r

$BGP7586 config-file $opt(dir)/bgpd7586.conf
$BGP7586 attach-node $node(7586)
$ns at 316 "$BGP7586 command \"show ip bgp\""

#puts "Creating Router 7590"
set node(7590) [$ns node]
set BGP7590 [new Application/Route/Bgp]
$BGP7590 register  $r

$BGP7590 config-file $opt(dir)/bgpd7590.conf
$BGP7590 attach-node $node(7590)
$ns at 316 "$BGP7590 command \"show ip bgp\""

#puts "Creating Router 7594"
set node(7594) [$ns node]
set BGP7594 [new Application/Route/Bgp]
$BGP7594 register  $r

$BGP7594 config-file $opt(dir)/bgpd7594.conf
$BGP7594 attach-node $node(7594)
$ns at 316 "$BGP7594 command \"show ip bgp\""

#puts "Creating Router 760"
set node(760) [$ns node]
set BGP760 [new Application/Route/Bgp]
$BGP760 register  $r

$BGP760 config-file $opt(dir)/bgpd760.conf
$BGP760 attach-node $node(760)
$ns at 316 "$BGP760 command \"show ip bgp\""

#puts "Creating Router 7604"
set node(7604) [$ns node]
set BGP7604 [new Application/Route/Bgp]
$BGP7604 register  $r

$BGP7604 config-file $opt(dir)/bgpd7604.conf
$BGP7604 attach-node $node(7604)
$ns at 316 "$BGP7604 command \"show ip bgp\""

#puts "Creating Router 7616"
set node(7616) [$ns node]
set BGP7616 [new Application/Route/Bgp]
$BGP7616 register  $r

$BGP7616 config-file $opt(dir)/bgpd7616.conf
$BGP7616 attach-node $node(7616)
$ns at 316 "$BGP7616 command \"show ip bgp\""

#puts "Creating Router 7618"
set node(7618) [$ns node]
set BGP7618 [new Application/Route/Bgp]
$BGP7618 register  $r

$BGP7618 config-file $opt(dir)/bgpd7618.conf
$BGP7618 attach-node $node(7618)
$ns at 316 "$BGP7618 command \"show ip bgp\""

#puts "Creating Router 7620"
set node(7620) [$ns node]
set BGP7620 [new Application/Route/Bgp]
$BGP7620 register  $r

$BGP7620 config-file $opt(dir)/bgpd7620.conf
$BGP7620 attach-node $node(7620)
$ns at 316 "$BGP7620 command \"show ip bgp\""

#puts "Creating Router 7623"
set node(7623) [$ns node]
set BGP7623 [new Application/Route/Bgp]
$BGP7623 register  $r

$BGP7623 config-file $opt(dir)/bgpd7623.conf
$BGP7623 attach-node $node(7623)
$ns at 316 "$BGP7623 command \"show ip bgp\""

#puts "Creating Router 7632"
set node(7632) [$ns node]
set BGP7632 [new Application/Route/Bgp]
$BGP7632 register  $r

$BGP7632 config-file $opt(dir)/bgpd7632.conf
$BGP7632 attach-node $node(7632)
$ns at 316 "$BGP7632 command \"show ip bgp\""

#puts "Creating Router 7635"
set node(7635) [$ns node]
set BGP7635 [new Application/Route/Bgp]
$BGP7635 register  $r

$BGP7635 config-file $opt(dir)/bgpd7635.conf
$BGP7635 attach-node $node(7635)
$ns at 316 "$BGP7635 command \"show ip bgp\""

#puts "Creating Router 7642"
set node(7642) [$ns node]
set BGP7642 [new Application/Route/Bgp]
$BGP7642 register  $r

$BGP7642 config-file $opt(dir)/bgpd7642.conf
$BGP7642 attach-node $node(7642)
$ns at 316 "$BGP7642 command \"show ip bgp\""

#puts "Creating Router 7652"
set node(7652) [$ns node]
set BGP7652 [new Application/Route/Bgp]
$BGP7652 register  $r

$BGP7652 config-file $opt(dir)/bgpd7652.conf
$BGP7652 attach-node $node(7652)
$ns at 316 "$BGP7652 command \"show ip bgp\""

#puts "Creating Router 7655"
set node(7655) [$ns node]
set BGP7655 [new Application/Route/Bgp]
$BGP7655 register  $r

$BGP7655 config-file $opt(dir)/bgpd7655.conf
$BGP7655 attach-node $node(7655)
$ns at 316 "$BGP7655 command \"show ip bgp\""

#puts "Creating Router 7656"
set node(7656) [$ns node]
set BGP7656 [new Application/Route/Bgp]
$BGP7656 register  $r

$BGP7656 config-file $opt(dir)/bgpd7656.conf
$BGP7656 attach-node $node(7656)
$ns at 316 "$BGP7656 command \"show ip bgp\""

#puts "Creating Router 7657"
set node(7657) [$ns node]
set BGP7657 [new Application/Route/Bgp]
$BGP7657 register  $r

$BGP7657 config-file $opt(dir)/bgpd7657.conf
$BGP7657 attach-node $node(7657)
$ns at 316 "$BGP7657 command \"show ip bgp\""

#puts "Creating Router 766"
set node(766) [$ns node]
set BGP766 [new Application/Route/Bgp]
$BGP766 register  $r

$BGP766 config-file $opt(dir)/bgpd766.conf
$BGP766 attach-node $node(766)
$ns at 316 "$BGP766 command \"show ip bgp\""

#puts "Creating Router 7694"
set node(7694) [$ns node]
set BGP7694 [new Application/Route/Bgp]
$BGP7694 register  $r

$BGP7694 config-file $opt(dir)/bgpd7694.conf
$BGP7694 attach-node $node(7694)
$ns at 316 "$BGP7694 command \"show ip bgp\""

#puts "Creating Router 7725"
set node(7725) [$ns node]
set BGP7725 [new Application/Route/Bgp]
$BGP7725 register  $r

$BGP7725 config-file $opt(dir)/bgpd7725.conf
$BGP7725 attach-node $node(7725)
$ns at 316 "$BGP7725 command \"show ip bgp\""

#puts "Creating Router 7736"
set node(7736) [$ns node]
set BGP7736 [new Application/Route/Bgp]
$BGP7736 register  $r

$BGP7736 config-file $opt(dir)/bgpd7736.conf
$BGP7736 attach-node $node(7736)
$ns at 316 "$BGP7736 command \"show ip bgp\""

#puts "Creating Router 7737"
set node(7737) [$ns node]
set BGP7737 [new Application/Route/Bgp]
$BGP7737 register  $r

$BGP7737 config-file $opt(dir)/bgpd7737.conf
$BGP7737 attach-node $node(7737)
$ns at 316 "$BGP7737 command \"show ip bgp\""

#puts "Creating Router 7742"
set node(7742) [$ns node]
set BGP7742 [new Application/Route/Bgp]
$BGP7742 register  $r

$BGP7742 config-file $opt(dir)/bgpd7742.conf
$BGP7742 attach-node $node(7742)
$ns at 316 "$BGP7742 command \"show ip bgp\""

#puts "Creating Router 7751"
set node(7751) [$ns node]
set BGP7751 [new Application/Route/Bgp]
$BGP7751 register  $r

$BGP7751 config-file $opt(dir)/bgpd7751.conf
$BGP7751 attach-node $node(7751)
$ns at 316 "$BGP7751 command \"show ip bgp\""

#puts "Creating Router 7752"
set node(7752) [$ns node]
set BGP7752 [new Application/Route/Bgp]
$BGP7752 register  $r

$BGP7752 config-file $opt(dir)/bgpd7752.conf
$BGP7752 attach-node $node(7752)
$ns at 316 "$BGP7752 command \"show ip bgp\""

#puts "Creating Router 7753"
set node(7753) [$ns node]
set BGP7753 [new Application/Route/Bgp]
$BGP7753 register  $r

$BGP7753 config-file $opt(dir)/bgpd7753.conf
$BGP7753 attach-node $node(7753)
$ns at 316 "$BGP7753 command \"show ip bgp\""

#puts "Creating Router 7757"
set node(7757) [$ns node]
set BGP7757 [new Application/Route/Bgp]
$BGP7757 register  $r

$BGP7757 config-file $opt(dir)/bgpd7757.conf
$BGP7757 attach-node $node(7757)
$ns at 316 "$BGP7757 command \"show ip bgp\""

#puts "Creating Router 7770"
set node(7770) [$ns node]
set BGP7770 [new Application/Route/Bgp]
$BGP7770 register  $r

$BGP7770 config-file $opt(dir)/bgpd7770.conf
$BGP7770 attach-node $node(7770)
$ns at 316 "$BGP7770 command \"show ip bgp\""

#puts "Creating Router 7772"
set node(7772) [$ns node]
set BGP7772 [new Application/Route/Bgp]
$BGP7772 register  $r

$BGP7772 config-file $opt(dir)/bgpd7772.conf
$BGP7772 attach-node $node(7772)
$ns at 316 "$BGP7772 command \"show ip bgp\""

#puts "Creating Router 7782"
set node(7782) [$ns node]
set BGP7782 [new Application/Route/Bgp]
$BGP7782 register  $r

$BGP7782 config-file $opt(dir)/bgpd7782.conf
$BGP7782 attach-node $node(7782)
$ns at 316 "$BGP7782 command \"show ip bgp\""

#puts "Creating Router 7784"
set node(7784) [$ns node]
set BGP7784 [new Application/Route/Bgp]
$BGP7784 register  $r

$BGP7784 config-file $opt(dir)/bgpd7784.conf
$BGP7784 attach-node $node(7784)
$ns at 316 "$BGP7784 command \"show ip bgp\""

#puts "Creating Router 7788"
set node(7788) [$ns node]
set BGP7788 [new Application/Route/Bgp]
$BGP7788 register  $r

$BGP7788 config-file $opt(dir)/bgpd7788.conf
$BGP7788 attach-node $node(7788)
$ns at 316 "$BGP7788 command \"show ip bgp\""

#puts "Creating Router 7790"
set node(7790) [$ns node]
set BGP7790 [new Application/Route/Bgp]
$BGP7790 register  $r

$BGP7790 config-file $opt(dir)/bgpd7790.conf
$BGP7790 attach-node $node(7790)
$ns at 316 "$BGP7790 command \"show ip bgp\""

#puts "Creating Router 7792"
set node(7792) [$ns node]
set BGP7792 [new Application/Route/Bgp]
$BGP7792 register  $r

$BGP7792 config-file $opt(dir)/bgpd7792.conf
$BGP7792 attach-node $node(7792)
$ns at 316 "$BGP7792 command \"show ip bgp\""

#puts "Creating Router 7800"
set node(7800) [$ns node]
set BGP7800 [new Application/Route/Bgp]
$BGP7800 register  $r

$BGP7800 config-file $opt(dir)/bgpd7800.conf
$BGP7800 attach-node $node(7800)
$ns at 316 "$BGP7800 command \"show ip bgp\""

#puts "Creating Router 7816"
set node(7816) [$ns node]
set BGP7816 [new Application/Route/Bgp]
$BGP7816 register  $r

$BGP7816 config-file $opt(dir)/bgpd7816.conf
$BGP7816 attach-node $node(7816)
$ns at 316 "$BGP7816 command \"show ip bgp\""

#puts "Creating Router 7820"
set node(7820) [$ns node]
set BGP7820 [new Application/Route/Bgp]
$BGP7820 register  $r

$BGP7820 config-file $opt(dir)/bgpd7820.conf
$BGP7820 attach-node $node(7820)
$ns at 316 "$BGP7820 command \"show ip bgp\""

#puts "Creating Router 7825"
set node(7825) [$ns node]
set BGP7825 [new Application/Route/Bgp]
$BGP7825 register  $r

$BGP7825 config-file $opt(dir)/bgpd7825.conf
$BGP7825 attach-node $node(7825)
$ns at 316 "$BGP7825 command \"show ip bgp\""

#puts "Creating Router 7829"
set node(7829) [$ns node]
set BGP7829 [new Application/Route/Bgp]
$BGP7829 register  $r

$BGP7829 config-file $opt(dir)/bgpd7829.conf
$BGP7829 attach-node $node(7829)
$ns at 316 "$BGP7829 command \"show ip bgp\""

#puts "Creating Router 7832"
set node(7832) [$ns node]
set BGP7832 [new Application/Route/Bgp]
$BGP7832 register  $r

$BGP7832 config-file $opt(dir)/bgpd7832.conf
$BGP7832 attach-node $node(7832)
$ns at 316 "$BGP7832 command \"show ip bgp\""

#puts "Creating Router 7833"
set node(7833) [$ns node]
set BGP7833 [new Application/Route/Bgp]
$BGP7833 register  $r

$BGP7833 config-file $opt(dir)/bgpd7833.conf
$BGP7833 attach-node $node(7833)
$ns at 316 "$BGP7833 command \"show ip bgp\""

#puts "Creating Router 7850"
set node(7850) [$ns node]
set BGP7850 [new Application/Route/Bgp]
$BGP7850 register  $r

$BGP7850 config-file $opt(dir)/bgpd7850.conf
$BGP7850 attach-node $node(7850)
$ns at 316 "$BGP7850 command \"show ip bgp\""

#puts "Creating Router 786"
set node(786) [$ns node]
set BGP786 [new Application/Route/Bgp]
$BGP786 register  $r

$BGP786 config-file $opt(dir)/bgpd786.conf
$BGP786 attach-node $node(786)
$ns at 316 "$BGP786 command \"show ip bgp\""

#puts "Creating Router 7864"
set node(7864) [$ns node]
set BGP7864 [new Application/Route/Bgp]
$BGP7864 register  $r

$BGP7864 config-file $opt(dir)/bgpd7864.conf
$BGP7864 attach-node $node(7864)
$ns at 316 "$BGP7864 command \"show ip bgp\""

#puts "Creating Router 7875"
set node(7875) [$ns node]
set BGP7875 [new Application/Route/Bgp]
$BGP7875 register  $r

$BGP7875 config-file $opt(dir)/bgpd7875.conf
$BGP7875 attach-node $node(7875)
$ns at 316 "$BGP7875 command \"show ip bgp\""

#puts "Creating Router 7878"
set node(7878) [$ns node]
set BGP7878 [new Application/Route/Bgp]
$BGP7878 register  $r

$BGP7878 config-file $opt(dir)/bgpd7878.conf
$BGP7878 attach-node $node(7878)
$ns at 316 "$BGP7878 command \"show ip bgp\""

#puts "Creating Router 7891"
set node(7891) [$ns node]
set BGP7891 [new Application/Route/Bgp]
$BGP7891 register  $r

$BGP7891 config-file $opt(dir)/bgpd7891.conf
$BGP7891 attach-node $node(7891)
$ns at 316 "$BGP7891 command \"show ip bgp\""

#puts "Creating Router 7892"
set node(7892) [$ns node]
set BGP7892 [new Application/Route/Bgp]
$BGP7892 register  $r

$BGP7892 config-file $opt(dir)/bgpd7892.conf
$BGP7892 attach-node $node(7892)
$ns at 316 "$BGP7892 command \"show ip bgp\""

#puts "Creating Router 7893"
set node(7893) [$ns node]
set BGP7893 [new Application/Route/Bgp]
$BGP7893 register  $r

$BGP7893 config-file $opt(dir)/bgpd7893.conf
$BGP7893 attach-node $node(7893)
$ns at 316 "$BGP7893 command \"show ip bgp\""

#puts "Creating Router 7894"
set node(7894) [$ns node]
set BGP7894 [new Application/Route/Bgp]
$BGP7894 register  $r

$BGP7894 config-file $opt(dir)/bgpd7894.conf
$BGP7894 attach-node $node(7894)
$ns at 316 "$BGP7894 command \"show ip bgp\""

#puts "Creating Router 7908"
set node(7908) [$ns node]
set BGP7908 [new Application/Route/Bgp]
$BGP7908 register  $r

$BGP7908 config-file $opt(dir)/bgpd7908.conf
$BGP7908 attach-node $node(7908)
$ns at 316 "$BGP7908 command \"show ip bgp\""

#puts "Creating Router 7915"
set node(7915) [$ns node]
set BGP7915 [new Application/Route/Bgp]
$BGP7915 register  $r

$BGP7915 config-file $opt(dir)/bgpd7915.conf
$BGP7915 attach-node $node(7915)
$ns at 316 "$BGP7915 command \"show ip bgp\""

#puts "Creating Router 7922"
set node(7922) [$ns node]
set BGP7922 [new Application/Route/Bgp]
$BGP7922 register  $r

$BGP7922 config-file $opt(dir)/bgpd7922.conf
$BGP7922 attach-node $node(7922)
$ns at 316 "$BGP7922 command \"show ip bgp\""

#puts "Creating Router 7927"
set node(7927) [$ns node]
set BGP7927 [new Application/Route/Bgp]
$BGP7927 register  $r

$BGP7927 config-file $opt(dir)/bgpd7927.conf
$BGP7927 attach-node $node(7927)
$ns at 316 "$BGP7927 command \"show ip bgp\""

#puts "Creating Router 7928"
set node(7928) [$ns node]
set BGP7928 [new Application/Route/Bgp]
$BGP7928 register  $r

$BGP7928 config-file $opt(dir)/bgpd7928.conf
$BGP7928 attach-node $node(7928)
$ns at 316 "$BGP7928 command \"show ip bgp\""

#puts "Creating Router 7934"
set node(7934) [$ns node]
set BGP7934 [new Application/Route/Bgp]
$BGP7934 register  $r

$BGP7934 config-file $opt(dir)/bgpd7934.conf
$BGP7934 attach-node $node(7934)
$ns at 316 "$BGP7934 command \"show ip bgp\""

#puts "Creating Router 7949"
set node(7949) [$ns node]
set BGP7949 [new Application/Route/Bgp]
$BGP7949 register  $r

$BGP7949 config-file $opt(dir)/bgpd7949.conf
$BGP7949 attach-node $node(7949)
$ns at 316 "$BGP7949 command \"show ip bgp\""

#puts "Creating Router 7951"
set node(7951) [$ns node]
set BGP7951 [new Application/Route/Bgp]
$BGP7951 register  $r

$BGP7951 config-file $opt(dir)/bgpd7951.conf
$BGP7951 attach-node $node(7951)
$ns at 316 "$BGP7951 command \"show ip bgp\""

#puts "Creating Router 7960"
set node(7960) [$ns node]
set BGP7960 [new Application/Route/Bgp]
$BGP7960 register  $r

$BGP7960 config-file $opt(dir)/bgpd7960.conf
$BGP7960 attach-node $node(7960)
$ns at 316 "$BGP7960 command \"show ip bgp\""

#puts "Creating Router 7966"
set node(7966) [$ns node]
set BGP7966 [new Application/Route/Bgp]
$BGP7966 register  $r

$BGP7966 config-file $opt(dir)/bgpd7966.conf
$BGP7966 attach-node $node(7966)
$ns at 316 "$BGP7966 command \"show ip bgp\""

#puts "Creating Router 7973"
set node(7973) [$ns node]
set BGP7973 [new Application/Route/Bgp]
$BGP7973 register  $r

$BGP7973 config-file $opt(dir)/bgpd7973.conf
$BGP7973 attach-node $node(7973)
$ns at 316 "$BGP7973 command \"show ip bgp\""

#puts "Creating Router 7980"
set node(7980) [$ns node]
set BGP7980 [new Application/Route/Bgp]
$BGP7980 register  $r

$BGP7980 config-file $opt(dir)/bgpd7980.conf
$BGP7980 attach-node $node(7980)
$ns at 316 "$BGP7980 command \"show ip bgp\""

#puts "Creating Router 7982"
set node(7982) [$ns node]
set BGP7982 [new Application/Route/Bgp]
$BGP7982 register  $r

$BGP7982 config-file $opt(dir)/bgpd7982.conf
$BGP7982 attach-node $node(7982)
$ns at 316 "$BGP7982 command \"show ip bgp\""

#puts "Creating Router 7992"
set node(7992) [$ns node]
set BGP7992 [new Application/Route/Bgp]
$BGP7992 register  $r

$BGP7992 config-file $opt(dir)/bgpd7992.conf
$BGP7992 attach-node $node(7992)
$ns at 316 "$BGP7992 command \"show ip bgp\""

#puts "Creating Router 7996"
set node(7996) [$ns node]
set BGP7996 [new Application/Route/Bgp]
$BGP7996 register  $r

$BGP7996 config-file $opt(dir)/bgpd7996.conf
$BGP7996 attach-node $node(7996)
$ns at 316 "$BGP7996 command \"show ip bgp\""

#puts "Creating Router 7997"
set node(7997) [$ns node]
set BGP7997 [new Application/Route/Bgp]
$BGP7997 register  $r

$BGP7997 config-file $opt(dir)/bgpd7997.conf
$BGP7997 attach-node $node(7997)
$ns at 316 "$BGP7997 command \"show ip bgp\""

#puts "Creating Router 8001"
set node(8001) [$ns node]
set BGP8001 [new Application/Route/Bgp]
$BGP8001 register  $r

$BGP8001 config-file $opt(dir)/bgpd8001.conf
$BGP8001 attach-node $node(8001)
$ns at 316 "$BGP8001 command \"show ip bgp\""

#puts "Creating Router 8007"
set node(8007) [$ns node]
set BGP8007 [new Application/Route/Bgp]
$BGP8007 register  $r

$BGP8007 config-file $opt(dir)/bgpd8007.conf
$BGP8007 attach-node $node(8007)
$ns at 316 "$BGP8007 command \"show ip bgp\""

#puts "Creating Router 8011"
set node(8011) [$ns node]
set BGP8011 [new Application/Route/Bgp]
$BGP8011 register  $r

$BGP8011 config-file $opt(dir)/bgpd8011.conf
$BGP8011 attach-node $node(8011)
$ns at 316 "$BGP8011 command \"show ip bgp\""

#puts "Creating Router 8015"
set node(8015) [$ns node]
set BGP8015 [new Application/Route/Bgp]
$BGP8015 register  $r

$BGP8015 config-file $opt(dir)/bgpd8015.conf
$BGP8015 attach-node $node(8015)
$ns at 316 "$BGP8015 command \"show ip bgp\""

#puts "Creating Router 8018"
set node(8018) [$ns node]
set BGP8018 [new Application/Route/Bgp]
$BGP8018 register  $r

$BGP8018 config-file $opt(dir)/bgpd8018.conf
$BGP8018 attach-node $node(8018)
$ns at 316 "$BGP8018 command \"show ip bgp\""

#puts "Creating Router 8036"
set node(8036) [$ns node]
set BGP8036 [new Application/Route/Bgp]
$BGP8036 register  $r

$BGP8036 config-file $opt(dir)/bgpd8036.conf
$BGP8036 attach-node $node(8036)
$ns at 316 "$BGP8036 command \"show ip bgp\""

#puts "Creating Router 8041"
set node(8041) [$ns node]
set BGP8041 [new Application/Route/Bgp]
$BGP8041 register  $r

$BGP8041 config-file $opt(dir)/bgpd8041.conf
$BGP8041 attach-node $node(8041)
$ns at 316 "$BGP8041 command \"show ip bgp\""

#puts "Creating Router 8043"
set node(8043) [$ns node]
set BGP8043 [new Application/Route/Bgp]
$BGP8043 register  $r

$BGP8043 config-file $opt(dir)/bgpd8043.conf
$BGP8043 attach-node $node(8043)
$ns at 316 "$BGP8043 command \"show ip bgp\""

#puts "Creating Router 8046"
set node(8046) [$ns node]
set BGP8046 [new Application/Route/Bgp]
$BGP8046 register  $r

$BGP8046 config-file $opt(dir)/bgpd8046.conf
$BGP8046 attach-node $node(8046)
$ns at 316 "$BGP8046 command \"show ip bgp\""

#puts "Creating Router 8048"
set node(8048) [$ns node]
set BGP8048 [new Application/Route/Bgp]
$BGP8048 register  $r

$BGP8048 config-file $opt(dir)/bgpd8048.conf
$BGP8048 attach-node $node(8048)
$ns at 316 "$BGP8048 command \"show ip bgp\""

#puts "Creating Router 8056"
set node(8056) [$ns node]
set BGP8056 [new Application/Route/Bgp]
$BGP8056 register  $r

$BGP8056 config-file $opt(dir)/bgpd8056.conf
$BGP8056 attach-node $node(8056)
$ns at 316 "$BGP8056 command \"show ip bgp\""

#puts "Creating Router 8058"
set node(8058) [$ns node]
set BGP8058 [new Application/Route/Bgp]
$BGP8058 register  $r

$BGP8058 config-file $opt(dir)/bgpd8058.conf
$BGP8058 attach-node $node(8058)
$ns at 316 "$BGP8058 command \"show ip bgp\""

#puts "Creating Router 8060"
set node(8060) [$ns node]
set BGP8060 [new Application/Route/Bgp]
$BGP8060 register  $r

$BGP8060 config-file $opt(dir)/bgpd8060.conf
$BGP8060 attach-node $node(8060)
$ns at 316 "$BGP8060 command \"show ip bgp\""

#puts "Creating Router 8061"
set node(8061) [$ns node]
set BGP8061 [new Application/Route/Bgp]
$BGP8061 register  $r

$BGP8061 config-file $opt(dir)/bgpd8061.conf
$BGP8061 attach-node $node(8061)
$ns at 316 "$BGP8061 command \"show ip bgp\""

#puts "Creating Router 8062"
set node(8062) [$ns node]
set BGP8062 [new Application/Route/Bgp]
$BGP8062 register  $r

$BGP8062 config-file $opt(dir)/bgpd8062.conf
$BGP8062 attach-node $node(8062)
$ns at 316 "$BGP8062 command \"show ip bgp\""

#puts "Creating Router 8063"
set node(8063) [$ns node]
set BGP8063 [new Application/Route/Bgp]
$BGP8063 register  $r

$BGP8063 config-file $opt(dir)/bgpd8063.conf
$BGP8063 attach-node $node(8063)
$ns at 316 "$BGP8063 command \"show ip bgp\""

#puts "Creating Router 8066"
set node(8066) [$ns node]
set BGP8066 [new Application/Route/Bgp]
$BGP8066 register  $r

$BGP8066 config-file $opt(dir)/bgpd8066.conf
$BGP8066 attach-node $node(8066)
$ns at 316 "$BGP8066 command \"show ip bgp\""

#puts "Creating Router 8081"
set node(8081) [$ns node]
set BGP8081 [new Application/Route/Bgp]
$BGP8081 register  $r

$BGP8081 config-file $opt(dir)/bgpd8081.conf
$BGP8081 attach-node $node(8081)
$ns at 316 "$BGP8081 command \"show ip bgp\""

#puts "Creating Router 8091"
set node(8091) [$ns node]
set BGP8091 [new Application/Route/Bgp]
$BGP8091 register  $r

$BGP8091 config-file $opt(dir)/bgpd8091.conf
$BGP8091 attach-node $node(8091)
$ns at 316 "$BGP8091 command \"show ip bgp\""

#puts "Creating Router 8094"
set node(8094) [$ns node]
set BGP8094 [new Application/Route/Bgp]
$BGP8094 register  $r

$BGP8094 config-file $opt(dir)/bgpd8094.conf
$BGP8094 attach-node $node(8094)
$ns at 316 "$BGP8094 command \"show ip bgp\""

#puts "Creating Router 81"
set node(81) [$ns node]
set BGP81 [new Application/Route/Bgp]
$BGP81 register  $r

$BGP81 config-file $opt(dir)/bgpd81.conf
$BGP81 attach-node $node(81)
$ns at 316 "$BGP81 command \"show ip bgp\""

#puts "Creating Router 8100"
set node(8100) [$ns node]
set BGP8100 [new Application/Route/Bgp]
$BGP8100 register  $r

$BGP8100 config-file $opt(dir)/bgpd8100.conf
$BGP8100 attach-node $node(8100)
$ns at 316 "$BGP8100 command \"show ip bgp\""

#puts "Creating Router 8101"
set node(8101) [$ns node]
set BGP8101 [new Application/Route/Bgp]
$BGP8101 register  $r

$BGP8101 config-file $opt(dir)/bgpd8101.conf
$BGP8101 attach-node $node(8101)
$ns at 316 "$BGP8101 command \"show ip bgp\""

#puts "Creating Router 8111"
set node(8111) [$ns node]
set BGP8111 [new Application/Route/Bgp]
$BGP8111 register  $r

$BGP8111 config-file $opt(dir)/bgpd8111.conf
$BGP8111 attach-node $node(8111)
$ns at 316 "$BGP8111 command \"show ip bgp\""

#puts "Creating Router 8114"
set node(8114) [$ns node]
set BGP8114 [new Application/Route/Bgp]
$BGP8114 register  $r

$BGP8114 config-file $opt(dir)/bgpd8114.conf
$BGP8114 attach-node $node(8114)
$ns at 316 "$BGP8114 command \"show ip bgp\""

#puts "Creating Router 8119"
set node(8119) [$ns node]
set BGP8119 [new Application/Route/Bgp]
$BGP8119 register  $r

$BGP8119 config-file $opt(dir)/bgpd8119.conf
$BGP8119 attach-node $node(8119)
$ns at 316 "$BGP8119 command \"show ip bgp\""

#puts "Creating Router 812"
set node(812) [$ns node]
set BGP812 [new Application/Route/Bgp]
$BGP812 register  $r

$BGP812 config-file $opt(dir)/bgpd812.conf
$BGP812 attach-node $node(812)
$ns at 316 "$BGP812 command \"show ip bgp\""

#puts "Creating Router 8120"
set node(8120) [$ns node]
set BGP8120 [new Application/Route/Bgp]
$BGP8120 register  $r

$BGP8120 config-file $opt(dir)/bgpd8120.conf
$BGP8120 attach-node $node(8120)
$ns at 316 "$BGP8120 command \"show ip bgp\""

#puts "Creating Router 8121"
set node(8121) [$ns node]
set BGP8121 [new Application/Route/Bgp]
$BGP8121 register  $r

$BGP8121 config-file $opt(dir)/bgpd8121.conf
$BGP8121 attach-node $node(8121)
$ns at 316 "$BGP8121 command \"show ip bgp\""

#puts "Creating Router 8125"
set node(8125) [$ns node]
set BGP8125 [new Application/Route/Bgp]
$BGP8125 register  $r

$BGP8125 config-file $opt(dir)/bgpd8125.conf
$BGP8125 attach-node $node(8125)
$ns at 316 "$BGP8125 command \"show ip bgp\""

#puts "Creating Router 8135"
set node(8135) [$ns node]
set BGP8135 [new Application/Route/Bgp]
$BGP8135 register  $r

$BGP8135 config-file $opt(dir)/bgpd8135.conf
$BGP8135 attach-node $node(8135)
$ns at 316 "$BGP8135 command \"show ip bgp\""

#puts "Creating Router 8138"
set node(8138) [$ns node]
set BGP8138 [new Application/Route/Bgp]
$BGP8138 register  $r

$BGP8138 config-file $opt(dir)/bgpd8138.conf
$BGP8138 attach-node $node(8138)
$ns at 316 "$BGP8138 command \"show ip bgp\""

#puts "Creating Router 814"
set node(814) [$ns node]
set BGP814 [new Application/Route/Bgp]
$BGP814 register  $r

$BGP814 config-file $opt(dir)/bgpd814.conf
$BGP814 attach-node $node(814)
$ns at 316 "$BGP814 command \"show ip bgp\""

#puts "Creating Router 8142"
set node(8142) [$ns node]
set BGP8142 [new Application/Route/Bgp]
$BGP8142 register  $r

$BGP8142 config-file $opt(dir)/bgpd8142.conf
$BGP8142 attach-node $node(8142)
$ns at 316 "$BGP8142 command \"show ip bgp\""

#puts "Creating Router 8148"
set node(8148) [$ns node]
set BGP8148 [new Application/Route/Bgp]
$BGP8148 register  $r

$BGP8148 config-file $opt(dir)/bgpd8148.conf
$BGP8148 attach-node $node(8148)
$ns at 316 "$BGP8148 command \"show ip bgp\""

#puts "Creating Router 815"
set node(815) [$ns node]
set BGP815 [new Application/Route/Bgp]
$BGP815 register  $r

$BGP815 config-file $opt(dir)/bgpd815.conf
$BGP815 attach-node $node(815)
$ns at 316 "$BGP815 command \"show ip bgp\""

#puts "Creating Router 8151"
set node(8151) [$ns node]
set BGP8151 [new Application/Route/Bgp]
$BGP8151 register  $r

$BGP8151 config-file $opt(dir)/bgpd8151.conf
$BGP8151 attach-node $node(8151)
$ns at 316 "$BGP8151 command \"show ip bgp\""

#puts "Creating Router 816"
set node(816) [$ns node]
set BGP816 [new Application/Route/Bgp]
$BGP816 register  $r

$BGP816 config-file $opt(dir)/bgpd816.conf
$BGP816 attach-node $node(816)
$ns at 316 "$BGP816 command \"show ip bgp\""

#puts "Creating Router 8166"
set node(8166) [$ns node]
set BGP8166 [new Application/Route/Bgp]
$BGP8166 register  $r

$BGP8166 config-file $opt(dir)/bgpd8166.conf
$BGP8166 attach-node $node(8166)
$ns at 316 "$BGP8166 command \"show ip bgp\""

#puts "Creating Router 817"
set node(817) [$ns node]
set BGP817 [new Application/Route/Bgp]
$BGP817 register  $r

$BGP817 config-file $opt(dir)/bgpd817.conf
$BGP817 attach-node $node(817)
$ns at 316 "$BGP817 command \"show ip bgp\""

#puts "Creating Router 8175"
set node(8175) [$ns node]
set BGP8175 [new Application/Route/Bgp]
$BGP8175 register  $r

$BGP8175 config-file $opt(dir)/bgpd8175.conf
$BGP8175 attach-node $node(8175)
$ns at 316 "$BGP8175 command \"show ip bgp\""

#puts "Creating Router 8180"
set node(8180) [$ns node]
set BGP8180 [new Application/Route/Bgp]
$BGP8180 register  $r

$BGP8180 config-file $opt(dir)/bgpd8180.conf
$BGP8180 attach-node $node(8180)
$ns at 316 "$BGP8180 command \"show ip bgp\""

#puts "Creating Router 8191"
set node(8191) [$ns node]
set BGP8191 [new Application/Route/Bgp]
$BGP8191 register  $r

$BGP8191 config-file $opt(dir)/bgpd8191.conf
$BGP8191 attach-node $node(8191)
$ns at 316 "$BGP8191 command \"show ip bgp\""

#puts "Creating Router 8196"
set node(8196) [$ns node]
set BGP8196 [new Application/Route/Bgp]
$BGP8196 register  $r

$BGP8196 config-file $opt(dir)/bgpd8196.conf
$BGP8196 attach-node $node(8196)
$ns at 316 "$BGP8196 command \"show ip bgp\""

#puts "Creating Router 8198"
set node(8198) [$ns node]
set BGP8198 [new Application/Route/Bgp]
$BGP8198 register  $r

$BGP8198 config-file $opt(dir)/bgpd8198.conf
$BGP8198 attach-node $node(8198)
$ns at 316 "$BGP8198 command \"show ip bgp\""

#puts "Creating Router 8199"
set node(8199) [$ns node]
set BGP8199 [new Application/Route/Bgp]
$BGP8199 register  $r

$BGP8199 config-file $opt(dir)/bgpd8199.conf
$BGP8199 attach-node $node(8199)
$ns at 316 "$BGP8199 command \"show ip bgp\""

#puts "Creating Router 8200"
set node(8200) [$ns node]
set BGP8200 [new Application/Route/Bgp]
$BGP8200 register  $r

$BGP8200 config-file $opt(dir)/bgpd8200.conf
$BGP8200 attach-node $node(8200)
$ns at 316 "$BGP8200 command \"show ip bgp\""

#puts "Creating Router 8205"
set node(8205) [$ns node]
set BGP8205 [new Application/Route/Bgp]
$BGP8205 register  $r

$BGP8205 config-file $opt(dir)/bgpd8205.conf
$BGP8205 attach-node $node(8205)
$ns at 316 "$BGP8205 command \"show ip bgp\""

#puts "Creating Router 8207"
set node(8207) [$ns node]
set BGP8207 [new Application/Route/Bgp]
$BGP8207 register  $r

$BGP8207 config-file $opt(dir)/bgpd8207.conf
$BGP8207 attach-node $node(8207)
$ns at 316 "$BGP8207 command \"show ip bgp\""

#puts "Creating Router 8208"
set node(8208) [$ns node]
set BGP8208 [new Application/Route/Bgp]
$BGP8208 register  $r

$BGP8208 config-file $opt(dir)/bgpd8208.conf
$BGP8208 attach-node $node(8208)
$ns at 316 "$BGP8208 command \"show ip bgp\""

#puts "Creating Router 8210"
set node(8210) [$ns node]
set BGP8210 [new Application/Route/Bgp]
$BGP8210 register  $r

$BGP8210 config-file $opt(dir)/bgpd8210.conf
$BGP8210 attach-node $node(8210)
$ns at 316 "$BGP8210 command \"show ip bgp\""

#puts "Creating Router 8211"
set node(8211) [$ns node]
set BGP8211 [new Application/Route/Bgp]
$BGP8211 register  $r

$BGP8211 config-file $opt(dir)/bgpd8211.conf
$BGP8211 attach-node $node(8211)
$ns at 316 "$BGP8211 command \"show ip bgp\""

#puts "Creating Router 8213"
set node(8213) [$ns node]
set BGP8213 [new Application/Route/Bgp]
$BGP8213 register  $r

$BGP8213 config-file $opt(dir)/bgpd8213.conf
$BGP8213 attach-node $node(8213)
$ns at 316 "$BGP8213 command \"show ip bgp\""

#puts "Creating Router 8215"
set node(8215) [$ns node]
set BGP8215 [new Application/Route/Bgp]
$BGP8215 register  $r

$BGP8215 config-file $opt(dir)/bgpd8215.conf
$BGP8215 attach-node $node(8215)
$ns at 316 "$BGP8215 command \"show ip bgp\""

#puts "Creating Router 8216"
set node(8216) [$ns node]
set BGP8216 [new Application/Route/Bgp]
$BGP8216 register  $r

$BGP8216 config-file $opt(dir)/bgpd8216.conf
$BGP8216 attach-node $node(8216)
$ns at 316 "$BGP8216 command \"show ip bgp\""

#puts "Creating Router 8217"
set node(8217) [$ns node]
set BGP8217 [new Application/Route/Bgp]
$BGP8217 register  $r

$BGP8217 config-file $opt(dir)/bgpd8217.conf
$BGP8217 attach-node $node(8217)
$ns at 316 "$BGP8217 command \"show ip bgp\""

#puts "Creating Router 8220"
set node(8220) [$ns node]
set BGP8220 [new Application/Route/Bgp]
$BGP8220 register  $r

$BGP8220 config-file $opt(dir)/bgpd8220.conf
$BGP8220 attach-node $node(8220)
$ns at 316 "$BGP8220 command \"show ip bgp\""

#puts "Creating Router 8223"
set node(8223) [$ns node]
set BGP8223 [new Application/Route/Bgp]
$BGP8223 register  $r

$BGP8223 config-file $opt(dir)/bgpd8223.conf
$BGP8223 attach-node $node(8223)
$ns at 316 "$BGP8223 command \"show ip bgp\""

#puts "Creating Router 8225"
set node(8225) [$ns node]
set BGP8225 [new Application/Route/Bgp]
$BGP8225 register  $r

$BGP8225 config-file $opt(dir)/bgpd8225.conf
$BGP8225 attach-node $node(8225)
$ns at 316 "$BGP8225 command \"show ip bgp\""

#puts "Creating Router 8228"
set node(8228) [$ns node]
set BGP8228 [new Application/Route/Bgp]
$BGP8228 register  $r

$BGP8228 config-file $opt(dir)/bgpd8228.conf
$BGP8228 attach-node $node(8228)
$ns at 316 "$BGP8228 command \"show ip bgp\""

#puts "Creating Router 8231"
set node(8231) [$ns node]
set BGP8231 [new Application/Route/Bgp]
$BGP8231 register  $r

$BGP8231 config-file $opt(dir)/bgpd8231.conf
$BGP8231 attach-node $node(8231)
$ns at 316 "$BGP8231 command \"show ip bgp\""

#puts "Creating Router 8245"
set node(8245) [$ns node]
set BGP8245 [new Application/Route/Bgp]
$BGP8245 register  $r

$BGP8245 config-file $opt(dir)/bgpd8245.conf
$BGP8245 attach-node $node(8245)
$ns at 316 "$BGP8245 command \"show ip bgp\""

#puts "Creating Router 8246"
set node(8246) [$ns node]
set BGP8246 [new Application/Route/Bgp]
$BGP8246 register  $r

$BGP8246 config-file $opt(dir)/bgpd8246.conf
$BGP8246 attach-node $node(8246)
$ns at 316 "$BGP8246 command \"show ip bgp\""

#puts "Creating Router 8249"
set node(8249) [$ns node]
set BGP8249 [new Application/Route/Bgp]
$BGP8249 register  $r

$BGP8249 config-file $opt(dir)/bgpd8249.conf
$BGP8249 attach-node $node(8249)
$ns at 316 "$BGP8249 command \"show ip bgp\""

#puts "Creating Router 8250"
set node(8250) [$ns node]
set BGP8250 [new Application/Route/Bgp]
$BGP8250 register  $r

$BGP8250 config-file $opt(dir)/bgpd8250.conf
$BGP8250 attach-node $node(8250)
$ns at 316 "$BGP8250 command \"show ip bgp\""

#puts "Creating Router 8251"
set node(8251) [$ns node]
set BGP8251 [new Application/Route/Bgp]
$BGP8251 register  $r

$BGP8251 config-file $opt(dir)/bgpd8251.conf
$BGP8251 attach-node $node(8251)
$ns at 316 "$BGP8251 command \"show ip bgp\""

#puts "Creating Router 8253"
set node(8253) [$ns node]
set BGP8253 [new Application/Route/Bgp]
$BGP8253 register  $r

$BGP8253 config-file $opt(dir)/bgpd8253.conf
$BGP8253 attach-node $node(8253)
$ns at 316 "$BGP8253 command \"show ip bgp\""

#puts "Creating Router 8257"
set node(8257) [$ns node]
set BGP8257 [new Application/Route/Bgp]
$BGP8257 register  $r

$BGP8257 config-file $opt(dir)/bgpd8257.conf
$BGP8257 attach-node $node(8257)
$ns at 316 "$BGP8257 command \"show ip bgp\""

#puts "Creating Router 8258"
set node(8258) [$ns node]
set BGP8258 [new Application/Route/Bgp]
$BGP8258 register  $r

$BGP8258 config-file $opt(dir)/bgpd8258.conf
$BGP8258 attach-node $node(8258)
$ns at 316 "$BGP8258 command \"show ip bgp\""

#puts "Creating Router 8259"
set node(8259) [$ns node]
set BGP8259 [new Application/Route/Bgp]
$BGP8259 register  $r

$BGP8259 config-file $opt(dir)/bgpd8259.conf
$BGP8259 attach-node $node(8259)
$ns at 316 "$BGP8259 command \"show ip bgp\""

#puts "Creating Router 8262"
set node(8262) [$ns node]
set BGP8262 [new Application/Route/Bgp]
$BGP8262 register  $r

$BGP8262 config-file $opt(dir)/bgpd8262.conf
$BGP8262 attach-node $node(8262)
$ns at 316 "$BGP8262 command \"show ip bgp\""

#puts "Creating Router 8263"
set node(8263) [$ns node]
set BGP8263 [new Application/Route/Bgp]
$BGP8263 register  $r

$BGP8263 config-file $opt(dir)/bgpd8263.conf
$BGP8263 attach-node $node(8263)
$ns at 316 "$BGP8263 command \"show ip bgp\""

#puts "Creating Router 8264"
set node(8264) [$ns node]
set BGP8264 [new Application/Route/Bgp]
$BGP8264 register  $r

$BGP8264 config-file $opt(dir)/bgpd8264.conf
$BGP8264 attach-node $node(8264)
$ns at 316 "$BGP8264 command \"show ip bgp\""

#puts "Creating Router 8265"
set node(8265) [$ns node]
set BGP8265 [new Application/Route/Bgp]
$BGP8265 register  $r

$BGP8265 config-file $opt(dir)/bgpd8265.conf
$BGP8265 attach-node $node(8265)
$ns at 316 "$BGP8265 command \"show ip bgp\""

#puts "Creating Router 8267"
set node(8267) [$ns node]
set BGP8267 [new Application/Route/Bgp]
$BGP8267 register  $r

$BGP8267 config-file $opt(dir)/bgpd8267.conf
$BGP8267 attach-node $node(8267)
$ns at 316 "$BGP8267 command \"show ip bgp\""

#puts "Creating Router 8269"
set node(8269) [$ns node]
set BGP8269 [new Application/Route/Bgp]
$BGP8269 register  $r

$BGP8269 config-file $opt(dir)/bgpd8269.conf
$BGP8269 attach-node $node(8269)
$ns at 316 "$BGP8269 command \"show ip bgp\""

#puts "Creating Router 8271"
set node(8271) [$ns node]
set BGP8271 [new Application/Route/Bgp]
$BGP8271 register  $r

$BGP8271 config-file $opt(dir)/bgpd8271.conf
$BGP8271 attach-node $node(8271)
$ns at 316 "$BGP8271 command \"show ip bgp\""

#puts "Creating Router 8272"
set node(8272) [$ns node]
set BGP8272 [new Application/Route/Bgp]
$BGP8272 register  $r

$BGP8272 config-file $opt(dir)/bgpd8272.conf
$BGP8272 attach-node $node(8272)
$ns at 316 "$BGP8272 command \"show ip bgp\""

#puts "Creating Router 8275"
set node(8275) [$ns node]
set BGP8275 [new Application/Route/Bgp]
$BGP8275 register  $r

$BGP8275 config-file $opt(dir)/bgpd8275.conf
$BGP8275 attach-node $node(8275)
$ns at 316 "$BGP8275 command \"show ip bgp\""

#puts "Creating Router 8277"
set node(8277) [$ns node]
set BGP8277 [new Application/Route/Bgp]
$BGP8277 register  $r

$BGP8277 config-file $opt(dir)/bgpd8277.conf
$BGP8277 attach-node $node(8277)
$ns at 316 "$BGP8277 command \"show ip bgp\""

#puts "Creating Router 8278"
set node(8278) [$ns node]
set BGP8278 [new Application/Route/Bgp]
$BGP8278 register  $r

$BGP8278 config-file $opt(dir)/bgpd8278.conf
$BGP8278 attach-node $node(8278)
$ns at 316 "$BGP8278 command \"show ip bgp\""

#puts "Creating Router 8280"
set node(8280) [$ns node]
set BGP8280 [new Application/Route/Bgp]
$BGP8280 register  $r

$BGP8280 config-file $opt(dir)/bgpd8280.conf
$BGP8280 attach-node $node(8280)
$ns at 316 "$BGP8280 command \"show ip bgp\""

#puts "Creating Router 8284"
set node(8284) [$ns node]
set BGP8284 [new Application/Route/Bgp]
$BGP8284 register  $r

$BGP8284 config-file $opt(dir)/bgpd8284.conf
$BGP8284 attach-node $node(8284)
$ns at 316 "$BGP8284 command \"show ip bgp\""

#puts "Creating Router 8291"
set node(8291) [$ns node]
set BGP8291 [new Application/Route/Bgp]
$BGP8291 register  $r

$BGP8291 config-file $opt(dir)/bgpd8291.conf
$BGP8291 attach-node $node(8291)
$ns at 316 "$BGP8291 command \"show ip bgp\""

#puts "Creating Router 8294"
set node(8294) [$ns node]
set BGP8294 [new Application/Route/Bgp]
$BGP8294 register  $r

$BGP8294 config-file $opt(dir)/bgpd8294.conf
$BGP8294 attach-node $node(8294)
$ns at 316 "$BGP8294 command \"show ip bgp\""

#puts "Creating Router 8296"
set node(8296) [$ns node]
set BGP8296 [new Application/Route/Bgp]
$BGP8296 register  $r

$BGP8296 config-file $opt(dir)/bgpd8296.conf
$BGP8296 attach-node $node(8296)
$ns at 316 "$BGP8296 command \"show ip bgp\""

#puts "Creating Router 8297"
set node(8297) [$ns node]
set BGP8297 [new Application/Route/Bgp]
$BGP8297 register  $r

$BGP8297 config-file $opt(dir)/bgpd8297.conf
$BGP8297 attach-node $node(8297)
$ns at 316 "$BGP8297 command \"show ip bgp\""

#puts "Creating Router 83"
set node(83) [$ns node]
set BGP83 [new Application/Route/Bgp]
$BGP83 register  $r

$BGP83 config-file $opt(dir)/bgpd83.conf
$BGP83 attach-node $node(83)
$ns at 316 "$BGP83 command \"show ip bgp\""

#puts "Creating Router 8300"
set node(8300) [$ns node]
set BGP8300 [new Application/Route/Bgp]
$BGP8300 register  $r

$BGP8300 config-file $opt(dir)/bgpd8300.conf
$BGP8300 attach-node $node(8300)
$ns at 316 "$BGP8300 command \"show ip bgp\""

#puts "Creating Router 8306"
set node(8306) [$ns node]
set BGP8306 [new Application/Route/Bgp]
$BGP8306 register  $r

$BGP8306 config-file $opt(dir)/bgpd8306.conf
$BGP8306 attach-node $node(8306)
$ns at 316 "$BGP8306 command \"show ip bgp\""

#puts "Creating Router 8309"
set node(8309) [$ns node]
set BGP8309 [new Application/Route/Bgp]
$BGP8309 register  $r

$BGP8309 config-file $opt(dir)/bgpd8309.conf
$BGP8309 attach-node $node(8309)
$ns at 316 "$BGP8309 command \"show ip bgp\""

#puts "Creating Router 8313"
set node(8313) [$ns node]
set BGP8313 [new Application/Route/Bgp]
$BGP8313 register  $r

$BGP8313 config-file $opt(dir)/bgpd8313.conf
$BGP8313 attach-node $node(8313)
$ns at 316 "$BGP8313 command \"show ip bgp\""

#puts "Creating Router 8314"
set node(8314) [$ns node]
set BGP8314 [new Application/Route/Bgp]
$BGP8314 register  $r

$BGP8314 config-file $opt(dir)/bgpd8314.conf
$BGP8314 attach-node $node(8314)
$ns at 316 "$BGP8314 command \"show ip bgp\""

#puts "Creating Router 8316"
set node(8316) [$ns node]
set BGP8316 [new Application/Route/Bgp]
$BGP8316 register  $r

$BGP8316 config-file $opt(dir)/bgpd8316.conf
$BGP8316 attach-node $node(8316)
$ns at 316 "$BGP8316 command \"show ip bgp\""

#puts "Creating Router 8319"
set node(8319) [$ns node]
set BGP8319 [new Application/Route/Bgp]
$BGP8319 register  $r

$BGP8319 config-file $opt(dir)/bgpd8319.conf
$BGP8319 attach-node $node(8319)
$ns at 316 "$BGP8319 command \"show ip bgp\""

#puts "Creating Router 8321"
set node(8321) [$ns node]
set BGP8321 [new Application/Route/Bgp]
$BGP8321 register  $r

$BGP8321 config-file $opt(dir)/bgpd8321.conf
$BGP8321 attach-node $node(8321)
$ns at 316 "$BGP8321 command \"show ip bgp\""

#puts "Creating Router 8327"
set node(8327) [$ns node]
set BGP8327 [new Application/Route/Bgp]
$BGP8327 register  $r

$BGP8327 config-file $opt(dir)/bgpd8327.conf
$BGP8327 attach-node $node(8327)
$ns at 316 "$BGP8327 command \"show ip bgp\""

#puts "Creating Router 8328"
set node(8328) [$ns node]
set BGP8328 [new Application/Route/Bgp]
$BGP8328 register  $r

$BGP8328 config-file $opt(dir)/bgpd8328.conf
$BGP8328 attach-node $node(8328)
$ns at 316 "$BGP8328 command \"show ip bgp\""

#puts "Creating Router 8330"
set node(8330) [$ns node]
set BGP8330 [new Application/Route/Bgp]
$BGP8330 register  $r

$BGP8330 config-file $opt(dir)/bgpd8330.conf
$BGP8330 attach-node $node(8330)
$ns at 316 "$BGP8330 command \"show ip bgp\""

#puts "Creating Router 8331"
set node(8331) [$ns node]
set BGP8331 [new Application/Route/Bgp]
$BGP8331 register  $r

$BGP8331 config-file $opt(dir)/bgpd8331.conf
$BGP8331 attach-node $node(8331)
$ns at 316 "$BGP8331 command \"show ip bgp\""

#puts "Creating Router 8334"
set node(8334) [$ns node]
set BGP8334 [new Application/Route/Bgp]
$BGP8334 register  $r

$BGP8334 config-file $opt(dir)/bgpd8334.conf
$BGP8334 attach-node $node(8334)
$ns at 316 "$BGP8334 command \"show ip bgp\""

#puts "Creating Router 8336"
set node(8336) [$ns node]
set BGP8336 [new Application/Route/Bgp]
$BGP8336 register  $r

$BGP8336 config-file $opt(dir)/bgpd8336.conf
$BGP8336 attach-node $node(8336)
$ns at 316 "$BGP8336 command \"show ip bgp\""

#puts "Creating Router 8340"
set node(8340) [$ns node]
set BGP8340 [new Application/Route/Bgp]
$BGP8340 register  $r

$BGP8340 config-file $opt(dir)/bgpd8340.conf
$BGP8340 attach-node $node(8340)
$ns at 316 "$BGP8340 command \"show ip bgp\""

#puts "Creating Router 8342"
set node(8342) [$ns node]
set BGP8342 [new Application/Route/Bgp]
$BGP8342 register  $r

$BGP8342 config-file $opt(dir)/bgpd8342.conf
$BGP8342 attach-node $node(8342)
$ns at 316 "$BGP8342 command \"show ip bgp\""

#puts "Creating Router 8343"
set node(8343) [$ns node]
set BGP8343 [new Application/Route/Bgp]
$BGP8343 register  $r

$BGP8343 config-file $opt(dir)/bgpd8343.conf
$BGP8343 attach-node $node(8343)
$ns at 316 "$BGP8343 command \"show ip bgp\""

#puts "Creating Router 8346"
set node(8346) [$ns node]
set BGP8346 [new Application/Route/Bgp]
$BGP8346 register  $r

$BGP8346 config-file $opt(dir)/bgpd8346.conf
$BGP8346 attach-node $node(8346)
$ns at 316 "$BGP8346 command \"show ip bgp\""

#puts "Creating Router 8349"
set node(8349) [$ns node]
set BGP8349 [new Application/Route/Bgp]
$BGP8349 register  $r

$BGP8349 config-file $opt(dir)/bgpd8349.conf
$BGP8349 attach-node $node(8349)
$ns at 316 "$BGP8349 command \"show ip bgp\""

#puts "Creating Router 8350"
set node(8350) [$ns node]
set BGP8350 [new Application/Route/Bgp]
$BGP8350 register  $r

$BGP8350 config-file $opt(dir)/bgpd8350.conf
$BGP8350 attach-node $node(8350)
$ns at 316 "$BGP8350 command \"show ip bgp\""

#puts "Creating Router 8352"
set node(8352) [$ns node]
set BGP8352 [new Application/Route/Bgp]
$BGP8352 register  $r

$BGP8352 config-file $opt(dir)/bgpd8352.conf
$BGP8352 attach-node $node(8352)
$ns at 316 "$BGP8352 command \"show ip bgp\""

#puts "Creating Router 8359"
set node(8359) [$ns node]
set BGP8359 [new Application/Route/Bgp]
$BGP8359 register  $r

$BGP8359 config-file $opt(dir)/bgpd8359.conf
$BGP8359 attach-node $node(8359)
$ns at 316 "$BGP8359 command \"show ip bgp\""

#puts "Creating Router 8361"
set node(8361) [$ns node]
set BGP8361 [new Application/Route/Bgp]
$BGP8361 register  $r

$BGP8361 config-file $opt(dir)/bgpd8361.conf
$BGP8361 attach-node $node(8361)
$ns at 316 "$BGP8361 command \"show ip bgp\""

#puts "Creating Router 8363"
set node(8363) [$ns node]
set BGP8363 [new Application/Route/Bgp]
$BGP8363 register  $r

$BGP8363 config-file $opt(dir)/bgpd8363.conf
$BGP8363 attach-node $node(8363)
$ns at 316 "$BGP8363 command \"show ip bgp\""

#puts "Creating Router 8366"
set node(8366) [$ns node]
set BGP8366 [new Application/Route/Bgp]
$BGP8366 register  $r

$BGP8366 config-file $opt(dir)/bgpd8366.conf
$BGP8366 attach-node $node(8366)
$ns at 316 "$BGP8366 command \"show ip bgp\""

#puts "Creating Router 8374"
set node(8374) [$ns node]
set BGP8374 [new Application/Route/Bgp]
$BGP8374 register  $r

$BGP8374 config-file $opt(dir)/bgpd8374.conf
$BGP8374 attach-node $node(8374)
$ns at 316 "$BGP8374 command \"show ip bgp\""

#puts "Creating Router 8375"
set node(8375) [$ns node]
set BGP8375 [new Application/Route/Bgp]
$BGP8375 register  $r

$BGP8375 config-file $opt(dir)/bgpd8375.conf
$BGP8375 attach-node $node(8375)
$ns at 316 "$BGP8375 command \"show ip bgp\""

#puts "Creating Router 838"
set node(838) [$ns node]
set BGP838 [new Application/Route/Bgp]
$BGP838 register  $r

$BGP838 config-file $opt(dir)/bgpd838.conf
$BGP838 attach-node $node(838)
$ns at 316 "$BGP838 command \"show ip bgp\""

#puts "Creating Router 8385"
set node(8385) [$ns node]
set BGP8385 [new Application/Route/Bgp]
$BGP8385 register  $r

$BGP8385 config-file $opt(dir)/bgpd8385.conf
$BGP8385 attach-node $node(8385)
$ns at 316 "$BGP8385 command \"show ip bgp\""

#puts "Creating Router 8388"
set node(8388) [$ns node]
set BGP8388 [new Application/Route/Bgp]
$BGP8388 register  $r

$BGP8388 config-file $opt(dir)/bgpd8388.conf
$BGP8388 attach-node $node(8388)
$ns at 316 "$BGP8388 command \"show ip bgp\""

#puts "Creating Router 8390"
set node(8390) [$ns node]
set BGP8390 [new Application/Route/Bgp]
$BGP8390 register  $r

$BGP8390 config-file $opt(dir)/bgpd8390.conf
$BGP8390 attach-node $node(8390)
$ns at 316 "$BGP8390 command \"show ip bgp\""

#puts "Creating Router 8391"
set node(8391) [$ns node]
set BGP8391 [new Application/Route/Bgp]
$BGP8391 register  $r

$BGP8391 config-file $opt(dir)/bgpd8391.conf
$BGP8391 attach-node $node(8391)
$ns at 316 "$BGP8391 command \"show ip bgp\""

#puts "Creating Router 8394"
set node(8394) [$ns node]
set BGP8394 [new Application/Route/Bgp]
$BGP8394 register  $r

$BGP8394 config-file $opt(dir)/bgpd8394.conf
$BGP8394 attach-node $node(8394)
$ns at 316 "$BGP8394 command \"show ip bgp\""

#puts "Creating Router 8395"
set node(8395) [$ns node]
set BGP8395 [new Application/Route/Bgp]
$BGP8395 register  $r

$BGP8395 config-file $opt(dir)/bgpd8395.conf
$BGP8395 attach-node $node(8395)
$ns at 316 "$BGP8395 command \"show ip bgp\""

#puts "Creating Router 8396"
set node(8396) [$ns node]
set BGP8396 [new Application/Route/Bgp]
$BGP8396 register  $r

$BGP8396 config-file $opt(dir)/bgpd8396.conf
$BGP8396 attach-node $node(8396)
$ns at 316 "$BGP8396 command \"show ip bgp\""

#puts "Creating Router 8397"
set node(8397) [$ns node]
set BGP8397 [new Application/Route/Bgp]
$BGP8397 register  $r

$BGP8397 config-file $opt(dir)/bgpd8397.conf
$BGP8397 attach-node $node(8397)
$ns at 316 "$BGP8397 command \"show ip bgp\""

#puts "Creating Router 8398"
set node(8398) [$ns node]
set BGP8398 [new Application/Route/Bgp]
$BGP8398 register  $r

$BGP8398 config-file $opt(dir)/bgpd8398.conf
$BGP8398 attach-node $node(8398)
$ns at 316 "$BGP8398 command \"show ip bgp\""

#puts "Creating Router 8402"
set node(8402) [$ns node]
set BGP8402 [new Application/Route/Bgp]
$BGP8402 register  $r

$BGP8402 config-file $opt(dir)/bgpd8402.conf
$BGP8402 attach-node $node(8402)
$ns at 316 "$BGP8402 command \"show ip bgp\""

#puts "Creating Router 8405"
set node(8405) [$ns node]
set BGP8405 [new Application/Route/Bgp]
$BGP8405 register  $r

$BGP8405 config-file $opt(dir)/bgpd8405.conf
$BGP8405 attach-node $node(8405)
$ns at 316 "$BGP8405 command \"show ip bgp\""

#puts "Creating Router 8406"
set node(8406) [$ns node]
set BGP8406 [new Application/Route/Bgp]
$BGP8406 register  $r

$BGP8406 config-file $opt(dir)/bgpd8406.conf
$BGP8406 attach-node $node(8406)
$ns at 316 "$BGP8406 command \"show ip bgp\""

#puts "Creating Router 8407"
set node(8407) [$ns node]
set BGP8407 [new Application/Route/Bgp]
$BGP8407 register  $r

$BGP8407 config-file $opt(dir)/bgpd8407.conf
$BGP8407 attach-node $node(8407)
$ns at 316 "$BGP8407 command \"show ip bgp\""

#puts "Creating Router 8408"
set node(8408) [$ns node]
set BGP8408 [new Application/Route/Bgp]
$BGP8408 register  $r

$BGP8408 config-file $opt(dir)/bgpd8408.conf
$BGP8408 attach-node $node(8408)
$ns at 316 "$BGP8408 command \"show ip bgp\""

#puts "Creating Router 8411"
set node(8411) [$ns node]
set BGP8411 [new Application/Route/Bgp]
$BGP8411 register  $r

$BGP8411 config-file $opt(dir)/bgpd8411.conf
$BGP8411 attach-node $node(8411)
$ns at 316 "$BGP8411 command \"show ip bgp\""

#puts "Creating Router 8412"
set node(8412) [$ns node]
set BGP8412 [new Application/Route/Bgp]
$BGP8412 register  $r

$BGP8412 config-file $opt(dir)/bgpd8412.conf
$BGP8412 attach-node $node(8412)
$ns at 316 "$BGP8412 command \"show ip bgp\""

#puts "Creating Router 8413"
set node(8413) [$ns node]
set BGP8413 [new Application/Route/Bgp]
$BGP8413 register  $r

$BGP8413 config-file $opt(dir)/bgpd8413.conf
$BGP8413 attach-node $node(8413)
$ns at 316 "$BGP8413 command \"show ip bgp\""

#puts "Creating Router 8417"
set node(8417) [$ns node]
set BGP8417 [new Application/Route/Bgp]
$BGP8417 register  $r

$BGP8417 config-file $opt(dir)/bgpd8417.conf
$BGP8417 attach-node $node(8417)
$ns at 316 "$BGP8417 command \"show ip bgp\""

#puts "Creating Router 8419"
set node(8419) [$ns node]
set BGP8419 [new Application/Route/Bgp]
$BGP8419 register  $r

$BGP8419 config-file $opt(dir)/bgpd8419.conf
$BGP8419 attach-node $node(8419)
$ns at 316 "$BGP8419 command \"show ip bgp\""

#puts "Creating Router 8421"
set node(8421) [$ns node]
set BGP8421 [new Application/Route/Bgp]
$BGP8421 register  $r

$BGP8421 config-file $opt(dir)/bgpd8421.conf
$BGP8421 attach-node $node(8421)
$ns at 316 "$BGP8421 command \"show ip bgp\""

#puts "Creating Router 8422"
set node(8422) [$ns node]
set BGP8422 [new Application/Route/Bgp]
$BGP8422 register  $r

$BGP8422 config-file $opt(dir)/bgpd8422.conf
$BGP8422 attach-node $node(8422)
$ns at 316 "$BGP8422 command \"show ip bgp\""

#puts "Creating Router 8424"
set node(8424) [$ns node]
set BGP8424 [new Application/Route/Bgp]
$BGP8424 register  $r

$BGP8424 config-file $opt(dir)/bgpd8424.conf
$BGP8424 attach-node $node(8424)
$ns at 316 "$BGP8424 command \"show ip bgp\""

#puts "Creating Router 8425"
set node(8425) [$ns node]
set BGP8425 [new Application/Route/Bgp]
$BGP8425 register  $r

$BGP8425 config-file $opt(dir)/bgpd8425.conf
$BGP8425 attach-node $node(8425)
$ns at 316 "$BGP8425 command \"show ip bgp\""

#puts "Creating Router 8431"
set node(8431) [$ns node]
set BGP8431 [new Application/Route/Bgp]
$BGP8431 register  $r

$BGP8431 config-file $opt(dir)/bgpd8431.conf
$BGP8431 attach-node $node(8431)
$ns at 316 "$BGP8431 command \"show ip bgp\""

#puts "Creating Router 8442"
set node(8442) [$ns node]
set BGP8442 [new Application/Route/Bgp]
$BGP8442 register  $r

$BGP8442 config-file $opt(dir)/bgpd8442.conf
$BGP8442 attach-node $node(8442)
$ns at 316 "$BGP8442 command \"show ip bgp\""

#puts "Creating Router 8447"
set node(8447) [$ns node]
set BGP8447 [new Application/Route/Bgp]
$BGP8447 register  $r

$BGP8447 config-file $opt(dir)/bgpd8447.conf
$BGP8447 attach-node $node(8447)
$ns at 316 "$BGP8447 command \"show ip bgp\""

#puts "Creating Router 8451"
set node(8451) [$ns node]
set BGP8451 [new Application/Route/Bgp]
$BGP8451 register  $r

$BGP8451 config-file $opt(dir)/bgpd8451.conf
$BGP8451 attach-node $node(8451)
$ns at 316 "$BGP8451 command \"show ip bgp\""

#puts "Creating Router 8452"
set node(8452) [$ns node]
set BGP8452 [new Application/Route/Bgp]
$BGP8452 register  $r

$BGP8452 config-file $opt(dir)/bgpd8452.conf
$BGP8452 attach-node $node(8452)
$ns at 316 "$BGP8452 command \"show ip bgp\""

#puts "Creating Router 8454"
set node(8454) [$ns node]
set BGP8454 [new Application/Route/Bgp]
$BGP8454 register  $r

$BGP8454 config-file $opt(dir)/bgpd8454.conf
$BGP8454 attach-node $node(8454)
$ns at 316 "$BGP8454 command \"show ip bgp\""

#puts "Creating Router 8455"
set node(8455) [$ns node]
set BGP8455 [new Application/Route/Bgp]
$BGP8455 register  $r

$BGP8455 config-file $opt(dir)/bgpd8455.conf
$BGP8455 attach-node $node(8455)
$ns at 316 "$BGP8455 command \"show ip bgp\""

#puts "Creating Router 8456"
set node(8456) [$ns node]
set BGP8456 [new Application/Route/Bgp]
$BGP8456 register  $r

$BGP8456 config-file $opt(dir)/bgpd8456.conf
$BGP8456 attach-node $node(8456)
$ns at 316 "$BGP8456 command \"show ip bgp\""

#puts "Creating Router 8457"
set node(8457) [$ns node]
set BGP8457 [new Application/Route/Bgp]
$BGP8457 register  $r

$BGP8457 config-file $opt(dir)/bgpd8457.conf
$BGP8457 attach-node $node(8457)
$ns at 316 "$BGP8457 command \"show ip bgp\""

#puts "Creating Router 8460"
set node(8460) [$ns node]
set BGP8460 [new Application/Route/Bgp]
$BGP8460 register  $r

$BGP8460 config-file $opt(dir)/bgpd8460.conf
$BGP8460 attach-node $node(8460)
$ns at 316 "$BGP8460 command \"show ip bgp\""

#puts "Creating Router 8463"
set node(8463) [$ns node]
set BGP8463 [new Application/Route/Bgp]
$BGP8463 register  $r

$BGP8463 config-file $opt(dir)/bgpd8463.conf
$BGP8463 attach-node $node(8463)
$ns at 316 "$BGP8463 command \"show ip bgp\""

#puts "Creating Router 8464"
set node(8464) [$ns node]
set BGP8464 [new Application/Route/Bgp]
$BGP8464 register  $r

$BGP8464 config-file $opt(dir)/bgpd8464.conf
$BGP8464 attach-node $node(8464)
$ns at 316 "$BGP8464 command \"show ip bgp\""

#puts "Creating Router 8465"
set node(8465) [$ns node]
set BGP8465 [new Application/Route/Bgp]
$BGP8465 register  $r

$BGP8465 config-file $opt(dir)/bgpd8465.conf
$BGP8465 attach-node $node(8465)
$ns at 316 "$BGP8465 command \"show ip bgp\""

#puts "Creating Router 8468"
set node(8468) [$ns node]
set BGP8468 [new Application/Route/Bgp]
$BGP8468 register  $r

$BGP8468 config-file $opt(dir)/bgpd8468.conf
$BGP8468 attach-node $node(8468)
$ns at 316 "$BGP8468 command \"show ip bgp\""

#puts "Creating Router 8469"
set node(8469) [$ns node]
set BGP8469 [new Application/Route/Bgp]
$BGP8469 register  $r

$BGP8469 config-file $opt(dir)/bgpd8469.conf
$BGP8469 attach-node $node(8469)
$ns at 316 "$BGP8469 command \"show ip bgp\""

#puts "Creating Router 8470"
set node(8470) [$ns node]
set BGP8470 [new Application/Route/Bgp]
$BGP8470 register  $r

$BGP8470 config-file $opt(dir)/bgpd8470.conf
$BGP8470 attach-node $node(8470)
$ns at 316 "$BGP8470 command \"show ip bgp\""

#puts "Creating Router 8472"
set node(8472) [$ns node]
set BGP8472 [new Application/Route/Bgp]
$BGP8472 register  $r

$BGP8472 config-file $opt(dir)/bgpd8472.conf
$BGP8472 attach-node $node(8472)
$ns at 316 "$BGP8472 command \"show ip bgp\""

#puts "Creating Router 8473"
set node(8473) [$ns node]
set BGP8473 [new Application/Route/Bgp]
$BGP8473 register  $r

$BGP8473 config-file $opt(dir)/bgpd8473.conf
$BGP8473 attach-node $node(8473)
$ns at 316 "$BGP8473 command \"show ip bgp\""

#puts "Creating Router 8475"
set node(8475) [$ns node]
set BGP8475 [new Application/Route/Bgp]
$BGP8475 register  $r

$BGP8475 config-file $opt(dir)/bgpd8475.conf
$BGP8475 attach-node $node(8475)
$ns at 316 "$BGP8475 command \"show ip bgp\""

#puts "Creating Router 8476"
set node(8476) [$ns node]
set BGP8476 [new Application/Route/Bgp]
$BGP8476 register  $r

$BGP8476 config-file $opt(dir)/bgpd8476.conf
$BGP8476 attach-node $node(8476)
$ns at 316 "$BGP8476 command \"show ip bgp\""

#puts "Creating Router 8483"
set node(8483) [$ns node]
set BGP8483 [new Application/Route/Bgp]
$BGP8483 register  $r

$BGP8483 config-file $opt(dir)/bgpd8483.conf
$BGP8483 attach-node $node(8483)
$ns at 316 "$BGP8483 command \"show ip bgp\""

#puts "Creating Router 8484"
set node(8484) [$ns node]
set BGP8484 [new Application/Route/Bgp]
$BGP8484 register  $r

$BGP8484 config-file $opt(dir)/bgpd8484.conf
$BGP8484 attach-node $node(8484)
$ns at 316 "$BGP8484 command \"show ip bgp\""

#puts "Creating Router 8485"
set node(8485) [$ns node]
set BGP8485 [new Application/Route/Bgp]
$BGP8485 register  $r

$BGP8485 config-file $opt(dir)/bgpd8485.conf
$BGP8485 attach-node $node(8485)
$ns at 316 "$BGP8485 command \"show ip bgp\""

#puts "Creating Router 8489"
set node(8489) [$ns node]
set BGP8489 [new Application/Route/Bgp]
$BGP8489 register  $r

$BGP8489 config-file $opt(dir)/bgpd8489.conf
$BGP8489 attach-node $node(8489)
$ns at 316 "$BGP8489 command \"show ip bgp\""

#puts "Creating Router 8491"
set node(8491) [$ns node]
set BGP8491 [new Application/Route/Bgp]
$BGP8491 register  $r

$BGP8491 config-file $opt(dir)/bgpd8491.conf
$BGP8491 attach-node $node(8491)
$ns at 316 "$BGP8491 command \"show ip bgp\""

#puts "Creating Router 8496"
set node(8496) [$ns node]
set BGP8496 [new Application/Route/Bgp]
$BGP8496 register  $r

$BGP8496 config-file $opt(dir)/bgpd8496.conf
$BGP8496 attach-node $node(8496)
$ns at 316 "$BGP8496 command \"show ip bgp\""

#puts "Creating Router 8498"
set node(8498) [$ns node]
set BGP8498 [new Application/Route/Bgp]
$BGP8498 register  $r

$BGP8498 config-file $opt(dir)/bgpd8498.conf
$BGP8498 attach-node $node(8498)
$ns at 316 "$BGP8498 command \"show ip bgp\""

#puts "Creating Router 8499"
set node(8499) [$ns node]
set BGP8499 [new Application/Route/Bgp]
$BGP8499 register  $r

$BGP8499 config-file $opt(dir)/bgpd8499.conf
$BGP8499 attach-node $node(8499)
$ns at 316 "$BGP8499 command \"show ip bgp\""

#puts "Creating Router 8504"
set node(8504) [$ns node]
set BGP8504 [new Application/Route/Bgp]
$BGP8504 register  $r

$BGP8504 config-file $opt(dir)/bgpd8504.conf
$BGP8504 attach-node $node(8504)
$ns at 316 "$BGP8504 command \"show ip bgp\""

#puts "Creating Router 8506"
set node(8506) [$ns node]
set BGP8506 [new Application/Route/Bgp]
$BGP8506 register  $r

$BGP8506 config-file $opt(dir)/bgpd8506.conf
$BGP8506 attach-node $node(8506)
$ns at 316 "$BGP8506 command \"show ip bgp\""

#puts "Creating Router 8507"
set node(8507) [$ns node]
set BGP8507 [new Application/Route/Bgp]
$BGP8507 register  $r

$BGP8507 config-file $opt(dir)/bgpd8507.conf
$BGP8507 attach-node $node(8507)
$ns at 316 "$BGP8507 command \"show ip bgp\""

#puts "Creating Router 8510"
set node(8510) [$ns node]
set BGP8510 [new Application/Route/Bgp]
$BGP8510 register  $r

$BGP8510 config-file $opt(dir)/bgpd8510.conf
$BGP8510 attach-node $node(8510)
$ns at 316 "$BGP8510 command \"show ip bgp\""

#puts "Creating Router 8511"
set node(8511) [$ns node]
set BGP8511 [new Application/Route/Bgp]
$BGP8511 register  $r

$BGP8511 config-file $opt(dir)/bgpd8511.conf
$BGP8511 attach-node $node(8511)
$ns at 316 "$BGP8511 command \"show ip bgp\""

#puts "Creating Router 8512"
set node(8512) [$ns node]
set BGP8512 [new Application/Route/Bgp]
$BGP8512 register  $r

$BGP8512 config-file $opt(dir)/bgpd8512.conf
$BGP8512 attach-node $node(8512)
$ns at 316 "$BGP8512 command \"show ip bgp\""

#puts "Creating Router 8513"
set node(8513) [$ns node]
set BGP8513 [new Application/Route/Bgp]
$BGP8513 register  $r

$BGP8513 config-file $opt(dir)/bgpd8513.conf
$BGP8513 attach-node $node(8513)
$ns at 316 "$BGP8513 command \"show ip bgp\""

#puts "Creating Router 8514"
set node(8514) [$ns node]
set BGP8514 [new Application/Route/Bgp]
$BGP8514 register  $r

$BGP8514 config-file $opt(dir)/bgpd8514.conf
$BGP8514 attach-node $node(8514)
$ns at 316 "$BGP8514 command \"show ip bgp\""

#puts "Creating Router 8515"
set node(8515) [$ns node]
set BGP8515 [new Application/Route/Bgp]
$BGP8515 register  $r

$BGP8515 config-file $opt(dir)/bgpd8515.conf
$BGP8515 attach-node $node(8515)
$ns at 316 "$BGP8515 command \"show ip bgp\""

#puts "Creating Router 8516"
set node(8516) [$ns node]
set BGP8516 [new Application/Route/Bgp]
$BGP8516 register  $r

$BGP8516 config-file $opt(dir)/bgpd8516.conf
$BGP8516 attach-node $node(8516)
$ns at 316 "$BGP8516 command \"show ip bgp\""

#puts "Creating Router 8517"
set node(8517) [$ns node]
set BGP8517 [new Application/Route/Bgp]
$BGP8517 register  $r

$BGP8517 config-file $opt(dir)/bgpd8517.conf
$BGP8517 attach-node $node(8517)
$ns at 316 "$BGP8517 command \"show ip bgp\""

#puts "Creating Router 852"
set node(852) [$ns node]
set BGP852 [new Application/Route/Bgp]
$BGP852 register  $r

$BGP852 config-file $opt(dir)/bgpd852.conf
$BGP852 attach-node $node(852)
$ns at 316 "$BGP852 command \"show ip bgp\""

#puts "Creating Router 8529"
set node(8529) [$ns node]
set BGP8529 [new Application/Route/Bgp]
$BGP8529 register  $r

$BGP8529 config-file $opt(dir)/bgpd8529.conf
$BGP8529 attach-node $node(8529)
$ns at 316 "$BGP8529 command \"show ip bgp\""

#puts "Creating Router 8533"
set node(8533) [$ns node]
set BGP8533 [new Application/Route/Bgp]
$BGP8533 register  $r

$BGP8533 config-file $opt(dir)/bgpd8533.conf
$BGP8533 attach-node $node(8533)
$ns at 316 "$BGP8533 command \"show ip bgp\""

#puts "Creating Router 8535"
set node(8535) [$ns node]
set BGP8535 [new Application/Route/Bgp]
$BGP8535 register  $r

$BGP8535 config-file $opt(dir)/bgpd8535.conf
$BGP8535 attach-node $node(8535)
$ns at 316 "$BGP8535 command \"show ip bgp\""

#puts "Creating Router 854"
set node(854) [$ns node]
set BGP854 [new Application/Route/Bgp]
$BGP854 register  $r

$BGP854 config-file $opt(dir)/bgpd854.conf
$BGP854 attach-node $node(854)
$ns at 316 "$BGP854 command \"show ip bgp\""

#puts "Creating Router 8540"
set node(8540) [$ns node]
set BGP8540 [new Application/Route/Bgp]
$BGP8540 register  $r

$BGP8540 config-file $opt(dir)/bgpd8540.conf
$BGP8540 attach-node $node(8540)
$ns at 316 "$BGP8540 command \"show ip bgp\""

#puts "Creating Router 8542"
set node(8542) [$ns node]
set BGP8542 [new Application/Route/Bgp]
$BGP8542 register  $r

$BGP8542 config-file $opt(dir)/bgpd8542.conf
$BGP8542 attach-node $node(8542)
$ns at 316 "$BGP8542 command \"show ip bgp\""

#puts "Creating Router 855"
set node(855) [$ns node]
set BGP855 [new Application/Route/Bgp]
$BGP855 register  $r

$BGP855 config-file $opt(dir)/bgpd855.conf
$BGP855 attach-node $node(855)
$ns at 316 "$BGP855 command \"show ip bgp\""

#puts "Creating Router 8551"
set node(8551) [$ns node]
set BGP8551 [new Application/Route/Bgp]
$BGP8551 register  $r

$BGP8551 config-file $opt(dir)/bgpd8551.conf
$BGP8551 attach-node $node(8551)
$ns at 316 "$BGP8551 command \"show ip bgp\""

#puts "Creating Router 8553"
set node(8553) [$ns node]
set BGP8553 [new Application/Route/Bgp]
$BGP8553 register  $r

$BGP8553 config-file $opt(dir)/bgpd8553.conf
$BGP8553 attach-node $node(8553)
$ns at 316 "$BGP8553 command \"show ip bgp\""

#puts "Creating Router 8556"
set node(8556) [$ns node]
set BGP8556 [new Application/Route/Bgp]
$BGP8556 register  $r

$BGP8556 config-file $opt(dir)/bgpd8556.conf
$BGP8556 attach-node $node(8556)
$ns at 316 "$BGP8556 command \"show ip bgp\""

#puts "Creating Router 8573"
set node(8573) [$ns node]
set BGP8573 [new Application/Route/Bgp]
$BGP8573 register  $r

$BGP8573 config-file $opt(dir)/bgpd8573.conf
$BGP8573 attach-node $node(8573)
$ns at 316 "$BGP8573 command \"show ip bgp\""

#puts "Creating Router 8578"
set node(8578) [$ns node]
set BGP8578 [new Application/Route/Bgp]
$BGP8578 register  $r

$BGP8578 config-file $opt(dir)/bgpd8578.conf
$BGP8578 attach-node $node(8578)
$ns at 316 "$BGP8578 command \"show ip bgp\""

#puts "Creating Router 8583"
set node(8583) [$ns node]
set BGP8583 [new Application/Route/Bgp]
$BGP8583 register  $r

$BGP8583 config-file $opt(dir)/bgpd8583.conf
$BGP8583 attach-node $node(8583)
$ns at 316 "$BGP8583 command \"show ip bgp\""

#puts "Creating Router 9"
set node(9) [$ns node]
set BGP9 [new Application/Route/Bgp]
$BGP9 register  $r

$BGP9 config-file $opt(dir)/bgpd9.conf
$BGP9 attach-node $node(9)
$ns at 316 "$BGP9 command \"show ip bgp\""

#puts "Creating Router 93"
set node(93) [$ns node]
set BGP93 [new Application/Route/Bgp]
$BGP93 register  $r

$BGP93 config-file $opt(dir)/bgpd93.conf
$BGP93 attach-node $node(93)
$ns at 316 "$BGP93 command \"show ip bgp\""

#puts "Creating Router 97"
set node(97) [$ns node]
set BGP97 [new Application/Route/Bgp]
$BGP97 register  $r

$BGP97 config-file $opt(dir)/bgpd97.conf
$BGP97 attach-node $node(97)
$ns at 316 "$BGP97 command \"show ip bgp\""

#puts "Creating Router 9999"
set node(9999) [$ns node]
set BGP9999 [new Application/Route/Bgp]
$BGP9999 register  $r

$BGP9999 config-file $opt(dir)/bgpd9999.conf
$BGP9999 attach-node $node(9999)
$ns at 316 "$BGP9999 command \"show ip bgp\""
set ctime [clock seconds]
puts "nodecreation elapsed seconds [expr $ctime - $stime]"


# Create the Router Links
puts "Creating the links and BGP connectivity"
#puts "Connecting Router 1"
#puts "Connecting Router 10240"
#puts "Connecting Router 10243"
#puts "Connecting Router 10245"
#puts "Connecting Router 10249"
#puts "Connecting Router 10252"
#puts "Connecting Router 10256"
#puts "Connecting Router 10260"
#puts "Connecting Router 10263"
#puts "Connecting Router 10264"
#puts "Connecting Router 10267"
#puts "Connecting Router 10268"
#puts "Connecting Router 10270"
#puts "Connecting Router 10275"
#puts "Connecting Router 10278"
#puts "Connecting Router 10279"
#puts "Connecting Router 10289"
#puts "Connecting Router 10292"
#puts "Connecting Router 10299"
#puts "Connecting Router 103"
#puts "Connecting Router 10303"
#puts "Connecting Router 10304"
#puts "Connecting Router 10305"
#puts "Connecting Router 10306"
#puts "Connecting Router 10318"
#puts "Connecting Router 10335"
#puts "Connecting Router 10339"
#puts "Connecting Router 10345"
#puts "Connecting Router 10348"
#puts "Connecting Router 10349"
#puts "Connecting Router 10352"
#puts "Connecting Router 10354"
#puts "Connecting Router 10357"
#puts "Connecting Router 10367"
#puts "Connecting Router 10377"
#puts "Connecting Router 10384"
#puts "Connecting Router 10385"
#puts "Connecting Router 10387"
#puts "Connecting Router 10393"
#puts "Connecting Router 10399"
#puts "Connecting Router 10415"
#puts "Connecting Router 10417"
#puts "Connecting Router 10420"
#puts "Connecting Router 10436"
#puts "Connecting Router 10444"
#puts "Connecting Router 10448"
#puts "Connecting Router 10450"
#puts "Connecting Router 10466"
#puts "Connecting Router 10468"
$ns duplex-link $node(10468) $node(10450) 1.5Mb 10ms DropTail
#puts "Connecting Router 10477"
#puts "Connecting Router 10479"
#puts "Connecting Router 10481"
#puts "Connecting Router 10482"
#puts "Connecting Router 10483"
#puts "Connecting Router 10487"
#puts "Connecting Router 10490"
#puts "Connecting Router 10496"
$ns duplex-link $node(10496) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 10501"
#puts "Connecting Router 10505"
#puts "Connecting Router 10506"
$ns duplex-link $node(10506) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 10514"
#puts "Connecting Router 10531"
$ns duplex-link $node(10531) $node(10417) 1.5Mb 10ms DropTail
#puts "Connecting Router 10533"
#puts "Connecting Router 10535"
#puts "Connecting Router 10543"
#puts "Connecting Router 10545"
#puts "Connecting Router 10562"
#puts "Connecting Router 10570"
#puts "Connecting Router 10576"
#puts "Connecting Router 10583"
#puts "Connecting Router 10585"
#puts "Connecting Router 10588"
#puts "Connecting Router 10589"
#puts "Connecting Router 10590"
#puts "Connecting Router 10601"
$ns duplex-link $node(10601) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 10605"
#puts "Connecting Router 10606"
#puts "Connecting Router 10609"
#puts "Connecting Router 10618"
#puts "Connecting Router 10621"
#puts "Connecting Router 10631"
$ns duplex-link $node(10631) $node(10490) 1.5Mb 10ms DropTail
#puts "Connecting Router 10654"
#puts "Connecting Router 10656"
#puts "Connecting Router 10661"
#puts "Connecting Router 10671"
#puts "Connecting Router 10674"
#puts "Connecting Router 10684"
#puts "Connecting Router 10689"
#puts "Connecting Router 10691"
#puts "Connecting Router 10692"
$ns duplex-link $node(10692) $node(10689) 1.5Mb 10ms DropTail
#puts "Connecting Router 10708"
#puts "Connecting Router 10711"
#puts "Connecting Router 10725"
#puts "Connecting Router 10732"
#puts "Connecting Router 10734"
#puts "Connecting Router 10746"
#puts "Connecting Router 10748"
#puts "Connecting Router 10749"
#puts "Connecting Router 10757"
#puts "Connecting Router 10766"
#puts "Connecting Router 10771"
#puts "Connecting Router 10793"
#puts "Connecting Router 10814"
#puts "Connecting Router 10821"
$ns duplex-link $node(10821) $node(10771) 1.5Mb 10ms DropTail
#puts "Connecting Router 10823"
#puts "Connecting Router 10834"
#puts "Connecting Router 10839"
#puts "Connecting Router 10843"
#puts "Connecting Router 10887"
#puts "Connecting Router 1103"
#puts "Connecting Router 1129"
#puts "Connecting Router 1133"
#puts "Connecting Router 1136"
#puts "Connecting Router 1137"
$ns duplex-link $node(1137) $node(1136) 1.5Mb 10ms DropTail
#puts "Connecting Router 1138"
$ns duplex-link $node(1138) $node(1103) 1.5Mb 10ms DropTail
#puts "Connecting Router 114"
#puts "Connecting Router 1140"
#puts "Connecting Router 1198"
$ns duplex-link $node(1198) $node(1103) 1.5Mb 10ms DropTail
#puts "Connecting Router 1201"
#puts "Connecting Router 1205"
#puts "Connecting Router 1206"
#puts "Connecting Router 1213"
#puts "Connecting Router 1220"
#puts "Connecting Router 1221"
#puts "Connecting Router 1225"
#puts "Connecting Router 1237"
#puts "Connecting Router 1239"
$ns duplex-link $node(1239) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(1239) $node(10292) 1.5Mb 10ms DropTail
$ns duplex-link $node(1239) $node(10399) 1.5Mb 10ms DropTail
$ns duplex-link $node(1239) $node(10514) 1.5Mb 10ms DropTail
$ns duplex-link $node(1239) $node(10609) 1.5Mb 10ms DropTail
$ns duplex-link $node(1239) $node(10771) 1.5Mb 10ms DropTail
#puts "Connecting Router 1241"
#puts "Connecting Router 1257"
#puts "Connecting Router 1263"
#puts "Connecting Router 1267"
#puts "Connecting Router 1270"
#puts "Connecting Router 1273"
#puts "Connecting Router 1275"
#puts "Connecting Router 1280"
#puts "Connecting Router 1290"
#puts "Connecting Router 1292"
#puts "Connecting Router 1299"
#puts "Connecting Router 13"
#puts "Connecting Router 1312"
#puts "Connecting Router 132"
#puts "Connecting Router 1321"
#puts "Connecting Router 1322"
#puts "Connecting Router 1323"
#puts "Connecting Router 1324"
#puts "Connecting Router 1325"
#puts "Connecting Router 1326"
#puts "Connecting Router 1327"
#puts "Connecting Router 1328"
#puts "Connecting Router 1330"
#puts "Connecting Router 1331"
#puts "Connecting Router 1332"
#puts "Connecting Router 1333"
#puts "Connecting Router 1334"
#puts "Connecting Router 1335"
#puts "Connecting Router 1347"
#puts "Connecting Router 137"
#puts "Connecting Router 145"
$ns duplex-link $node(145) $node(103) 1.5Mb 10ms DropTail
$ns duplex-link $node(145) $node(10490) 1.5Mb 10ms DropTail
#puts "Connecting Router 146"
#puts "Connecting Router 160"
#puts "Connecting Router 1653"
#puts "Connecting Router 1662"
#puts "Connecting Router 1664"
#puts "Connecting Router 1667"
#puts "Connecting Router 1670"
#puts "Connecting Router 1673"
$ns duplex-link $node(1673) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1323) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1325) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1327) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1129) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1133) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1321) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1322) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1324) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1326) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1328) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1330) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1331) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1332) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1333) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1334) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1335) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1662) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1664) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1667) 1.5Mb 10ms DropTail
$ns duplex-link $node(1673) $node(1670) 1.5Mb 10ms DropTail
#puts "Connecting Router 1675"
$ns duplex-link $node(1675) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1677"
$ns duplex-link $node(1677) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1686"
$ns duplex-link $node(1686) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1691"
#puts "Connecting Router 1694"
$ns duplex-link $node(1694) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1699"
$ns duplex-link $node(1699) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 17"
$ns duplex-link $node(17) $node(1323) 1.5Mb 10ms DropTail
#puts "Connecting Router 1717"
#puts "Connecting Router 174"
$ns duplex-link $node(174) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(174) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(174) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(174) $node(1290) 1.5Mb 10ms DropTail
$ns duplex-link $node(174) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1740"
$ns duplex-link $node(1740) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(1740) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(1740) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(1740) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(1740) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(1740) $node(10689) 1.5Mb 10ms DropTail
#puts "Connecting Router 1741"
#puts "Connecting Router 1742"
#puts "Connecting Router 1746"
$ns duplex-link $node(1746) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 1755"
$ns duplex-link $node(1755) $node(1213) 1.5Mb 10ms DropTail
$ns duplex-link $node(1755) $node(1241) 1.5Mb 10ms DropTail
$ns duplex-link $node(1755) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(1755) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(1755) $node(1290) 1.5Mb 10ms DropTail
$ns duplex-link $node(1755) $node(1299) 1.5Mb 10ms DropTail
#puts "Connecting Router 1759"
$ns duplex-link $node(1759) $node(1755) 1.5Mb 10ms DropTail
#puts "Connecting Router 1760"
$ns duplex-link $node(1760) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1761"
#puts "Connecting Router 1767"
$ns duplex-link $node(1767) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1778"
#puts "Connecting Router 1784"
#puts "Connecting Router 1785"
$ns duplex-link $node(1785) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1797"
#puts "Connecting Router 1798"
$ns duplex-link $node(1798) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1800"
$ns duplex-link $node(1800) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(1800) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(1800) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(1800) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(1800) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(1800) $node(1759) 1.5Mb 10ms DropTail
#puts "Connecting Router 1808"
#puts "Connecting Router 1829"
#puts "Connecting Router 1830"
#puts "Connecting Router 1831"
#puts "Connecting Router 1833"
$ns duplex-link $node(1833) $node(1299) 1.5Mb 10ms DropTail
#puts "Connecting Router 1835"
#puts "Connecting Router 1849"
$ns duplex-link $node(1849) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(1849) $node(1290) 1.5Mb 10ms DropTail
$ns duplex-link $node(1849) $node(1299) 1.5Mb 10ms DropTail
#puts "Connecting Router 1850"
#puts "Connecting Router 1852"
$ns duplex-link $node(1852) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1853"
$ns duplex-link $node(1853) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(1853) $node(1205) 1.5Mb 10ms DropTail
#puts "Connecting Router 1880"
$ns duplex-link $node(1880) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(1880) $node(1800) 1.5Mb 10ms DropTail
#puts "Connecting Router 1887"
$ns duplex-link $node(1887) $node(1755) 1.5Mb 10ms DropTail
#puts "Connecting Router 1890"
#puts "Connecting Router 1891"
#puts "Connecting Router 1899"
#puts "Connecting Router 1901"
#puts "Connecting Router 1902"
$ns duplex-link $node(1902) $node(1755) 1.5Mb 10ms DropTail
#puts "Connecting Router 1913"
$ns duplex-link $node(1913) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 1916"
$ns duplex-link $node(1916) $node(10417) 1.5Mb 10ms DropTail
#puts "Connecting Router 1930"
#puts "Connecting Router 1932"
#puts "Connecting Router 194"
$ns duplex-link $node(194) $node(145) 1.5Mb 10ms DropTail
#puts "Connecting Router 195"
$ns duplex-link $node(195) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(195) $node(1740) 1.5Mb 10ms DropTail
#puts "Connecting Router 1967"
#puts "Connecting Router 1970"
#puts "Connecting Router 1975"
#puts "Connecting Router 1982"
$ns duplex-link $node(1982) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 1998"
#puts "Connecting Router 201"
#puts "Connecting Router 2012"
#puts "Connecting Router 2015"
#puts "Connecting Router 2018"
#puts "Connecting Router 2024"
#puts "Connecting Router 2033"
#puts "Connecting Router 204"
#puts "Connecting Router 2041"
$ns duplex-link $node(2041) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(2041) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2041) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(2041) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(2041) $node(1740) 1.5Mb 10ms DropTail
#puts "Connecting Router 2042"
#puts "Connecting Router 2044"
$ns duplex-link $node(2044) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 2048"
#puts "Connecting Router 2052"
#puts "Connecting Router 209"
$ns duplex-link $node(209) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(209) $node(194) 1.5Mb 10ms DropTail
#puts "Connecting Router 2107"
$ns duplex-link $node(2107) $node(1129) 1.5Mb 10ms DropTail
#puts "Connecting Router 2108"
#puts "Connecting Router 2109"
#puts "Connecting Router 2118"
#puts "Connecting Router 2150"
$ns duplex-link $node(2150) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 217"
#puts "Connecting Router 22"
#puts "Connecting Router 224"
#puts "Connecting Router 225"
#puts "Connecting Router 226"
$ns duplex-link $node(226) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(226) $node(2150) 1.5Mb 10ms DropTail
#puts "Connecting Router 2276"
$ns duplex-link $node(2276) $node(2041) 1.5Mb 10ms DropTail
#puts "Connecting Router 237"
$ns duplex-link $node(237) $node(145) 1.5Mb 10ms DropTail
#puts "Connecting Router 2379"
$ns duplex-link $node(2379) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 2380"
$ns duplex-link $node(2380) $node(1759) 1.5Mb 10ms DropTail
#puts "Connecting Router 2381"
#puts "Connecting Router 2493"
#puts "Connecting Router 2497"
$ns duplex-link $node(2497) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2497) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(2497) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(2497) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(2497) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 25"
$ns duplex-link $node(25) $node(1852) 1.5Mb 10ms DropTail
#puts "Connecting Router 2500"
$ns duplex-link $node(2500) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2505"
#puts "Connecting Router 2506"
$ns duplex-link $node(2506) $node(2500) 1.5Mb 10ms DropTail
#puts "Connecting Router 2510"
$ns duplex-link $node(2510) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2512"
#puts "Connecting Router 2513"
$ns duplex-link $node(2513) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2514"
$ns duplex-link $node(2514) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2516"
$ns duplex-link $node(2516) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2516) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2516) $node(2500) 1.5Mb 10ms DropTail
$ns duplex-link $node(2516) $node(2513) 1.5Mb 10ms DropTail
$ns duplex-link $node(2516) $node(2514) 1.5Mb 10ms DropTail
#puts "Connecting Router 2519"
$ns duplex-link $node(2519) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2519) $node(2516) 1.5Mb 10ms DropTail
#puts "Connecting Router 2521"
$ns duplex-link $node(2521) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2521) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(2521) $node(2514) 1.5Mb 10ms DropTail
#puts "Connecting Router 2527"
#puts "Connecting Router 2529"
$ns duplex-link $node(2529) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(2529) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(2529) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(2529) $node(2516) 1.5Mb 10ms DropTail
#puts "Connecting Router 2532"
$ns duplex-link $node(2532) $node(1746) 1.5Mb 10ms DropTail
#puts "Connecting Router 2546"
#puts "Connecting Router 2548"
$ns duplex-link $node(2548) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(237) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1225) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1853) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(1887) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(10399) 1.5Mb 10ms DropTail
$ns duplex-link $node(2548) $node(10543) 1.5Mb 10ms DropTail
#puts "Connecting Router 2549"
#puts "Connecting Router 2551"
$ns duplex-link $node(2551) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2551) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(2551) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(2551) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2568"
#puts "Connecting Router 2572"
$ns duplex-link $node(2572) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 2578"
$ns duplex-link $node(2578) $node(2118) 1.5Mb 10ms DropTail
#puts "Connecting Router 2588"
#puts "Connecting Router 2592"
#puts "Connecting Router 2593"
#puts "Connecting Router 2598"
#puts "Connecting Router 2602"
#puts "Connecting Router 2603"
$ns duplex-link $node(2603) $node(1759) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(224) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(1653) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(1741) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(1835) 1.5Mb 10ms DropTail
$ns duplex-link $node(2603) $node(1887) 1.5Mb 10ms DropTail
#puts "Connecting Router 2609"
#puts "Connecting Router 2611"
#puts "Connecting Router 2614"
#puts "Connecting Router 2637"
$ns duplex-link $node(2637) $node(10490) 1.5Mb 10ms DropTail
#puts "Connecting Router 2638"
#puts "Connecting Router 2652"
$ns duplex-link $node(2652) $node(2493) 1.5Mb 10ms DropTail
#puts "Connecting Router 266"
$ns duplex-link $node(266) $node(237) 1.5Mb 10ms DropTail
$ns duplex-link $node(266) $node(1225) 1.5Mb 10ms DropTail
#puts "Connecting Router 2683"
$ns duplex-link $node(2683) $node(1275) 1.5Mb 10ms DropTail
#puts "Connecting Router 2685"
$ns duplex-link $node(2685) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(2685) $node(237) 1.5Mb 10ms DropTail
$ns duplex-link $node(2685) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2685) $node(1673) 1.5Mb 10ms DropTail
#puts "Connecting Router 2686"
$ns duplex-link $node(2686) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(2686) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(2686) $node(2685) 1.5Mb 10ms DropTail
#puts "Connecting Router 2687"
$ns duplex-link $node(2687) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(2687) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2687) $node(2685) 1.5Mb 10ms DropTail
#puts "Connecting Router 2688"
#puts "Connecting Router 2697"
#puts "Connecting Router 2698"
#puts "Connecting Router 2706"
#puts "Connecting Router 2713"
#puts "Connecting Router 2764"
$ns duplex-link $node(2764) $node(1221) 1.5Mb 10ms DropTail
#puts "Connecting Router 2766"
#puts "Connecting Router 2767"
#puts "Connecting Router 278"
$ns duplex-link $node(278) $node(114) 1.5Mb 10ms DropTail
#puts "Connecting Router 2792"
#puts "Connecting Router 2820"
#puts "Connecting Router 2828"
$ns duplex-link $node(2828) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2828) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(2828) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 2832"
$ns duplex-link $node(2832) $node(1653) 1.5Mb 10ms DropTail
#puts "Connecting Router 2836"
$ns duplex-link $node(2836) $node(1653) 1.5Mb 10ms DropTail
#puts "Connecting Router 284"
#puts "Connecting Router 2840"
$ns duplex-link $node(2840) $node(1653) 1.5Mb 10ms DropTail
#puts "Connecting Router 2843"
$ns duplex-link $node(2843) $node(1653) 1.5Mb 10ms DropTail
#puts "Connecting Router 2848"
#puts "Connecting Router 2852"
#puts "Connecting Router 2853"
$ns duplex-link $node(2853) $node(1741) 1.5Mb 10ms DropTail
$ns duplex-link $node(2853) $node(1759) 1.5Mb 10ms DropTail
#puts "Connecting Router 2854"
#puts "Connecting Router 2856"
$ns duplex-link $node(2856) $node(1849) 1.5Mb 10ms DropTail
#puts "Connecting Router 286"
$ns duplex-link $node(286) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1270) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1741) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1891) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1899) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(1901) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2118) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(286) $node(2828) 1.5Mb 10ms DropTail
#puts "Connecting Router 2860"
#puts "Connecting Router 2871"
#puts "Connecting Router 2874"
$ns duplex-link $node(2874) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(2874) $node(1800) 1.5Mb 10ms DropTail
#puts "Connecting Router 288"
$ns duplex-link $node(288) $node(1890) 1.5Mb 10ms DropTail
#puts "Connecting Router 2895"
#puts "Connecting Router 2900"
$ns duplex-link $node(2900) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 2905"
$ns duplex-link $node(2905) $node(2018) 1.5Mb 10ms DropTail
$ns duplex-link $node(2905) $node(2686) 1.5Mb 10ms DropTail
#puts "Connecting Router 2907"
$ns duplex-link $node(2907) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2907) $node(2500) 1.5Mb 10ms DropTail
$ns duplex-link $node(2907) $node(2505) 1.5Mb 10ms DropTail
$ns duplex-link $node(2907) $node(2506) 1.5Mb 10ms DropTail
#puts "Connecting Router 2914"
$ns duplex-link $node(2914) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(2905) 1.5Mb 10ms DropTail
$ns duplex-link $node(2914) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 2915"
$ns duplex-link $node(2915) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(2915) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(2915) $node(2713) 1.5Mb 10ms DropTail
#puts "Connecting Router 2917"
$ns duplex-link $node(2917) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 293"
$ns duplex-link $node(293) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(25) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(103) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(226) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1225) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1275) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1829) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(1852) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(2917) 1.5Mb 10ms DropTail
$ns duplex-link $node(293) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 2933"
$ns duplex-link $node(2933) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(2933) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(2933) $node(10399) 1.5Mb 10ms DropTail
#puts "Connecting Router 2966"
$ns duplex-link $node(2966) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 297"
$ns duplex-link $node(297) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(288) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(1263) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(2513) 1.5Mb 10ms DropTail
$ns duplex-link $node(297) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 298"
#puts "Connecting Router 3058"
$ns duplex-link $node(3058) $node(1275) 1.5Mb 10ms DropTail
#puts "Connecting Router 3064"
#puts "Connecting Router 3066"
#puts "Connecting Router 3128"
$ns duplex-link $node(3128) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(3128) $node(2381) 1.5Mb 10ms DropTail
#puts "Connecting Router 3142"
#puts "Connecting Router 3149"
$ns duplex-link $node(3149) $node(1332) 1.5Mb 10ms DropTail
#puts "Connecting Router 3150"
#puts "Connecting Router 3152"
$ns duplex-link $node(3152) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3152) $node(3128) 1.5Mb 10ms DropTail
#puts "Connecting Router 3208"
#puts "Connecting Router 3215"
$ns duplex-link $node(3215) $node(1755) 1.5Mb 10ms DropTail
#puts "Connecting Router 3216"
#puts "Connecting Router 3220"
$ns duplex-link $node(3220) $node(286) 1.5Mb 10ms DropTail
#puts "Connecting Router 3228"
#puts "Connecting Router 3230"
$ns duplex-link $node(3230) $node(288) 1.5Mb 10ms DropTail
#puts "Connecting Router 3242"
#puts "Connecting Router 3243"
#puts "Connecting Router 3244"
#puts "Connecting Router 3245"
$ns duplex-link $node(3245) $node(286) 1.5Mb 10ms DropTail
#puts "Connecting Router 3246"
$ns duplex-link $node(3246) $node(1759) 1.5Mb 10ms DropTail
$ns duplex-link $node(3246) $node(2853) 1.5Mb 10ms DropTail
#puts "Connecting Router 3248"
#puts "Connecting Router 3249"
#puts "Connecting Router 3252"
#puts "Connecting Router 3254"
#puts "Connecting Router 3255"
$ns duplex-link $node(3255) $node(1137) 1.5Mb 10ms DropTail
$ns duplex-link $node(3255) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(3255) $node(3254) 1.5Mb 10ms DropTail
#puts "Connecting Router 3256"
$ns duplex-link $node(3256) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(3256) $node(1899) 1.5Mb 10ms DropTail
$ns duplex-link $node(3256) $node(3208) 1.5Mb 10ms DropTail
$ns duplex-link $node(3256) $node(3215) 1.5Mb 10ms DropTail
#puts "Connecting Router 3257"
$ns duplex-link $node(3257) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(1270) 1.5Mb 10ms DropTail
$ns duplex-link $node(3257) $node(2871) 1.5Mb 10ms DropTail
#puts "Connecting Router 3258"
#puts "Connecting Router 3260"
#puts "Connecting Router 3261"
#puts "Connecting Router 3265"
$ns duplex-link $node(3265) $node(1136) 1.5Mb 10ms DropTail
#puts "Connecting Router 3268"
#puts "Connecting Router 3269"
$ns duplex-link $node(3269) $node(2598) 1.5Mb 10ms DropTail
#puts "Connecting Router 3273"
#puts "Connecting Router 3286"
$ns duplex-link $node(3286) $node(1849) 1.5Mb 10ms DropTail
#puts "Connecting Router 3291"
$ns duplex-link $node(3291) $node(1755) 1.5Mb 10ms DropTail
#puts "Connecting Router 3292"
#puts "Connecting Router 33"
$ns duplex-link $node(33) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(33) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(33) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3300"
$ns duplex-link $node(3300) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(1198) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(2109) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(3300) $node(1136) 1.5Mb 10ms DropTail
#puts "Connecting Router 3301"
$ns duplex-link $node(3301) $node(1299) 1.5Mb 10ms DropTail
#puts "Connecting Router 3302"
$ns duplex-link $node(3302) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(3302) $node(1267) 1.5Mb 10ms DropTail
#puts "Connecting Router 3303"
$ns duplex-link $node(3303) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3303) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(3303) $node(1833) 1.5Mb 10ms DropTail
$ns duplex-link $node(3303) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(3303) $node(3302) 1.5Mb 10ms DropTail
#puts "Connecting Router 3304"
$ns duplex-link $node(3304) $node(3300) 1.5Mb 10ms DropTail
#puts "Connecting Router 3305"
$ns duplex-link $node(3305) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(3305) $node(3256) 1.5Mb 10ms DropTail
#puts "Connecting Router 3306"
$ns duplex-link $node(3306) $node(3300) 1.5Mb 10ms DropTail
#puts "Connecting Router 3307"
$ns duplex-link $node(3307) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(3307) $node(3301) 1.5Mb 10ms DropTail
#puts "Connecting Router 3308"
$ns duplex-link $node(3308) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(3308) $node(2109) 1.5Mb 10ms DropTail
$ns duplex-link $node(3308) $node(3307) 1.5Mb 10ms DropTail
#puts "Connecting Router 3312"
#puts "Connecting Router 3313"
#puts "Connecting Router 3315"
#puts "Connecting Router 3316"
$ns duplex-link $node(3316) $node(2118) 1.5Mb 10ms DropTail
#puts "Connecting Router 3320"
$ns duplex-link $node(3320) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(2895) 1.5Mb 10ms DropTail
$ns duplex-link $node(3320) $node(3254) 1.5Mb 10ms DropTail
#puts "Connecting Router 3323"
#puts "Connecting Router 3324"
#puts "Connecting Router 3327"
$ns duplex-link $node(3327) $node(286) 1.5Mb 10ms DropTail
#puts "Connecting Router 3328"
$ns duplex-link $node(3328) $node(1849) 1.5Mb 10ms DropTail
#puts "Connecting Router 3330"
#puts "Connecting Router 3333"
$ns duplex-link $node(3333) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3333) $node(1103) 1.5Mb 10ms DropTail
$ns duplex-link $node(3333) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(3333) $node(1890) 1.5Mb 10ms DropTail
#puts "Connecting Router 3334"
#puts "Connecting Router 3335"
#puts "Connecting Router 3336"
$ns duplex-link $node(3336) $node(1800) 1.5Mb 10ms DropTail
#puts "Connecting Router 3339"
$ns duplex-link $node(3339) $node(2686) 1.5Mb 10ms DropTail
#puts "Connecting Router 3340"
#puts "Connecting Router 3343"
$ns duplex-link $node(3343) $node(1741) 1.5Mb 10ms DropTail
$ns duplex-link $node(3343) $node(2848) 1.5Mb 10ms DropTail
$ns duplex-link $node(3343) $node(2895) 1.5Mb 10ms DropTail
$ns duplex-link $node(3343) $node(3315) 1.5Mb 10ms DropTail
$ns duplex-link $node(3343) $node(3316) 1.5Mb 10ms DropTail
#puts "Connecting Router 3344"
$ns duplex-link $node(3344) $node(1849) 1.5Mb 10ms DropTail
#puts "Connecting Router 3352"
$ns duplex-link $node(3352) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(3352) $node(3324) 1.5Mb 10ms DropTail
#puts "Connecting Router 3354"
$ns duplex-link $node(3354) $node(114) 1.5Mb 10ms DropTail
$ns duplex-link $node(3354) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3354) $node(2276) 1.5Mb 10ms DropTail
#puts "Connecting Router 3356"
$ns duplex-link $node(3356) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3356) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3360"
#puts "Connecting Router 3361"
$ns duplex-link $node(3361) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3361) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3363"
#puts "Connecting Router 3365"
#puts "Connecting Router 3381"
$ns duplex-link $node(3381) $node(1335) 1.5Mb 10ms DropTail
#puts "Connecting Router 3384"
$ns duplex-link $node(3384) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3384) $node(2041) 1.5Mb 10ms DropTail
#puts "Connecting Router 3393"
#puts "Connecting Router 3404"
$ns duplex-link $node(3404) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3404) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3407"
$ns duplex-link $node(3407) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3407) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3407) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3407) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3407) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3409"
#puts "Connecting Router 3426"
$ns duplex-link $node(3426) $node(137) 1.5Mb 10ms DropTail
$ns duplex-link $node(3426) $node(293) 1.5Mb 10ms DropTail
#puts "Connecting Router 3429"
$ns duplex-link $node(3429) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3429) $node(2505) 1.5Mb 10ms DropTail
#puts "Connecting Router 3447"
$ns duplex-link $node(3447) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3449"
#puts "Connecting Router 3462"
#puts "Connecting Router 3463"
$ns duplex-link $node(3463) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3464"
#puts "Connecting Router 3479"
$ns duplex-link $node(3479) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 3484"
#puts "Connecting Router 3491"
$ns duplex-link $node(3491) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(3491) $node(1778) 1.5Mb 10ms DropTail
#puts "Connecting Router 3493"
#puts "Connecting Router 35"
#puts "Connecting Router 3505"
$ns duplex-link $node(3505) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3506"
$ns duplex-link $node(3506) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3506) $node(3447) 1.5Mb 10ms DropTail
#puts "Connecting Router 3508"
$ns duplex-link $node(3508) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3508) $node(2041) 1.5Mb 10ms DropTail
#puts "Connecting Router 3513"
#puts "Connecting Router 3527"
$ns duplex-link $node(3527) $node(10748) 1.5Mb 10ms DropTail
#puts "Connecting Router 3549"
$ns duplex-link $node(3549) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3549) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3549) $node(3491) 1.5Mb 10ms DropTail
#puts "Connecting Router 3550"
$ns duplex-link $node(3550) $node(10275) 1.5Mb 10ms DropTail
#puts "Connecting Router 3554"
$ns duplex-link $node(3554) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3557"
#puts "Connecting Router 3559"
#puts "Connecting Router 3561"
$ns duplex-link $node(3561) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3356) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3404) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3463) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(114) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(194) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(237) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(278) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1138) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1213) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1225) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1237) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1241) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1275) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1691) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1767) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1833) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1916) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1930) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(1982) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2033) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2044) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2150) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2276) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2493) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2500) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2510) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2521) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2529) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2578) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(2933) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3149) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3243) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3292) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3361) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3407) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3447) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3508) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(3559) 1.5Mb 10ms DropTail
$ns duplex-link $node(3561) $node(10450) 1.5Mb 10ms DropTail
#puts "Connecting Router 3564"
$ns duplex-link $node(3564) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3564) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3566"
#puts "Connecting Router 3575"
#puts "Connecting Router 3576"
#puts "Connecting Router 3577"
$ns duplex-link $node(3577) $node(3576) 1.5Mb 10ms DropTail
#puts "Connecting Router 3578"
#puts "Connecting Router 3586"
$ns duplex-link $node(3586) $node(10292) 1.5Mb 10ms DropTail
#puts "Connecting Router 3602"
$ns duplex-link $node(3602) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3603"
#puts "Connecting Router 3608"
$ns duplex-link $node(3608) $node(2856) 1.5Mb 10ms DropTail
#puts "Connecting Router 3615"
#puts "Connecting Router 3632"
$ns duplex-link $node(3632) $node(1292) 1.5Mb 10ms DropTail
$ns duplex-link $node(3632) $node(2549) 1.5Mb 10ms DropTail
#puts "Connecting Router 3640"
#puts "Connecting Router 3662"
$ns duplex-link $node(3662) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3669"
#puts "Connecting Router 3672"
#puts "Connecting Router 3676"
#puts "Connecting Router 3701"
$ns duplex-link $node(3701) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3701) $node(1798) 1.5Mb 10ms DropTail
#puts "Connecting Router 3714"
#puts "Connecting Router 3720"
$ns duplex-link $node(3720) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3720) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3720) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3720) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3722"
#puts "Connecting Router 3727"
#puts "Connecting Router 3734"
#puts "Connecting Router 3739"
$ns duplex-link $node(3739) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3739) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3741"
$ns duplex-link $node(3741) $node(2905) 1.5Mb 10ms DropTail
$ns duplex-link $node(3741) $node(2018) 1.5Mb 10ms DropTail
#puts "Connecting Router 3742"
$ns duplex-link $node(3742) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3742) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3743"
#puts "Connecting Router 3749"
$ns duplex-link $node(3749) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3749) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3758"
$ns duplex-link $node(3758) $node(1321) 1.5Mb 10ms DropTail
$ns duplex-link $node(3758) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 376"
#puts "Connecting Router 3761"
#puts "Connecting Router 3764"
$ns duplex-link $node(3764) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3764) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3768"
$ns duplex-link $node(3768) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3768) $node(1321) 1.5Mb 10ms DropTail
$ns duplex-link $node(3768) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3770"
#puts "Connecting Router 3776"
$ns duplex-link $node(3776) $node(1335) 1.5Mb 10ms DropTail
#puts "Connecting Router 3786"
$ns duplex-link $node(3786) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3789"
$ns duplex-link $node(3789) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3789) $node(1323) 1.5Mb 10ms DropTail
$ns duplex-link $node(3789) $node(2041) 1.5Mb 10ms DropTail
#puts "Connecting Router 3790"
#puts "Connecting Router 3796"
#puts "Connecting Router 38"
$ns duplex-link $node(38) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(38) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(38) $node(1225) 1.5Mb 10ms DropTail
#puts "Connecting Router 3801"
#puts "Connecting Router 3803"
$ns duplex-link $node(3803) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3804"
#puts "Connecting Router 3812"
#puts "Connecting Router 3817"
#puts "Connecting Router 3819"
#puts "Connecting Router 3820"
#puts "Connecting Router 3831"
$ns duplex-link $node(3831) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3831) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3838"
$ns duplex-link $node(3838) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3839"
#puts "Connecting Router 3844"
#puts "Connecting Router 3847"
$ns duplex-link $node(3847) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(3356) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(3463) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(3720) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(226) 1.5Mb 10ms DropTail
$ns duplex-link $node(3847) $node(2900) 1.5Mb 10ms DropTail
#puts "Connecting Router 3857"
$ns duplex-link $node(3857) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3857) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3857) $node(3847) 1.5Mb 10ms DropTail
#puts "Connecting Router 3900"
#puts "Connecting Router 3905"
$ns duplex-link $node(3905) $node(1322) 1.5Mb 10ms DropTail
#puts "Connecting Router 3909"
$ns duplex-link $node(3909) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(3909) $node(194) 1.5Mb 10ms DropTail
$ns duplex-link $node(3909) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 3914"
$ns duplex-link $node(3914) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3914) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3914) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(3914) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3914) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3915"
$ns duplex-link $node(3915) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3915) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3915) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3915) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3915) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3915) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3932"
$ns duplex-link $node(3932) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3932) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3932) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3932) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(3932) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3940"
$ns duplex-link $node(3940) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3951"
$ns duplex-link $node(3951) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3951) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 3963"
$ns duplex-link $node(3963) $node(3493) 1.5Mb 10ms DropTail
#puts "Connecting Router 3967"
$ns duplex-link $node(3967) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(3967) $node(2529) 1.5Mb 10ms DropTail
#puts "Connecting Router 3976"
$ns duplex-link $node(3976) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 3999"
#puts "Connecting Router 4000"
$ns duplex-link $node(4000) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(2854) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(2874) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(3215) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(4000) $node(3336) 1.5Mb 10ms DropTail
#puts "Connecting Router 4001"
$ns duplex-link $node(4001) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4001) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 4002"
$ns duplex-link $node(4002) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 4003"
$ns duplex-link $node(4003) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4003) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(4003) $node(3462) 1.5Mb 10ms DropTail
$ns duplex-link $node(4003) $node(3550) 1.5Mb 10ms DropTail
$ns duplex-link $node(4003) $node(3559) 1.5Mb 10ms DropTail
$ns duplex-link $node(4003) $node(3608) 1.5Mb 10ms DropTail
#puts "Connecting Router 4004"
$ns duplex-link $node(4004) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4004) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 4005"
$ns duplex-link $node(4005) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(1267) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(2860) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(3243) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(3340) 1.5Mb 10ms DropTail
$ns duplex-link $node(4005) $node(3741) 1.5Mb 10ms DropTail
#puts "Connecting Router 4006"
$ns duplex-link $node(4006) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4006) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4010"
#puts "Connecting Router 4040"
$ns duplex-link $node(4040) $node(3559) 1.5Mb 10ms DropTail
#puts "Connecting Router 4058"
$ns duplex-link $node(4058) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 4060"
$ns duplex-link $node(4060) $node(3559) 1.5Mb 10ms DropTail
$ns duplex-link $node(4060) $node(4040) 1.5Mb 10ms DropTail
#puts "Connecting Router 4130"
#puts "Connecting Router 4133"
#puts "Connecting Router 4134"
$ns duplex-link $node(4134) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4134) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4134) $node(4003) 1.5Mb 10ms DropTail
#puts "Connecting Router 4151"
#puts "Connecting Router 4167"
$ns duplex-link $node(4167) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4178"
#puts "Connecting Router 4183"
$ns duplex-link $node(4183) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4183) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4183) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(4183) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4183) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4183) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4189"
$ns duplex-link $node(4189) $node(145) 1.5Mb 10ms DropTail
#puts "Connecting Router 419"
#puts "Connecting Router 4195"
#puts "Connecting Router 4197"
$ns duplex-link $node(4197) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 4200"
$ns duplex-link $node(4200) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(1833) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(4200) $node(3720) 1.5Mb 10ms DropTail
#puts "Connecting Router 4203"
#puts "Connecting Router 4205"
$ns duplex-link $node(4205) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4205) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4211"
#puts "Connecting Router 4222"
$ns duplex-link $node(4222) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4222) $node(3701) 1.5Mb 10ms DropTail
#puts "Connecting Router 4230"
$ns duplex-link $node(4230) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4230) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(4230) $node(4005) 1.5Mb 10ms DropTail
#puts "Connecting Router 4231"
$ns duplex-link $node(4231) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 4232"
$ns duplex-link $node(4232) $node(10399) 1.5Mb 10ms DropTail
#puts "Connecting Router 4247"
#puts "Connecting Router 4251"
#puts "Connecting Router 4259"
$ns duplex-link $node(4259) $node(10399) 1.5Mb 10ms DropTail
#puts "Connecting Router 4261"
#puts "Connecting Router 4270"
$ns duplex-link $node(4270) $node(3449) 1.5Mb 10ms DropTail
#puts "Connecting Router 4274"
#puts "Connecting Router 4314"
#puts "Connecting Router 4352"
$ns duplex-link $node(4352) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 4358"
#puts "Connecting Router 4376"
#puts "Connecting Router 4387"
#puts "Connecting Router 4390"
#puts "Connecting Router 4433"
$ns duplex-link $node(4433) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(4433) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4434"
#puts "Connecting Router 4436"
$ns duplex-link $node(4436) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(4436) $node(4200) 1.5Mb 10ms DropTail
#puts "Connecting Router 4454"
#puts "Connecting Router 4459"
$ns duplex-link $node(4459) $node(2033) 1.5Mb 10ms DropTail
$ns duplex-link $node(4459) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(4459) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4470"
#puts "Connecting Router 4472"
#puts "Connecting Router 4492"
#puts "Connecting Router 4495"
#puts "Connecting Router 4496"
#puts "Connecting Router 450"
$ns duplex-link $node(450) $node(419) 1.5Mb 10ms DropTail
$ns duplex-link $node(450) $node(1913) 1.5Mb 10ms DropTail
#puts "Connecting Router 4509"
#puts "Connecting Router 4513"
$ns duplex-link $node(4513) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4513) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4515"
$ns duplex-link $node(4515) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4527"
#puts "Connecting Router 4534"
$ns duplex-link $node(4534) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4534) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4535"
#puts "Connecting Router 4544"
$ns duplex-link $node(4544) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4544) $node(1760) 1.5Mb 10ms DropTail
#puts "Connecting Router 4550"
$ns duplex-link $node(4550) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 4557"
$ns duplex-link $node(4557) $node(145) 1.5Mb 10ms DropTail
#puts "Connecting Router 4565"
$ns duplex-link $node(4565) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4565) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4589"
$ns duplex-link $node(4589) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(4589) $node(3491) 1.5Mb 10ms DropTail
#puts "Connecting Router 4600"
$ns duplex-link $node(4600) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4600) $node(3701) 1.5Mb 10ms DropTail
#puts "Connecting Router 4609"
$ns duplex-link $node(4609) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4618"
#puts "Connecting Router 4621"
#puts "Connecting Router 4622"
#puts "Connecting Router 4623"
$ns duplex-link $node(4623) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 4628"
#puts "Connecting Router 4630"
#puts "Connecting Router 4631"
$ns duplex-link $node(4631) $node(4623) 1.5Mb 10ms DropTail
#puts "Connecting Router 4637"
$ns duplex-link $node(4637) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(4637) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4637) $node(3662) 1.5Mb 10ms DropTail
$ns duplex-link $node(4637) $node(4609) 1.5Mb 10ms DropTail
$ns duplex-link $node(4637) $node(4623) 1.5Mb 10ms DropTail
$ns duplex-link $node(4637) $node(4630) 1.5Mb 10ms DropTail
#puts "Connecting Router 4648"
$ns duplex-link $node(4648) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4648) $node(4003) 1.5Mb 10ms DropTail
#puts "Connecting Router 4651"
$ns duplex-link $node(4651) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4652"
$ns duplex-link $node(4652) $node(4651) 1.5Mb 10ms DropTail
#puts "Connecting Router 4657"
#puts "Connecting Router 4660"
#puts "Connecting Router 4662"
#puts "Connecting Router 4663"
#puts "Connecting Router 4668"
#puts "Connecting Router 4673"
$ns duplex-link $node(4673) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4673) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(4673) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4677"
#puts "Connecting Router 4678"
#puts "Connecting Router 4681"
$ns duplex-link $node(4681) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4681) $node(2516) 1.5Mb 10ms DropTail
#puts "Connecting Router 4682"
$ns duplex-link $node(4682) $node(2497) 1.5Mb 10ms DropTail
#puts "Connecting Router 4686"
#puts "Connecting Router 4691"
#puts "Connecting Router 4692"
#puts "Connecting Router 4694"
$ns duplex-link $node(4694) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(2514) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(4197) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(4677) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(4678) 1.5Mb 10ms DropTail
$ns duplex-link $node(4694) $node(4686) 1.5Mb 10ms DropTail
#puts "Connecting Router 4700"
$ns duplex-link $node(4700) $node(4682) 1.5Mb 10ms DropTail
#puts "Connecting Router 4704"
$ns duplex-link $node(4704) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4704) $node(2510) 1.5Mb 10ms DropTail
$ns duplex-link $node(4704) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(4704) $node(4251) 1.5Mb 10ms DropTail
#puts "Connecting Router 4708"
#puts "Connecting Router 4710"
#puts "Connecting Router 4711"
$ns duplex-link $node(4711) $node(4694) 1.5Mb 10ms DropTail
#puts "Connecting Router 4713"
$ns duplex-link $node(4713) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4713) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(4713) $node(4710) 1.5Mb 10ms DropTail
#puts "Connecting Router 4716"
$ns duplex-link $node(4716) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4716) $node(2521) 1.5Mb 10ms DropTail
$ns duplex-link $node(4716) $node(4711) 1.5Mb 10ms DropTail
#puts "Connecting Router 4717"
$ns duplex-link $node(4717) $node(2500) 1.5Mb 10ms DropTail
$ns duplex-link $node(4717) $node(3363) 1.5Mb 10ms DropTail
#puts "Connecting Router 4720"
$ns duplex-link $node(4720) $node(4694) 1.5Mb 10ms DropTail
#puts "Connecting Router 4722"
$ns duplex-link $node(4722) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4722) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(4722) $node(2510) 1.5Mb 10ms DropTail
$ns duplex-link $node(4722) $node(4682) 1.5Mb 10ms DropTail
#puts "Connecting Router 4725"
$ns duplex-link $node(4725) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(2521) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(4722) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(2512) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(4692) 1.5Mb 10ms DropTail
$ns duplex-link $node(4725) $node(4708) 1.5Mb 10ms DropTail
#puts "Connecting Router 4727"
$ns duplex-link $node(4727) $node(4700) 1.5Mb 10ms DropTail
#puts "Connecting Router 4728"
#puts "Connecting Router 4736"
$ns duplex-link $node(4736) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(4736) $node(201) 1.5Mb 10ms DropTail
#puts "Connecting Router 4738"
#puts "Connecting Router 4740"
#puts "Connecting Router 4742"
$ns duplex-link $node(4742) $node(1221) 1.5Mb 10ms DropTail
#puts "Connecting Router 4744"
#puts "Connecting Router 4755"
$ns duplex-link $node(4755) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4755) $node(2697) 1.5Mb 10ms DropTail
#puts "Connecting Router 4760"
#puts "Connecting Router 4761"
$ns duplex-link $node(4761) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4761) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(4761) $node(4622) 1.5Mb 10ms DropTail
#puts "Connecting Router 4762"
#puts "Connecting Router 4763"
$ns duplex-link $node(4763) $node(1221) 1.5Mb 10ms DropTail
#puts "Connecting Router 4765"
$ns duplex-link $node(4765) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4765) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(4765) $node(4762) 1.5Mb 10ms DropTail
#puts "Connecting Router 4766"
$ns duplex-link $node(4766) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4766) $node(3559) 1.5Mb 10ms DropTail
$ns duplex-link $node(4766) $node(4660) 1.5Mb 10ms DropTail
#puts "Connecting Router 4767"
$ns duplex-link $node(4767) $node(4717) 1.5Mb 10ms DropTail
$ns duplex-link $node(4767) $node(4765) 1.5Mb 10ms DropTail
#puts "Connecting Router 4768"
$ns duplex-link $node(4768) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4768) $node(4763) 1.5Mb 10ms DropTail
#puts "Connecting Router 4774"
$ns duplex-link $node(4774) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4637) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(2042) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(2527) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(2706) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(3976) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4434) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4628) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4651) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4682) 1.5Mb 10ms DropTail
$ns duplex-link $node(4774) $node(4691) 1.5Mb 10ms DropTail
#puts "Connecting Router 4775"
$ns duplex-link $node(4775) $node(3758) 1.5Mb 10ms DropTail
#puts "Connecting Router 4776"
#puts "Connecting Router 4778"
$ns duplex-link $node(4778) $node(3786) 1.5Mb 10ms DropTail
#puts "Connecting Router 4779"
$ns duplex-link $node(4779) $node(4778) 1.5Mb 10ms DropTail
#puts "Connecting Router 4780"
$ns duplex-link $node(4780) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4780) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(4780) $node(4779) 1.5Mb 10ms DropTail
$ns duplex-link $node(4780) $node(4662) 1.5Mb 10ms DropTail
#puts "Connecting Router 4783"
$ns duplex-link $node(4783) $node(4778) 1.5Mb 10ms DropTail
$ns duplex-link $node(4783) $node(4780) 1.5Mb 10ms DropTail
#puts "Connecting Router 4786"
$ns duplex-link $node(4786) $node(1221) 1.5Mb 10ms DropTail
#puts "Connecting Router 4788"
$ns duplex-link $node(4788) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 4792"
$ns duplex-link $node(4792) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4792) $node(2792) 1.5Mb 10ms DropTail
#puts "Connecting Router 4793"
#puts "Connecting Router 4794"
#puts "Connecting Router 4795"
$ns duplex-link $node(4795) $node(4761) 1.5Mb 10ms DropTail
#puts "Connecting Router 4796"
$ns duplex-link $node(4796) $node(4717) 1.5Mb 10ms DropTail
#puts "Connecting Router 4800"
$ns duplex-link $node(4800) $node(4761) 1.5Mb 10ms DropTail
#puts "Connecting Router 4803"
#puts "Connecting Router 4805"
$ns duplex-link $node(4805) $node(2764) 1.5Mb 10ms DropTail
$ns duplex-link $node(4805) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(4805) $node(4736) 1.5Mb 10ms DropTail
$ns duplex-link $node(4805) $node(4744) 1.5Mb 10ms DropTail
#puts "Connecting Router 4855"
$ns duplex-link $node(4855) $node(4761) 1.5Mb 10ms DropTail
#puts "Connecting Router 4861"
$ns duplex-link $node(4861) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(4861) $node(4663) 1.5Mb 10ms DropTail
#puts "Connecting Router 4911"
$ns duplex-link $node(4911) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4911) $node(4203) 1.5Mb 10ms DropTail
#puts "Connecting Router 4913"
#puts "Connecting Router 4923"
$ns duplex-link $node(4923) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4923) $node(4133) 1.5Mb 10ms DropTail
$ns duplex-link $node(4923) $node(10367) 1.5Mb 10ms DropTail
#puts "Connecting Router 4926"
$ns duplex-link $node(4926) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(2688) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(4270) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10481) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10605) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10606) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10671) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10757) 1.5Mb 10ms DropTail
$ns duplex-link $node(4926) $node(10834) 1.5Mb 10ms DropTail
#puts "Connecting Router 4957"
$ns duplex-link $node(4957) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 4958"
#puts "Connecting Router 4963"
$ns duplex-link $node(4963) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 4967"
$ns duplex-link $node(4967) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 4969"
$ns duplex-link $node(4969) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(3564) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(3932) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(4231) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(3066) 1.5Mb 10ms DropTail
$ns duplex-link $node(4969) $node(4495) 1.5Mb 10ms DropTail
#puts "Connecting Router 4982"
#puts "Connecting Router 50"
$ns duplex-link $node(50) $node(293) 1.5Mb 10ms DropTail
#puts "Connecting Router 5000"
$ns duplex-link $node(5000) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5000) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5000) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5000) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5000) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5000) $node(4969) 1.5Mb 10ms DropTail
#puts "Connecting Router 5002"
#puts "Connecting Router 5003"
$ns duplex-link $node(5003) $node(3831) 1.5Mb 10ms DropTail
$ns duplex-link $node(5003) $node(4259) 1.5Mb 10ms DropTail
$ns duplex-link $node(5003) $node(10589) 1.5Mb 10ms DropTail
#puts "Connecting Router 5006"
$ns duplex-link $node(5006) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5006) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5006) $node(217) 1.5Mb 10ms DropTail
$ns duplex-link $node(5006) $node(1347) 1.5Mb 10ms DropTail
$ns duplex-link $node(5006) $node(1998) 1.5Mb 10ms DropTail
$ns duplex-link $node(5006) $node(10711) 1.5Mb 10ms DropTail
#puts "Connecting Router 5009"
#puts "Connecting Router 5048"
#puts "Connecting Router 5050"
$ns duplex-link $node(5050) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(204) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(1206) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(3577) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(3999) 1.5Mb 10ms DropTail
$ns duplex-link $node(5050) $node(4130) 1.5Mb 10ms DropTail
#puts "Connecting Router 5051"
$ns duplex-link $node(5051) $node(4766) 1.5Mb 10ms DropTail
#puts "Connecting Router 5072"
#puts "Connecting Router 5074"
#puts "Connecting Router 5075"
#puts "Connecting Router 5076"
#puts "Connecting Router 5078"
$ns duplex-link $node(5078) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5089"
$ns duplex-link $node(5089) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5089) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5089) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 5097"
$ns duplex-link $node(5097) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(5097) $node(2828) 1.5Mb 10ms DropTail
#puts "Connecting Router 5109"
#puts "Connecting Router 5119"
$ns duplex-link $node(5119) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5119) $node(3576) 1.5Mb 10ms DropTail
$ns duplex-link $node(5119) $node(10466) 1.5Mb 10ms DropTail
#puts "Connecting Router 513"
$ns duplex-link $node(513) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(513) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 517"
$ns duplex-link $node(517) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(517) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(517) $node(3257) 1.5Mb 10ms DropTail
#puts "Connecting Router 52"
$ns duplex-link $node(52) $node(1852) 1.5Mb 10ms DropTail
$ns duplex-link $node(52) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5203"
#puts "Connecting Router 523"
#puts "Connecting Router 5248"
$ns duplex-link $node(5248) $node(5203) 1.5Mb 10ms DropTail
#puts "Connecting Router 5377"
$ns duplex-link $node(5377) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(5377) $node(2588) 1.5Mb 10ms DropTail
$ns duplex-link $node(5377) $node(2614) 1.5Mb 10ms DropTail
#puts "Connecting Router 5378"
$ns duplex-link $node(5378) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(1653) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(1930) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(2874) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(3220) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(3336) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(3932) 1.5Mb 10ms DropTail
$ns duplex-link $node(5378) $node(5377) 1.5Mb 10ms DropTail
#puts "Connecting Router 5380"
#puts "Connecting Router 5382"
#puts "Connecting Router 5385"
#puts "Connecting Router 5387"
#puts "Connecting Router 5388"
$ns duplex-link $node(5388) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5388) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5388) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5388) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5388) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5388) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5389"
$ns duplex-link $node(5389) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5389) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5390"
$ns duplex-link $node(5390) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(5390) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5390) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5390) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5390) $node(3491) 1.5Mb 10ms DropTail
#puts "Connecting Router 5391"
$ns duplex-link $node(5391) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5391) $node(2108) 1.5Mb 10ms DropTail
#puts "Connecting Router 5393"
#puts "Connecting Router 5394"
#puts "Connecting Router 5395"
#puts "Connecting Router 5396"
#puts "Connecting Router 5397"
#puts "Connecting Router 5398"
#puts "Connecting Router 5400"
$ns duplex-link $node(5400) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5400) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5400) $node(1930) 1.5Mb 10ms DropTail
$ns duplex-link $node(5400) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(5400) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5400) $node(1890) 1.5Mb 10ms DropTail
#puts "Connecting Router 5402"
$ns duplex-link $node(5402) $node(2683) 1.5Mb 10ms DropTail
$ns duplex-link $node(5402) $node(5387) 1.5Mb 10ms DropTail
#puts "Connecting Router 5403"
$ns duplex-link $node(5403) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5403) $node(5385) 1.5Mb 10ms DropTail
#puts "Connecting Router 5405"
$ns duplex-link $node(5405) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5405) $node(3257) 1.5Mb 10ms DropTail
#puts "Connecting Router 5407"
$ns duplex-link $node(5407) $node(517) 1.5Mb 10ms DropTail
$ns duplex-link $node(5407) $node(2548) 1.5Mb 10ms DropTail
#puts "Connecting Router 5408"
$ns duplex-link $node(5408) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(5408) $node(2546) 1.5Mb 10ms DropTail
$ns duplex-link $node(5408) $node(3323) 1.5Mb 10ms DropTail
#puts "Connecting Router 5409"
$ns duplex-link $node(5409) $node(2548) 1.5Mb 10ms DropTail
#puts "Connecting Router 5412"
#puts "Connecting Router 5413"
$ns duplex-link $node(5413) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1759) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(1887) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3246) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3407) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3915) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(3967) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(4006) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(4544) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(4565) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(4969) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(5000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(5412) 1.5Mb 10ms DropTail
$ns duplex-link $node(5413) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 5414"
#puts "Connecting Router 5415"
$ns duplex-link $node(5415) $node(2548) 1.5Mb 10ms DropTail
#puts "Connecting Router 5416"
#puts "Connecting Router 5417"
$ns duplex-link $node(5417) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5417) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(5417) $node(2529) 1.5Mb 10ms DropTail
$ns duplex-link $node(5417) $node(1140) 1.5Mb 10ms DropTail
$ns duplex-link $node(5417) $node(2611) 1.5Mb 10ms DropTail
$ns duplex-link $node(5417) $node(3265) 1.5Mb 10ms DropTail
#puts "Connecting Router 5418"
$ns duplex-link $node(5418) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5418) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5418) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 5422"
$ns duplex-link $node(5422) $node(1290) 1.5Mb 10ms DropTail
#puts "Connecting Router 5423"
#puts "Connecting Router 5426"
#puts "Connecting Router 5428"
$ns duplex-link $node(5428) $node(5422) 1.5Mb 10ms DropTail
#puts "Connecting Router 5429"
#puts "Connecting Router 5430"
$ns duplex-link $node(5430) $node(3257) 1.5Mb 10ms DropTail
#puts "Connecting Router 5432"
#puts "Connecting Router 5434"
$ns duplex-link $node(5434) $node(2118) 1.5Mb 10ms DropTail
#puts "Connecting Router 5436"
#puts "Connecting Router 5441"
$ns duplex-link $node(5441) $node(137) 1.5Mb 10ms DropTail
#puts "Connecting Router 5442"
#puts "Connecting Router 5443"
$ns duplex-link $node(5443) $node(137) 1.5Mb 10ms DropTail
#puts "Connecting Router 5444"
$ns duplex-link $node(5444) $node(5441) 1.5Mb 10ms DropTail
#puts "Connecting Router 5445"
$ns duplex-link $node(5445) $node(137) 1.5Mb 10ms DropTail
$ns duplex-link $node(5445) $node(5441) 1.5Mb 10ms DropTail
#puts "Connecting Router 5446"
$ns duplex-link $node(5446) $node(5445) 1.5Mb 10ms DropTail
#puts "Connecting Router 5447"
$ns duplex-link $node(5447) $node(5441) 1.5Mb 10ms DropTail
#puts "Connecting Router 5448"
$ns duplex-link $node(5448) $node(137) 1.5Mb 10ms DropTail
$ns duplex-link $node(5448) $node(5442) 1.5Mb 10ms DropTail
#puts "Connecting Router 5449"
$ns duplex-link $node(5449) $node(5441) 1.5Mb 10ms DropTail
#puts "Connecting Router 5450"
$ns duplex-link $node(5450) $node(5441) 1.5Mb 10ms DropTail
#puts "Connecting Router 5451"
$ns duplex-link $node(5451) $node(5441) 1.5Mb 10ms DropTail
$ns duplex-link $node(5451) $node(5445) 1.5Mb 10ms DropTail
#puts "Connecting Router 5455"
$ns duplex-link $node(5455) $node(137) 1.5Mb 10ms DropTail
#puts "Connecting Router 5456"
$ns duplex-link $node(5456) $node(5455) 1.5Mb 10ms DropTail
#puts "Connecting Router 5457"
$ns duplex-link $node(5457) $node(5443) 1.5Mb 10ms DropTail
#puts "Connecting Router 5459"
$ns duplex-link $node(5459) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(1290) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(2529) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(2686) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(2917) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(3286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(3328) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(3344) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(4589) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(5089) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(5388) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(5390) 1.5Mb 10ms DropTail
$ns duplex-link $node(5459) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 5462"
$ns duplex-link $node(5462) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(3333) 1.5Mb 10ms DropTail
$ns duplex-link $node(5462) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5463"
#puts "Connecting Router 5466"
$ns duplex-link $node(5466) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5466) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5466) $node(3615) 1.5Mb 10ms DropTail
#puts "Connecting Router 5468"
#puts "Connecting Router 5470"
$ns duplex-link $node(5470) $node(5408) 1.5Mb 10ms DropTail
#puts "Connecting Router 5471"
#puts "Connecting Router 5479"
$ns duplex-link $node(5479) $node(5377) 1.5Mb 10ms DropTail
#puts "Connecting Router 5482"
#puts "Connecting Router 5483"
$ns duplex-link $node(5483) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(5483) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5483) $node(5393) 1.5Mb 10ms DropTail
#puts "Connecting Router 5484"
$ns duplex-link $node(5484) $node(5400) 1.5Mb 10ms DropTail
#puts "Connecting Router 549"
#puts "Connecting Router 5491"
$ns duplex-link $node(5491) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5491) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5491) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5491) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 5492"
$ns duplex-link $node(5492) $node(5491) 1.5Mb 10ms DropTail
#puts "Connecting Router 5496"
$ns duplex-link $node(5496) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5496) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 5498"
#puts "Connecting Router 5499"
#puts "Connecting Router 55"
$ns duplex-link $node(55) $node(10466) 1.5Mb 10ms DropTail
#puts "Connecting Router 5500"
#puts "Connecting Router 5503"
$ns duplex-link $node(5503) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 5505"
#puts "Connecting Router 5509"
$ns duplex-link $node(5509) $node(2874) 1.5Mb 10ms DropTail
$ns duplex-link $node(5509) $node(4000) 1.5Mb 10ms DropTail
#puts "Connecting Router 5510"
$ns duplex-link $node(5510) $node(3302) 1.5Mb 10ms DropTail
#puts "Connecting Router 5511"
$ns duplex-link $node(5511) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5511) $node(1717) 1.5Mb 10ms DropTail
$ns duplex-link $node(5511) $node(3215) 1.5Mb 10ms DropTail
#puts "Connecting Router 5512"
#puts "Connecting Router 5513"
$ns duplex-link $node(5513) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 5519"
$ns duplex-link $node(5519) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5519) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5519) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(5519) $node(5412) 1.5Mb 10ms DropTail
$ns duplex-link $node(5519) $node(5414) 1.5Mb 10ms DropTail
$ns duplex-link $node(5519) $node(5482) 1.5Mb 10ms DropTail
#puts "Connecting Router 5522"
$ns duplex-link $node(5522) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 5532"
#puts "Connecting Router 5533"
#puts "Connecting Router 5539"
$ns duplex-link $node(5539) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(5539) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5539) $node(5430) 1.5Mb 10ms DropTail
#puts "Connecting Router 5548"
#puts "Connecting Router 5549"
$ns duplex-link $node(5549) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(5549) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5549) $node(3257) 1.5Mb 10ms DropTail
#puts "Connecting Router 5551"
$ns duplex-link $node(5551) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5551) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5554"
$ns duplex-link $node(5554) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 5556"
$ns duplex-link $node(5556) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5556) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5556) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5556) $node(3292) 1.5Mb 10ms DropTail
#puts "Connecting Router 5557"
$ns duplex-link $node(5557) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5559"
$ns duplex-link $node(5559) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(5559) $node(5551) 1.5Mb 10ms DropTail
#puts "Connecting Router 5560"
$ns duplex-link $node(5560) $node(5000) 1.5Mb 10ms DropTail
#puts "Connecting Router 5561"
$ns duplex-link $node(5561) $node(2548) 1.5Mb 10ms DropTail
#puts "Connecting Router 5564"
$ns duplex-link $node(5564) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5564) $node(5388) 1.5Mb 10ms DropTail
$ns duplex-link $node(5564) $node(5500) 1.5Mb 10ms DropTail
#puts "Connecting Router 5568"
$ns duplex-link $node(5568) $node(3315) 1.5Mb 10ms DropTail
$ns duplex-link $node(5568) $node(3316) 1.5Mb 10ms DropTail
$ns duplex-link $node(5568) $node(3335) 1.5Mb 10ms DropTail
$ns duplex-link $node(5568) $node(3343) 1.5Mb 10ms DropTail
$ns duplex-link $node(5568) $node(5468) 1.5Mb 10ms DropTail
$ns duplex-link $node(5568) $node(5471) 1.5Mb 10ms DropTail
#puts "Connecting Router 5571"
$ns duplex-link $node(5571) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5571) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5571) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5573"
#puts "Connecting Router 5578"
#puts "Connecting Router 5580"
$ns duplex-link $node(5580) $node(3244) 1.5Mb 10ms DropTail
#puts "Connecting Router 5583"
$ns duplex-link $node(5583) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(5583) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5583) $node(5417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5583) $node(3333) 1.5Mb 10ms DropTail
#puts "Connecting Router 559"
#puts "Connecting Router 5590"
$ns duplex-link $node(5590) $node(5417) 1.5Mb 10ms DropTail
#puts "Connecting Router 5594"
$ns duplex-link $node(5594) $node(3305) 1.5Mb 10ms DropTail
#puts "Connecting Router 5596"
$ns duplex-link $node(5596) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 5597"
$ns duplex-link $node(5597) $node(5412) 1.5Mb 10ms DropTail
#puts "Connecting Router 5599"
#puts "Connecting Router 5600"
#puts "Connecting Router 5603"
$ns duplex-link $node(5603) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5604"
$ns duplex-link $node(5604) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5607"
$ns duplex-link $node(5607) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(5607) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5609"
#puts "Connecting Router 5611"
$ns duplex-link $node(5611) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5611) $node(5519) 1.5Mb 10ms DropTail
#puts "Connecting Router 5615"
$ns duplex-link $node(5615) $node(5417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5615) $node(5484) 1.5Mb 10ms DropTail
#puts "Connecting Router 5617"
$ns duplex-link $node(5617) $node(1887) 1.5Mb 10ms DropTail
$ns duplex-link $node(5617) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5618"
#puts "Connecting Router 5620"
$ns duplex-link $node(5620) $node(5377) 1.5Mb 10ms DropTail
#puts "Connecting Router 5621"
$ns duplex-link $node(5621) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5622"
#puts "Connecting Router 5623"
$ns duplex-link $node(5623) $node(1136) 1.5Mb 10ms DropTail
#puts "Connecting Router 5625"
#puts "Connecting Router 5628"
#puts "Connecting Router 5630"
#puts "Connecting Router 5632"
$ns duplex-link $node(5632) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(3356) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(2568) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(10289) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(10487) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(10708) 1.5Mb 10ms DropTail
$ns duplex-link $node(5632) $node(10732) 1.5Mb 10ms DropTail
#puts "Connecting Router 5637"
#puts "Connecting Router 5639"
#puts "Connecting Router 5641"
$ns duplex-link $node(5641) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5641) $node(3360) 1.5Mb 10ms DropTail
#puts "Connecting Router 5645"
#puts "Connecting Router 5646"
$ns duplex-link $node(5646) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(1323) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(38) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(103) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(160) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(2381) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(2907) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3365) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3669) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(3789) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(4247) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(4358) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(4527) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(10268) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(10377) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(10692) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(10711) 1.5Mb 10ms DropTail
$ns duplex-link $node(5646) $node(10839) 1.5Mb 10ms DropTail
#puts "Connecting Router 5648"
$ns duplex-link $node(5648) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 5650"
$ns duplex-link $node(5650) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(4167) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(4376) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(5048) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(5097) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(10345) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(10444) 1.5Mb 10ms DropTail
$ns duplex-link $node(5650) $node(10496) 1.5Mb 10ms DropTail
#puts "Connecting Router 5651"
$ns duplex-link $node(5651) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5651) $node(3578) 1.5Mb 10ms DropTail
#puts "Connecting Router 5656"
$ns duplex-link $node(5656) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 5666"
#puts "Connecting Router 5669"
$ns duplex-link $node(5669) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 5671"
$ns duplex-link $node(5671) $node(3356) 1.5Mb 10ms DropTail
#puts "Connecting Router 5672"
$ns duplex-link $node(5672) $node(10501) 1.5Mb 10ms DropTail
$ns duplex-link $node(5672) $node(10533) 1.5Mb 10ms DropTail
$ns duplex-link $node(5672) $node(10570) 1.5Mb 10ms DropTail
#puts "Connecting Router 5673"
$ns duplex-link $node(5673) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5673) $node(5671) 1.5Mb 10ms DropTail
$ns duplex-link $node(5673) $node(5672) 1.5Mb 10ms DropTail
$ns duplex-link $node(5673) $node(10270) 1.5Mb 10ms DropTail
$ns duplex-link $node(5673) $node(10725) 1.5Mb 10ms DropTail
#puts "Connecting Router 5676"
$ns duplex-link $node(5676) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5676) $node(5672) 1.5Mb 10ms DropTail
$ns duplex-link $node(5676) $node(10585) 1.5Mb 10ms DropTail
$ns duplex-link $node(5676) $node(10749) 1.5Mb 10ms DropTail
#puts "Connecting Router 5678"
$ns duplex-link $node(5678) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5678) $node(10306) 1.5Mb 10ms DropTail
#puts "Connecting Router 568"
$ns duplex-link $node(568) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(1913) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(568) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 5683"
$ns duplex-link $node(5683) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(3727) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(4760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(5551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(5666) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(10252) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(10278) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(10292) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(10535) 1.5Mb 10ms DropTail
$ns duplex-link $node(5683) $node(10661) 1.5Mb 10ms DropTail
#puts "Connecting Router 5687"
$ns duplex-link $node(5687) $node(3742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5687) $node(4534) 1.5Mb 10ms DropTail
$ns duplex-link $node(5687) $node(4982) 1.5Mb 10ms DropTail
#puts "Connecting Router 5691"
$ns duplex-link $node(5691) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5691) $node(35) 1.5Mb 10ms DropTail
#puts "Connecting Router 5692"
$ns duplex-link $node(5692) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 5693"
$ns duplex-link $node(5693) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5693) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5693) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5693) $node(10746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5693) $node(10766) 1.5Mb 10ms DropTail
#puts "Connecting Router 5696"
$ns duplex-link $node(5696) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(1808) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(2900) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3365) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3463) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3844) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(3967) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(4314) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(4358) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(4472) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(5009) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(5097) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10249) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10260) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10263) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10305) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10345) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10654) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10814) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10823) 1.5Mb 10ms DropTail
$ns duplex-link $node(5696) $node(10887) 1.5Mb 10ms DropTail
#puts "Connecting Router 5697"
$ns duplex-link $node(5697) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 5698"
$ns duplex-link $node(5698) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 5700"
$ns duplex-link $node(5700) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 5702"
#puts "Connecting Router 5710"
#puts "Connecting Router 5713"
$ns duplex-link $node(5713) $node(4178) 1.5Mb 10ms DropTail
$ns duplex-link $node(5713) $node(5710) 1.5Mb 10ms DropTail
$ns duplex-link $node(5713) $node(10393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5713) $node(10505) 1.5Mb 10ms DropTail
#puts "Connecting Router 5715"
$ns duplex-link $node(5715) $node(5006) 1.5Mb 10ms DropTail
#puts "Connecting Router 5726"
$ns duplex-link $node(5726) $node(226) 1.5Mb 10ms DropTail
$ns duplex-link $node(5726) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(5726) $node(4200) 1.5Mb 10ms DropTail
#puts "Connecting Router 5727"
$ns duplex-link $node(5727) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(4788) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(2042) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(2713) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(4134) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(4631) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(4742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5727) $node(4793) 1.5Mb 10ms DropTail
#puts "Connecting Router 5730"
#puts "Connecting Router 5736"
$ns duplex-link $node(5736) $node(5726) 1.5Mb 10ms DropTail
#puts "Connecting Router 5737"
$ns duplex-link $node(5737) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 5746"
$ns duplex-link $node(5746) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 5749"
#puts "Connecting Router 5754"
#puts "Connecting Router 5756"
#puts "Connecting Router 5760"
$ns duplex-link $node(5760) $node(10339) 1.5Mb 10ms DropTail
#puts "Connecting Router 5767"
#puts "Connecting Router 5768"
$ns duplex-link $node(5768) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 577"
$ns duplex-link $node(577) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(577) $node(549) 1.5Mb 10ms DropTail
$ns duplex-link $node(577) $node(2652) 1.5Mb 10ms DropTail
$ns duplex-link $node(577) $node(3804) 1.5Mb 10ms DropTail
$ns duplex-link $node(577) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5771"
#puts "Connecting Router 5773"
$ns duplex-link $node(5773) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 5778"
$ns duplex-link $node(5778) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5778) $node(10843) 1.5Mb 10ms DropTail
#puts "Connecting Router 5788"
$ns duplex-link $node(5788) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 5792"
$ns duplex-link $node(5792) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 5922"
#puts "Connecting Router 600"
$ns duplex-link $node(600) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 6057"
$ns duplex-link $node(6057) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6057) $node(1797) 1.5Mb 10ms DropTail
#puts "Connecting Router 6062"
$ns duplex-link $node(6062) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6062) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6062) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(6062) $node(10583) 1.5Mb 10ms DropTail
#puts "Connecting Router 6064"
#puts "Connecting Router 6065"
$ns duplex-link $node(6065) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6065) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 6066"
#puts "Connecting Router 6067"
$ns duplex-link $node(6067) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 6071"
#puts "Connecting Router 6072"
$ns duplex-link $node(6072) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6072) $node(6071) 1.5Mb 10ms DropTail
#puts "Connecting Router 6073"
$ns duplex-link $node(6073) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 6078"
$ns duplex-link $node(6078) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6078) $node(4969) 1.5Mb 10ms DropTail
#puts "Connecting Router 6079"
$ns duplex-link $node(6079) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6079) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(6079) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(6079) $node(5683) 1.5Mb 10ms DropTail
$ns duplex-link $node(6079) $node(4496) 1.5Mb 10ms DropTail
$ns duplex-link $node(6079) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 6081"
$ns duplex-link $node(6081) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6081) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6081) $node(4358) 1.5Mb 10ms DropTail
#puts "Connecting Router 6082"
$ns duplex-link $node(6082) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(6082) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6082) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(6082) $node(1784) 1.5Mb 10ms DropTail
$ns duplex-link $node(6082) $node(3066) 1.5Mb 10ms DropTail
$ns duplex-link $node(6082) $node(3803) 1.5Mb 10ms DropTail
#puts "Connecting Router 6083"
$ns duplex-link $node(6083) $node(5713) 1.5Mb 10ms DropTail
#puts "Connecting Router 6089"
$ns duplex-link $node(6089) $node(5713) 1.5Mb 10ms DropTail
#puts "Connecting Router 6095"
$ns duplex-link $node(6095) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6095) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 6112"
#puts "Connecting Router 6113"
$ns duplex-link $node(6113) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(4565) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(1220) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(3505) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(4958) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(5002) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(10304) 1.5Mb 10ms DropTail
$ns duplex-link $node(6113) $node(10793) 1.5Mb 10ms DropTail
#puts "Connecting Router 6114"
$ns duplex-link $node(6114) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 6115"
$ns duplex-link $node(6115) $node(6082) 1.5Mb 10ms DropTail
#puts "Connecting Router 6122"
$ns duplex-link $node(6122) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6122) $node(2698) 1.5Mb 10ms DropTail
$ns duplex-link $node(6122) $node(3676) 1.5Mb 10ms DropTail
#puts "Connecting Router 613"
#puts "Connecting Router 6136"
$ns duplex-link $node(6136) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6138"
$ns duplex-link $node(6138) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 6140"
$ns duplex-link $node(6140) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6140) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 6144"
#puts "Connecting Router 6147"
#puts "Connecting Router 6172"
$ns duplex-link $node(6172) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(2024) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(10240) 1.5Mb 10ms DropTail
$ns duplex-link $node(6172) $node(10746) 1.5Mb 10ms DropTail
#puts "Connecting Router 6180"
#puts "Connecting Router 6187"
$ns duplex-link $node(6187) $node(2905) 1.5Mb 10ms DropTail
$ns duplex-link $node(6187) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6187) $node(6083) 1.5Mb 10ms DropTail
$ns duplex-link $node(6187) $node(6180) 1.5Mb 10ms DropTail
#puts "Connecting Router 6188"
$ns duplex-link $node(6188) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(6188) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6188) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 6196"
$ns duplex-link $node(6196) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(1932) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(6196) $node(6066) 1.5Mb 10ms DropTail
#puts "Connecting Router 6197"
$ns duplex-link $node(6197) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6198"
$ns duplex-link $node(6198) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6200"
$ns duplex-link $node(6200) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6203"
#puts "Connecting Router 6205"
$ns duplex-link $node(6205) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6214"
$ns duplex-link $node(6214) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6217"
$ns duplex-link $node(6217) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6218"
$ns duplex-link $node(6218) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(6218) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6218) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6218) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6218) $node(3734) 1.5Mb 10ms DropTail
#puts "Connecting Router 6226"
$ns duplex-link $node(6226) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6226) $node(4211) 1.5Mb 10ms DropTail
#puts "Connecting Router 6233"
#puts "Connecting Router 6235"
$ns duplex-link $node(6235) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(5389) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(5510) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(5630) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(5651) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(6140) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(6233) 1.5Mb 10ms DropTail
$ns duplex-link $node(6235) $node(10674) 1.5Mb 10ms DropTail
#puts "Connecting Router 6239"
$ns duplex-link $node(6239) $node(5673) 1.5Mb 10ms DropTail
#puts "Connecting Router 6245"
$ns duplex-link $node(6245) $node(6082) 1.5Mb 10ms DropTail
#puts "Connecting Router 6251"
$ns duplex-link $node(6251) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6251) $node(52) 1.5Mb 10ms DropTail
#puts "Connecting Router 6255"
$ns duplex-link $node(6255) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6259"
$ns duplex-link $node(6259) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6259) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6259) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6259) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(6259) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(6259) $node(2015) 1.5Mb 10ms DropTail
#puts "Connecting Router 6261"
$ns duplex-link $node(6261) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6261) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6261) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6261) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(6261) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6269"
#puts "Connecting Router 6287"
$ns duplex-link $node(6287) $node(5737) 1.5Mb 10ms DropTail
#puts "Connecting Router 6292"
$ns duplex-link $node(6292) $node(5556) 1.5Mb 10ms DropTail
#puts "Connecting Router 6297"
#puts "Connecting Router 6299"
$ns duplex-link $node(6299) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6299) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6299) $node(6203) 1.5Mb 10ms DropTail
#puts "Connecting Router 6302"
$ns duplex-link $node(6302) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6302) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6302) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6302) $node(10589) 1.5Mb 10ms DropTail
#puts "Connecting Router 6306"
#puts "Connecting Router 6308"
$ns duplex-link $node(6308) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6308) $node(5771) 1.5Mb 10ms DropTail
#puts "Connecting Router 6315"
$ns duplex-link $node(6315) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 6320"
$ns duplex-link $node(6320) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6320) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6320) $node(3344) 1.5Mb 10ms DropTail
#puts "Connecting Router 6322"
$ns duplex-link $node(6322) $node(5048) 1.5Mb 10ms DropTail
$ns duplex-link $node(6322) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(6322) $node(5746) 1.5Mb 10ms DropTail
#puts "Connecting Router 6325"
$ns duplex-link $node(6325) $node(5656) 1.5Mb 10ms DropTail
#puts "Connecting Router 6327"
$ns duplex-link $node(6327) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6327) $node(3602) 1.5Mb 10ms DropTail
$ns duplex-link $node(6327) $node(3672) 1.5Mb 10ms DropTail
$ns duplex-link $node(6327) $node(4509) 1.5Mb 10ms DropTail
$ns duplex-link $node(6327) $node(6172) 1.5Mb 10ms DropTail
$ns duplex-link $node(6327) $node(10482) 1.5Mb 10ms DropTail
#puts "Connecting Router 6331"
#puts "Connecting Router 6332"
$ns duplex-link $node(6332) $node(1328) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(3905) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(278) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(1831) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(3640) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(6065) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(10436) 1.5Mb 10ms DropTail
$ns duplex-link $node(6332) $node(10479) 1.5Mb 10ms DropTail
#puts "Connecting Router 6335"
$ns duplex-link $node(6335) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6342"
$ns duplex-link $node(6342) $node(6332) 1.5Mb 10ms DropTail
#puts "Connecting Router 6345"
$ns duplex-link $node(6345) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6347"
$ns duplex-link $node(6347) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(613) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(2015) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(3796) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(3967) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(5076) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(5656) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(5756) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(6144) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10263) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10267) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10387) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10415) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10477) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10576) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10621) 1.5Mb 10ms DropTail
$ns duplex-link $node(6347) $node(10749) 1.5Mb 10ms DropTail
#puts "Connecting Router 6349"
$ns duplex-link $node(6349) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6350"
$ns duplex-link $node(6350) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(6350) $node(4390) 1.5Mb 10ms DropTail
#puts "Connecting Router 6357"
#puts "Connecting Router 6362"
#puts "Connecting Router 6365"
$ns duplex-link $node(6365) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6369"
$ns duplex-link $node(6369) $node(6235) 1.5Mb 10ms DropTail
#puts "Connecting Router 6371"
$ns duplex-link $node(6371) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6371) $node(3790) 1.5Mb 10ms DropTail
#puts "Connecting Router 6373"
$ns duplex-link $node(6373) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6375"
#puts "Connecting Router 6379"
$ns duplex-link $node(6379) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6380"
$ns duplex-link $node(6380) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6381"
$ns duplex-link $node(6381) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6382"
$ns duplex-link $node(6382) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(6382) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(6382) $node(4454) 1.5Mb 10ms DropTail
#puts "Connecting Router 6383"
$ns duplex-link $node(6383) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(6383) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(6383) $node(4454) 1.5Mb 10ms DropTail
#puts "Connecting Router 6384"
$ns duplex-link $node(6384) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6385"
$ns duplex-link $node(6385) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(6385) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(6385) $node(10349) 1.5Mb 10ms DropTail
#puts "Connecting Router 6386"
$ns duplex-link $node(6386) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(6386) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(6386) $node(3714) 1.5Mb 10ms DropTail
#puts "Connecting Router 6387"
$ns duplex-link $node(6387) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6388"
$ns duplex-link $node(6388) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(6388) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(6388) $node(3464) 1.5Mb 10ms DropTail
#puts "Connecting Router 6391"
$ns duplex-link $node(6391) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6391) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6391) $node(4200) 1.5Mb 10ms DropTail
#puts "Connecting Router 6392"
$ns duplex-link $node(6392) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6401"
$ns duplex-link $node(6401) $node(3602) 1.5Mb 10ms DropTail
$ns duplex-link $node(6401) $node(10264) 1.5Mb 10ms DropTail
#puts "Connecting Router 6402"
$ns duplex-link $node(6402) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(6402) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(6402) $node(5072) 1.5Mb 10ms DropTail
#puts "Connecting Router 6419"
$ns duplex-link $node(6419) $node(10506) 1.5Mb 10ms DropTail
#puts "Connecting Router 6427"
$ns duplex-link $node(6427) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6427) $node(1675) 1.5Mb 10ms DropTail
$ns duplex-link $node(6427) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 6428"
$ns duplex-link $node(6428) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 6433"
$ns duplex-link $node(6433) $node(5651) 1.5Mb 10ms DropTail
#puts "Connecting Router 6434"
$ns duplex-link $node(6434) $node(4969) 1.5Mb 10ms DropTail
#puts "Connecting Router 6441"
$ns duplex-link $node(6441) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6441) $node(6297) 1.5Mb 10ms DropTail
#puts "Connecting Router 6448"
$ns duplex-link $node(6448) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6450"
$ns duplex-link $node(6450) $node(2033) 1.5Mb 10ms DropTail
$ns duplex-link $node(6450) $node(4969) 1.5Mb 10ms DropTail
#puts "Connecting Router 6453"
$ns duplex-link $node(6453) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(577) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(1850) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(2042) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(2493) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(2820) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(2854) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(3249) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4230) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4274) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4618) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4768) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4776) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(4803) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(5416) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(5522) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(5607) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(5617) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(5639) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(6147) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(10256) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(10278) 1.5Mb 10ms DropTail
$ns duplex-link $node(6453) $node(10354) 1.5Mb 10ms DropTail
#puts "Connecting Router 6458"
$ns duplex-link $node(6458) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6458) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6461"
$ns duplex-link $node(6461) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(3557) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(3734) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(4058) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(5637) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(6320) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(10245) 1.5Mb 10ms DropTail
$ns duplex-link $node(6461) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 6463"
$ns duplex-link $node(6463) $node(577) 1.5Mb 10ms DropTail
$ns duplex-link $node(6463) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6463) $node(6327) 1.5Mb 10ms DropTail
#puts "Connecting Router 6467"
$ns duplex-link $node(6467) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3064) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3150) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3554) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3722) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(3801) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(4963) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(5009) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(5109) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(6064) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(6357) 1.5Mb 10ms DropTail
$ns duplex-link $node(6467) $node(6375) 1.5Mb 10ms DropTail
#puts "Connecting Router 6471"
$ns duplex-link $node(6471) $node(6371) 1.5Mb 10ms DropTail
#puts "Connecting Router 6472"
$ns duplex-link $node(6472) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 6474"
$ns duplex-link $node(6474) $node(6467) 1.5Mb 10ms DropTail
#puts "Connecting Router 6478"
$ns duplex-link $node(6478) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6478) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6478) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(6478) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6478) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6478) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6484"
#puts "Connecting Router 6487"
$ns duplex-link $node(6487) $node(6371) 1.5Mb 10ms DropTail
$ns duplex-link $node(6487) $node(6458) 1.5Mb 10ms DropTail
#puts "Connecting Router 6493"
$ns duplex-link $node(6493) $node(6078) 1.5Mb 10ms DropTail
#puts "Connecting Router 6494"
#puts "Connecting Router 6495"
$ns duplex-link $node(6495) $node(6332) 1.5Mb 10ms DropTail
#puts "Connecting Router 6496"
$ns duplex-link $node(6496) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6499"
$ns duplex-link $node(6499) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6499) $node(3743) 1.5Mb 10ms DropTail
#puts "Connecting Router 6503"
$ns duplex-link $node(6503) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6503) $node(278) 1.5Mb 10ms DropTail
$ns duplex-link $node(6503) $node(1292) 1.5Mb 10ms DropTail
$ns duplex-link $node(6503) $node(2549) 1.5Mb 10ms DropTail
$ns duplex-link $node(6503) $node(3632) 1.5Mb 10ms DropTail
$ns duplex-link $node(6503) $node(6064) 1.5Mb 10ms DropTail
#puts "Connecting Router 6505"
$ns duplex-link $node(6505) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6505) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(6505) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(6505) $node(4005) 1.5Mb 10ms DropTail
$ns duplex-link $node(6505) $node(10531) 1.5Mb 10ms DropTail
#puts "Connecting Router 6509"
$ns duplex-link $node(6509) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6509) $node(549) 1.5Mb 10ms DropTail
$ns duplex-link $node(6509) $node(376) 1.5Mb 10ms DropTail
#puts "Connecting Router 6521"
$ns duplex-link $node(6521) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 6525"
$ns duplex-link $node(6525) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 6540"
$ns duplex-link $node(6540) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 6541"
$ns duplex-link $node(6541) $node(1239) 1.5Mb 10ms DropTail
#puts "Connecting Router 6542"
$ns duplex-link $node(6542) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6542) $node(4535) 1.5Mb 10ms DropTail
#puts "Connecting Router 6543"
$ns duplex-link $node(6543) $node(6505) 1.5Mb 10ms DropTail
#puts "Connecting Router 6547"
#puts "Connecting Router 6553"
$ns duplex-link $node(6553) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(2915) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(1830) 1.5Mb 10ms DropTail
$ns duplex-link $node(6553) $node(10348) 1.5Mb 10ms DropTail
#puts "Connecting Router 6555"
$ns duplex-link $node(6555) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6561"
$ns duplex-link $node(6561) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6561) $node(6461) 1.5Mb 10ms DropTail
#puts "Connecting Router 6568"
#puts "Connecting Router 6571"
$ns duplex-link $node(6571) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 6576"
$ns duplex-link $node(6576) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6582"
$ns duplex-link $node(6582) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6582) $node(4151) 1.5Mb 10ms DropTail
#puts "Connecting Router 6583"
$ns duplex-link $node(6583) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6590"
$ns duplex-link $node(6590) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 6597"
$ns duplex-link $node(6597) $node(6235) 1.5Mb 10ms DropTail
#puts "Connecting Router 6598"
$ns duplex-link $node(6598) $node(4923) 1.5Mb 10ms DropTail
$ns duplex-link $node(6598) $node(6235) 1.5Mb 10ms DropTail
#puts "Connecting Router 6602"
$ns duplex-link $node(6602) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6604"
$ns duplex-link $node(6604) $node(5676) 1.5Mb 10ms DropTail
$ns duplex-link $node(6604) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 6618"
$ns duplex-link $node(6618) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(6618) $node(5683) 1.5Mb 10ms DropTail
$ns duplex-link $node(6618) $node(10335) 1.5Mb 10ms DropTail
#puts "Connecting Router 6619"
$ns duplex-link $node(6619) $node(5727) 1.5Mb 10ms DropTail
#puts "Connecting Router 6620"
$ns duplex-link $node(6620) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 6630"
$ns duplex-link $node(6630) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6633"
$ns duplex-link $node(6633) $node(6362) 1.5Mb 10ms DropTail
#puts "Connecting Router 6639"
$ns duplex-link $node(6639) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6648"
$ns duplex-link $node(6648) $node(10275) 1.5Mb 10ms DropTail
#puts "Connecting Router 6652"
$ns duplex-link $node(6652) $node(10814) 1.5Mb 10ms DropTail
#puts "Connecting Router 6656"
#puts "Connecting Router 6658"
#puts "Connecting Router 6660"
$ns duplex-link $node(6660) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(3066) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(6235) 1.5Mb 10ms DropTail
$ns duplex-link $node(6660) $node(5378) 1.5Mb 10ms DropTail
#puts "Connecting Router 6661"
$ns duplex-link $node(6661) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(6661) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(6661) $node(2602) 1.5Mb 10ms DropTail
#puts "Connecting Router 6662"
$ns duplex-link $node(6662) $node(2854) 1.5Mb 10ms DropTail
$ns duplex-link $node(6662) $node(5573) 1.5Mb 10ms DropTail
#puts "Connecting Router 6664"
$ns duplex-link $node(6664) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(2593) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(3228) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(3269) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(5394) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(5395) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(5397) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(5512) 1.5Mb 10ms DropTail
$ns duplex-link $node(6664) $node(5609) 1.5Mb 10ms DropTail
#puts "Connecting Router 6665"
$ns duplex-link $node(6665) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 6667"
#puts "Connecting Router 6668"
$ns duplex-link $node(6668) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(6668) $node(2012) 1.5Mb 10ms DropTail
#puts "Connecting Router 6669"
$ns duplex-link $node(6669) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6669) $node(5548) 1.5Mb 10ms DropTail
#puts "Connecting Router 6670"
$ns duplex-link $node(6670) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6670) $node(5556) 1.5Mb 10ms DropTail
#puts "Connecting Router 6671"
$ns duplex-link $node(6671) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 6676"
$ns duplex-link $node(6676) $node(5462) 1.5Mb 10ms DropTail
#puts "Connecting Router 6677"
$ns duplex-link $node(6677) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6678"
#puts "Connecting Router 6679"
$ns duplex-link $node(6679) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(6679) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6679) $node(513) 1.5Mb 10ms DropTail
$ns duplex-link $node(6679) $node(559) 1.5Mb 10ms DropTail
#puts "Connecting Router 668"
$ns duplex-link $node(668) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(22) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(132) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(668) $node(3847) 1.5Mb 10ms DropTail
#puts "Connecting Router 6680"
$ns duplex-link $node(6680) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(6680) $node(1275) 1.5Mb 10ms DropTail
$ns duplex-link $node(6680) $node(2602) 1.5Mb 10ms DropTail
$ns duplex-link $node(6680) $node(2852) 1.5Mb 10ms DropTail
$ns duplex-link $node(6680) $node(6679) 1.5Mb 10ms DropTail
#puts "Connecting Router 6681"
$ns duplex-link $node(6681) $node(6680) 1.5Mb 10ms DropTail
$ns duplex-link $node(6681) $node(1717) 1.5Mb 10ms DropTail
#puts "Connecting Router 6682"
$ns duplex-link $node(6682) $node(5408) 1.5Mb 10ms DropTail
$ns duplex-link $node(6682) $node(6679) 1.5Mb 10ms DropTail
$ns duplex-link $node(6682) $node(6680) 1.5Mb 10ms DropTail
#puts "Connecting Router 6683"
$ns duplex-link $node(6683) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6683) $node(6680) 1.5Mb 10ms DropTail
$ns duplex-link $node(6683) $node(6681) 1.5Mb 10ms DropTail
#puts "Connecting Router 6684"
$ns duplex-link $node(6684) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6684) $node(6664) 1.5Mb 10ms DropTail
$ns duplex-link $node(6684) $node(3313) 1.5Mb 10ms DropTail
$ns duplex-link $node(6684) $node(5396) 1.5Mb 10ms DropTail
$ns duplex-link $node(6684) $node(5499) 1.5Mb 10ms DropTail
#puts "Connecting Router 6685"
$ns duplex-link $node(6685) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6685) $node(5539) 1.5Mb 10ms DropTail
#puts "Connecting Router 6686"
$ns duplex-link $node(6686) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6686) $node(5618) 1.5Mb 10ms DropTail
#puts "Connecting Router 6687"
$ns duplex-link $node(6687) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6687) $node(3291) 1.5Mb 10ms DropTail
#puts "Connecting Router 6688"
$ns duplex-link $node(6688) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6688) $node(10243) 1.5Mb 10ms DropTail
#puts "Connecting Router 6689"
$ns duplex-link $node(6689) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6689) $node(5436) 1.5Mb 10ms DropTail
#puts "Connecting Router 6690"
$ns duplex-link $node(6690) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6691"
$ns duplex-link $node(6691) $node(6684) 1.5Mb 10ms DropTail
#puts "Connecting Router 6697"
$ns duplex-link $node(6697) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6697) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(6697) $node(5498) 1.5Mb 10ms DropTail
#puts "Connecting Router 6703"
$ns duplex-link $node(6703) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 6706"
$ns duplex-link $node(6706) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6708"
#puts "Connecting Router 6713"
#puts "Connecting Router 6714"
$ns duplex-link $node(6714) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 6715"
$ns duplex-link $node(6715) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(6715) $node(5484) 1.5Mb 10ms DropTail
#puts "Connecting Router 6716"
$ns duplex-link $node(6716) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6716) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6716) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(6716) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(6716) $node(3328) 1.5Mb 10ms DropTail
#puts "Connecting Router 6717"
$ns duplex-link $node(6717) $node(5462) 1.5Mb 10ms DropTail
#puts "Connecting Router 6718"
$ns duplex-link $node(6718) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6718) $node(5382) 1.5Mb 10ms DropTail
$ns duplex-link $node(6718) $node(5499) 1.5Mb 10ms DropTail
#puts "Connecting Router 6719"
$ns duplex-link $node(6719) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6719) $node(3291) 1.5Mb 10ms DropTail
$ns duplex-link $node(6719) $node(3334) 1.5Mb 10ms DropTail
$ns duplex-link $node(6719) $node(5398) 1.5Mb 10ms DropTail
$ns duplex-link $node(6719) $node(5622) 1.5Mb 10ms DropTail
#puts "Connecting Router 6722"
$ns duplex-link $node(6722) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 6726"
$ns duplex-link $node(6726) $node(2686) 1.5Mb 10ms DropTail
#puts "Connecting Router 6727"
$ns duplex-link $node(6727) $node(5607) 1.5Mb 10ms DropTail
#puts "Connecting Router 6728"
$ns duplex-link $node(6728) $node(3328) 1.5Mb 10ms DropTail
$ns duplex-link $node(6728) $node(5378) 1.5Mb 10ms DropTail
#puts "Connecting Router 6730"
$ns duplex-link $node(6730) $node(3303) 1.5Mb 10ms DropTail
$ns duplex-link $node(6730) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6730) $node(6687) 1.5Mb 10ms DropTail
$ns duplex-link $node(6730) $node(3334) 1.5Mb 10ms DropTail
$ns duplex-link $node(6730) $node(5398) 1.5Mb 10ms DropTail
#puts "Connecting Router 6731"
#puts "Connecting Router 6732"
$ns duplex-link $node(6732) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 6734"
$ns duplex-link $node(6734) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 6735"
#puts "Connecting Router 6737"
$ns duplex-link $node(6737) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 6740"
$ns duplex-link $node(6740) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(6740) $node(5407) 1.5Mb 10ms DropTail
$ns duplex-link $node(6740) $node(5580) 1.5Mb 10ms DropTail
#puts "Connecting Router 6742"
$ns duplex-link $node(6742) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(6742) $node(5623) 1.5Mb 10ms DropTail
#puts "Connecting Router 6744"
$ns duplex-link $node(6744) $node(5408) 1.5Mb 10ms DropTail
#puts "Connecting Router 6745"
$ns duplex-link $node(6745) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6745) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6745) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 6746"
$ns duplex-link $node(6746) $node(5377) 1.5Mb 10ms DropTail
#puts "Connecting Router 6750"
$ns duplex-link $node(6750) $node(6726) 1.5Mb 10ms DropTail
#puts "Connecting Router 6751"
$ns duplex-link $node(6751) $node(5549) 1.5Mb 10ms DropTail
#puts "Connecting Router 6752"
#puts "Connecting Router 6753"
$ns duplex-link $node(6753) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6753) $node(3258) 1.5Mb 10ms DropTail
#puts "Connecting Router 6754"
$ns duplex-link $node(6754) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(6754) $node(3306) 1.5Mb 10ms DropTail
$ns duplex-link $node(6754) $node(3258) 1.5Mb 10ms DropTail
$ns duplex-link $node(6754) $node(6753) 1.5Mb 10ms DropTail
#puts "Connecting Router 6756"
$ns duplex-link $node(6756) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 6757"
$ns duplex-link $node(6757) $node(5551) 1.5Mb 10ms DropTail
#puts "Connecting Router 6760"
$ns duplex-link $node(6760) $node(5594) 1.5Mb 10ms DropTail
#puts "Connecting Router 6761"
$ns duplex-link $node(6761) $node(6689) 1.5Mb 10ms DropTail
#puts "Connecting Router 6762"
$ns duplex-link $node(6762) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(6664) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(2609) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(4755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(5505) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(5532) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(6568) 1.5Mb 10ms DropTail
$ns duplex-link $node(6762) $node(6713) 1.5Mb 10ms DropTail
#puts "Connecting Router 6763"
$ns duplex-link $node(6763) $node(5607) 1.5Mb 10ms DropTail
#puts "Connecting Router 6764"
$ns duplex-link $node(6764) $node(5623) 1.5Mb 10ms DropTail
#puts "Connecting Router 6765"
$ns duplex-link $node(6765) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(5426) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(5503) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(5600) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(5611) 1.5Mb 10ms DropTail
$ns duplex-link $node(6765) $node(6656) 1.5Mb 10ms DropTail
#puts "Connecting Router 6769"
#puts "Connecting Router 6770"
$ns duplex-link $node(6770) $node(6679) 1.5Mb 10ms DropTail
#puts "Connecting Router 6771"
$ns duplex-link $node(6771) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6772"
$ns duplex-link $node(6772) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 6774"
$ns duplex-link $node(6774) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6774) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6774) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6774) $node(5432) 1.5Mb 10ms DropTail
#puts "Connecting Router 6776"
$ns duplex-link $node(6776) $node(6730) 1.5Mb 10ms DropTail
#puts "Connecting Router 6778"
$ns duplex-link $node(6778) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 6783"
$ns duplex-link $node(6783) $node(6754) 1.5Mb 10ms DropTail
#puts "Connecting Router 6784"
$ns duplex-link $node(6784) $node(5561) 1.5Mb 10ms DropTail
#puts "Connecting Router 6785"
$ns duplex-link $node(6785) $node(5509) 1.5Mb 10ms DropTail
#puts "Connecting Router 6787"
$ns duplex-link $node(6787) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 6792"
$ns duplex-link $node(6792) $node(6461) 1.5Mb 10ms DropTail
#puts "Connecting Router 6793"
$ns duplex-link $node(6793) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(6793) $node(6667) 1.5Mb 10ms DropTail
#puts "Connecting Router 6795"
#puts "Connecting Router 6798"
#puts "Connecting Router 6799"
$ns duplex-link $node(6799) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(6799) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6799) $node(3260) 1.5Mb 10ms DropTail
#puts "Connecting Router 6803"
#puts "Connecting Router 6805"
$ns duplex-link $node(6805) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(6805) $node(1324) 1.5Mb 10ms DropTail
$ns duplex-link $node(6805) $node(1667) 1.5Mb 10ms DropTail
$ns duplex-link $node(6805) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(6805) $node(2871) 1.5Mb 10ms DropTail
#puts "Connecting Router 6806"
#puts "Connecting Router 6809"
$ns duplex-link $node(6809) $node(4913) 1.5Mb 10ms DropTail
#puts "Connecting Router 681"
$ns duplex-link $node(681) $node(4763) 1.5Mb 10ms DropTail
$ns duplex-link $node(681) $node(4768) 1.5Mb 10ms DropTail
#puts "Connecting Router 6813"
$ns duplex-link $node(6813) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6813) $node(1930) 1.5Mb 10ms DropTail
$ns duplex-link $node(6813) $node(3352) 1.5Mb 10ms DropTail
$ns duplex-link $node(6813) $node(6752) 1.5Mb 10ms DropTail
#puts "Connecting Router 6820"
$ns duplex-link $node(6820) $node(6793) 1.5Mb 10ms DropTail
#puts "Connecting Router 6821"
$ns duplex-link $node(6821) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 6823"
$ns duplex-link $node(6823) $node(5405) 1.5Mb 10ms DropTail
#puts "Connecting Router 6827"
$ns duplex-link $node(6827) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6829"
#puts "Connecting Router 683"
$ns duplex-link $node(683) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(683) $node(1225) 1.5Mb 10ms DropTail
$ns duplex-link $node(683) $node(3847) 1.5Mb 10ms DropTail
#puts "Connecting Router 6830"
$ns duplex-link $node(6830) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 6841"
$ns duplex-link $node(6841) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(3304) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(1103) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(1136) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(3216) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(6841) $node(3305) 1.5Mb 10ms DropTail
#puts "Connecting Router 6844"
$ns duplex-link $node(6844) $node(4005) 1.5Mb 10ms DropTail
#puts "Connecting Router 6845"
$ns duplex-link $node(6845) $node(5377) 1.5Mb 10ms DropTail
#puts "Connecting Router 6846"
$ns duplex-link $node(6846) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(6846) $node(3252) 1.5Mb 10ms DropTail
$ns duplex-link $node(6846) $node(5380) 1.5Mb 10ms DropTail
$ns duplex-link $node(6846) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 6847"
$ns duplex-link $node(6847) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(6847) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 6848"
$ns duplex-link $node(6848) $node(6686) 1.5Mb 10ms DropTail
#puts "Connecting Router 6849"
$ns duplex-link $node(6849) $node(5415) 1.5Mb 10ms DropTail
$ns duplex-link $node(6849) $node(3252) 1.5Mb 10ms DropTail
$ns duplex-link $node(6849) $node(3254) 1.5Mb 10ms DropTail
$ns duplex-link $node(6849) $node(3261) 1.5Mb 10ms DropTail
$ns duplex-link $node(6849) $node(5380) 1.5Mb 10ms DropTail
#puts "Connecting Router 685"
$ns duplex-link $node(685) $node(3940) 1.5Mb 10ms DropTail
$ns duplex-link $node(685) $node(4134) 1.5Mb 10ms DropTail
$ns duplex-link $node(685) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(685) $node(2914) 1.5Mb 10ms DropTail
#puts "Connecting Router 6850"
$ns duplex-link $node(6850) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(6850) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 6852"
$ns duplex-link $node(6852) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6852) $node(5463) 1.5Mb 10ms DropTail
$ns duplex-link $node(6852) $node(5618) 1.5Mb 10ms DropTail
#puts "Connecting Router 6853"
$ns duplex-link $node(6853) $node(5533) 1.5Mb 10ms DropTail
#puts "Connecting Router 6854"
#puts "Connecting Router 6855"
$ns duplex-link $node(6855) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(6855) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(6855) $node(5628) 1.5Mb 10ms DropTail
#puts "Connecting Router 6858"
#puts "Connecting Router 6859"
$ns duplex-link $node(6859) $node(5388) 1.5Mb 10ms DropTail
#puts "Connecting Router 6863"
$ns duplex-link $node(6863) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(6863) $node(2766) 1.5Mb 10ms DropTail
$ns duplex-link $node(6863) $node(6858) 1.5Mb 10ms DropTail
#puts "Connecting Router 6864"
#puts "Connecting Router 6866"
$ns duplex-link $node(6866) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6866) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(6866) $node(3268) 1.5Mb 10ms DropTail
#puts "Connecting Router 6867"
$ns duplex-link $node(6867) $node(5408) 1.5Mb 10ms DropTail
#puts "Connecting Router 6868"
$ns duplex-link $node(6868) $node(3316) 1.5Mb 10ms DropTail
#puts "Connecting Router 687"
#puts "Connecting Router 6870"
$ns duplex-link $node(6870) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(6870) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(6870) $node(3340) 1.5Mb 10ms DropTail
$ns duplex-link $node(6870) $node(5412) 1.5Mb 10ms DropTail
$ns duplex-link $node(6870) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 6871"
$ns duplex-link $node(6871) $node(5571) 1.5Mb 10ms DropTail
#puts "Connecting Router 6873"
$ns duplex-link $node(6873) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(3248) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(3330) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(5403) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(5423) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(6798) 1.5Mb 10ms DropTail
$ns duplex-link $node(6873) $node(6829) 1.5Mb 10ms DropTail
#puts "Connecting Router 6876"
$ns duplex-link $node(6876) $node(6849) 1.5Mb 10ms DropTail
#puts "Connecting Router 6878"
$ns duplex-link $node(6878) $node(6805) 1.5Mb 10ms DropTail
#puts "Connecting Router 6880"
$ns duplex-link $node(6880) $node(6868) 1.5Mb 10ms DropTail
#puts "Connecting Router 6881"
$ns duplex-link $node(6881) $node(5407) 1.5Mb 10ms DropTail
#puts "Connecting Router 6882"
$ns duplex-link $node(6882) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 6883"
$ns duplex-link $node(6883) $node(5403) 1.5Mb 10ms DropTail
#puts "Connecting Router 6884"
$ns duplex-link $node(6884) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 6886"
$ns duplex-link $node(6886) $node(5380) 1.5Mb 10ms DropTail
#puts "Connecting Router 6887"
#puts "Connecting Router 6888"
#puts "Connecting Router 6889"
$ns duplex-link $node(6889) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(6889) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 6893"
$ns duplex-link $node(6893) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 6896"
$ns duplex-link $node(6896) $node(5603) 1.5Mb 10ms DropTail
#puts "Connecting Router 6897"
$ns duplex-link $node(6897) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(6897) $node(3273) 1.5Mb 10ms DropTail
#puts "Connecting Router 6902"
$ns duplex-link $node(6902) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(6902) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 6903"
#puts "Connecting Router 6904"
$ns duplex-link $node(6904) $node(5623) 1.5Mb 10ms DropTail
#puts "Connecting Router 6905"
$ns duplex-link $node(6905) $node(6841) 1.5Mb 10ms DropTail
$ns duplex-link $node(6905) $node(3333) 1.5Mb 10ms DropTail
$ns duplex-link $node(6905) $node(5623) 1.5Mb 10ms DropTail
#puts "Connecting Router 6912"
$ns duplex-link $node(6912) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6913"
$ns duplex-link $node(6913) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 6922"
$ns duplex-link $node(6922) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6922) $node(3354) 1.5Mb 10ms DropTail
$ns duplex-link $node(6922) $node(1761) 1.5Mb 10ms DropTail
$ns duplex-link $node(6922) $node(1970) 1.5Mb 10ms DropTail
#puts "Connecting Router 6924"
$ns duplex-link $node(6924) $node(5737) 1.5Mb 10ms DropTail
#puts "Connecting Router 693"
$ns duplex-link $node(693) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 6938"
$ns duplex-link $node(6938) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(6938) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 6939"
$ns duplex-link $node(6939) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(6939) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(6939) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(6939) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(6939) $node(6461) 1.5Mb 10ms DropTail
#puts "Connecting Router 6954"
$ns duplex-link $node(6954) $node(6095) 1.5Mb 10ms DropTail
#puts "Connecting Router 6955"
$ns duplex-link $node(6955) $node(1325) 1.5Mb 10ms DropTail
$ns duplex-link $node(6955) $node(6954) 1.5Mb 10ms DropTail
$ns duplex-link $node(6955) $node(10590) 1.5Mb 10ms DropTail
$ns duplex-link $node(6955) $node(10618) 1.5Mb 10ms DropTail
#puts "Connecting Router 6957"
$ns duplex-link $node(6957) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 6968"
$ns duplex-link $node(6968) $node(6083) 1.5Mb 10ms DropTail
$ns duplex-link $node(6968) $node(6089) 1.5Mb 10ms DropTail
#puts "Connecting Router 6981"
$ns duplex-link $node(6981) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(6981) $node(6235) 1.5Mb 10ms DropTail
#puts "Connecting Router 6983"
$ns duplex-link $node(6983) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6983) $node(6467) 1.5Mb 10ms DropTail
$ns duplex-link $node(6983) $node(6112) 1.5Mb 10ms DropTail
#puts "Connecting Router 6984"
$ns duplex-link $node(6984) $node(1326) 1.5Mb 10ms DropTail
$ns duplex-link $node(6984) $node(146) 1.5Mb 10ms DropTail
#puts "Connecting Router 6986"
$ns duplex-link $node(6986) $node(6391) 1.5Mb 10ms DropTail
#puts "Connecting Router 6990"
$ns duplex-link $node(6990) $node(6218) 1.5Mb 10ms DropTail
#puts "Connecting Router 6993"
$ns duplex-link $node(6993) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(6993) $node(1331) 1.5Mb 10ms DropTail
$ns duplex-link $node(6993) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(6993) $node(3575) 1.5Mb 10ms DropTail
#puts "Connecting Router 6997"
#puts "Connecting Router 70"
$ns duplex-link $node(70) $node(1) 1.5Mb 10ms DropTail
#puts "Connecting Router 7001"
$ns duplex-link $node(7001) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7003"
$ns duplex-link $node(7003) $node(6993) 1.5Mb 10ms DropTail
#puts "Connecting Router 7006"
$ns duplex-link $node(7006) $node(3384) 1.5Mb 10ms DropTail
$ns duplex-link $node(7006) $node(10734) 1.5Mb 10ms DropTail
#puts "Connecting Router 701"
$ns duplex-link $node(701) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(114) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(17) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(33) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(284) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(685) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1270) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1760) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1833) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(1982) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2276) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2706) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2871) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2905) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2917) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(2933) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3216) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3243) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3286) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3302) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3336) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3356) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3384) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3407) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3479) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3493) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3739) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3742) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3803) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3820) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3838) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3914) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3915) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3967) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(3976) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4006) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4058) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4183) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4195) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4231) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4352) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4433) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4436) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4495) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4515) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4534) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4544) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4565) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4600) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4621) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4637) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4694) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4722) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4778) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4786) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4792) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4911) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4913) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4923) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(4969) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5000) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5003) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5089) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5390) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5418) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5462) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5496) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5580) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5594) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5650) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5671) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5683) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5713) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5727) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5737) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5754) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(5778) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6073) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6078) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6081) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6082) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6095) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6196) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6226) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6235) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6299) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6335) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6347) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6362) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6365) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6371) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6461) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6467) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6478) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6499) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6525) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6541) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6553) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6582) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6664) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6745) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6938) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6955) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6983) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(6993) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(10275) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(10339) 1.5Mb 10ms DropTail
$ns duplex-link $node(701) $node(10748) 1.5Mb 10ms DropTail
#puts "Connecting Router 7015"
#puts "Connecting Router 7017"
#puts "Connecting Router 7018"
$ns duplex-link $node(7018) $node(6478) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(1742) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(1975) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(2572) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(2767) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(3462) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(3741) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(4780) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(4926) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(5074) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(5075) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(5623) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(5727) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(5730) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6203) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6269) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6742) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6795) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6841) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(6922) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(10384) 1.5Mb 10ms DropTail
$ns duplex-link $node(7018) $node(10588) 1.5Mb 10ms DropTail
#puts "Connecting Router 702"
$ns duplex-link $node(702) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1103) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1267) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1270) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1653) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1759) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(2871) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(2917) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3242) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3243) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3246) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3286) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3302) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3324) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3328) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3333) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(3336) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5390) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5409) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5418) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5430) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5434) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5496) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(5556) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(6735) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(6754) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(6849) 1.5Mb 10ms DropTail
$ns duplex-link $node(702) $node(6902) 1.5Mb 10ms DropTail
#puts "Connecting Router 7020"
$ns duplex-link $node(7020) $node(6187) 1.5Mb 10ms DropTail
#puts "Connecting Router 7021"
$ns duplex-link $node(7021) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(7021) $node(10279) 1.5Mb 10ms DropTail
$ns duplex-link $node(7021) $node(10448) 1.5Mb 10ms DropTail
#puts "Connecting Router 7022"
$ns duplex-link $node(7022) $node(5672) 1.5Mb 10ms DropTail
#puts "Connecting Router 703"
$ns duplex-link $node(703) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(703) $node(702) 1.5Mb 10ms DropTail
$ns duplex-link $node(703) $node(3758) 1.5Mb 10ms DropTail
$ns duplex-link $node(703) $node(4515) 1.5Mb 10ms DropTail
$ns duplex-link $node(703) $node(4778) 1.5Mb 10ms DropTail
#puts "Connecting Router 7037"
$ns duplex-link $node(7037) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7037) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7037) $node(3776) 1.5Mb 10ms DropTail
$ns duplex-link $node(7037) $node(4010) 1.5Mb 10ms DropTail
$ns duplex-link $node(7037) $node(10684) 1.5Mb 10ms DropTail
#puts "Connecting Router 7038"
$ns duplex-link $node(7038) $node(6332) 1.5Mb 10ms DropTail
#puts "Connecting Router 7051"
$ns duplex-link $node(7051) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7051) $node(5650) 1.5Mb 10ms DropTail
$ns duplex-link $node(7051) $node(6322) 1.5Mb 10ms DropTail
$ns duplex-link $node(7051) $node(10385) 1.5Mb 10ms DropTail
#puts "Connecting Router 7055"
$ns duplex-link $node(7055) $node(5641) 1.5Mb 10ms DropTail
$ns duplex-link $node(7055) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 7062"
$ns duplex-link $node(7062) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 7065"
$ns duplex-link $node(7065) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7065) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7065) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 7066"
$ns duplex-link $node(7066) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(225) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(1201) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(1312) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(10357) 1.5Mb 10ms DropTail
$ns duplex-link $node(7066) $node(10545) 1.5Mb 10ms DropTail
#puts "Connecting Router 7080"
$ns duplex-link $node(7080) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 7087"
$ns duplex-link $node(7087) $node(6542) 1.5Mb 10ms DropTail
$ns duplex-link $node(7087) $node(3603) 1.5Mb 10ms DropTail
#puts "Connecting Router 7091"
$ns duplex-link $node(7091) $node(6939) 1.5Mb 10ms DropTail
#puts "Connecting Router 7095"
$ns duplex-link $node(7095) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7096"
$ns duplex-link $node(7096) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7096) $node(1982) 1.5Mb 10ms DropTail
$ns duplex-link $node(7096) $node(3513) 1.5Mb 10ms DropTail
#puts "Connecting Router 7098"
$ns duplex-link $node(7098) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7106"
$ns duplex-link $node(7106) $node(6955) 1.5Mb 10ms DropTail
#puts "Connecting Router 7120"
$ns duplex-link $node(7120) $node(6332) 1.5Mb 10ms DropTail
#puts "Connecting Router 7125"
$ns duplex-link $node(7125) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 7128"
$ns duplex-link $node(7128) $node(6172) 1.5Mb 10ms DropTail
#puts "Connecting Router 7137"
$ns duplex-link $node(7137) $node(4005) 1.5Mb 10ms DropTail
$ns duplex-link $node(7137) $node(2638) 1.5Mb 10ms DropTail
#puts "Connecting Router 7138"
$ns duplex-link $node(7138) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7138) $node(2588) 1.5Mb 10ms DropTail
#puts "Connecting Router 714"
$ns duplex-link $node(714) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7140"
$ns duplex-link $node(7140) $node(10303) 1.5Mb 10ms DropTail
#puts "Connecting Router 7143"
$ns duplex-link $node(7143) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7148"
$ns duplex-link $node(7148) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 715"
$ns duplex-link $node(715) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(715) $node(3915) 1.5Mb 10ms DropTail
#puts "Connecting Router 7170"
$ns duplex-link $node(7170) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(298) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(668) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(13) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(22) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(132) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(523) 1.5Mb 10ms DropTail
$ns duplex-link $node(7170) $node(687) 1.5Mb 10ms DropTail
#puts "Connecting Router 7176"
$ns duplex-link $node(7176) $node(5388) 1.5Mb 10ms DropTail
#puts "Connecting Router 7178"
$ns duplex-link $node(7178) $node(7018) 1.5Mb 10ms DropTail
#puts "Connecting Router 7181"
$ns duplex-link $node(7181) $node(6082) 1.5Mb 10ms DropTail
#puts "Connecting Router 7188"
$ns duplex-link $node(7188) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(7188) $node(6494) 1.5Mb 10ms DropTail
#puts "Connecting Router 7189"
$ns duplex-link $node(7189) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7189) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(7189) $node(1691) 1.5Mb 10ms DropTail
$ns duplex-link $node(7189) $node(3812) 1.5Mb 10ms DropTail
$ns duplex-link $node(7189) $node(6997) 1.5Mb 10ms DropTail
#puts "Connecting Router 719"
$ns duplex-link $node(719) $node(3336) 1.5Mb 10ms DropTail
#puts "Connecting Router 7192"
$ns duplex-link $node(7192) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(7192) $node(5922) 1.5Mb 10ms DropTail
#puts "Connecting Router 7194"
$ns duplex-link $node(7194) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(7194) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7194) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7194) $node(5700) 1.5Mb 10ms DropTail
#puts "Connecting Router 7195"
$ns duplex-link $node(7195) $node(6140) 1.5Mb 10ms DropTail
$ns duplex-link $node(7195) $node(3603) 1.5Mb 10ms DropTail
#puts "Connecting Router 7199"
$ns duplex-link $node(7199) $node(7018) 1.5Mb 10ms DropTail
$ns duplex-link $node(7199) $node(10691) 1.5Mb 10ms DropTail
#puts "Connecting Router 72"
$ns duplex-link $node(72) $node(5551) 1.5Mb 10ms DropTail
#puts "Connecting Router 7206"
$ns duplex-link $node(7206) $node(6402) 1.5Mb 10ms DropTail
#puts "Connecting Router 7207"
$ns duplex-link $node(7207) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 7223"
$ns duplex-link $node(7223) $node(7018) 1.5Mb 10ms DropTail
#puts "Connecting Router 7224"
$ns duplex-link $node(7224) $node(6993) 1.5Mb 10ms DropTail
#puts "Connecting Router 7226"
$ns duplex-link $node(7226) $node(5792) 1.5Mb 10ms DropTail
#puts "Connecting Router 7236"
$ns duplex-link $node(7236) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 7239"
$ns duplex-link $node(7239) $node(6138) 1.5Mb 10ms DropTail
#puts "Connecting Router 724"
$ns duplex-link $node(724) $node(568) 1.5Mb 10ms DropTail
#puts "Connecting Router 7252"
$ns duplex-link $node(7252) $node(6561) 1.5Mb 10ms DropTail
#puts "Connecting Router 7258"
$ns duplex-link $node(7258) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7260"
$ns duplex-link $node(7260) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7260) $node(3566) 1.5Mb 10ms DropTail
$ns duplex-link $node(7260) $node(5767) 1.5Mb 10ms DropTail
$ns duplex-link $node(7260) $node(10352) 1.5Mb 10ms DropTail
$ns duplex-link $node(7260) $node(10656) 1.5Mb 10ms DropTail
#puts "Connecting Router 7263"
$ns duplex-link $node(7263) $node(5006) 1.5Mb 10ms DropTail
$ns duplex-link $node(7263) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 7268"
$ns duplex-link $node(7268) $node(7260) 1.5Mb 10ms DropTail
#puts "Connecting Router 7271"
$ns duplex-link $node(7271) $node(2493) 1.5Mb 10ms DropTail
$ns duplex-link $node(7271) $node(6463) 1.5Mb 10ms DropTail
#puts "Connecting Router 7272"
$ns duplex-link $node(7272) $node(7271) 1.5Mb 10ms DropTail
#puts "Connecting Router 7275"
$ns duplex-link $node(7275) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7275) $node(3761) 1.5Mb 10ms DropTail
#puts "Connecting Router 7283"
$ns duplex-link $node(7283) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7283) $node(7037) 1.5Mb 10ms DropTail
$ns duplex-link $node(7283) $node(4492) 1.5Mb 10ms DropTail
#puts "Connecting Router 7303"
$ns duplex-link $node(7303) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(6371) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(6762) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(7018) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(4270) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(4387) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(4967) 1.5Mb 10ms DropTail
$ns duplex-link $node(7303) $node(5648) 1.5Mb 10ms DropTail
#puts "Connecting Router 7306"
$ns duplex-link $node(7306) $node(4775) 1.5Mb 10ms DropTail
#puts "Connecting Router 7313"
#puts "Connecting Router 7314"
$ns duplex-link $node(7314) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7314) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(7314) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7314) $node(10562) 1.5Mb 10ms DropTail
#puts "Connecting Router 7319"
$ns duplex-link $node(7319) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7319) $node(6331) 1.5Mb 10ms DropTail
#puts "Connecting Router 7333"
$ns duplex-link $node(7333) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(7333) $node(4261) 1.5Mb 10ms DropTail
#puts "Connecting Router 7337"
$ns duplex-link $node(7337) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7338"
$ns duplex-link $node(7338) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7340"
$ns duplex-link $node(7340) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 7344"
$ns duplex-link $node(7344) $node(5097) 1.5Mb 10ms DropTail
#puts "Connecting Router 7346"
$ns duplex-link $node(7346) $node(7252) 1.5Mb 10ms DropTail
#puts "Connecting Router 7349"
$ns duplex-link $node(7349) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 7354"
$ns duplex-link $node(7354) $node(6235) 1.5Mb 10ms DropTail
#puts "Connecting Router 7359"
$ns duplex-link $node(7359) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7361"
$ns duplex-link $node(7361) $node(6327) 1.5Mb 10ms DropTail
#puts "Connecting Router 7369"
$ns duplex-link $node(7369) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7370"
$ns duplex-link $node(7370) $node(5754) 1.5Mb 10ms DropTail
#puts "Connecting Router 7372"
$ns duplex-link $node(7372) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7372) $node(5702) 1.5Mb 10ms DropTail
#puts "Connecting Router 7374"
$ns duplex-link $node(7374) $node(6461) 1.5Mb 10ms DropTail
#puts "Connecting Router 7385"
$ns duplex-link $node(7385) $node(5650) 1.5Mb 10ms DropTail
#puts "Connecting Router 7393"
$ns duplex-link $node(7393) $node(6365) 1.5Mb 10ms DropTail
#puts "Connecting Router 7395"
$ns duplex-link $node(7395) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 7414"
$ns duplex-link $node(7414) $node(4230) 1.5Mb 10ms DropTail
$ns duplex-link $node(7414) $node(7313) 1.5Mb 10ms DropTail
#puts "Connecting Router 7417"
$ns duplex-link $node(7417) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 7424"
$ns duplex-link $node(7424) $node(6467) 1.5Mb 10ms DropTail
#puts "Connecting Router 7431"
$ns duplex-link $node(7431) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7436"
$ns duplex-link $node(7436) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7438"
$ns duplex-link $node(7438) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 7439"
$ns duplex-link $node(7439) $node(6938) 1.5Mb 10ms DropTail
#puts "Connecting Router 7445"
$ns duplex-link $node(7445) $node(2493) 1.5Mb 10ms DropTail
$ns duplex-link $node(7445) $node(3963) 1.5Mb 10ms DropTail
$ns duplex-link $node(7445) $node(4470) 1.5Mb 10ms DropTail
#puts "Connecting Router 745"
$ns duplex-link $node(745) $node(1913) 1.5Mb 10ms DropTail
$ns duplex-link $node(745) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 7459"
$ns duplex-link $node(7459) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(7459) $node(10514) 1.5Mb 10ms DropTail
#puts "Connecting Router 7460"
$ns duplex-link $node(7460) $node(5713) 1.5Mb 10ms DropTail
$ns duplex-link $node(7460) $node(6187) 1.5Mb 10ms DropTail
#puts "Connecting Router 7470"
$ns duplex-link $node(7470) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(7470) $node(4651) 1.5Mb 10ms DropTail
$ns duplex-link $node(7470) $node(3839) 1.5Mb 10ms DropTail
$ns duplex-link $node(7470) $node(4762) 1.5Mb 10ms DropTail
#puts "Connecting Router 7473"
$ns duplex-link $node(7473) $node(5727) 1.5Mb 10ms DropTail
$ns duplex-link $node(7473) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(7473) $node(3758) 1.5Mb 10ms DropTail
$ns duplex-link $node(7473) $node(4628) 1.5Mb 10ms DropTail
$ns duplex-link $node(7473) $node(4657) 1.5Mb 10ms DropTail
#puts "Connecting Router 7474"
$ns duplex-link $node(7474) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7474) $node(703) 1.5Mb 10ms DropTail
$ns duplex-link $node(7474) $node(5683) 1.5Mb 10ms DropTail
$ns duplex-link $node(7474) $node(4738) 1.5Mb 10ms DropTail
$ns duplex-link $node(7474) $node(4740) 1.5Mb 10ms DropTail
$ns duplex-link $node(7474) $node(4794) 1.5Mb 10ms DropTail
#puts "Connecting Router 7476"
$ns duplex-link $node(7476) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7482"
$ns duplex-link $node(7482) $node(4780) 1.5Mb 10ms DropTail
#puts "Connecting Router 7485"
$ns duplex-link $node(7485) $node(4765) 1.5Mb 10ms DropTail
#puts "Connecting Router 7489"
#puts "Connecting Router 7501"
$ns duplex-link $node(7501) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(7501) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(7501) $node(4694) 1.5Mb 10ms DropTail
$ns duplex-link $node(7501) $node(4728) 1.5Mb 10ms DropTail
#puts "Connecting Router 7511"
$ns duplex-link $node(7511) $node(4725) 1.5Mb 10ms DropTail
#puts "Connecting Router 7512"
$ns duplex-link $node(7512) $node(4725) 1.5Mb 10ms DropTail
#puts "Connecting Router 7514"
$ns duplex-link $node(7514) $node(4716) 1.5Mb 10ms DropTail
#puts "Connecting Router 7515"
$ns duplex-link $node(7515) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(7515) $node(4774) 1.5Mb 10ms DropTail
$ns duplex-link $node(7515) $node(4713) 1.5Mb 10ms DropTail
#puts "Connecting Router 7518"
$ns duplex-link $node(7518) $node(4694) 1.5Mb 10ms DropTail
#puts "Connecting Router 7525"
$ns duplex-link $node(7525) $node(7501) 1.5Mb 10ms DropTail
#puts "Connecting Router 7526"
$ns duplex-link $node(7526) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7526) $node(4691) 1.5Mb 10ms DropTail
#puts "Connecting Router 7533"
#puts "Connecting Router 7541"
$ns duplex-link $node(7541) $node(4778) 1.5Mb 10ms DropTail
#puts "Connecting Router 7543"
#puts "Connecting Router 7544"
$ns duplex-link $node(7544) $node(4788) 1.5Mb 10ms DropTail
#puts "Connecting Router 7545"
$ns duplex-link $node(7545) $node(4742) 1.5Mb 10ms DropTail
#puts "Connecting Router 7561"
$ns duplex-link $node(7561) $node(3786) 1.5Mb 10ms DropTail
$ns duplex-link $node(7561) $node(4766) 1.5Mb 10ms DropTail
$ns duplex-link $node(7561) $node(4668) 1.5Mb 10ms DropTail
#puts "Connecting Router 7565"
$ns duplex-link $node(7565) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7567"
$ns duplex-link $node(7567) $node(4805) 1.5Mb 10ms DropTail
#puts "Connecting Router 7569"
$ns duplex-link $node(7569) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7570"
$ns duplex-link $node(7570) $node(7474) 1.5Mb 10ms DropTail
$ns duplex-link $node(7570) $node(7569) 1.5Mb 10ms DropTail
#puts "Connecting Router 7571"
$ns duplex-link $node(7571) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7572"
$ns duplex-link $node(7572) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7573"
$ns duplex-link $node(7573) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7574"
$ns duplex-link $node(7574) $node(7474) 1.5Mb 10ms DropTail
#puts "Connecting Router 7585"
#puts "Connecting Router 7586"
$ns duplex-link $node(7586) $node(703) 1.5Mb 10ms DropTail
$ns duplex-link $node(7586) $node(7585) 1.5Mb 10ms DropTail
#puts "Connecting Router 7590"
$ns duplex-link $node(7590) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7594"
$ns duplex-link $node(7594) $node(4969) 1.5Mb 10ms DropTail
$ns duplex-link $node(7594) $node(6261) 1.5Mb 10ms DropTail
#puts "Connecting Router 760"
$ns duplex-link $node(760) $node(1853) 1.5Mb 10ms DropTail
#puts "Connecting Router 7604"
$ns duplex-link $node(7604) $node(7586) 1.5Mb 10ms DropTail
#puts "Connecting Router 7616"
$ns duplex-link $node(7616) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7618"
$ns duplex-link $node(7618) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(7618) $node(4780) 1.5Mb 10ms DropTail
#puts "Connecting Router 7620"
$ns duplex-link $node(7620) $node(4778) 1.5Mb 10ms DropTail
#puts "Connecting Router 7623"
$ns duplex-link $node(7623) $node(3608) 1.5Mb 10ms DropTail
$ns duplex-link $node(7623) $node(1237) 1.5Mb 10ms DropTail
#puts "Connecting Router 7632"
$ns duplex-link $node(7632) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(7632) $node(3409) 1.5Mb 10ms DropTail
#puts "Connecting Router 7635"
$ns duplex-link $node(7635) $node(7586) 1.5Mb 10ms DropTail
#puts "Connecting Router 7642"
$ns duplex-link $node(7642) $node(6762) 1.5Mb 10ms DropTail
#puts "Connecting Router 7652"
$ns duplex-link $node(7652) $node(7586) 1.5Mb 10ms DropTail
#puts "Connecting Router 7655"
$ns duplex-link $node(7655) $node(4778) 1.5Mb 10ms DropTail
$ns duplex-link $node(7655) $node(7533) 1.5Mb 10ms DropTail
#puts "Connecting Router 7656"
$ns duplex-link $node(7656) $node(7655) 1.5Mb 10ms DropTail
#puts "Connecting Router 7657"
$ns duplex-link $node(7657) $node(5673) 1.5Mb 10ms DropTail
$ns duplex-link $node(7657) $node(7489) 1.5Mb 10ms DropTail
$ns duplex-link $node(7657) $node(7543) 1.5Mb 10ms DropTail
#puts "Connecting Router 766"
$ns duplex-link $node(766) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(766) $node(6813) 1.5Mb 10ms DropTail
#puts "Connecting Router 7694"
$ns duplex-link $node(7694) $node(4786) 1.5Mb 10ms DropTail
#puts "Connecting Router 7725"
#puts "Connecting Router 7736"
$ns duplex-link $node(7736) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7736) $node(3142) 1.5Mb 10ms DropTail
#puts "Connecting Router 7737"
$ns duplex-link $node(7737) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7742"
$ns duplex-link $node(7742) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7751"
$ns duplex-link $node(7751) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7752"
$ns duplex-link $node(7752) $node(5646) 1.5Mb 10ms DropTail
#puts "Connecting Router 7753"
#puts "Connecting Router 7757"
#puts "Connecting Router 7770"
$ns duplex-link $node(7770) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(7770) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7770) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(7770) $node(6347) 1.5Mb 10ms DropTail
$ns duplex-link $node(7770) $node(6484) 1.5Mb 10ms DropTail
#puts "Connecting Router 7772"
$ns duplex-link $node(7772) $node(4969) 1.5Mb 10ms DropTail
#puts "Connecting Router 7782"
$ns duplex-link $node(7782) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(7782) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(7782) $node(6308) 1.5Mb 10ms DropTail
$ns duplex-link $node(7782) $node(10483) 1.5Mb 10ms DropTail
#puts "Connecting Router 7784"
$ns duplex-link $node(7784) $node(10543) 1.5Mb 10ms DropTail
#puts "Connecting Router 7788"
$ns duplex-link $node(7788) $node(6463) 1.5Mb 10ms DropTail
#puts "Connecting Router 7790"
$ns duplex-link $node(7790) $node(7252) 1.5Mb 10ms DropTail
#puts "Connecting Router 7792"
$ns duplex-link $node(7792) $node(5006) 1.5Mb 10ms DropTail
#puts "Connecting Router 7800"
$ns duplex-link $node(7800) $node(5006) 1.5Mb 10ms DropTail
#puts "Connecting Router 7816"
$ns duplex-link $node(7816) $node(6993) 1.5Mb 10ms DropTail
#puts "Connecting Router 7820"
$ns duplex-link $node(7820) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(7820) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(7820) $node(7260) 1.5Mb 10ms DropTail
#puts "Connecting Router 7825"
$ns duplex-link $node(7825) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 7829"
$ns duplex-link $node(7829) $node(5632) 1.5Mb 10ms DropTail
#puts "Connecting Router 7832"
$ns duplex-link $node(7832) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 7833"
$ns duplex-link $node(7833) $node(6391) 1.5Mb 10ms DropTail
#puts "Connecting Router 7850"
$ns duplex-link $node(7850) $node(5673) 1.5Mb 10ms DropTail
#puts "Connecting Router 786"
$ns duplex-link $node(786) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(1213) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(4589) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(786) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7864"
$ns duplex-link $node(7864) $node(6065) 1.5Mb 10ms DropTail
#puts "Connecting Router 7875"
$ns duplex-link $node(7875) $node(6525) 1.5Mb 10ms DropTail
#puts "Connecting Router 7878"
$ns duplex-link $node(7878) $node(6327) 1.5Mb 10ms DropTail
#puts "Connecting Router 7891"
$ns duplex-link $node(7891) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 7892"
$ns duplex-link $node(7892) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 7893"
$ns duplex-link $node(7893) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(7893) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(7893) $node(2048) 1.5Mb 10ms DropTail
#puts "Connecting Router 7894"
$ns duplex-link $node(7894) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 7908"
$ns duplex-link $node(7908) $node(4926) 1.5Mb 10ms DropTail
$ns duplex-link $node(7908) $node(10318) 1.5Mb 10ms DropTail
#puts "Connecting Router 7915"
$ns duplex-link $node(7915) $node(10609) 1.5Mb 10ms DropTail
#puts "Connecting Router 7922"
$ns duplex-link $node(7922) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(6660) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(7015) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(7017) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(7725) 1.5Mb 10ms DropTail
$ns duplex-link $node(7922) $node(7757) 1.5Mb 10ms DropTail
#puts "Connecting Router 7927"
$ns duplex-link $node(7927) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(7927) $node(6306) 1.5Mb 10ms DropTail
#puts "Connecting Router 7928"
$ns duplex-link $node(7928) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 7934"
$ns duplex-link $node(7934) $node(4926) 1.5Mb 10ms DropTail
$ns duplex-link $node(7934) $node(7303) 1.5Mb 10ms DropTail
#puts "Connecting Router 7949"
$ns duplex-link $node(7949) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 7951"
$ns duplex-link $node(7951) $node(6188) 1.5Mb 10ms DropTail
#puts "Connecting Router 7960"
$ns duplex-link $node(7960) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(7960) $node(4969) 1.5Mb 10ms DropTail
$ns duplex-link $node(7960) $node(6082) 1.5Mb 10ms DropTail
$ns duplex-link $node(7960) $node(5749) 1.5Mb 10ms DropTail
#puts "Connecting Router 7966"
$ns duplex-link $node(7966) $node(6955) 1.5Mb 10ms DropTail
#puts "Connecting Router 7973"
$ns duplex-link $node(7973) $node(5006) 1.5Mb 10ms DropTail
#puts "Connecting Router 7980"
$ns duplex-link $node(7980) $node(7303) 1.5Mb 10ms DropTail
#puts "Connecting Router 7982"
$ns duplex-link $node(7982) $node(5632) 1.5Mb 10ms DropTail
#puts "Connecting Router 7992"
$ns duplex-link $node(7992) $node(6463) 1.5Mb 10ms DropTail
#puts "Connecting Router 7996"
$ns duplex-link $node(7996) $node(6955) 1.5Mb 10ms DropTail
#puts "Connecting Router 7997"
$ns duplex-link $node(7997) $node(4005) 1.5Mb 10ms DropTail
$ns duplex-link $node(7997) $node(10299) 1.5Mb 10ms DropTail
#puts "Connecting Router 8001"
$ns duplex-link $node(8001) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(6427) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(7372) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(6320) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(6765) 1.5Mb 10ms DropTail
$ns duplex-link $node(8001) $node(6889) 1.5Mb 10ms DropTail
#puts "Connecting Router 8007"
$ns duplex-link $node(8007) $node(6503) 1.5Mb 10ms DropTail
#puts "Connecting Router 8011"
$ns duplex-link $node(8011) $node(7260) 1.5Mb 10ms DropTail
#puts "Connecting Router 8015"
$ns duplex-link $node(8015) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(8015) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(8015) $node(1347) 1.5Mb 10ms DropTail
$ns duplex-link $node(8015) $node(7753) 1.5Mb 10ms DropTail
#puts "Connecting Router 8018"
$ns duplex-link $node(8018) $node(5097) 1.5Mb 10ms DropTail
#puts "Connecting Router 8036"
$ns duplex-link $node(8036) $node(5078) 1.5Mb 10ms DropTail
#puts "Connecting Router 8041"
$ns duplex-link $node(8041) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(8041) $node(1323) 1.5Mb 10ms DropTail
$ns duplex-link $node(8041) $node(6547) 1.5Mb 10ms DropTail
#puts "Connecting Router 8043"
$ns duplex-link $node(8043) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(3796) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(3817) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(3819) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(3900) 1.5Mb 10ms DropTail
$ns duplex-link $node(8043) $node(5645) 1.5Mb 10ms DropTail
#puts "Connecting Router 8046"
$ns duplex-link $node(8046) $node(7065) 1.5Mb 10ms DropTail
#puts "Connecting Router 8048"
$ns duplex-link $node(8048) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(8048) $node(6541) 1.5Mb 10ms DropTail
$ns duplex-link $node(8048) $node(4535) 1.5Mb 10ms DropTail
#puts "Connecting Router 8056"
$ns duplex-link $node(8056) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8058"
$ns duplex-link $node(8058) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 8060"
$ns duplex-link $node(8060) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 8061"
$ns duplex-link $node(8061) $node(6113) 1.5Mb 10ms DropTail
#puts "Connecting Router 8062"
$ns duplex-link $node(8062) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(8062) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(8062) $node(3464) 1.5Mb 10ms DropTail
#puts "Connecting Router 8063"
$ns duplex-link $node(8063) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(8063) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(8063) $node(3464) 1.5Mb 10ms DropTail
#puts "Connecting Router 8066"
$ns duplex-link $node(8066) $node(4926) 1.5Mb 10ms DropTail
#puts "Connecting Router 8081"
$ns duplex-link $node(8081) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 8091"
$ns duplex-link $node(8091) $node(5651) 1.5Mb 10ms DropTail
#puts "Connecting Router 8094"
$ns duplex-link $node(8094) $node(5713) 1.5Mb 10ms DropTail
#puts "Connecting Router 81"
$ns duplex-link $node(81) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(81) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(81) $node(10490) 1.5Mb 10ms DropTail
#puts "Connecting Router 8100"
$ns duplex-link $node(8100) $node(6335) 1.5Mb 10ms DropTail
#puts "Connecting Router 8101"
$ns duplex-link $node(8101) $node(7037) 1.5Mb 10ms DropTail
#puts "Connecting Router 8111"
$ns duplex-link $node(8111) $node(6509) 1.5Mb 10ms DropTail
#puts "Connecting Router 8114"
$ns duplex-link $node(8114) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(8114) $node(2052) 1.5Mb 10ms DropTail
#puts "Connecting Router 8119"
$ns duplex-link $node(8119) $node(7018) 1.5Mb 10ms DropTail
#puts "Connecting Router 812"
$ns duplex-link $node(812) $node(6172) 1.5Mb 10ms DropTail
#puts "Connecting Router 8120"
$ns duplex-link $node(8120) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 8121"
$ns duplex-link $node(8121) $node(6461) 1.5Mb 10ms DropTail
#puts "Connecting Router 8125"
$ns duplex-link $node(8125) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(8125) $node(3770) 1.5Mb 10ms DropTail
#puts "Connecting Router 8135"
$ns duplex-link $node(8135) $node(7018) 1.5Mb 10ms DropTail
#puts "Connecting Router 8138"
$ns duplex-link $node(8138) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(8138) $node(6955) 1.5Mb 10ms DropTail
#puts "Connecting Router 814"
$ns duplex-link $node(814) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(814) $node(3602) 1.5Mb 10ms DropTail
$ns duplex-link $node(814) $node(7189) 1.5Mb 10ms DropTail
#puts "Connecting Router 8142"
$ns duplex-link $node(8142) $node(6955) 1.5Mb 10ms DropTail
#puts "Connecting Router 8148"
$ns duplex-link $node(8148) $node(5737) 1.5Mb 10ms DropTail
#puts "Connecting Router 815"
$ns duplex-link $node(815) $node(814) 1.5Mb 10ms DropTail
$ns duplex-link $node(815) $node(6327) 1.5Mb 10ms DropTail
#puts "Connecting Router 8151"
$ns duplex-link $node(8151) $node(4001) 1.5Mb 10ms DropTail
$ns duplex-link $node(8151) $node(6332) 1.5Mb 10ms DropTail
$ns duplex-link $node(8151) $node(3484) 1.5Mb 10ms DropTail
$ns duplex-link $node(8151) $node(10420) 1.5Mb 10ms DropTail
#puts "Connecting Router 816"
$ns duplex-link $node(816) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(816) $node(815) 1.5Mb 10ms DropTail
$ns duplex-link $node(816) $node(3602) 1.5Mb 10ms DropTail
$ns duplex-link $node(816) $node(3963) 1.5Mb 10ms DropTail
$ns duplex-link $node(816) $node(7271) 1.5Mb 10ms DropTail
#puts "Connecting Router 8166"
$ns duplex-link $node(8166) $node(8043) 1.5Mb 10ms DropTail
#puts "Connecting Router 817"
$ns duplex-link $node(817) $node(3963) 1.5Mb 10ms DropTail
$ns duplex-link $node(817) $node(3493) 1.5Mb 10ms DropTail
#puts "Connecting Router 8175"
$ns duplex-link $node(8175) $node(5696) 1.5Mb 10ms DropTail
#puts "Connecting Router 8180"
$ns duplex-link $node(8180) $node(6347) 1.5Mb 10ms DropTail
#puts "Connecting Router 8191"
$ns duplex-link $node(8191) $node(6261) 1.5Mb 10ms DropTail
#puts "Connecting Router 8196"
$ns duplex-link $node(8196) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(8196) $node(6685) 1.5Mb 10ms DropTail
$ns duplex-link $node(8196) $node(6887) 1.5Mb 10ms DropTail
#puts "Connecting Router 8198"
$ns duplex-link $node(8198) $node(5413) 1.5Mb 10ms DropTail
#puts "Connecting Router 8199"
$ns duplex-link $node(8199) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 8200"
$ns duplex-link $node(8200) $node(6844) 1.5Mb 10ms DropTail
#puts "Connecting Router 8205"
$ns duplex-link $node(8205) $node(5462) 1.5Mb 10ms DropTail
$ns duplex-link $node(8205) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8207"
$ns duplex-link $node(8207) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 8208"
$ns duplex-link $node(8208) $node(5539) 1.5Mb 10ms DropTail
$ns duplex-link $node(8208) $node(8196) 1.5Mb 10ms DropTail
#puts "Connecting Router 8210"
$ns duplex-link $node(8210) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(8210) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(8210) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(8210) $node(5556) 1.5Mb 10ms DropTail
#puts "Connecting Router 8211"
$ns duplex-link $node(8211) $node(5484) 1.5Mb 10ms DropTail
$ns duplex-link $node(8211) $node(5583) 1.5Mb 10ms DropTail
#puts "Connecting Router 8213"
$ns duplex-link $node(8213) $node(5378) 1.5Mb 10ms DropTail
#puts "Connecting Router 8215"
$ns duplex-link $node(8215) $node(5418) 1.5Mb 10ms DropTail
#puts "Connecting Router 8216"
$ns duplex-link $node(8216) $node(6897) 1.5Mb 10ms DropTail
#puts "Connecting Router 8217"
$ns duplex-link $node(8217) $node(6684) 1.5Mb 10ms DropTail
#puts "Connecting Router 8220"
$ns duplex-link $node(8220) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(8220) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8223"
$ns duplex-link $node(8223) $node(6855) 1.5Mb 10ms DropTail
#puts "Connecting Router 8225"
$ns duplex-link $node(8225) $node(6762) 1.5Mb 10ms DropTail
#puts "Connecting Router 8228"
$ns duplex-link $node(8228) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(8228) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 8231"
$ns duplex-link $node(8231) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8245"
$ns duplex-link $node(8245) $node(6873) 1.5Mb 10ms DropTail
#puts "Connecting Router 8246"
$ns duplex-link $node(8246) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 8249"
$ns duplex-link $node(8249) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 8250"
$ns duplex-link $node(8250) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8251"
$ns duplex-link $node(8251) $node(5496) 1.5Mb 10ms DropTail
$ns duplex-link $node(8251) $node(5583) 1.5Mb 10ms DropTail
#puts "Connecting Router 8253"
$ns duplex-link $node(8253) $node(5408) 1.5Mb 10ms DropTail
#puts "Connecting Router 8257"
#puts "Connecting Router 8258"
$ns duplex-link $node(8258) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 8259"
$ns duplex-link $node(8259) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(8259) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(8259) $node(6196) 1.5Mb 10ms DropTail
#puts "Connecting Router 8262"
#puts "Connecting Router 8263"
$ns duplex-link $node(8263) $node(1785) 1.5Mb 10ms DropTail
$ns duplex-link $node(8263) $node(6903) 1.5Mb 10ms DropTail
#puts "Connecting Router 8264"
$ns duplex-link $node(8264) $node(8210) 1.5Mb 10ms DropTail
$ns duplex-link $node(8264) $node(5625) 1.5Mb 10ms DropTail
$ns duplex-link $node(8264) $node(6658) 1.5Mb 10ms DropTail
$ns duplex-link $node(8264) $node(6803) 1.5Mb 10ms DropTail
$ns duplex-link $node(8264) $node(6864) 1.5Mb 10ms DropTail
$ns duplex-link $node(8264) $node(8257) 1.5Mb 10ms DropTail
#puts "Connecting Router 8265"
$ns duplex-link $node(8265) $node(5510) 1.5Mb 10ms DropTail
$ns duplex-link $node(8265) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 8267"
$ns duplex-link $node(8267) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 8269"
$ns duplex-link $node(8269) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(8269) $node(2860) 1.5Mb 10ms DropTail
$ns duplex-link $node(8269) $node(6806) 1.5Mb 10ms DropTail
$ns duplex-link $node(8269) $node(6853) 1.5Mb 10ms DropTail
#puts "Connecting Router 8271"
$ns duplex-link $node(8271) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 8272"
$ns duplex-link $node(8272) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(8272) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8275"
$ns duplex-link $node(8275) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 8277"
$ns duplex-link $node(8277) $node(5390) 1.5Mb 10ms DropTail
#puts "Connecting Router 8278"
$ns duplex-link $node(8278) $node(5408) 1.5Mb 10ms DropTail
#puts "Connecting Router 8280"
$ns duplex-link $node(8280) $node(6728) 1.5Mb 10ms DropTail
#puts "Connecting Router 8284"
$ns duplex-link $node(8284) $node(6661) 1.5Mb 10ms DropTail
#puts "Connecting Router 8291"
$ns duplex-link $node(8291) $node(6863) 1.5Mb 10ms DropTail
#puts "Connecting Router 8294"
$ns duplex-link $node(8294) $node(5389) 1.5Mb 10ms DropTail
$ns duplex-link $node(8294) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 8296"
$ns duplex-link $node(8296) $node(6841) 1.5Mb 10ms DropTail
#puts "Connecting Router 8297"
$ns duplex-link $node(8297) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(8297) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(8297) $node(6678) 1.5Mb 10ms DropTail
#puts "Connecting Router 83"
$ns duplex-link $node(83) $node(7170) 1.5Mb 10ms DropTail
#puts "Connecting Router 8300"
$ns duplex-link $node(8300) $node(3303) 1.5Mb 10ms DropTail
$ns duplex-link $node(8300) $node(3248) 1.5Mb 10ms DropTail
#puts "Connecting Router 8306"
$ns duplex-link $node(8306) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8309"
$ns duplex-link $node(8309) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(8309) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(8309) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 8313"
$ns duplex-link $node(8313) $node(6844) 1.5Mb 10ms DropTail
#puts "Connecting Router 8314"
$ns duplex-link $node(8314) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(8314) $node(5522) 1.5Mb 10ms DropTail
#puts "Connecting Router 8316"
$ns duplex-link $node(8316) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(8316) $node(5578) 1.5Mb 10ms DropTail
#puts "Connecting Router 8319"
$ns duplex-link $node(8319) $node(5409) 1.5Mb 10ms DropTail
$ns duplex-link $node(8319) $node(5539) 1.5Mb 10ms DropTail
#puts "Connecting Router 8321"
$ns duplex-link $node(8321) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 8327"
$ns duplex-link $node(8327) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 8328"
$ns duplex-link $node(8328) $node(6684) 1.5Mb 10ms DropTail
#puts "Connecting Router 8330"
$ns duplex-link $node(8330) $node(6728) 1.5Mb 10ms DropTail
#puts "Connecting Router 8331"
$ns duplex-link $node(8331) $node(3216) 1.5Mb 10ms DropTail
#puts "Connecting Router 8334"
$ns duplex-link $node(8334) $node(8263) 1.5Mb 10ms DropTail
#puts "Connecting Router 8336"
$ns duplex-link $node(8336) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8340"
$ns duplex-link $node(8340) $node(6846) 1.5Mb 10ms DropTail
#puts "Connecting Router 8342"
$ns duplex-link $node(8342) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(2118) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(2766) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(2848) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(2854) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(6854) 1.5Mb 10ms DropTail
$ns duplex-link $node(8342) $node(6863) 1.5Mb 10ms DropTail
#puts "Connecting Router 8343"
$ns duplex-link $node(8343) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 8346"
$ns duplex-link $node(8346) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8349"
$ns duplex-link $node(8349) $node(5415) 1.5Mb 10ms DropTail
#puts "Connecting Router 8350"
$ns duplex-link $node(8350) $node(8342) 1.5Mb 10ms DropTail
#puts "Connecting Router 8352"
$ns duplex-link $node(8352) $node(6863) 1.5Mb 10ms DropTail
#puts "Connecting Router 8359"
$ns duplex-link $node(8359) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(8359) $node(6809) 1.5Mb 10ms DropTail
$ns duplex-link $node(8359) $node(6903) 1.5Mb 10ms DropTail
#puts "Connecting Router 8361"
$ns duplex-link $node(8361) $node(6689) 1.5Mb 10ms DropTail
#puts "Connecting Router 8363"
#puts "Connecting Router 8366"
$ns duplex-link $node(8366) $node(5378) 1.5Mb 10ms DropTail
#puts "Connecting Router 8374"
$ns duplex-link $node(8374) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 8375"
$ns duplex-link $node(8375) $node(8309) 1.5Mb 10ms DropTail
#puts "Connecting Router 838"
$ns duplex-link $node(838) $node(577) 1.5Mb 10ms DropTail
#puts "Connecting Router 8385"
$ns duplex-link $node(8385) $node(702) 1.5Mb 10ms DropTail
$ns duplex-link $node(8385) $node(5599) 1.5Mb 10ms DropTail
#puts "Connecting Router 8388"
$ns duplex-link $node(8388) $node(6799) 1.5Mb 10ms DropTail
#puts "Connecting Router 8390"
$ns duplex-link $node(8390) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(8390) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(8390) $node(8262) 1.5Mb 10ms DropTail
#puts "Connecting Router 8391"
$ns duplex-link $node(8391) $node(6753) 1.5Mb 10ms DropTail
$ns duplex-link $node(8391) $node(8309) 1.5Mb 10ms DropTail
#puts "Connecting Router 8394"
$ns duplex-link $node(8394) $node(702) 1.5Mb 10ms DropTail
#puts "Connecting Router 8395"
$ns duplex-link $node(8395) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 8396"
$ns duplex-link $node(8396) $node(6799) 1.5Mb 10ms DropTail
#puts "Connecting Router 8397"
$ns duplex-link $node(8397) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(8397) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 8398"
$ns duplex-link $node(8398) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8402"
#puts "Connecting Router 8405"
$ns duplex-link $node(8405) $node(6735) 1.5Mb 10ms DropTail
#puts "Connecting Router 8406"
$ns duplex-link $node(8406) $node(5551) 1.5Mb 10ms DropTail
#puts "Connecting Router 8407"
$ns duplex-link $node(8407) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8408"
$ns duplex-link $node(8408) $node(6719) 1.5Mb 10ms DropTail
#puts "Connecting Router 8411"
$ns duplex-link $node(8411) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8412"
$ns duplex-link $node(8412) $node(5403) 1.5Mb 10ms DropTail
$ns duplex-link $node(8412) $node(5683) 1.5Mb 10ms DropTail
#puts "Connecting Router 8413"
$ns duplex-link $node(8413) $node(702) 1.5Mb 10ms DropTail
$ns duplex-link $node(8413) $node(1913) 1.5Mb 10ms DropTail
#puts "Connecting Router 8417"
$ns duplex-link $node(8417) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 8419"
$ns duplex-link $node(8419) $node(6728) 1.5Mb 10ms DropTail
#puts "Connecting Router 8421"
$ns duplex-link $node(8421) $node(6847) 1.5Mb 10ms DropTail
#puts "Connecting Router 8422"
$ns duplex-link $node(8422) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 8424"
$ns duplex-link $node(8424) $node(5532) 1.5Mb 10ms DropTail
#puts "Connecting Router 8425"
$ns duplex-link $node(8425) $node(5483) 1.5Mb 10ms DropTail
#puts "Connecting Router 8431"
$ns duplex-link $node(8431) $node(8390) 1.5Mb 10ms DropTail
#puts "Connecting Router 8442"
$ns duplex-link $node(8442) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 8447"
$ns duplex-link $node(8447) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(8447) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(8447) $node(6708) 1.5Mb 10ms DropTail
#puts "Connecting Router 8451"
$ns duplex-link $node(8451) $node(701) 1.5Mb 10ms DropTail
#puts "Connecting Router 8452"
$ns duplex-link $node(8452) $node(6762) 1.5Mb 10ms DropTail
#puts "Connecting Router 8454"
$ns duplex-link $node(8454) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(8454) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(8454) $node(3286) 1.5Mb 10ms DropTail
#puts "Connecting Router 8455"
$ns duplex-link $node(8455) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(8455) $node(6708) 1.5Mb 10ms DropTail
#puts "Connecting Router 8456"
$ns duplex-link $node(8456) $node(8451) 1.5Mb 10ms DropTail
#puts "Connecting Router 8457"
$ns duplex-link $node(8457) $node(6745) 1.5Mb 10ms DropTail
#puts "Connecting Router 8460"
$ns duplex-link $node(8460) $node(8228) 1.5Mb 10ms DropTail
#puts "Connecting Router 8463"
$ns duplex-link $node(8463) $node(6664) 1.5Mb 10ms DropTail
#puts "Connecting Router 8464"
$ns duplex-link $node(8464) $node(6849) 1.5Mb 10ms DropTail
$ns duplex-link $node(8464) $node(8207) 1.5Mb 10ms DropTail
#puts "Connecting Router 8465"
$ns duplex-link $node(8465) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(8465) $node(6680) 1.5Mb 10ms DropTail
#puts "Connecting Router 8468"
$ns duplex-link $node(8468) $node(5551) 1.5Mb 10ms DropTail
#puts "Connecting Router 8469"
$ns duplex-link $node(8469) $node(5430) 1.5Mb 10ms DropTail
#puts "Connecting Router 8470"
$ns duplex-link $node(8470) $node(2118) 1.5Mb 10ms DropTail
$ns duplex-link $node(8470) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(8470) $node(8402) 1.5Mb 10ms DropTail
#puts "Connecting Router 8472"
$ns duplex-link $node(8472) $node(6685) 1.5Mb 10ms DropTail
#puts "Connecting Router 8473"
$ns duplex-link $node(8473) $node(6902) 1.5Mb 10ms DropTail
$ns duplex-link $node(8473) $node(8385) 1.5Mb 10ms DropTail
#puts "Connecting Router 8475"
$ns duplex-link $node(8475) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8476"
$ns duplex-link $node(8476) $node(6686) 1.5Mb 10ms DropTail
$ns duplex-link $node(8476) $node(6852) 1.5Mb 10ms DropTail
#puts "Connecting Router 8483"
$ns duplex-link $node(8483) $node(5417) 1.5Mb 10ms DropTail
#puts "Connecting Router 8484"
$ns duplex-link $node(8484) $node(6686) 1.5Mb 10ms DropTail
$ns duplex-link $node(8484) $node(6765) 1.5Mb 10ms DropTail
#puts "Connecting Router 8485"
$ns duplex-link $node(8485) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8489"
$ns duplex-link $node(8489) $node(8397) 1.5Mb 10ms DropTail
#puts "Connecting Router 8491"
$ns duplex-link $node(8491) $node(6863) 1.5Mb 10ms DropTail
$ns duplex-link $node(8491) $node(3312) 1.5Mb 10ms DropTail
#puts "Connecting Router 8496"
$ns duplex-link $node(8496) $node(8225) 1.5Mb 10ms DropTail
#puts "Connecting Router 8498"
$ns duplex-link $node(8498) $node(8342) 1.5Mb 10ms DropTail
$ns duplex-link $node(8498) $node(8359) 1.5Mb 10ms DropTail
#puts "Connecting Router 8499"
$ns duplex-link $node(8499) $node(6870) 1.5Mb 10ms DropTail
#puts "Connecting Router 8504"
$ns duplex-link $node(8504) $node(6850) 1.5Mb 10ms DropTail
#puts "Connecting Router 8506"
$ns duplex-link $node(8506) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8507"
$ns duplex-link $node(8507) $node(8331) 1.5Mb 10ms DropTail
#puts "Connecting Router 8510"
$ns duplex-link $node(8510) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8511"
$ns duplex-link $node(8511) $node(5434) 1.5Mb 10ms DropTail
#puts "Connecting Router 8512"
$ns duplex-link $node(8512) $node(5561) 1.5Mb 10ms DropTail
#puts "Connecting Router 8513"
$ns duplex-link $node(8513) $node(3803) 1.5Mb 10ms DropTail
$ns duplex-link $node(8513) $node(5429) 1.5Mb 10ms DropTail
$ns duplex-link $node(8513) $node(6888) 1.5Mb 10ms DropTail
#puts "Connecting Router 8514"
$ns duplex-link $node(8514) $node(6873) 1.5Mb 10ms DropTail
#puts "Connecting Router 8515"
$ns duplex-link $node(8515) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 8516"
$ns duplex-link $node(8516) $node(6769) 1.5Mb 10ms DropTail
#puts "Connecting Router 8517"
$ns duplex-link $node(8517) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(8517) $node(1967) 1.5Mb 10ms DropTail
$ns duplex-link $node(8517) $node(2592) 1.5Mb 10ms DropTail
$ns duplex-link $node(8517) $node(8363) 1.5Mb 10ms DropTail
$ns duplex-link $node(8517) $node(8456) 1.5Mb 10ms DropTail
#puts "Connecting Router 852"
$ns duplex-link $node(852) $node(577) 1.5Mb 10ms DropTail
$ns duplex-link $node(852) $node(6509) 1.5Mb 10ms DropTail
$ns duplex-link $node(852) $node(1691) 1.5Mb 10ms DropTail
#puts "Connecting Router 8529"
$ns duplex-link $node(8529) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8533"
$ns duplex-link $node(8533) $node(6731) 1.5Mb 10ms DropTail
#puts "Connecting Router 8535"
$ns duplex-link $node(8535) $node(5617) 1.5Mb 10ms DropTail
#puts "Connecting Router 854"
$ns duplex-link $node(854) $node(577) 1.5Mb 10ms DropTail
#puts "Connecting Router 8540"
$ns duplex-link $node(8540) $node(5405) 1.5Mb 10ms DropTail
#puts "Connecting Router 8542"
$ns duplex-link $node(8542) $node(8394) 1.5Mb 10ms DropTail
#puts "Connecting Router 855"
$ns duplex-link $node(855) $node(577) 1.5Mb 10ms DropTail
#puts "Connecting Router 8551"
$ns duplex-link $node(8551) $node(6453) 1.5Mb 10ms DropTail
#puts "Connecting Router 8553"
$ns duplex-link $node(8553) $node(5378) 1.5Mb 10ms DropTail
#puts "Connecting Router 8556"
$ns duplex-link $node(8556) $node(5568) 1.5Mb 10ms DropTail
#puts "Connecting Router 8573"
$ns duplex-link $node(8573) $node(8499) 1.5Mb 10ms DropTail
#puts "Connecting Router 8578"
$ns duplex-link $node(8578) $node(5409) 1.5Mb 10ms DropTail
$ns duplex-link $node(8578) $node(5459) 1.5Mb 10ms DropTail
#puts "Connecting Router 8583"
$ns duplex-link $node(8583) $node(5510) 1.5Mb 10ms DropTail
#puts "Connecting Router 9"
$ns duplex-link $node(9) $node(5050) 1.5Mb 10ms DropTail
#puts "Connecting Router 93"
$ns duplex-link $node(93) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(93) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 97"
$ns duplex-link $node(97) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(97) $node(6984) 1.5Mb 10ms DropTail
$ns duplex-link $node(97) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(97) $node(3561) 1.5Mb 10ms DropTail
#puts "Connecting Router 9999"
$ns duplex-link $node(9999) $node(6073) 1.5Mb 10ms DropTail

puts "created 2773 peering agreements"
set ltime [clock seconds]
puts "linkcreation elapsed seconds [expr $ltime - $ctime]"
if { $opt(check-fin) } {
	$ns at $opt(check-start)  "finish-check $opt(check-time)"
} else {
	$ns at $opt(stop)  "finish"
}

$ns duplex-link $node(5) $node(7359) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3804) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8473) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10303) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1225) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6670) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4657) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1967) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6827) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10240) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10243) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1785) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3363) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8198) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6820) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10514) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5726) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8394) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6453) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4786) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8180) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5512) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2549) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6463) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5422) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6188) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6751) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5398) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5072) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8349) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8251) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10757) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8514) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2041) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6582) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5727) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5594) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6499) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8216) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7314) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7181) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5560) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4778) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2048) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6331) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5571) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8485) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(376) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3303) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4200) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5611) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6205) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5505) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6365) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4352) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2687) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4376) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6873) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8516) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7206) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1677) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2572) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3602) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8424) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8208) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8504) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7340) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6706) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1694) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1975) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1103) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3741) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7616) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4796) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7894) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6957) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6287) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7445) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4668) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4259) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6683) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7436) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3360) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8330) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7306) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(194) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6217) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8259) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6887) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7372) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5408) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10684) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7080) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8419) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5548) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7832) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8215) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6494) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5450) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10387) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7736) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4001) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3320) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5922) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6737) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7474) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7864) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10583) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7017) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7006) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4003) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7800) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(523) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8350) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1275) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6391) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6082) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8464) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6682) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7374) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3770) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8319) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8081) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8398) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3909) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6071) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8507) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7788) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8352) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8111) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(701) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8262) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4681) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7414) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8533) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5590) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7632) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1970) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1312) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2529) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4861) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7657) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(52) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10543) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5400) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6954) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3265) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10483) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5556) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7655) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6332) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7189) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4205) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1853) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3429) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8447) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8498) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1797) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3336) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5754) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1330) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4232) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6708) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6380) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4783) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6717) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3857) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7569) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8484) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10725) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5666) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5639) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6805) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10505) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1321) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7303) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4744) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8265) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3150) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4151) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2107) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8374) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6541) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5402) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7772) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8220) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7055) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4722) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2516) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5470) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7875) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5097) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6461) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7125) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7960) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5691) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5692) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1220) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6854) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10671) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10589) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6187) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4060) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7757) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3335) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8231) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8397) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6713) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6697) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2895) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4761) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6784) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5615) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(814) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5397) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8142) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3786) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(724) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6719) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6652) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3340) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5457) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4010) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5416) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7485) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2514) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8375) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5503) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(838) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6679) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3669) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3246) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5412) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10749) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6467) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6308) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3313) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3714) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3409) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1206) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6858) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5673) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1887) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7226) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7652) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6496) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7188) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1137) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6754) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8015) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8175) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(600) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6495) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6763) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3603) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7594) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(816) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10834) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5737) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7194) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1686) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6776) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5578) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6830) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3292) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2905) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1335) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6871) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8405) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(137) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1129) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3812) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8275) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6664) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5648) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8391) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6428) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6598) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5492) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3749) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4713) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6668) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6251) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10618) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4178) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2843) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7148) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5580) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1331) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3334) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5405) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(812) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7572) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6870) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10748) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5446) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(297) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3249) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4609) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3268) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10823) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5697) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3149) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5683) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8510) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4628) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6067) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7618) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(715) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6392) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(132) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5391) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5510) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1852) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3484) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4700) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4005) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10305) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5621) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6662) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8094) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3820) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8196) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3789) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8328) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4565) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8294) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5549) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5443) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8578) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8207) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3764) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6322) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5459) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10506) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7001) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2592) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8200) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6689) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4358) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6325) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7997) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10348) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10487) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2109) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5736) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6144) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2611) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10605) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2500) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6787) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4663) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4040) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4779) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10479) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6320) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6904) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8553) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5048) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8512) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1800) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5771) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4692) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4134) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2108) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6770) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7725) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7087) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7020) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6757) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4387) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6866) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5388) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4557) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6809) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5792) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5696) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3216) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5455) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7473) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10349) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10490) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10654) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10399) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5500) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6997) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6762) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(226) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5641) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6079) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5484) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(93) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3304) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4766) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3722) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10691) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6876) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6771) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8246) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5533) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7642) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4728) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1784) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3999) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6855) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8411) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6484) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3527) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6893) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6714) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6813) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5006) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6715) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7271) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6669) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1699) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10588) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5415) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7346) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4967) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6095) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4736) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3462) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4002) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6066) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(419) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7268) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8463) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2150) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8205) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6846) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3215) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5768) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6493) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8395) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8506) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3796) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1833) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8306) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7319) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2767) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2686) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8421) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4768) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7820) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3576) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10436) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3701) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3324) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5483) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2638) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6138) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7223) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7949) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6660) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2598) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3734) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5447) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6730) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2024) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4958) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7893) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5051) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5377) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6924) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5671) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6658) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(72) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4855) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4767) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5449) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5462) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3256) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3352) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2603) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10352) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1913) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(25) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3220) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7424) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(284) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7533) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8135) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6350) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(174) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10318) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5702) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5436) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6922) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4660) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(22) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(237) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4775) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10339) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7275) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3559) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7354) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3330) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6630) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6597) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8460) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6764) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6335) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2512) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8309) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5603) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2568) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10264) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7620) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4621) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10268) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3291) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(81) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7022) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6472) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5423) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1667) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4911) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6255) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7694) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8210) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6852) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7431) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1902) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1263) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3356) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7792) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8475) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7091) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10477) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3312) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6078) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(668) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3776) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8402) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8454) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(33) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10887) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10335) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7927) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3255) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8496) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6882) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8148) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8228) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5385) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6680) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10766) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3662) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3252) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5778) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2713) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8390) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10385) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8407) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5519) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6878) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5441) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5710) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2871) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4314) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10466) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1830) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6503) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10535) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1741) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7751) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1829) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8529) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8457) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7344) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7176) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4274) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4509) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8272) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7515) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4622) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8472) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2900) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4203) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4662) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2578) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3900) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1334) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4270) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10270) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(204) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6542) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6913) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8048) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1136) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8119) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3254) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7570) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6903) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7623) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6844) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4211) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6671) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6433) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6639) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6686) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3447) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5442) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10306) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3306) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(114) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10590) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3426) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6434) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10367) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(288) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3327) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10275) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5773) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3578) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3245) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6226) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7850) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5623) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(224) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2820) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5479) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4765) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7574) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6845) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6072) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8062) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4923) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3915) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6690) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3323) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6239) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2593) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6886) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10278) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4637) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6847) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3333) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6896) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5756) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3566) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6342) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7501) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6474) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2497) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3228) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6136) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1347) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6083) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3301) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4677) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(13) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5429) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7482) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1761) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(549) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6676) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5074) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1880) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8138) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2527) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10843) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3727) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6619) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8011) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7752) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6521) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5698) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6373) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4673) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8249) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6419) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2044) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8342) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3381) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5119) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7065) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5078) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(225) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6665) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8556) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8515) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4195) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5075) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10656) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7095) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8121) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5499) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5089) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3261) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6798) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7333) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6868) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8101) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6938) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6081) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4725) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6297) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6656) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7928) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8199) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7567) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5678) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3307) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10708) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6198) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6848) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4776) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(559) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(745) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6347) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6722) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6726) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5463) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(577) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6853) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2548) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7782) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6618) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(50) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4454) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4535) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6785) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8396) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2588) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10606) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8041) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(70) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6362) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10661) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8001) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6112) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4515) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5713) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6147) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3564) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5009) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6057) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3844) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6718) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5414) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6778) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5418) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6602) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8469) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2688) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1998) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7980) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6667) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3343) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1767) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5378) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(55) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2792) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3308) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7816) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6218) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5767) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7966) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6382) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2854) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8408) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1982) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7313) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8213) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7337) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1133) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7170) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4492) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10609) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6196) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6583) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2506) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7512) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5632) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3365) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6180) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4792) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3672) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10450) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6984) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5650) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5604) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4600) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2018) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6772) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6115) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4004) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1664) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7439) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(201) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3819) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6371) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8431) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6385) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8114) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6261) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7066) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7038) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3831) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6315) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6113) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7385) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6691) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6744) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7511) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3066) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4618) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10289) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7195) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4550) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5395) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1327) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1292) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3739) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7753) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3243) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(103) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6386) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7021) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6233) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6487) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8451) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6547) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7138) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1322) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(817) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7003) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6441) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8258) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6684) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2521) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(17) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6880) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6756) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5000) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6716) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(293) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6402) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1198) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6993) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3242) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(855) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10576) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6752) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6203) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3058) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6540) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4717) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8468) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8297) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3817) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8125) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3577) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3354) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6633) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1328) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6806) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8483) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6799) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8346) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7891) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1778) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2856) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(719) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3344) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8406) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10260) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5403) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6889) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6912) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6571) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2546) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6292) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3305) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7604) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5730) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3905) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(145) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4738) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7996) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8277) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6381) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7915) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6379) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1201) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7656) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4631) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8100) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6821) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2860) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5109) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6200) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2697) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5471) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10601) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4969) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7770) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2602) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10814) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3208) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8151) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6327) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(266) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3963) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6401) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6981) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2532) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(217) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8245) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4678) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7525) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8217) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10468) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7260) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7544) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2033) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5248) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10570) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6990) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5617) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3839) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6302) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6505) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8314) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5491) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3269) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(209) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5456) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1691) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6604) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5380) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4472) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(815) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6883) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10263) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8499) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8412) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3505) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10279) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6388) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6939) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6888) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4133) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7128) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7349) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2505) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4795) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3676) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6884) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6735) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6349) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10256) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5628) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(854) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5532) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10345) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7934) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8225) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8061) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6850) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3967) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6478) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3720) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7037) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7573) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5554) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6859) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4763) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8223) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6688) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8425) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8343) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6727) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5539) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5430) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7438) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7361) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4805) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5583) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6734) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7140) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1808) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5551) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5448) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(702) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1241) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4794) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6387) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1662) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4630) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8036) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(146) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2493) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6677) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(693) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2379) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4495) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3273) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4189) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1138) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6590) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7737) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8336) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7098) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7338) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4544) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6793) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3932) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2510) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5050) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7784) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5620) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7571) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8359) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10357) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8517) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5482) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(9999) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6731) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5672) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7476) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5466) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1930) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3258) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8327) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7526) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6765) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8043) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6620) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8442) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8007) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6235) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7992) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6792) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10448) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3508) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8535) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6753) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8366) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6769) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4648) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4708) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7395) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6881) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4704) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3554) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5599) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7635) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4589) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6114) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6089) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7878) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6553) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7272) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10292) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8257) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1280) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6576) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3464) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6823) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2015) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4230) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2380) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6197) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7051) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2698) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10621) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3801) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3549) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8018) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6760) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8056) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6384) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8058) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1270) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5511) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5428) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3640) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(766) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3407) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2828) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1323) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1205) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3803) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3128) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7252) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5394) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1267) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5568) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6829) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3550) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6269) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8191) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10689) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7586) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(613) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6740) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8361) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8296) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10420) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10482) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10377) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4803) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7908) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2381) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4130) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1324) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7545) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8385) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3940) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(9) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2706) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(160) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8091) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4527) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3838) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7283) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7192) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7460) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4774) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(852) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1237) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3316) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6687) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(568) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5693) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5564) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5407) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6703) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6306) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8120) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(38) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4720) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3339) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1213) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5445) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7137) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8455) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10821) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3230) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3260) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4496) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2614) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8540) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10839) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3608) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2764) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6867) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5625) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8470) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6448) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3404) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1332) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4470) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5003) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6661) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8300) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6905) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4711) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1850) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7565) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10496) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2609) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6902) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10771) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8060) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5646) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4006) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4433) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5609) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6357) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4167) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7470) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6986) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10711) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6383) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4780) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8334) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1798) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8264) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5600) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1831) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2118) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4222) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5700) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2917) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2915) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4251) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(450) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10384) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10531) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8263) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5669) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8456) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10793) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6983) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10299) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1835) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2276) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2832) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5622) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(35) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(681) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8476) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6471) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3761) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10533) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3449) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3557) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3244) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5651) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(298) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6122) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5409) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3315) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5468) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8465) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5496) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5413) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8284) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3142) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4963) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4694) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7143) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6774) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4762) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(517) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2513) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2914) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2519) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5390) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8066) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8166) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5630) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7062) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2874) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7514) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4793) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7258) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2012) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6732) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6064) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1221) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7199) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4623) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8573) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2933) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4691) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6841) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5432) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10545) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4434) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(286) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3064) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10481) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(786) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4534) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3506) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6863) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(97) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7543) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4261) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6728) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1932) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2840) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8250) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8489) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(83) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5509) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5389) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8321) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6678) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7120) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2907) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6543) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10674) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2042) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5618) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1899) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10732) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8291) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4982) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5498) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6555) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8280) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8278) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3743) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(714) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7982) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1916) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4727) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7829) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5396) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3951) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8511) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10304) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10245) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4800) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5656) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10249) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5788) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6955) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6745) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8269) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5434) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7236) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5002) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2637) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1675) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5715) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5637) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4651) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6450) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6140) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4788) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3248) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4390) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10444) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1325) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7018) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7015) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1717) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5596) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6864) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6783) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7541) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8422) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6750) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7370) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4247) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6561) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7207) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4686) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10692) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6259) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1890) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7790) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4183) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8046) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4197) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6795) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6375) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4957) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7833) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5444) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6761) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6648) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5607) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4742) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7518) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4926) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3758) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5203) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2683) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6685) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2853) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10354) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1653) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(278) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7178) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3328) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1290) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7106) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1326) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8316) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2052) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3586) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4913) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10746) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6968) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4716) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5387) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6172) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10734) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6509) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2836) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1673) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6897) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6214) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(687) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8253) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8271) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4058) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6803) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(195) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7224) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7892) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3632) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2766) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6458) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3384) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8211) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6073) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1333) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7585) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4459) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8063) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8340) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6062) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1759) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1891) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7825) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4682) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3768) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5451) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8331) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10585) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2652) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5076) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7973) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7489) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10631) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3302) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8452) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7922) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5426) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3479) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6681) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2852) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5645) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8388) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6369) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2848) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6427) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5597) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7369) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3976) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8313) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5559) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3493) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7417) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5749) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5676) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1273) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4710) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4436) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5687) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1670) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10267) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6245) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3575) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7459) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5382) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(2966) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6568) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(703) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8542) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4652) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1755) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6849) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3463) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1140) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6345) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(683) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3152) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7951) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6525) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10501) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(6065) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5573) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7263) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10562) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8267) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8583) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10415) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3361) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5522) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7590) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(5557) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(8363) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(4231) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(1901) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(10252) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3393) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(7096) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3790) 1.5Mb 10ms DropTail
$ns duplex-link $node(5) $node(3615) 1.5Mb 10ms DropTail

$ns at 20 "$BGP286 command \"network 10.0.1.0/24\""

$ns at 310 "$BGP1833 command \"route-map RMAP_NONCUST_OUT permit 10\""
$ns at 315 "$BGP1833 command \"clear ip bgp * soft\""
#$ns at 410 "$BGP174 command \"route-map RMAP_NONCUST_OUT deny 10\""
#$ns at 415 "$BGP174 command \"clear ip bgp *\""

puts "Starting the run"
$ns run
set etime [clock seconds]
puts "simulation elapsed seconds [expr $etime - $ltime]"
