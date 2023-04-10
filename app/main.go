package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
)

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	var env []string
	for _, e := range os.Environ() {
		if strings.HasPrefix(e, "APP_") {
			env = append(env, e)
		}
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		fmt.Fprintf(w, "Hello from %s\n\n", hostname)
		fmt.Fprintf(w, "Environment:\n%s\n", strings.Join(env, "\n"))
	})

	log.Fatal(http.ListenAndServe(":8080", handler))
}
