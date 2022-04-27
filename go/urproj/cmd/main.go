package main

import (
	"flag"
	"fmt"
	"net/http"

	"urproj/pkg/msg"
)

var portFlag = flag.Int("port", 8000, "msg server port")

func main() {
	flag.Parse()
	port := fmt.Sprintf(":%d", *portFlag)

	http.ListenAndServe(port, http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			w.Write([]byte(msg.Msg()))
		},
	))
}
