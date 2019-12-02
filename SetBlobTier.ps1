# This script requres Powershell 5 due to use of Out-GridView

# This script will move to Archive storage all blobs within a container

Import-Module Az.Storage
Import-Module Az.Resources

#login to your account
Connect-AzAccount

$ResourceGroupName = (Get-AzResourceGroup| Out-GridView -Title "Select Resource Group" -PassThru).ResourceGroupName

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Out-GridView -Title "Select Storage Account" -PassThru 

$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccount.StorageAccountName)[0].Value

$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $StorageAccountKey

$ContainerName = (Get-AzStorageContainer -Context $ctx | Out-GridView -Title "Select Storage Container" -PassThru).name

#select all blobs that are not already in Archive
$blobs = Get-AzStorageBlob -container $ContainerName -Context $StorageContext | 
			Where-Object{$_.icloudblob.Properties.StandardBlobTier -ne 'Archive'}

$blobs.ICloudBlob.SetStandardBlobTier("Archive")
 