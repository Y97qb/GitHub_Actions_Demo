$modulePath = "C:\Users\nxy\Documents\Documents_NXY\Folder-test\SharePointPnPPowerShellOnline"

# Import module SharePointPnPPowerShellOnline
Import-Module -Name $modulePath

# Thông tin xác thực SharePoint
$siteUrl = "https://cmcglobalcompany.sharepoint.com/sites/Test_GitHubActions"
$username = "Sbtmaff2024"
$password = "cxpzlmmkysyqbffr"

# Đường dẫn tới tệp tin cần tải lên
$filePath = "C:\Users\nxy\Documents\Documents_NXY\Folder-test\aaaa.txt"

# Đường dẫn tới thư mục trong SharePoint để lưu tệp tin
$destinationFolderUrl = "/Shared Documents/Test_Upload_File/Evd"

# Tạo kết nối đến SharePoint
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
Connect-PnPOnline -Url $siteUrl -Credentials $credentials

# Tải lên tệp tin
Add-PnPFile -Path $filePath -Folder $destinationFolderUrl -ErrorAction Stop

# Đóng kết nối đến SharePoint
Disconnect-PnPOnline

Write-Host "File uploaded successfully."