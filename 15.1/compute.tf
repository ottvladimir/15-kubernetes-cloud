resource "yandex_compute_instance" "nat" {
  name        = "nat"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ya-network-public.id
    nat       = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_compute_instance" "netology" {
  name        = "netology"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ya-network-private.id
  }

  metadata = {
     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
 }

