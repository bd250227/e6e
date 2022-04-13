package main

import (
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/fsnotify/fsnotify"
)

func main() {
	// set up OS signal watcher - do nothing with signal
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	// set up coverage file watcher
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	// create handler for file watcher
	done := make(chan struct{})
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					log.Fatal("received NOT OK on watcher.Events channel")
				}
				log.Println("event: ", event)
				if event.Op&fsnotify.Write == fsnotify.Write {
					log.Println("modified file: ", event.Name)
				}

				done <- struct{}{}
				return
			case err, ok := <-watcher.Errors:
				if !ok {
					log.Fatal("received NOT OK on watcher.Errors channel")
				}
				log.Fatal("error:", err)
			}
		}
	}()

	// watch the coverage file
	// NOTE: file has to exist or Add will fail
	err = watcher.Add("/tmp")
	if err != nil {
		log.Fatal("could not add fs watcher: ", err)
	}

	// read new coverage file
	<-done
	content, err := ioutil.ReadFile("/tmp/coverage.out")
	if err != nil {
		log.Fatal("could not read coverage file: ", err)
	}
	log.Println("content: ", string(content))
}
