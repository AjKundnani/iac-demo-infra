// Recovery Services Vault and backup policy

param location string = resourceGroup().location

resource backupVault 'Microsoft.RecoveryServices/vaults@2024-04-01' = {
  name: 'rsv-${resourceGroup().name}'
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-01' = {
  parent: backupVault
  name: 'enhanced-vm-policy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    policyType: 'V2'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicyV2'
      scheduleRunFrequency: 'Hourly'
      hourlySchedule: {
        interval: 4
        scheduleWindowStartTime: '2024-01-01T08:00:00Z'
        scheduleWindowDuration: 16
      }
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: ['2024-01-01T08:00:00Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 5
  }
}
