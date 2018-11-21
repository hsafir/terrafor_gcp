provider "google" {
  credentials = "${file("~/Downloads/kube-cluster-223011-dc8d8659ac85.json")}"
  project = "kube-cluster-223011"
  region = "us-central1"
}
resource "google_compute_instance_group" "kube-master-group" {
  name = "kube-master-group"
  instances = [
    "${google_compute_instance.kube-master-0.self_link}",
    "${google_compute_instance.kube-master-1.self_link}"
  ]
  zone = "us-central1-a"
}

resource "google_compute_instance" "kube-master-1" {
  name = "kube-master-1"
  machine_type = "n1-standard-2"
  zone = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "centos-7-v20170816"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.kube_subnetwork.name}"
    access_config {
      // Ephemeral IP
    }
  }
}
resource "google_compute_instance" "kube-master-0" {
  name = "kube-master-0"
  machine_type = "n1-standard-2"
  zone = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "centos-7-v20170816"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.kube_subnetwork.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "kube-node" {
  count = "2"
  name = "kube-node-${count.index}"
  machine_type = "n1-standard-1"
  zone = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "centos-7-v20170816"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.kube_subnetwork.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_network" "kube_network" {
  name = "kube-cluster-network"
}

resource "google_compute_subnetwork" "kube_subnetwork" {
  name          = "kube-cluster-subnetwork-us-central1"
  region        = "us-central1"
  network       = "${google_compute_network.kube_network.self_link}"
  ip_cidr_range = "10.0.0.0/16"
}

resource "google_compute_firewall" "ssh" {
  name    = "kube-cluster-network-firewall-ssh"
  network = "${google_compute_network.kube_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["kube-cluster-network-firewall-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name    = "kube-cluster-network-firewall-http"
  network = "${google_compute_network.kube_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["kube-cluster-network-firewall-http"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https" {
  name    = "kube-cluster-network-firewall-https"
  network = "${google_compute_network.kube_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["kube-cluster-network-firewall-https"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kube-console" {
  name    = "kube-cluster-network-firewall-kube-console"
  network = "${google_compute_network.kube_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags   = ["kube-cluster-network-firewall-kube-console"]
  source_ranges = ["0.0.0.0/0"]
}
