$configKeys = [array] @('WEB_URL', 'SERVER_RELATIVE_PATH', 'USERNAME', 'APP_PASSWORD')

function ReadConfigFile {
    param ([Parameter(Mandatory)][string] $Path)

    try {
        if (!(Test-Path -Path $Path)) {
            throw "Config file not exist: $Path"
        }

        $content = [array](Get-Content -Path $Path -Encoding UTF8)
        $results = ValidateConfig -Data $content -Keys $configKeys
        return $results;
    } catch {
        WriteLog "debug" "Error occur in 'ReadConfigFile' function";
        throw ($Error);
    }
}
