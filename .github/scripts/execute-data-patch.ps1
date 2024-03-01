# Thiết lập các thông tin cần thiết
$siteUrl = "https://cmcglobalcompany.sharepoint.com"
$libraryName = "Documents"
$folderPath = "/Test_Upload_File/Evd"
$localFolderPath = "C:\Users\nxy\Documents\Documents_NXY\Folder-test"

# Đường dẫn tới thư viện CSOM (Client Side Object Model) của SharePoint
Add-Type -Path "C:\Path\To\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Path\To\Microsoft.SharePoint.Client.Runtime.dll"

# Tạo đối tượng ClientContext
$credentials = Get-Credential
$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
$context.Credentials = $credentials

# Lấy thư mục đích trong SharePoint
$web = $context.Web
$folder = $web.GetFolderByServerRelativeUrl($folderPath)
$context.Load($folder)
$context.ExecuteQuery()

# Lấy danh sách tệp tin trong thư mục cục bộ
$fileNames = Get-ChildItem -Path $localFolderPath -Filter "*.txt" -File | Select-Object -ExpandProperty Name

# Đẩy các tệp tin lên SharePoint
foreach ($fileName in $fileNames) {
    $fileContent = [System.IO.File]::ReadAllBytes("$localFolderPath\$fileName")
    $fileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
    $fileCreationInfo.Content = $fileContent
    $fileCreationInfo.Overwrite = $true
    $fileCreationInfo.Url = "$folderPath/$fileName"
    $uploadFile = $folder.Files.Add($fileCreationInfo)
    $context.Load($uploadFile)
    $context.ExecuteQuery()

    Write-Host "File '$fileName' uploaded successfully."
}

$context.Dispose()