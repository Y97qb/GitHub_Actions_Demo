Function UploadPnPFolder {
    param (
        [Parameter(Mandatory)] [string] $SourceFolderPath,
        [Parameter(Mandatory)] [string] $TargetFolder,
        [Parameter(Mandatory)] [string] $UserName,
        [Parameter(Mandatory)] [SecureString ] $AppPassword,
        [Parameter(Mandatory)] [string] $WebUrl,
        [Parameter(Mandatory)] [string] $EnvironmentFolder
    )
    try {
        # Setup Credentials to connect
        $Cred = New-Object System.Management.Automation.PSCredential ($UserName, $AppPassword);
        Add-PnPStoredCredential -Name $WebUrl -Username $Cred.UserName -Password $Cred.Password;
        Connect-PnPOnline $WebUrl -UseWebLogin;
        $targetEnvFolder = $TargetFolder + '/' + $EnvironmentFolder;
        WriteLog 'DEBUG' 'Uploading...';

        try {
            # Sharepoint online powershell delete folder
            Remove-PnPFolder -Name $EnvironmentFolder -Folder $TargetFolder -Force -Recycle -ErrorAction Stop;
            Add-PnPFolder -Name $EnvironmentFolder -Folder $TargetFolder -ErrorAction Stop;
        } catch {
            WriteLog 'DEBUG' "Folder  $EnvironmentFolder does not exist";
        }

        # Get All Files from a Local Folder
        $Files = Get-ChildItem -Path $SourceFolderPath -Force -Recurse;

        # Bulk upload files to sharepoint online using powershell
        WriteLog 'DEBUG' 'Uploading...';
        foreach ($File in $Files)
        {
            # Upload a file to sharepoint online using powershell - Upload File and Set Metadata
            Add-PnPFile -Path "$($File.Directory)\$($File.Name)" -Folder $targetEnvFolder -Values @{"Title" = $($File.Name)}
        }
        Disconnect-PnPOnline
    } catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
}
