chcp 65001

$rootPath = Split-Path $script:MyInvocation.MyCommand.Path
Import-Module "$rootPath\module\CommonFunction" -Global;
Import-Module "$rootPath\module\UniqueFunction" -Global;
Import-Module "$rootPath\module\ValidateInput" -Global;
Import-Module "$rootPath\module\ReadInputFile" -Global;
Import-Module "$rootPath\module\UploadPnPFolder" -Global;

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false;
$datetimePathFormat = Get-Date -Format 'yyyyMMddHHmmss';
$inputPath = "$rootPath\input\";
$sourceAuthPath = "$($inputPath)source\sourceAuth.txt";
$destinationAuthPath = "$($inputPath)destination\";
$configSharepointPath = "$($inputPath)configSharePoint.txt";
$outputPath = "$rootPath\output\";
$logPath = "$($outputPath)log\";
$logFile = "$($logPath)log_$datetimePathFormat.txt";
$global:ORG_INFO;
$global:USERNAME;
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding;
$global:queryAll = $true;
# Progress
$global:fieldStatusObjectSource = 'ElctrcPrcdr__r.sinchoku__c';
$global:statusList = [array]@("'071'","'072'", "'078'","'100'");
# List values of zokusei in CodeName
$global:headerValueHash = [hashtable]@{};
$filesUpload = [hashtable]@{};

# ===========================================================
#                          MAIN SCRIPT
# ===========================================================
Start-Transcript -Path $logFile;
WriteLog 'debug' 'Execution - Start';

try {
    WriteLog 'debug' 'Initializing...';
    $authSourceOrgResult = SFDXAuthenticate $sourceAuthPath;
    if ($authSourceOrgResult.success -eq $false) {
        WriteLog 'error' 'Cannot connect to Source org.';
        throw $($authSourceOrgResult.message);
    }
    Get-ChildItem -Path "$outputPath\*.csv" -Recurse | Remove-Item;
    GenerateFolderPath -Path $outputPath;

    WriteLog 'debug' 'Querying data from Code__c';
    #-- Step 1: Get CodeName in Source org
    $codeSourceHash = GetCodeName
    if ($codeSourceHash.keys.count -le 0) {
        WriteLog 'debug' 'No data found.';
        WriteLog 'debug' 'Execution - End';
        Stop-Transcript;
        Exit;
    }
    #-- End Step1
    $destinationAuthFiles =  Get-ChildItem -Path $destinationAuthPath -File -Recurse;
    $destinationAuthFiles | ForEach-Object {
        $destAuthPath = $_.FullName;
        $destinationAuthName = $_.Name;
        #-- Step 2: Create output folderName for each environment
        if ($_.Name.Contains('SH')) {
            $destinationAuthName = 'SH環境';
        } elseif ($_.Name.Contains('PRD')) {
            $destinationAuthName = '本番環境';
        }
        $environmentPath = $outputPath + "$destinationAuthName\";
        GenerateFolderPath -Path $environmentPath;
        #-- End Step2

        WriteLog 'info' "Connect to Destination $destinationAuthName org.";

        $authDestinationOrgResult = SFDXAuthenticate $destAuthPath;
        if ($authDestinationOrgResult.success -eq $false) {
            WriteLog 'error' "Cannot connect to Destination $destinationAuthName org.";
            throw $($authDestinationOrgResult.message);
        }

        #-- Step 3: Get data CodeDetail of CodeName in destination org
        $codeDetailDesHash = GetCodeDetailDes -CodeNameSourceHash $codeSourceHash;
        if ($codeDetailDesHash.keys.count -gt 0) {
            $codeSourceHash.keys | ForEach-Object {
                $codeName = $_;
                #-- Step 3.1: Get data CodeDetail of each CodeName
                if ($codeDetailDesHash.ContainsKey($codeName)) {
                    #-- Step 3.2: Create file for CodeName
                    $codeNamePath = $($environmentPath + "$codeName.csv");
                    $codeDetailData = $codeDetailDesHash[$codeName];
                    ExportContentToCsv -Objects $codeDetailData -FilePath $codeNamePath;

                    #-- Step 3.3: Get content file to replace header
                    $csvLines = Get-Content $codeNamePath;
                    #-- Step 3.4 Create headers in the order of fields in the query
                    $csvHeaders = [array]@('"コード"', '"名称"', '"有効期間（開始）"', '"有効期間（終了）"');
                    $csvHeaders += $headerValueHash[$codeName];
                    $csvLines[0] = $csvHeaders -join ',';
                    #-- Step 3.5:  Replace data
                    [System.IO.File]::WriteAllLines($codeNamePath, $csvLines, $Utf8NoBomEncoding)
                    $filesUpload[$environmentPath] = $destinationAuthName;
                }
            }
        } else {
            WriteLog 'debug' "Code__c on $destinationAuthName not data.";
        }
        #-- End Step3
    }
    if ($filesUpload.keys.count -gt 0) {
        #-- Step 4: Upload files for each environment
        $filesUpload.keys | ForEach-Object {
            $sourceFolderPath = $_;
            $environmentFolder = $filesUpload[$sourceFolderPath];
            $config = ReadConfigFile -Path $configSharepointPath;
            $targetFolder = $config.SERVER_RELATIVE_PATH;
            $userName = $config.USERNAME;
            $appPassword = $config.APP_PASSWORD;
            $webUrl = $config.WEB_URL;

            $appPasswordSecure = ConvertTo-SecureString $appPassword -AsPlainText -Force;
            UploadPnPFolder -SourceFolderPath $sourceFolderPath -TargetFolder $targetFolder -UserName $userName -AppPassword $appPasswordSecure -WebUrl $webUrl -EnvironmentFolder $environmentFolder;
        }
        #-- End Step4
    }
} catch {
    WriteLog 'error' ("Detail: " + $Error);
}

WriteLog 'debug' 'Execution - End';
Stop-Transcript;
