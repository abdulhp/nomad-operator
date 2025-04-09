job "psql-client" {
    group "psql" {
        task "psql" {
            driver = "docker"

            config {
                image = "alpine/psql" # Pre-built image with psql
                entrypoint = [ "/bin/sh" ]
                args    = ["-c", "while true; do echo 'Running Alpine'; sleep 30; done"]
              	volumes = [
                    "/home/ubuntu/pg-backups:/pg-backups" # Host directory mapped to /data in the container
                ]
            }

            resources {
                cpu    = 100
                memory = 128
            }
        }
    }
}