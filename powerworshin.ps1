<#
.SYNOPSIS
    Finds and removes empty folders within a specified directory.

.DESCRIPTION
    This script recursively scans a given directory for empty folders and removes them.
    It includes features such as exclusion lists, dry run mode, age-based filtering,
    logging, progress tracking, and an undo option.

.PARAMETER RootPath
    The starting directory for the search.

.PARAMETER ExcludePaths
    An array of paths to exclude from the search and deletion process.

.PARAMETER DryRun
    If specified, the script will only show what would be deleted without actually removing anything.

.PARAMETER MinimumAge
    Only consider folders that haven't been modified for at least this many days.

.PARAMETER Force
    Skip the confirmation prompt before deleting folders.

.PARAMETER CreateBackup
    Create a backup of the folder structure before deletion for potential restoration.

.EXAMPLE
    .\RemoveEmptyFolders.ps1 -RootPath "C:\Users\YourUsername\Documents" -ExcludePaths "C:\Users\YourUsername\Documents\Important" -MinimumAge 30 -Verbose
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$RootPath,
    
    [string[]]$ExcludePaths,
    
    [switch]$DryRun,
    
    [int]$MinimumAge = 0,
    
    [switch]$Force,

    [switch]$CreateBackup
)

# Import required modules
Import-Module Microsoft.PowerShell.Management
Import-Module Microsoft.PowerShell.Utility

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize variables
$script:totalFolders = 0
$script:processedFolders = 0
$script:backupPath = $null

# Function to write log messages
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath "EmptyFolderRemoval.log"
    Write-Verbose $Message
}

# Function to get empty folders
function Get-EmptyFolders {
    param (
        [string]$Path,
        [string[]]$Exclude,
        [int]$MinAge
    )
    
    $emptyFolders = @()
    
    try {
        # Get all folders recursively
        $folders = Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction Stop
        $script:totalFolders = $folders.Count
        
        foreach ($folder in $folders) {
            # Update progress
            $script:processedFolders++
            Write-Progress -Activity "Scanning for empty folders" -Status "Progress" -PercentComplete (($script:processedFolders / $script:totalFolders) * 100)

            # Skip excluded paths
            if ($Exclude -contains $folder.FullName) { continue }
            
            # Check if folder is empty
            $items = Get-ChildItem -Path $folder.FullName -Force -ErrorAction SilentlyContinue
            if ($items.Count -eq 0) {
                # Check folder age
                if ($MinAge -eq 0 -or $folder.LastWriteTime -lt (Get-Date).AddDays(-$MinAge)) {
                    $emptyFolders += $folder.FullName
                }
            }
        }
    }
    catch {
        Write-Log "Error scanning folders: $_"
    }
    
    return $emptyFolders
}

# Function to remove empty folders
function Remove-EmptyFolders {
    param (
        [string[]]$Folders,
        [switch]$WhatIf
    )
    
    foreach ($folder in $Folders) {
        try {
            Remove-Item -Path $folder -Force -Recurse -WhatIf:$WhatIf
            if (-not $WhatIf) {
                Write-Log "Removed folder: $folder"
            }
        }
        catch {
            Write-Log "Error removing folder $folder: $_"
        }
    }
}

# Function to create a backup of the folder structure
function New-FolderBackup {
    param (
        [string]$SourcePath
    )
    $backupFolder = "EmptyFolderRemoval_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $script:backupPath = Join-Path -Path $env:TEMP -ChildPath $backupFolder
    
    try {
        # Create a JSON representation of the folder structure
        $folderStructure = Get-ChildItem -Path $SourcePath -Recurse -Directory | 
            Select-Object FullName, LastWriteTime |
            ConvertTo-Json -Depth 5
        
        # Save the JSON to the backup folder
        New-Item -ItemType Directory -Path $script:backupPath -Force | Out-Null
        $folderStructure | Out-File -FilePath (Join-Path -Path $script:backupPath -ChildPath "FolderStructure.json")
        
        Write-Log "Backup created at: $script:backupPath"
    }
    catch {
        Write-Log "Error creating backup: $_"
        $script:backupPath = $null
    }
}

# Function to restore from backup
function Restore-FromBackup {
    param (
        [string]$BackupPath
    )
    if (-not (Test-Path $BackupPath)) {
        Write-Log "Backup not found at: $BackupPath"
        return
    }

    try {
        $folderStructure = Get-Content -Path (Join-Path -Path $BackupPath -ChildPath "FolderStructure.json") | ConvertFrom-Json
        
        foreach ($folder in $folderStructure) {
            if (-not (Test-Path $folder.FullName)) {
                New-Item -ItemType Directory -Path $folder.FullName -Force | Out-Null
                (Get-Item $folder.FullName).LastWriteTime = $folder.LastWriteTime
                Write-Log "Restored folder: $($folder.FullName)"
            }
        }
        
        Write-Log "Restoration completed"
    }
    catch {
        Write-Log "Error during restoration: $_"
    }
}

# Main script logic
Write-Log "Script started. Root path: $RootPath"

# Validate root path
if (-not (Test-Path $RootPath)) {
    Write-Log "Error: Root path does not exist."
    exit
}

# Create backup if requested
if ($CreateBackup) {
    New-FolderBackup -SourcePath $RootPath
}

# Get empty folders
$emptyFolders = Get-EmptyFolders -Path $RootPath -Exclude $ExcludePaths -MinAge $MinimumAge

if ($emptyFolders.Count -eq 0) {
    Write-Host "No empty folders found."
    exit
}

Write-Host "Found $($emptyFolders.Count) empty folders."

# Prompt for confirmation unless Force is used
if (-not $Force) {
    $confirmation = Read-Host "Do you want to remove these folders? (Y/N)"
    if ($confirmation -ne "Y") {
        Write-Host "Operation cancelled by user."
        exit
    }
}

# Remove empty folders
Remove-EmptyFolders -Folders $emptyFolders -WhatIf:$DryRun

if ($DryRun) {
    Write-Host "Dry run completed. No folders were actually removed."
} else {
    Write-Host "Empty folders have been removed."
}

Write-Log "Script completed."

# Offer to undo if backup was created
if ($script:backupPath -and -not $DryRun) {
    $undoConfirmation = Read-Host "Do you want to undo the folder removal? (Y/N)"
    if ($undoConfirmation -eq "Y") {
        Restore-FromBackup -BackupPath $script:backupPath
        Write-Host "Folder structure has been restored from backup."
    }
}