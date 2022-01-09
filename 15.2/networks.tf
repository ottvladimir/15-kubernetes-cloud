# Create ya.cloud VPC
resource "yandex_vpc_network" "ya-network" {
  name = "ya-network"
}
# Create ya.cloud public subnet
resource "yandex_vpc_subnet" "ya-network-public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ya-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
