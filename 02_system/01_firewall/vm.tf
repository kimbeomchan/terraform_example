######################################################
## 본 모듈은 샘플 용도로 이미지는 Linux Image로 구성하였습니다. ##
######################################################

resource "azurerm_resource_group" "fw_rg" {
  name     = var.hub_fw_resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Firewall Virtual Machine 01
module "fw-linux-vm" {
  depends_on = [
    azurerm_resource_group.fw_rg
  ]

  source               = "../../modules/virtual_machine"
  virtual_machine_name = "hubfwlinux-vm-01"
  resource_group_name  = azurerm_resource_group.fw_rg.name
  location             = var.location
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  tags                 = var.tags

  ## Network Interface의 이름, 연결 할 Subnet 이름 및 ID 값을 작성
  network_interfaces = [
    {
      name        = "hubfwlinux-vm-untrusted-nic-01",
      subnet_name = var.untrusted_subnet_name,
      subnet_id   = data.azurerm_subnet.untrusted_subnet.id
    },
    {
      name        = "hubfwlinux-vm-trusted-nic-01",
      subnet_name = var.trusted_subnet_name,
      subnet_id   = data.azurerm_subnet.trusted_subnet.id
    }
  ]

  os_flavor                       = "linux"
  linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = "Standard_B2s"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  generate_admin_ssh_key          = true
  instances_count                 = 1
  vm_availability_zone            = 1

  # (선택) 프록시 배치 그룹, 가용성 집합 및 공용 IP
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = true
  enable_boot_diagnostics          = true

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # (선택) 애저 모니터링 활성화와 로그 어날리틱스 에이전트 설치 시 사용
  # (선택) 모니터링 로그를 스토리지 어카운트에 저장하려면 "storage_account_name" 추가 기입 필요
  /* log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id */

  # 로그 어날리틱스 에이전트를 가상머신에 배포 시 "true" 
  # 로그 어날리틱스 워크스페이스 "customer is"와 "primary shared key"가 요구됨
  /* deploy_log_analytics_agent                 = false */
  /* log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id */
  /* log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key */
}

# Create Firewall Virtual Machine 02
module "fw-linux-vm-02" {
  depends_on = [
    azurerm_resource_group.fw_rg
  ]

  source               = "../../modules/virtual_machine"
  virtual_machine_name = "hubfwlinux-vm-02"
  resource_group_name  = azurerm_resource_group.fw_rg.name
  location             = var.location
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  tags                 = var.tags

  network_interfaces = [
    {
      name        = "hubfwlinux-vm-untrusted-nic-02",
      subnet_name = var.untrusted_subnet_name,
      subnet_id   = data.azurerm_subnet.untrusted_subnet.id
    },
    {
      name        = "hubfwlinux-vm-trusted-nic-02",
      subnet_name = var.trusted_subnet_name,
      subnet_id   = data.azurerm_subnet.trusted_subnet.id
    }
  ]

  os_flavor                       = "linux"
  linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = "Standard_B2s"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  generate_admin_ssh_key          = true
  instances_count                 = 1
  vm_availability_zone            = 1

  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = true
  enable_boot_diagnostics          = true

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]
}
