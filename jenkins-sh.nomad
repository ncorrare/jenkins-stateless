job "jenkins-beta" {
  type = "service"
    datacenters = ["lhr-armhf"]
    update {
      stagger      = "30s"
        max_parallel = 1
    }
  group "web" {
    count = 1
      ephemeral_disk {
       migrate = true
       size    = "500"
       sticky  = true
       
     }
    task "frontend" {
      env {
        HTTP_PORT = 8087
      }
      vault {
        policies = ["github"]

        change_mode   = "noop"
      }
      driver = "exec"
      config {
        command  = "/bin/bash"
        args     = ["local/start_jenkins.sh"]
      }
      artifact {
        source = "https://raw.githubusercontent.com/ncorrare/jenkins-stateless/master/start_jenkins.sh"

        options {
          checksum = "sha256:a5a9a7016b2ee8abec300f13ed70f1ebf155f76ed77f089d4f527fe74100c8ac"
        }
      }
      service {
        # This tells Consul to monitor the service on the port
        # labled "http". Since Nomad allocates high dynamic port
        # numbers, we use labels to refer to them.
        port = "http"
        name = "jenkins-beta"

        check {
          type     = "http"
          path     = "/login"
          interval = "10s"
          timeout  = "2s"
        }
    }

# Specify the maximum resources required to run the job,
# include CPU, memory, and bandwidth.
      resources {
          cpu    = 1200 # MHz
          memory = 384 # MB
          network {
            mbits = 20

# This requests a dynamic port named "http". This will
# be something like "46283", but we refer to it via the
# label "http".
            port "http" {
                static = 8087
            }
            port "slave" {
              static = 5050
            }
          }
        }
      }
  }
}
