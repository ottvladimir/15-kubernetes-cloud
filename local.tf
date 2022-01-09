locals {
   current_time = formatdate("DD_MM_YYYY", timestamp())
   user = "${USERNAME}"
   }

    output "current_time" {
        value = "${local.user}_${local.current_time}"
        }
