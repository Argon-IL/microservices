terraform {
	required_version = "0.12.26"
}

provider "google" {
	version = "2.5.0"
	project = "${var.project}"
	region = "${var.region}"
}

resource "google_compute_instance" "app" {
	count = "${var.count_instances}"
	name = "reddit-app-${count.index}"
	machine_type = "n1-standard-1"
	zone = "${var.zone}"
	tags = ["reddit-app", "allow-80"]
	
	network_interface {
		network = "default"
		access_config {
		}
	}
	
		boot_disk {
		initialize_params { image = "ubuntu-1604-lts" }
	}
	
	metadata = {
		ssh-keys = "testuser:${file(var.public_key_path)}"
	}
	
	
}



resource "google_compute_firewall" "firewall_puma" {
	name = "allow-puma-default"
	network = "default"
	
	allow {
		protocol = "tcp"
		ports = ["9292"]
	}
	
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["reddit-app"]
}

