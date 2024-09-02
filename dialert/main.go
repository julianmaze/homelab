package main

import (
	"fmt"
	"os"
	"time"

	"github.com/julianmaze/dexcomfollow"
)

type Client struct {
	DexcomClient *dexcomfollow.Dexcom
	Username  string
	AccountID string
	Password  string
	Ous       bool
}

func setup() Client {
	
	return dexcomfollow.NewDexcom(auth)
}

func (d *dexcomfollow.Dexcom) GetBloodSugar(t time.Time) {
	fmt.Printf("Querying blood sugar at %s\n", t)

	GetLatestGlucoseReading()
}

func main() {
	// Create a ticker for 5 minutes used to query dexcoms follow API
	ticker := time.NewTicker(time.Second * 5)
	defer ticker.Stop()

	// Goroutine to terminate after 30 seconds for testing - for some reason I cannot terminate on my code server instance
	go func() {
		time.Sleep(30 * time.Second)
		os.Exit(0)
	}()

	// Setup client
	setup()

	for t := range ticker.C {
		GetBloodSugar(t)
	}
}
