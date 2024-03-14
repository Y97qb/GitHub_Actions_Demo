function ValidateConfig {
    param (
        [array] $Data,
        [array] $Keys
    )

    if (!$Data) {
        throw "Config file is empty";
    }

    $dataValidated = [hashtable]@{};
    $Data | ForEach-Object {
        $lineData = $_;
        $firstIndexEqualCharacter = $lineData.IndexOf("=");
        if ($firstIndexEqualCharacter -lt 1) {
            throw "Config file format not valid";
        }

        $lineSplit = $lineData -split "="
        if ($lineSplit.count -lt 2) {
            throw "Config file format not valid"
        }

        if (!$lineSplit[0]) {
            throw "Config file format not valid: Key is not empty"
        }

        $key = $lineData.SubString(0, $firstIndexEqualCharacter);

        $remainStringIndex = $firstIndexEqualCharacter + 1;
        $value = $lineData.SubString($remainStringIndex, ($lineData.length - $remainStringIndex));

        $dataValidated[$key] = $value;
    }

    $misingKeys = [array]@();
    for ($i = 0; $i -lt $Keys.count; $i++) {
        $keyName = $Keys[$i]
        $value = $dataValidated[$keyName];
        if (!$value) {
            $misingKeys += $keyName;
        }
    }
    if ($misingKeys) {
        $misingKeyJoined = $misingKeys -join ",";
        throw "$misingKeyJoined がまだ入力されていない。";
    }

    return $dataValidated;
}
