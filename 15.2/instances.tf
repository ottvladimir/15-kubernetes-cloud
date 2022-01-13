resource "yandex_compute_instance_group" "web" {
  name                = "netology-ig"
  folder_id           = var.yc_folder_id
  service_account_id  = yandex_iam_service_account.storage.id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 4
      }
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.ya-network-public.id]
      nat = true
    }
    labels = {
      label1 = "label1"
      label2 = "label2"
      label3 = "label3"
    }
    metadata = {
      user-data  = "${file("cloudconfig.yml")}" 
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  variables = {
    test_key1 = "test_value1"
    test_key2 = "test_value2"
    test_key3 = "test_value3"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
}
