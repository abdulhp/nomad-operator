job "operator" {
  type = "service"

  group "operators" {
    task "operator" {
      driver = "docker"
      
      template {
      	data=<<EOF
NOMAD_SRV_ADDR="https://192.168.58.23:4646"
NOMAD_SRV_SECRET_ID="a492b42f-be94-a12d-4b5a-70f7a84f4d4f"
NOMAD_CA_CERT_PATH="/opt/pg-operator/ca-cert.pem"
NOMAD_CLIENT_CERT_PATH="/opt/pg-operator/cli-cert.pem"
NOMAD_CLIENT_KEY_PATH="/opt/pg-operator/cli-key.pem"
EOF
        destination="secrets/operator.env"
        env=true
      }

      config {
        image = "operator:local"
        volumes = [
          "/etc/nomad.d/certs/ca-cert.pem:/opt/pg-operator/ca-cert.pem",
          "/etc/nomad.d/certs/cli-cert.pem:/opt/pg-operator/cli-cert.pem",
          "/etc/nomad.d/certs/cli-key.pem:/opt/pg-operator/cli-key.pem"
        ]
      }
    }
  }
}
