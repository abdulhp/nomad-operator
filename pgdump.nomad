job "pgdumpall" {
    type = "batch"
  
  	parameterized {}
  
    group "pgdumpall" {
        task "pgdumpall" {
            driver = "docker"

            env {
                PGHOST = "192.168.58.32"
                PGPORT = 23924
                PGUSER = "admin"
                PGPASSWORD = "dicodinglocal"
            }

            config {
                image = "alpine/psql" # Pre-built image with pgdumpall
                entrypoint = [ "/usr/bin/pg_dumpall" ]
                args    = [
                    "--clean",
                    "-f",
                    "/local/pg_dump.sql"
                ]
            }

            resources {
                cpu    = 100
                memory = 128
            }
        }
    }
}