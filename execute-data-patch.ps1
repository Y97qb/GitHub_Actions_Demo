$rootPath = Split-Path $script:MyInvocation.MyCommand.Path
$modulePath = Join-Path -Path $rootPath -ChildPath "module"
Install-Module -Name SharePointPnPPowerShellOnline -Force

Import-Module (Join-Path -Path $modulePath -ChildPath "CommonFunction") -Global
Import-Module (Join-Path -Path $modulePath -ChildPath "UniqueFunction") -Global
Import-Module (Join-Path -Path $modulePath -ChildPath "ValidateInput") -Global
Import-Module (Join-Path -Path $modulePath -ChildPath "ReadInputFile") -Global
Import-Module (Join-Path -Path $modulePath -ChildPath "UploadPnPFolder") -Global
$inputPath = Join-Path -Path $rootPath -ChildPath "input"
$configSharepointPath = Join-Path -Path $inputPath -ChildPath "configSharePoint.txt"
$global:ORG_INFO
$global:USERNAME
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$sourceFolderPath = 'C:\Users\nxy\Documents\Documents_NXY\Folder_test\index1.txt'
$environmentFolder = "cmc_test"
$config = ReadConfigFile -Path $configSharepointPath
$targetFolder = "https://cmcglobalcompany.sharepoint.com/sites/Test_GitHubActions/Shared%20Documents/Test_Upload_File/Evd"
$userName = $config.USERNAME
$appPassword = $config.APP_PASSWORD
$webUrl = $config.WEB_URL

$appPasswordSecure = ConvertTo-SecureString $appPassword -AsPlainText -Force
UploadPnPFolder -SourceFolderPath $sourceFolderPath -TargetFolder $targetFolder -UserName $userName -AppPassword $appPasswordSecure -WebUrl $webUrl -EnvironmentFolder $environmentFolder;