chcp 65001

# ===========================================================
#                          MAIN SCRIPT
# ===========================================================

Start-Transcript -Path $logFile;
WriteLog 'debug' 'Execution - Start';
try {
    WriteLog 'debug' 'Initializing...';
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
