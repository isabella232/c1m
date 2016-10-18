job "server" {
  region      = "${region}"
  datacenters = [${datacenters}]
  type        = "system"
  priority    = ${priority}

  constraint {
    attribute = "\$${node.datacenter}"
    regexp    = "(${replace(replace(join("|", split(",", datacenters)), "\"", ""), " ", "")})"
  }

  update {
    stagger      = "1s"
    max_parallel = 3
  }

  group "server" {
    restart {
      mode     = "delay"
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    task "server" {
      driver       = "exec"
      kill_timeout = "10s"

      config {
        command = "${command}"
      }

      artifact {
        source = "${artifact_source}"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10

        network {
          mbits = 1

          port "server" {
            static = 8000
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        NODE_DATACENTER = "\$${node.datacenter}"
        REDIS_ADDRESS   = "redis.query.consul:6379"
      }

      service {
        name = "server"
        port = "server"
        tags = [${tags}]

        check {
          name     = "server alive"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}