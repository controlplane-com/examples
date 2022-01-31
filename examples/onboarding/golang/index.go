package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

		fmt.Println("Workload Name: " + os.Getenv("CPLN_WORKLOAD"))
		fmt.Println("Location: " + os.Getenv("CPLN_LOCATION"))
		fmt.Fprintln(w, "Hello World")
	})

	http.ListenAndServe(":8080", nil)
}
