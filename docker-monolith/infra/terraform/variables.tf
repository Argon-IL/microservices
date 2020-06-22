
variable zone {
	description = "Instance zone"
}

variable public_key_path {
	description = "Path to public key used for ssh access"
}

variable region {
	description = "Region"
	default = "europe-west1"
}

variable project {
	description = "Project ID"
}

variable count_instances {
	description = "Count instances"
}
