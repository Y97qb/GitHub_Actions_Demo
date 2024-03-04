$Utf8BomEncoding = New-Object System.Text.UTF8Encoding $True;

function ConvertCsvToHash {
    param (
        [array] $Datas,
        [array] $KeyNames,
        [string] $KeyDelimiter = ''
    )
    $result = [hashtable]@{};
    foreach ($data in $Datas) {
        $keyDatas = [array]@();
        foreach ($keyName in $KeyNames) {
            $keyDatas += $data.$keyName;
        }
        $key = $keyDatas -join $KeyDelimiter;
        $result.add($key, $data);
    }
    return $result;
}

function GroupObject {
    param (
        [array] $Datas,
        [array] $Keys,
        [string] $KeyDelimiter = ''
    )
    $result = [hashtable]@{};
    foreach ($data in $Datas) {
        $keyDatas = [array]@();
        foreach ($key in $Keys) {
            $keyDatas += $data.$key;
        }
        $keyJoined = $keyDatas -join $KeyDelimiter;
        if ($result.ContainsKey($keyJoined)) {
            $result[$keyJoined] += $data;
        } else{
            $result[$keyJoined] = [array]@($data);
        }
    }
    return $result;
}

function GenerateFolderPath {
    param ([Parameter(Mandatory)][String] $Path)

    if (!(Test-Path -path $Path)) {
        $path = New-Item -ItemType directory -Path $Path;
    }
}

function QueryDatabase {
    param (
        [Parameter(Mandatory)][string] $Sql,
        [string] $Type = 'json'
    )

    if ($Type -eq 'csv') {
        $commandQuery = "sfdx force:data:soql:query --query `"$Sql`" --resultformat $Type -u $global:USERNAME";
        [void] (& { Invoke-Expression $commandQuery } 2>&1 | Tee-Object -Variable queryCommandOutput);

        if ($queryCommandOutput -and $queryCommandOutput -ne 'Your query returned no results.') {
            $queryCommandOutput = $queryCommandOutput | Where-Object { -not ([string]$_).Contains('Querying Data') }
            if (([string]$queryCommandOutput).StartsWith('ERROR')) {
                throw "(Response from server) $queryCommandOutput";
            }
            return $queryCommandOutput;
        }
        return [array]@();
    }

    $queryCommandOutput = sfdx force:data:soql:query --query "$Sql" --resultformat $Type -u $global:USERNAME;
    $jsonData = $queryCommandOutput | ConvertFrom-Json;
    if ($jsonData.status -ne 0) {
        throw "(Response from server) $queryCommandOutput";
    }
    return @($jsonData.result);
}

function ExportContentToCsv {
    param (
        [Parameter(Mandatory)][array] $Objects,
        [Parameter(Mandatory)][string] $FilePath
    )

    try {
        $csvData = $Objects | ConvertTo-Csv -NoTypeInformation;
        [System.IO.File]::WriteAllLines($FilePath, [string[]]$csvData, $Utf8BomEncoding);
    } catch {
        WriteLog 'debug' "Error occur in 'ExportContentToCsv' function";
        throw ($Error);
    }
}

function WriteLog($type, $text, $jptext) {
    $color = 'White';
    $content = '';
    switch ($type) {
        'info' { $color = 'Green' }
        'debug' { $color = 'Yellow' }
        'error' { $color = 'Red' }
        Default { $color = 'White' }
    }
    switch ($c_lang) {
        'en' { $content = $text }
        'jp' { if ($jptext) { $content = $jptext }else { $content = $text } }
        Default { $content = $text }
    }
    Write-Host (Get-Date -Format "yyyy/MM/dd HH:mm:ss |") ("[" + $type.ToUpper() + "] $content") -ForegroundColor $color;
}

function SFDXAuthenticate {
    param ([Parameter(Mandatory)][String] $AuthJsonPath)

    $authResult = @{
        success = $false
        message = ''
    }
    try {
        $authResponse = sfdx force:auth:sfdxurl:store -f $AuthJsonPath -s --json | ConvertFrom-Json;
        if ($authResponse.status -eq 0) {
            $global:ORG_INFO = $authResponse.result;
            $global:USERNAME = $authResponse.result.username;
            $authResult.success = $true;
            return $authResult;
        }
        $authResult.message = $authResponse.message;
    } catch {
        $authResult.message = $Error;
    }
    return $authResult;
}
