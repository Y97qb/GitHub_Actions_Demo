$siteUrl = "https://cmcglobalcompany.sharepoint.com/sites/Test_GitHubActions"
$username = "Sbtmaff2024"
$password = "cxpzlmmkysyqbffr"
$filePath = "C:\Users\nxy\Documents\Documents_NXY\Folder-test\aaaa.txt"
$destinationFolderUrl = "/sites/Test_GitHubActions/Shared Documents/Test_Upload_File/Evd"

# Tạo kết nối đến SharePoint
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

# Tạo web request để tải lên tệp tin
$webRequest = [System.Net.WebRequest]::Create("$siteUrl/_api/web/GetFolderByServerRelativeUrl('$destinationFolderUrl')/Files/Add(url='aaaa.txt', overwrite=true)")
$webRequest.Credentials = $credentials.GetNetworkCredential()
$webRequest.Method = "POST"
$webRequest.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
$webRequest.Headers.Add("binaryStringRequestBody", "true")
$webRequest.ContentType = "application/octet-stream"
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$webRequest.ContentLength = $fileBytes.Length
$requestStream = $webRequest.GetRequestStream()
$requestStream.Write($fileBytes, 0, $fileBytes.Length)
$requestStream.Close()

# Gửi yêu cầu và nhận phản hồi từ SharePoint
$response = $webRequest.GetResponse()
$response.Close()

Write-Host "File uploaded successfully."