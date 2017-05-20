package main

import (
	"time"
	"log"
	"flag"
	"math/rand"
)

func main() {

	// load command line arguments
	name := flag.String("name","world","name to print")
	flag.Parse()

	log.Printf("Starting sleepservice for %s",*name)
	for {
	  log.Printf("hello %s",*name)

	  // wait random number of milliseconds
	  Nsecs := rand.Intn(3000)	
	  log.Printf("About to sleep %dms before looping again",Nsecs)
	  time.Sleep(time.Millisecond * time.Duration(Nsecs))
	}

}
