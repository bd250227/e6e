package main

import (
	"net/http"

	"e6e/msg"
)

func main() {
	http.ListenAndServe(":8000", http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			w.Write([]byte(msg.Msg()))
		},
	))
}
