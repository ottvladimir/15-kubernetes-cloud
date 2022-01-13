Домашнее задание к занятию 15.2 "Вычислительные мощности. Балансировщики нагрузки".

1. Создаю bucket Object Storage и размещаю там файл с картинкой:  
 ```tf
 locals {
   username = "vladimir"
   }

// Create SA
resource "yandex_iam_service_account" "storage" {
  folder_id = var.yc_folder_id
  name      = "storage"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "stor-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "stor-static-key" {
  service_account_id = yandex_iam_service_account.storage.id
  description        = "static access key for object storage"
}

// Cоздаю bucket в Object Storage с генерируемым именем;
resource "yandex_storage_bucket" "my_storage" {
  access_key = yandex_iam_service_account_static_access_key.stor-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.stor-static-key.secret_key
  bucket = "bucket-${var.username}-${formatdate("DD-MM-YYYY",timestamp())}"
}
// Ложу файл с картинкой и делаю доступным из Интернет;
resource "yandex_storage_object" "picture" {
   access_key = yandex_iam_service_account_static_access_key.stor-static-key.access_key
   secret_key = yandex_iam_service_account_static_access_key.stor-static-key.secret_key
   bucket = yandex_storage_bucket.my_storage.bucket 
   key = "image.jpg"
   source = "./01-1.png"
   acl = "public-read"
  }
```
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и web-страничкой, содержащей ссылку на картинку из bucket:
```tf 
// Создаю Instance Group с 3 ВМ и шаблоном LAMP
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
    //
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
  // Loadbalancer
  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
}
```
Сетевой балансировщик
```tf
resource "yandex_lb_network_load_balancer" "ig-load-balancer" {
  name = "ig-load-balancer"

  listener {
    name = "ig-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
       port = 80
      }
    }
  }
}
```
