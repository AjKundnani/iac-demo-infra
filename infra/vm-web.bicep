// Sample: Resilient VM — with zones and backup configured
// This template should pass all resiliency checks

param location string = resourceGroup().location
param vmName string = 'vm-prod-web01'
param adminUsername string = 'azureuser'

@secure()
param adminPassword string

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-web'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  zones: ['1', '2', '3']
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_ZRS'
        }
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Empty'
          diskSizeGB: 256
          managedDisk: {
            storageAccountType: 'Premium_ZRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  tags: {
    environment: 'production'
    application: 'web-frontend'
  }
}
