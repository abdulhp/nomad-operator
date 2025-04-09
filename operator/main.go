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

	if os.Getenv("NOMAD_SRV_ADDR") == "" {
		return fmt.Errorf("NOMAD_SRV_ADDR is not set")
	}
	if os.Getenv("NOMAD_SRV_SECRET_ID") == "" {
		return fmt.Errorf("NOMAD_SRV_SECRET_ID is not set")
	}
	if os.Getenv("NOMAD_CA_CERT_PATH") == "" {
		return fmt.Errorf("NOMAD_CA_CERT_PATH is not set")
	}
	if os.Getenv("NOMAD_CLIENT_CERT_PATH") == "" {
		return fmt.Errorf("NOMAD_CLIENT_CERT_PATH is not set")	
	}
	if os.Getenv("NOMAD_CLIENT_KEY_PATH") == "" {
		return fmt.Errorf("NOMAD_CLIENT_KEY_PATH is not set")
	}

	client, err := api.NewClient(&api.Config{
		// sandbox local credentials
		Address:  os.Getenv("NOMAD_SRV_ADDR"),
		SecretID: os.Getenv("NOMAD_SRV_SECRET_ID"),
		TLSConfig: &api.TLSConfig{
			CACert:     os.Getenv("NOMAD_CA_CERT_PATH"),
			ClientCert: os.Getenv("NOMAD_CLIENT_CERT_PATH"),
			ClientKey:  os.Getenv("NOMAD_CLIENT_KEY_PATH"),
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
