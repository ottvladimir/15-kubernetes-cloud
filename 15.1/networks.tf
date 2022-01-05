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
# Create ya.cloud private subnet
resource "yandex_vpc_subnet" "ya-network-private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ya-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
  
}
resource "yandex_vpc_route_table" "route-table" {
  name = "nat-route"
  network_id = yandex_vpc_network.ya-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface[0].ip_address
  }
}
