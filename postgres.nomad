job "postgres" {
    meta {
        auto-backup = true
        backup-schedule = "*/2 * * * *"
        backup-target-db = "postgres"
    }

    group "postgres" {
        network {
            port "db" {
                to = 5432
            }
        }

        task "postgres" {
            driver = "docker"

            template {
                data = <<EOF
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');
EOF
                destination = "local/init.sql"
            }

            env {
                POSTGRES_USER     = "admin"
                POSTGRES_PASSWORD = "admin123"
                POSTGRES_DB       = "mydatabase"
                POSTGRES_HOST_AUTH_METHOD = "trust"
            }

            config {
                image = "postgres:latest"
                ports = ["db"]

                volumes = [
                    "local:/docker-entrypoint-initdb.d"
                ]
            }

            resources {
                cpu    = 500
                memory = 512
            }

            service {
                name = "postgres"
                port = "db"

                check {
                    type     = "tcp"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        }
    }
}