package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"ftr/pkg/fstrsfr"
)

func main() {
	// set up OS signal watcher - do nothing with signal
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	if err := fstrsfr.WaitAndTransfer("/tmp"); err != nil {
		log.Fatal(err)
	}
}
