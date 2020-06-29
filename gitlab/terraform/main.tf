terraform {
	required_version = "0.12.26"
}

provider "google" {
	version = "2.5.0"
	project = "${var.project}"
	region = "${var.region}"
}

resource "google_compute_instance" "gitlab_machine" {
	name = "gitlab-machine"
	machine_type = "n1-standard-2"
	zone = "${var.zone}"
	tags = ["allow-80-443", "allow-2222"]
	

	network_interface {
		network = "default"
		access_config {
		}
	}
	
	boot_disk {
		initialize_params { image = "ubuntu-1604-lts" }
	}
	
	metadata = {
		ssh-keys = "argon:${file(var.public_key_path)}"
	}
	
	provisioner "remote-exec" {
	inline = ["sudo apt -y install python && sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs"]

    connection {
	  host		  = "${self.network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "argon"
      private_key = "${file(var.ssh_key_path)}"
	  agent 	  = false
    }
  }


	provisioner "local-exec" {
    	command = "echo ${self.network_interface.0.access_config.0.nat_ip} > ./files/temp/ip-instance && ./files/createcopy.sh && ansible-playbook -u argon -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.ssh_key_path} ansible-playbooks/install-docker.yml" 
    }

	provisioner "remote-exec" {
	inline = ["cd /srv/gitlab && docker-compose up -d "]

    connection {
	  host		  = "${self.network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "argon"
      private_key = "${file(var.ssh_key_path)}"
	  agent 	  = false
    }
	}

	provisioner "local-exec" {
		command = "rm ./files/temp/*"
	}
}

resource "google_compute_firewall" "allow_port_80_and_443" {
	name = "allow-port-80-443"
	network = "default"
	
	allow {
		protocol = "tcp"
		ports = ["80", "443"]
	}
	
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["allow-80-443"]
}

resource "google_compute_firewall" "allow_port_2222" {
	name = "allow-port-2222"
	network = "default"

	allow {
		protocol = "tcp"
		ports = ["2222"]
	}
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["allow-2222"]
}