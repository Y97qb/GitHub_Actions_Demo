# Import module
Import-Module -Name Microsoft.Graph.GraphRequests.Authentication

# Khởi tạo các thông tin xác thực
$clientId = "1e291fa4-039d-41eb-9595-0f38c9ad3f56"
$clientSecret = "pn08Q~9jUjddG2bpnPp4sOsIno9B1ZYoV~a.Mbdc"
$tenantId = "f89c1178-4c5d-43b5-9f3b-d21c3bec61b5"

# Khởi tạo token
$token = Get-MgAccessToken -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId

# Thay thế các giá trị sau đây bằng thông tin của bạn
$siteUrl = "https://cmcglobalcompany.sharepoint.com/:f:/r/sites/Test_GitHubActions"
$filePath = "C:\Users\nxy\Documents\Documents_NXY\Folder-test\aaaa.txt"

# Trích xuất siteId
$siteId = ($siteUrl -split "/sites/")[1]

# Trích xuất driveId và folderPath
$pathParts = ($siteUrl -split "/:f:/")[1] -split "/"
$driveId = $pathParts[0]
$folderPath = $pathParts[1..($pathParts.Length - 2)] -join "/"

# Đọc nội dung file
$fileContent = Get-Content -Path $filePath -RawContent 

# Tạo URL upload file
$uploadUrl = "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/$folderPath/FileName.ext:/content"

# Upload file
$response = Invoke-RestMethod -Uri $uploadUrl -Headers @{Authorization = "Bearer $($token.access_token)"} -Method Put -ContentType "text/plain" -Body $fileContent

# Kiểm tra kết quả
if ($response.id) {
    Write-Output "File uploaded successfully."
} else {
    Write-Output "File upload failed."
}