function kan {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "CompleteTask")]
        [Alias("c")]
        [switch]
        $CompleteTask

    )
    # DynamicParam {
    #     $NameParam = New-RuntimeDefinedParameter `
    #         -ParameterName "Name" `
    #         -ValidateSetGetterScriptBlock { (Get-PSTask).Name }

    #     $IdParam = New-RuntimeDefinedParameter `
    #         -ParameterName "Id" `
    #         -ValidateSetGetterScriptBlock { (Get-PSTask).Id }

    #     Export-RuntimeDefinedParameterDictionary -RuntimeDefinedParameters $NameParam, $IdParam
    # }

    # begin {
    #     $Name = $PsBoundParameters["Name"]
    #     $Id = $PsBoundParameters["Id"]
    # }
    process {
        # Initialize-PSTasks

        # $Data = Get-PSTasksData

        # if (
        #     ($PsCmdlet.ParameterSetName -eq "CompleteTask") `
        #         -or `
        #     ($PsCmdlet.ParameterSetName -eq "GetTask")
        # ) {
        #     if ($Id) {
        #         $Task = $Data.Tasks | Where-Object { $_.Id -eq $Id }
        #     }
        #     elseif ($Name) {
        #         $Task = $Data.Tasks | Where-Object { $_.Name -eq $Name }
        #     }
        #     else { throw "Please provide an Id or a Name of a task."; break }
        # }

        switch ($PsCmdlet.ParameterSetName) {
            "CompleteTask" { $Task.Status = "Completed"; Write-Host "Completed '[$($Task.Id)] $($Task.Name)'." }
            default {
                Draw-KanBoard -Columns @("New", "Old", "Completed") -ColumnItems @(
                    @{
                        Status = "New"
                        Id     = 1
                        Name   = "Get the milk"
                    },
                    @{
                        Status = "New"
                        Id     = 2
                        Name   = "Get the eggs"
                    },
                    @{
                        Status = "Old"
                        Id     = 3
                        Name   = "Make some money"
                    },
                    @{
                        Status = "New"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    },
                    @{
                        Status = "Weird"
                        Id     = 3
                        Name   = "Be a BOSSSSSSS"
                    }
                )
            }
        }
    }
}

function Draw-KanBoard {
    [CmdletBinding()]
    param (
        $Columns,
        $ColumnItems
    )
    Clear-Host

    $HDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02550", 16))
    $VDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02551", 16))
    $ULDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02554", 16))
    $URDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02557", 16))
    $LLDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("0255A", 16))
    $LRDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("0255D", 16))
    $TDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02566", 16))
    $ITDL = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("02569", 16))
    
    # $Data = Get-PSTasksData

    $ColumnsHashTables = @()

    foreach ($Column in $Columns) {
        $ColumnsHashTables += @{
            Name       = $Column
            NameLength = $Column.Length
            Width      = (($ColumnItems | Where-Object { $_.Status -eq $Column }).Name | Measure-Object -Maximum -Property Length).Maximum `
                ? ((($ColumnItems | Where-Object { $_.Status -eq $Column }).Name | Measure-Object -Maximum -Property Length).Maximum) `
                : 16
        }
    }

    $ColumnTitlesTopLine = "$ULDL"; $ColumnsHashTables | ForEach-Object { $ColumnTitlesTopLine += "$($HDL * ($_.Width))$TDL" }; $ColumnTitlesTopLine = $ColumnTitlesTopLine.TrimEnd($TDL); $ColumnTitlesTopLine += "$URDL"

    $ColumnTitlesMiddleLine = "$VDL"
    foreach ($Column in $ColumnsHashTables) {
        $ColumnTitlesMiddleLine += "$(PadForCenterAlign $Column.Name $Column.Width)$VDL"
    }

    $ColumnTitlesBottomLine = "$LLDL"; $ColumnsHashTables | ForEach-Object { $ColumnTitlesBottomLine += "$($HDL * ($_.Width))$ITDL" }; $ColumnTitlesBottomLine = $ColumnTitlesBottomLine.TrimEnd($ITDL); $ColumnTitlesBottomLine += "$LRDL"

    # $(foreach ($C in $Columns) { (($ColumnItems | Where-Object { $_.Status -eq $C })).Occurrences })

    $ItemsLinesToDraw = $(foreach ($C in $Columns) { ($ColumnItems | Where-Object { $_.Status -eq $C }).Length }) | Sort-Object -Descending | Select-Object -First 1
    $ListsOfItemsListsToDraw = @()
    
 
    Write-Host @"
$ColumnTitlesTopLine
$ColumnTitlesMiddleLine
$ColumnTitlesBottomLine
"@
}

function New-PSTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $TaskName,
    
        [Parameter()]
        [string]
        $Status = "New",

        [Parameter()]
        [int]
        $Priority = 5
    )
    
    Initialize-PSTasks
    
    $Data = Get-PSTasksData

    $NewTask = [PSCustomObject]@{
        Id          = $Data.LastId + 1
        Status      = $Status
        Name        = $TaskName
        SnoozeUntil = $null
        Priority    = $Priority
    }

    $Data.Tasks += $NewTask
    $Data.LastId = $Data.LastId + 1

    $Data | Set-PSTasksData

    $NewTask | Format-List
}

function Get-PSTask {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $ShowCompleted,

        [Parameter()]
        [string[]]
        $Properties
    )

    Initialize-PSTasks

    if ($Properties) { $Properties = $Properties + @("id") }

    $Tasks = (Get-PSTasksData).tasks

    if (!$ShowCompleted) { $Tasks = $Tasks | Where-Object { $_.Status -ne "Completed" } }

    if ($Tasks.Count -gt 0) { $Tasks }
    else { Write-Host "There are no tasks to display." }    
}

function Remove-PSTask {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "All")]
        [switch]
        $All
    )

    DynamicParam {
        $NameParam = New-RuntimeDefinedParameter `
            -ParameterName "Name" `
            -ValidateSetGetterScriptBlock { (Get-PSTask).Name } `
            -Mandatory `
            -ParameterSetName "ByName"

        $IdParam = New-RuntimeDefinedParameter `
            -ParameterName "Id" `
            -ValidateSetGetterScriptBlock { (Get-PSTask).Id } `
            -Mandatory `
            -ParameterSetName "ById"

        Export-RuntimeDefinedParameterDictionary -RuntimeDefinedParameters $NameParam, $IdParam
    }

    begin {
        $Name = $PsBoundParameters["Name"]
        $Id = $PsBoundParameters["Id"]
    }

    process {
        Initialize-PSTasks

        $Data = Get-PSTasksData

        switch ($PsCmdlet.ParameterSetName) {
            "All" {
                $Response = Invoke-UserPromptWithInputLoopUntilSuccess `
                    -PromptText "Are you sure you want to remove all tasks?" `
                    -LimitResponses

                if ($Response -eq "y") {
                    $Data.Tasks = @()
                }
            }
            "ByName" { $Data.Tasks = $Data.Tasks | Where-Object { $_.Name -ne $Name }; Write-Host "Removed task '$Name'." }
            "ById" { $Data.Tasks = $Data.Tasks | Where-Object { $_.Id -ne $Id }; Write-Host "Removed task with id '$Id'." }
        }

        $Data | Set-PSTasksData
    }
}

function Set-PSTask {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        [ValidateSet("Complete")]
        $ChangeToMake
    )

    DynamicParam {
        $NameParam = New-RuntimeDefinedParameter `
            -ParameterName "Name" `
            -ValidateSetGetterScriptBlock { (Get-PSTask).Name } `
            -Mandatory `
            -ParameterSetName "ByName"

        $IdParam = New-RuntimeDefinedParameter `
            -ParameterName "Id" `
            -ValidateSetGetterScriptBlock { (Get-PSTask).Id } `
            -Mandatory `
            -ParameterSetName "ById"

        Export-RuntimeDefinedParameterDictionary -RuntimeDefinedParameters $NameParam, $IdParam
    }

    begin {
        $Name = $PsBoundParameters["Name"]
        $Id = $PsBoundParameters["Id"]
    }

    process {
        Initialize-PSTasks

        $Data = Get-PSTasksData

        $Task = switch ($PsCmdlet.ParameterSetName) {
            "ByName" {
                $Data.Tasks | Where-Object { $_.Name -eq $Name }
            }
            "ById" { $Data.Tasks | Where-Object { $_.Id -eq $Id } }
        }
    
        switch ($ChangeToMake) {
            "Complete" { $Task.Status = "Completed"; Write-Host "Completed '[$($Task.Id)] $($Task.Name)'." }
            "Remove" {}
        }

        $Data | Set-PSTasksData
    }
}

function Initialize-PSTasks {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Force
    )
    # if (
    #     (!(Get-ItemPropertyValue -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "IsInitialized")) `
    #         -or `
    #     ($Force)
    # ) {
    #     Write-Host "Initializing PSTasks..."

    #     if (!(Test-Path "HKCU:\Software\com.bellbellbell")) { New-Item -Force -Path "HKCU:\Software\com.bellbellbell" }
    #     if (!(Test-Path "HKCU:\Software\com.bellbellbell\PSTasks")) { New-Item -Force -Path "HKCU:\Software\com.bellbellbell\PSTasks" }
    
    #     $PSTasksJsonPath = $false
    #     $PSTasksJsonPath = Get-ItemPropertyValue -ErrorAction Ignore -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "PSTasksJsonPath"
    
    #     if ($PSTasksJsonPath) {
    #         if (!(Test-Path $PSTasksJsonPath)) {
    #             $response = Invoke-UserPromptWithInputLoopUntilSuccess `
    #                 -PromptText "It looks like you have previously setup a pstasks.json file at the path '$PSTasksJsonPath'. However, there doesn't seem to be any pstasks.json file there currently. Should it be re-created at this location?" `
    #                 -LimitResponses
    
    #             if ($response -eq "n") {
    #                 $response = Invoke-UserPromptWithInputLoopUntilSuccess `
    #                     -PromptText "Enter the full path of where you want to create the json file (including the filename ending in .json)" `
    #                     -AllowAnyResponse `
    #                     -ConfirmResponse
    #                 $PSTasksJsonPath = $response
    #             }
    #         }
    #     }
    #     elseif (!$PSTasksJsonPath) {
    #         $response = Invoke-UserPromptWithInputLoopUntilSuccess `
    #             -PromptText "It looks like you have not setup a pstasks.json file yet. Would you like to create one in your home directory?" `
    #             -LimitResponses
    
    #         if ($response -eq "y") {
    #             New-Item -Force -Path "Env:\PSTasksTaskFilePath" -Value "$env:USERPROFILE\pstasks.json"
    #             $PSTasksJsonPath = "$env:USERPROFILE\pstasks.json"
    #         }
    #         elseif ($response -eq "n") {
    #             $response = Invoke-UserPromptWithInputLoopUntilSuccess `
    #                 -PromptText "Enter the full path of where you want to create the json file (including the filename ending in .json)" `
    #                 -AllowAnyResponse `
    #                 -ConfirmResponse
    
    #             $PSTasksJsonPath = $response
    #         }
    #     }
    
    #     if (!(Test-Path -Path $PSTasksJsonPath)) { Copy-Item -Force -Path "$PSScriptRoot\pstasks.json.template" -Destination $PSTasksJsonPath | Out-Null }
    #     Set-ItemProperty -Force -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "PSTasksJsonPath" -Type String -Value $PSTasksJsonPath | Out-Null
    #     Set-ItemProperty -Force -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "IsInitialized" -Value "$true" | Out-Null
    # }
}

function Invoke-UserPromptWithInputLoopUntilSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $PromptText,

        [Parameter()]
        [string]
        $FailedText = "Error with that response. Please try again!",

        [Parameter(Mandatory = $true, ParameterSetName = "LimitedResponses")]
        [switch]
        $LimitResponses,

        [Parameter(ParameterSetName = "LimitedResponses")]
        [string[]]
        $ValidPromptResponses = @("y", "n"),

        [Parameter(Mandatory = $true, ParameterSetName = "AnyResponse")]
        [switch]
        $AllowAnyResponse,

        [Parameter()]
        [switch]
        $ConfirmResponse
    )

    $IsResponseConfirmed = $false
    $Success = $false
    $ProvidedResponse = ""

    while (!$IsResponseConfirmed) {
        while (!$Success) {
            $ProvidedResponse = Read-Host -Prompt "$PromptText$($LimitResponses ? " ($($ValidPromptResponses -join ', '))" : '')"
            
            if ($LimitResponses) { ($ProvidedResponse -in $ValidPromptResponses) ? $($Success = $true) : $($Success = $false) }
            elseif ($AllowAnyResponse) { ($ProvidedResponse) ? $($Success = $true) : $($Success = $false) }
    
            if (!$Success) { if ($FailedText) { Write-Host -Object $FailedText -ForegroundColor Red } }
        }

        if ($ConfirmResponse) {
            $IsValidConfirmationQuestionResponse = $false
            $ConfirmationQuestionResponse = ""
            $ValidConfirmationQuestionsResponses = @("y", "n")
            while (!$IsValidConfirmationQuestionResponse) {
                $ConfirmationQuestionResponse = Read-Host -Prompt "Is the provided response '$ProvidedResponse' correct? (y or n)"
                if ($ConfirmationQuestionResponse -in $ValidConfirmationQuestionsResponses) { $IsValidConfirmationQuestionResponse = $true }
            }
            if ($ConfirmationQuestionResponse -eq "y") { $IsResponseConfirmed = $true } elseif ($ConfirmationQuestionResponse -eq "n") { $IsResponseConfirmed = $false }
        }
        elseif (!$ConfirmResponse) { $IsResponseConfirmed = $true }
    }
    return $ProvidedResponse
}

# function Get-PSTasksData {
#     return ConvertFrom-Json -InputObject (Get-Content -Path $(Get-ItemPropertyValue -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "PSTasksJsonPath") | Out-String) 
# }

# function Set-PSTasksData {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory, ValueFromPipeline)]
#         [PSCustomObject]
#         $ConfigObject
#     )

#     Set-Content -Value (ConvertTo-Json $ConfigObject) -Path $(Get-ItemPropertyValue -Path "HKCU:\Software\com.bellbellbell\PSTasks" -Name "PSTasksJsonPath")
# }

function New-RuntimeDefinedParameter {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    param (
        [Parameter(Mandatory)]
        [string]
        $ParameterName,

        [Parameter(Mandatory)]
        [scriptblock]
        $ValidateSetGetterScriptBlock,

        [Parameter()]
        [switch]
        $Mandatory,

        [Parameter()]
        [string]
        $ParameterSetName
    )
    $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
    if ($Mandatory) { $ParameterAttribute.Mandatory = $true } else { $ParameterAttribute.Mandatory = $false }
    if ($ParameterSetName) { $ParameterAttribute.ParameterSetName = $ParameterSetName }

    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    $AttributeCollection.Add($(New-Object System.Management.Automation.ValidateSetAttribute($ValidateSetGetterScriptBlock.Invoke())))
    $AttributeCollection.Add($ParameterAttribute)

    return [PSCustomObject]@{
        Name      = $ParameterName
        Parameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
    }
}

function Export-RuntimeDefinedParameterDictionary {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]

    param (
        [Parameter(Mandatory)]
        [PSCustomObject[]]
        $RuntimeDefinedParameters
    )
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    foreach ($RP in $RuntimeDefinedParameters) { $RuntimeParameterDictionary.Add($RP.Name, $RP.Parameter) }
    return $RuntimeParameterDictionary
}

function IsEven($number) { return $number % 2 -eq 0 }
function MakeEvenAddOne($number) { if (IsEven($number)) { $number } else { $number + 1 } }
function PadForCenterAlign([string]$Text, $Width) {
    $LeftWhiteSpace = ($Width - $Text.Length) * 0.5
    $RightWhiteSpace = ($Width - $Text.Length) * 0.5; 
    if ((($Width - $Text.Length) % 2 -ne 0)) { $LeftWhiteSpace -= 0.5; $RightWhiteSpace += 0.5 }
    return "$(" " * $LeftWhiteSpace)$Text$(" " * $RightWhiteSpace)"
}

function PadForLeftAlign($Text, $Width) { return "$Text$(" " * ($Width - $Text.Length))" }

Export-ModuleMember -Function Get-PSTask, New-PSTask, Remove-PSTask, Set-PSTask, kan