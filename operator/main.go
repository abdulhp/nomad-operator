package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/hashicorp/nomad/api"
)

func main() {
	fmt.Println("Starting Nomad backup operator...")

	if err := run(os.Args[:]); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func run(args []string) error {
	fmt.Println("Creating Nomad client...")

	client, err := api.NewClient(&api.Config{
		// sandbox local credentials
		Address:  "https://192.168.58.23:4646",
		SecretID: "a492b42f-be94-a12d-4b5a-70f7a84f4d4f",
		TLSConfig: &api.TLSConfig{
			CACert:     "nomad99-certs/ca-cert.pem",
			ClientCert: "nomad99-certs/cli-cert.pem",
			ClientKey:  "nomad99-certs/cli-key.pem",
		},
	})

	if err != nil {
		return err
	}

	server, err := client.Agent().NodeName()

	if err != nil {
		return err
	}

	fmt.Println("Connected to Nomad server:", server)

	backup := NewBackup(client)
	consumer := NewConsumer(client, backup.OnJob)

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		s := <-signals
		fmt.Printf("Received %s, stopping Nomad backup operator...\n", s)
		
		consumer.Stop()
		os.Exit(0)
	}()

	// blocks
	fmt.Println("Listening Nomad Events...")
	consumer.Start()
	return nil
}
