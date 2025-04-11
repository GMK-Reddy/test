terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "6.28.0"
    }
  }
}

provider "oci" {
  # Configuration options
}

#BCOCI010004
resource "oci_identity_authentication_policy" "pass" {
  compartment_id = var.tenancy_id
  password_policy {
    minimum_password_length          = 14
  }
}

resource "oci_identity_authentication_policy" "fail" {
  compartment_id = var.tenancy_id
  password_policy {
    minimum_password_length          = 1
  }
}

#BCOCI020001
resource "oci_core_instance" "pass" {
  availability_domain = var.instance_availability_domain
  compartment_id = var.compartment_id
  shape = var.instance_shape
  ipxe_script                         = var.instance_ipxe_script
  is_pv_encryption_in_transit_enabled = true
  cluster_placement_group_id = oci_identity_group.test_group.id
  compute_cluster_id = oci_core_compute_cluster.test_compute_cluster.id
  launch_options {
    boot_volume_type                    = var.instance_launch_options_boot_volume_type
    firmware                            = var.instance_launch_options_firmware
    is_consistent_volume_naming_enabled = var.instance_launch_options_is_consistent_volume_naming_enabled
    is_pv_encryption_in_transit_enabled = true
    network_type                        = var.instance_launch_options_network_type
    remote_data_volume_type             = var.instance_launch_options_remote_data_volume_type
  }
}

resource "oci_core_instance" "fail" {
  availability_domain = var.instance_availability_domain
  compartment_id = var.compartment_id
  shape = var.instance_shape
  ipxe_script                         = var.instance_ipxe_script
  cluster_placement_group_id = oci_identity_group.test_group.id
  compute_cluster_id = oci_core_compute_cluster.test_compute_cluster.id
  launch_options {
    boot_volume_type                    = var.instance_launch_options_boot_volume_type
    firmware                            = var.instance_launch_options_firmware
    is_consistent_volume_naming_enabled = var.instance_launch_options_is_consistent_volume_naming_enabled
    network_type                        = var.instance_launch_options_network_type
    remote_data_volume_type             = var.instance_launch_options_remote_data_volume_type
  }
}

#BCOCI020002
resource "oci_core_instance" "pass_12" {
  availability_domain = var.instance_availability_domain
  compartment_id = var.compartment_id
  shape = var.instance_shape
  ipxe_script                         = var.instance_ipxe_script
  is_pv_encryption_in_transit_enabled = true
  cluster_placement_group_id = oci_identity_group.test_group.id
  compute_cluster_id = oci_core_compute_cluster.test_compute_cluster.id
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
}

resource "oci_core_instance" "fail_23" {
  availability_domain = var.instance_availability_domain
  compartment_id = var.compartment_id
  shape = var.instance_shape
  ipxe_script                         = var.instance_ipxe_script
  is_pv_encryption_in_transit_enabled = true
  cluster_placement_group_id = oci_identity_group.test_group.id
  compute_cluster_id = oci_core_compute_cluster.test_compute_cluster.id
}

#BCOCI030001
resource "oci_objectstorage_bucket" "pass2" {
  compartment_id = var.compartment_id
  name = var.bucket_name
  namespace = var.bucket_namespace
  access_type           = "NoPublicAccess"
}

resource "oci_objectstorage_bucket" "fail2" {
  compartment_id = var.compartment_id
  name = var.bucket_name
  namespace = var.bucket_namespace
  access_type           = "PublicAccess"
}

#BCOCI030002
resource "oci_objectstorage_bucket" "pass" {
  compartment_id = var.compartment_id
  name = var.bucket_name
  namespace = var.bucket_namespace
  kms_key_id            = var.oci_kms_key.id
}

resource "oci_objectstorage_bucket" "fail" {
  compartment_id = var.compartment_id
  name = var.bucket_name
  namespace = var.bucket_namespace
}

#BCOCI030003
resource "oci_file_storage_file_system" "encrypted_fs" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "encrypted-file-system"
  kms_key_id = oci_kms_key.cmk.id  
}

resource "oci_file_storage_file_system" "encrypted_fs_1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "encrypted-file-system"
}

#BCOCI030004
resource "oci_core_volume" "cmk_encrypted_volume" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "cmk-encrypted-block-volume"
  size_in_gbs         = 50
  kms_key_id = oci_kms_key.cmk.id 
}

resource "oci_core_volume" "cmk_encrypted_volume_1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "cmk-encrypted-block-volume"
  size_in_gbs         = 50
}

#BCOCI030006
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

resource "oci_audit_configuration" "audit_config" {
  compartment_id = data.oci_identity_tenancy.tenancy.id
  retention_period_days = 365
  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_audit_configuration" "audit_config_1" {
  compartment_id = data.oci_identity_tenancy.tenancy.id
  retention_period_days = 180
  lifecycle {
    prevent_destroy = true
  }
}

#BCOCI050001
resource "oci_core_security_list" "bastion" {
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "all" 
    tcp_options {
      destination_port_range {
        min = 22
        max = 22
      }
    }
  }
}

resource "oci_core_security_list" "bastion_host" {
  ingress_security_rules {
    source   = "10.10.10.0/32"
    protocol = "tcp" 
    tcp_options {
      destination_port_range {
        min = 10
        max = 6489
      }
    }
  }
}

#BCOCI050002
resource "oci_core_security_list" "bastion_3389" {
  ingress_security_rules {
    source   = "10.10.10.0/32"
    protocol = "tcp" 
    tcp_options {
      destination_port_range {
        min = 3389
        max = 3389
      }
    }
  }
}

resource "oci_core_security_list" "bastion_all" {
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "tcp" 
    tcp_options {
      destination_port_range {
        min = 0
        max = 6543
      }
    }
  }
}

#BCOCI050003
resource "oci_core_network_security_group" "example_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "example-nsg"
}

resource "oci_core_network_security_group_security_rule" "pass" {
  network_security_group_id = oci_core_network_security_group.example_nsg.id
  direction = "INGRESS"
  protocol = "all"
  source = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = 1
      min = 6543
    }
  }
}

#BCOCI050004
resource "oci_core_network_security_group" "example_nsg_123" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "example-nsg"
}

resource "oci_core_network_security_group_security_rule" "pass_123" {
  network_security_group_id = oci_core_network_security_group.example_nsg.id
  direction = "INGRESS"
  protocol = "tcp"
  source = "10.0.0.0/32"
  tcp_options {
    destination_port_range {
      max = 0
      min = 6543
    }
  }
}
