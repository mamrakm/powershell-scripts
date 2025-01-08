
function Find-LargeFiles {
    <#
    .SYNOPSIS
        Searches specified directories for files exceeding a defined size threshold and optionally exports the results to a CSV file.

    .DESCRIPTION
        This function scans one or more directories recursively to identify files larger than a specified size in Gibibytes (GiB). It displays the results in a formatted table and can export the findings to a CSV file when the -Export switch is used.

    .PARAMETER Paths
        An array of directory paths to search. Defaults to "C:\Users" and "C:\Program Files".

    .PARAMETER SizeThresholdGiB
        The minimum file size in Gibibytes (GiB) to search for. Defaults to 1 GiB.

    .PARAMETER ExportPath
        The file path where the CSV report will be saved. This parameter is required when using the -Export switch.

    .PARAMETER Export
        A switch parameter that, when specified, exports the results to a CSV file at the location provided by -ExportPath.

    .EXAMPLE
        Find-LargeFiles

    .EXAMPLE
        Find-LargeFiles -Paths "D:\Data", "E:\Backups" -SizeThresholdGiB 2

    .EXAMPLE
        Find-LargeFiles -Export -ExportPath "D:\Logs\LargeFilesReport.csv"

    .EXAMPLE
        Find-LargeFiles -Paths "D:\Data" -SizeThresholdGiB 3 -Export -ExportPath "D:\Logs\LargeFilesReport.csv"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Paths = @("C:\Users", "C:\Program Files"),

        [Parameter(Mandatory = $false)]
        [long]$SizeThresholdGiB = 1,

        [Parameter(Mandatory = $false)]
        [string]$ExportPath,

        [Parameter(Mandatory = $false)]
        [switch]$Export
    )

    # Helper function to convert bytes to GiB
    function Convert-BytesToGiB {
        param (
            [long]$Bytes,
            [int]$DecimalPlaces = 2
        )
        return [math]::Round($Bytes / [math]::Pow(1024, 3), $DecimalPlaces)
    }

    # Calculate size threshold in bytes
    $sizeThresholdBytes = $SizeThresholdGiB * [math]::Pow(1024, 3)

    # Retrieve files larger than the threshold
    $largeFiles = Get-ChildItem -Path $Paths -Recurse -File -ErrorAction SilentlyContinue | 
        Where-Object { $_.Length -gt $sizeThresholdBytes }

    if ($largeFiles.Count -eq 0) {
        Write-Output "No files larger than $SizeThresholdGiB GiB found in the specified paths."
    } else {
        # Select and format desired properties
        $formattedFiles = $largeFiles | Select-Object Mode, LastWriteTime, 
            @{Name = "Size (GiB)"; Expression = { Convert-BytesToGiB -Bytes $_.Length } }, 
            FullName

        # Sort the results by Size (GiB) in descending order
        $sortedFiles = $formattedFiles | Sort-Object "Size (GiB)" -Descending

        # Display the results in a table
        $sortedFiles | Format-Table -AutoSize -Wrap

        # Export the results to a CSV file if -Export is specified
        if ($Export) {
            if (-not $ExportPath) {
                Write-Warning "Export path not specified. Please provide an ExportPath when using -Export."
            } else {
                # Ensure the export directory exists
                $exportDirectory = Split-Path -Path $ExportPath -Parent
                if (-not (Test-Path -Path $exportDirectory)) {
                    try {
                        New-Item -Path $exportDirectory -ItemType Directory -Force | Out-Null
                        Write-Output "Created directory: $exportDirectory"
                    }
                    catch {
                        Write-Error "Failed to create directory '$exportDirectory'. $_"
                        return
                    }
                }

                try {
                    $sortedFiles | Export-Csv -Path $ExportPath -NoTypeInformation
                    Write-Output "Report exported to '$ExportPath'."
                }
                catch {
                    Write-Error "Failed to export to '$ExportPath'. $_"
                }
            }
        }
    }
}

Export-ModuleMember -Function Find-LargeFiles
