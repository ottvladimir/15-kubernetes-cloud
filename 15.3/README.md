# Домашнее задание к занятию 15.3 "Безопасность в облачных провайдерах"

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)
- Создаю ключ в KMS kms.tf
```tf
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "key"
  description       = "test key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
```

- С помощью ключа шифрую содержимое бакета, созданного ранее bucket.tf
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

// Use keys to create bucket
resource "yandex_storage_bucket" "my_storage" {
  access_key = yandex_iam_service_account_static_access_key.stor-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.stor-static-key.secret_key
  bucket = "bucket-${var.username}-${formatdate("DD-MM-YYYY",timestamp())}"
  server_side_encryption_configuration {
      rule {
            apply_server_side_encryption_by_default {
                    kms_master_key_id = yandex_kms_symmetric_key.key-a.id
                            sse_algorithm     = "aws:kms"
                                  }
}
}
}
resource "yandex_storage_object" "picture" {
   access_key = yandex_iam_service_account_static_access_key.stor-static-key.access_key
   secret_key = yandex_iam_service_account_static_access_key.stor-static-key.secret_key
   bucket = yandex_storage_bucket.my_storage.bucket 
   key = "image.jpg"
   source = "./01-1.png"
   acl = "public-read"
  }
```
