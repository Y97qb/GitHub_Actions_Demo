# Import SharePointPnPPowerShellOnline module
Import-Module -Name SharePointPnPPowerShellOnline

# SharePoint credentials
$tenantId = $env:TENANT_ID
$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET

# SharePoint site and file information
$siteUrl = "https://cmcglobalcompany.sharepoint.com/sites/Test_GitHubActions"
$libraryName = "Shared Documents"
$folderPath = "Test_Upload_File/Evd"  # Đường dẫn thư mục SharePoint
$filePath = "$env:GITHUB_WORKSPACE/aaaa.txt"  # Update with the actual file path

# Connect to SharePoint
$securePassword = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $securePassword
Connect-PnPOnline -Url $siteUrl -Credentials $credentials -ClientId $clientId -Tenant $tenantId

# Upload file to SharePoint
Add-PnPFile -Path $filePath -Folder $folderPath -List $libraryName -Connection $credentials

# Disconnect from SharePoint
Disconnect-PnPOnline