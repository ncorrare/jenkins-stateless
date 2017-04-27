job "jenkins" {
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
        JENKINS_HOME = "/local"
        JENKINS_SLAVE_AGENT_PORT = 5050
      }
      driver = "java"
      config {
        jar_path    = "local/jenkins.war"
        jvm_options = ["-Xmx768m", "-Xms384m"]
        args        = ["--httpPort=8080"]
      }
      artifact {
        source = "http://ftp-chi.osuosl.org/pub/jenkins/war-stable/2.46.2/jenkins.war"

        options {
          checksum = "sha256:aa7f243a4c84d3d6cfb99a218950b8f7b926af7aa2570b0e1707279d464472c7"
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
          cpu    = 2400 # MHz
          memory = 768 # MB
          network {
            mbits = 100

# This requests a dynamic port named "http". This will
# be something like "46283", but we refer to it via the
# label "http".
            port "http" {
                static = 8080
            }
            port "slave" {
              static = 5050
            }
          }
        }
      }
    task "provisioner" {
      driver = "exec"   
      config {
        command = "setup_jenkins.sh"
      }
      artifact {
        source = "https://raw.githubusercontent.com/ncorrare/jenkins-stateless/master/setup_jenkins.sh"
        options {
          checksum = "sha256:0373d92ede83ab4d5dd5136d0bd9570198b5626fc6bd7d0f55d7b989395b25ba"
        }
      }
    }
  }
}
