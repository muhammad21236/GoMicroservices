package main

import (
	"fmt"
	"log"
	"net/http"
)

const webPort = "80"

type Config struct{}

func main() {
	app := Config{}

	fmt.Printf("Broker service started on port %s", webPort)

	//define http server

	srv := &http.Server{
		Addr:    fmt.Sprintf(":%s", webPort),
		Handler: app.routes(),
	}

	//start the http server

	err := srv.ListenAndServe()
	if err != nil {
		log.Panic(err)
	}
}
