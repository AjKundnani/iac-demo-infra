// Non-resilient VMSS — no zones configured
// This should trigger VMSS zone findings

param location string = resourceGroup().location
param vmssName string = 'vmss-prod-api'
param adminUsername string = 'azureuser'

@secure()
param adminPassword string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: vmssName
  location: location
  sku: {
    name: 'Standard_D4s_v5'
    tier: 'Standard'
    capacity: 3
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Rolling'
      rollingUpgradePolicy: {
        maxBatchInstancePercent: 20
        maxUnhealthyInstancePercent: 20
        maxUnhealthyUpgradedInstancePercent: 5
        pauseTimeBetweenBatches: 'PT0S'
      }
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPassword
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
            storageAccountType: 'Premium_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${vmssName}-nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-api'
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
  tags: {
    environment: 'production'
    application: 'api-backend'
  }
}
