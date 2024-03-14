$zokuseiMeiMaxIndex = 50;

function GetCodeName {
    $codeNameHash = [hashtable]@{};
    $zokuseiMeiFields = [array]@();
    #-- Step 1.1: Create list zokuseiMei from 1 to 50
    for ($zokuseiMeiIndex = 1; $zokuseiMeiIndex -le $zokuseiMeiMaxIndex; $zokuseiMeiIndex++) {
        $zokuseiMeiFields += "ZokuseiMei$($zokuseiMeiIndex)__c";
    }
    $soql = "SELECT Name, $($zokuseiMeiFields -join ',') FROM Code__c WHERE Id IN (SELECT Code__c FROM RltdCode__c WHERE $fieldStatusObjectSource IN ($($statusList -join ',' )) AND Code__c != null)";
    $codeAllData = QueryDatabase -Sql $soql;
    $codeNameHash = ConvertCsvToHash $codeAllData.records @("Name") "";
    #-- Step 1.2: Get the zokuseiMei with the value for each CodeName
    $codeAllData.records | ForEach-Object {
        $codeName = $_.Name;
        $zokuseiMeiObject = $_ | Select-Object * -ExcludeProperty "attributes", "Name";
        $zokuseiMeiList = [string[]]@();
        #-- Step 1.3: Get the zokuseiMei with the value for each CodeName
        for ($zokuseiMeiIndex = 1; $zokuseiMeiIndex -le $zokuseiMeiMaxIndex; $zokuseiMeiIndex++) {
            $zokuseiMeiX = "ZokuseiMei$($zokuseiMeiIndex)__c";
            $zokuseiMeiValue = $zokuseiMeiObject.$zokuseiMeiX;
            if ($null -ne $zokuseiMeiValue) {
                $zokuseiMeiList += '"' + $($zokuseiMeiValue) + '"';
            } else {
                break;
            }
        }
        $headerValueHash[$codeName] = $zokuseiMeiList;
    }
    return $codeNameHash;
}

function GetCodeDetailDes {
    param ([Parameter(Mandatory)][hashtable[]] $CodeNameSourceHash)

    $codeNameHash = [hashtable]@{};
    $codeName = $CodeNameSourceHash.keys | ForEach-Object { "'$($_)'" };
    $zokuseiMeiFields = [array]@();
    for ($zokuseiMeiIndex = 1; $zokuseiMeiIndex -le $zokuseiMeiMaxIndex; $zokuseiMeiIndex++) {
        $zokuseiMeiFields += "Zokusei$($zokuseiMeiIndex)__c";
    }
    $soql = "SELECT CodeID__c, Code__c, Name, YukokikanKaishi__c, YukokikanShuryo__c, $($zokuseiMeiFields -join ', '), CodeID__r.Name FROM CodeDetail__c WHERE CodeID__r.Name IN ($($codeName -join ','))";
    $codeDetailAllData = QueryDatabase -Sql $soql;
    $codeListUnique = $codeDetailAllData.records | Select-Object -Unique "CodeID__r", "CodeID__c";
    # Group by CodeName
    $codeListUnique | ForEach-Object {
        $codeNameUnique = $_.CodeID__r.Name;
        $excludeProperties = [array]@('attributes', 'CodeID__r', 'CodeID__c');
        $zokuseiIndexCount = $headerValueHash[$codeNameUnique].Count;
        # Get zokuseiMei fields with no data to exclude
        for ($zokuseiMeiIndex = ($zokuseiIndexCount + 1); $zokuseiMeiIndex -le $zokuseiMeiMaxIndex; $zokuseiMeiIndex++) {
            $excludeProperties += "Zokusei$($zokuseiMeiIndex)__c";
        }
        # Get all fields with data for each CodeDetail
        $codeDetailData = $codeDetailAllData.records | Where-Object 'CodeID__c' -eq $_.CodeID__c | Select-Object * -ExcludeProperty $excludeProperties;
        $codeNameHash[$codeNameUnique] += $codeDetailData;
    }
    return $codeNameHash;
}
