provider "azurerm" {

  subscription_id = "c1bc2fcd-a809-4086-8763-1499cdf758fd"
  client_id       = "542fbf12-907c-4710-9245-1bea941abcd1"
  client_secret   = "N.S3x6P0z1Cd_xHokwoKosBg4W7~s_2E.c"
  tenant_id       = "2ce08630-4008-4367-b437-0a1accfe0c8d"

  features {}
}

# Create first resource group
resource "azurerm_resource_group" "Terraform-rg11" {
  name     = "${var.rgname11}"
  location = "${var.location}"
}

# Create a second resource group 
resource "azurerm_resource_group" "Terraform-rg22" {
  name     = "${var.rgname22}"
  location = "${var.location}"

  depends_on = [azurerm_storage_account.milestonesssss11]
}

#create first storage account
resource "azurerm_storage_account" "milestonesssss11" {
  name                     = "${var.storageacc1}"
  resource_group_name      = azurerm_resource_group.Terraform-rg11.name
  location                 = azurerm_resource_group.Terraform-rg11.location
  account_tier             = "${var.tier}"
  account_replication_type = "${var.replication}"

  tags = {
    environment = "staging"
  }
}

#create second storage account

resource "azurerm_storage_account" "milestonesssss22" {
  name                     = "${var.storageacc2}"
  resource_group_name      = azurerm_resource_group.Terraform-rg22.name
  location                 = azurerm_resource_group.Terraform-rg22.location
  account_tier             = "${var.tier}"
  account_replication_type = "${var.replication}"

  tags = {
    environment = "staging"
  }
}




resource "azurerm_network_security_group" "terraform-ng11" {
  name                = "terraform-ng11"
  location            = azurerm_resource_group.Terraform-rg11.location
  resource_group_name = azurerm_resource_group.Terraform-rg11.name
}







resource "azurerm_virtual_network" "avn" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.Terraform-rg11.location
  resource_group_name = azurerm_resource_group.Terraform-rg11.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

}
  resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.Terraform-rg11.name
  virtual_network_name = azurerm_virtual_network.avn.name
  address_prefix       = "10.0.2.0/24"
}

  









resource "azurerm_network_interface" "ani-nic" {
  name                = "ani-nic"
  location            = azurerm_resource_group.Terraform-rg11.location
  resource_group_name = azurerm_resource_group.Terraform-rg11.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "Terraform-rg11" {
  name                  = "terraformvm1"
  location              = azurerm_resource_group.Terraform-rg11.location
  resource_group_name   = azurerm_resource_group.Terraform-rg11.name
  network_interface_ids = [azurerm_network_interface.ani-nic.id]
  vm_size               = "Standard_B1ms"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "TerraformVM1"
    admin_username = "x950450"
    admin_password = "Silver@123456789"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}



terraform {
  backend "azurerm" {
    resource_group_name  = "Devopsweekend"
    storage_account_name = "tololing"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}


