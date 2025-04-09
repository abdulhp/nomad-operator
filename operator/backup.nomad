job "[[ .JobID ]]" {

  type = "batch"

  periodic {
    cron = "[[ .Schedule ]]"
    prohibit_overlap= true
  }

  group "backup" {
    count = 1

    task "backup" {
      driver = "docker"

      template {
        data = <<EOF
PGUSER=admin
PGPASSWORD=admin123

{{- range service "postgres"}}
PGHOST={{ .Address }}
PGPORT={{ .Port }}
{{- end }}
EOF

        destination = "secrets/db.env"
        env = true
      }

      config {
        image = "alpine/psql:latest"
        entrypoint = [ "/usr/bin/pg_dumpall" ]
        args    = [
            "--clean",
            "-f",
            "/local/pg_dump.sql"
        ]
      }
    }
  }
}
