# Define paths for both 32-bit and 64-bit installations
$uninstallRegistryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Initialize a flag to check if Firefox is found
$firefoxFound = $false

# Loop through the defined uninstall registry paths
foreach ($path in $uninstallRegistryPaths) {
    # Get all subkeys in the Uninstall registry path
    $subkeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

    foreach ($subkey in $subkeys) {
        # Get the DisplayName and UninstallString properties
        $displayName = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).DisplayName
        $uninstallString = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).UninstallString
        
        # Check if the display name contains "Mozilla Firefox"
        if ($displayName -like "*Mozilla Firefox*") {
            $firefoxFound = $true

            # Check if the uninstall string is not empty
            if ($uninstallString) {
                Write-Output "Uninstalling $displayName silently..."
                
                # Modify the uninstall string to run silently
                if ($uninstallString -like "*msiexec*") {
                    # For MSI uninstallation
                    $msiArgs = $uninstallString -replace 'msiexec.exe', 'msiexec.exe /x'
                    Start-Process -FilePath "msiexec.exe" -ArgumentList "$msiArgs /quiet /norestart" -Wait
                } else {
                    # For other uninstall strings (e.g., EXE installers)
                    Start-Process -FilePath $uninstallString -ArgumentList "/SILENT /NORESTART" -Wait
                }
                Write-Output "$displayName has been uninstalled."
            }
        }
    }
}

# Final check if Firefox is still installed
if (-not $firefoxFound) {
    Write-Output "No Mozilla Firefox installation found."
    exit 0
}

# Check if Firefox is still installed
$remainingFirefox = Get-Command "firefox" -ErrorAction SilentlyContinue
if (-not $remainingFirefox) {
    Write-Output "Mozilla Firefox has been successfully uninstalled."
    exit 0
} else {
    Write-Output "Mozilla Firefox could not be completely uninstalled."
    exit 1
}
