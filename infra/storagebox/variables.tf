variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "state_passphrase" {
  type        = string
  sensitive   = true
}

variable "location" {
  type    = string
  default = "fsn1"
}

variable "storage_box_type" {
  type    = string
  default = "bx11"
}

variable "subaccounts" {
  type = map(object({
    description    = string
    home_directory = string
    ssh            = optional(bool, false)
    webdav         = optional(bool, false)
    samba          = optional(bool, false)
    readonly       = optional(bool, false)
  }))

  default = {
    "immich" = {
      description    = "Immich Backups"
      home_directory = "immich/"
      ssh            = true
    }
    homeassistant = {
      description    = "Home Assistant Backups"
      home_directory = "homeassistant/"
      webdav         = true
    }
    homeassistant-2 = {
      description    = "Home Assistant 2 Backups"
      home_directory = "homeassistant-2/"
      webdav         = true
    }
    vaultwarden = {
      description    = "Vaultwarden Backups"
      home_directory = "vaultwarden/"
      ssh            = true
    }
  }
}

variable "ssh_public_keys" {
  type = list(string)
  default = [
    "../../keys/ssh/astral.pub",
    "../../keys/ssh/lunarium.pub",
  ]
}

