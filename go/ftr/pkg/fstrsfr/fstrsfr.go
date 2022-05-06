package fstrsfr

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"

	"gopkg.in/fsnotify.v1"
)

func WaitAndTransfer(watchDir string) error {
	// set up coverage file watcher
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("could not set up new fs watcher: %w", err)
	}
	defer watcher.Close()

	// create handler for file watcher
	done := make(chan error)
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					done <- errors.New("received NOT OK on watcher.Events channel")
					return
				}

				if event.Op&fsnotify.Write == fsnotify.Write {
					done <- nil
					return
				}

				fmt.Printf("received unrecognized watch event: %v\n", event)
			case err, ok := <-watcher.Errors:
				if !ok {
					done <- errors.New("received NOT OK on watcher.Errors channel")
					return
				}
				done <- fmt.Errorf("watcher encountered error: %w", err)
				return
			}
		}
	}()

	// watch the coverage file
	// NOTE: dir has to exist or Add will fail
	err = watcher.Add(watchDir)
	if err != nil {
		log.Fatal("could not add fs watcher: ", err)
	}

	// read new coverage file
	watchErr := <-done
	if watchErr != nil {
		return fmt.Errorf("error encountered while watching file system")
	}

	content, err := ioutil.ReadFile(filepath.Join(watchDir, "coverage.out"))
	if err != nil {
		return fmt.Errorf("could not read coverage file: %w", err)
	}

	fmt.Print(string(content))
	return nil
}
