locals {
  main_ssh_keys = [
    for p in var.ssh_public_keys :
    trimspace(file(startswith(p, "/") ? p : "${path.module}/${p}"))
  ]
}

resource "random_password" "main" {
  length           = 40
  special          = true
  override_special = "-_.!#%"
}


resource "hcloud_storage_box" "backups" {
  name             = "Backups"
  storage_box_type = var.storage_box_type
  location         = var.location
  password         = random_password.main.result
  ssh_keys         = local.main_ssh_keys

  delete_protection = true

  access_settings = {
    ssh_enabled          = true
    samba_enabled        = false
    webdav_enabled       = false
    zfs_enabled          = false
    reachable_externally = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "sub" {
  for_each = var.subaccounts

  length           = 40
  special          = true
  override_special = "-_.!#%"
}

resource "hcloud_storage_box_subaccount" "sub" {
  for_each = var.subaccounts

  storage_box_id = hcloud_storage_box.backups.id
  name           = each.key
  description    = each.value.description
  home_directory = each.value.home_directory
  password       = random_password.sub[each.key].result

  access_settings = {
    ssh_enabled          = each.value.ssh
    webdav_enabled       = each.value.webdav
    samba_enabled        = each.value.samba
    readonly             = each.value.readonly
    reachable_externally = true
  }
}

output "server" {
  value = hcloud_storage_box.backups.server
}

output "main_username" {
  value = hcloud_storage_box.backups.username
}

output "subaccount_usernames" {
  value = { for k, s in hcloud_storage_box_subaccount.sub : k => s.username }
}

output "subaccount_passwords" {
  sensitive = true
  value     = { for k, p in random_password.sub : k => p.result }
}

output "main_password" {
  sensitive = true
  value     = random_password.main.result
}
