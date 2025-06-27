# MyModule\MyModule.psm1

[string]$Root = (Get-Item -Path $PSScriptRoot -Force)
[string]$ModuleName = "MyModule"

# paths
$ManifestPath = Join-Path $Root "$ModuleName.psd1"
$PublicPath = Join-Path $Root "public"
$PrivatePath = Join-Path $Root "private"
$ClassesPath = Join-Path $Root "classes"

$Manifest = Test-ModuleManifest $ManifestPath -ErrorAction Stop

# get all files for import/export
$aliases = @()
$public  = Get-ChildItem -Path $PublicPath  -Recurse -Force | Where-Object { $_.Extension -eq ".ps1" }
$private = Get-ChildItem -Path $PrivatePath -Recurse -Force | Where-Object { $_.Extension -eq ".ps1" }
$classes = Get-ChildItem -Path $ClassesPath -Recurse -Force | Where-Object { $_.Extension -eq ".ps1" }

# Import all to session
$public | ForEach-Object { . $_.FullName }
$private | ForEach-Object { . $_.FullName }
$classes | ForEach-Object { . $_.FullName }

# Export 'public' functions (w/ aliases if present)
$public | ForEach-Object {
    $alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($alias) {
        # Export defined aliases
        $aliases += $alias
        Export-ModuleMember -Function $_.BaseName -Alias $alias
    } else {
        # Export with no alias
        Export-ModuleMember -Function $_.BaseName
    }
}

# Update the module manifest on changes
$Added = $public | Where-Object {$_.BaseName -notin $Manifest.ExportedFunctions.Keys}
$Removed = $Manifest.ExportedFunctions.Keys | Where-Object {$_ -notin $public.BaseName}
$aliasesAdded = $aliases | Where-Object {$_ -notin $Manifest.ExportedAliases.Keys}
$aliasesRemoved = $Manifest.ExportedAliases.Keys | Where-Object {$_ -notin $aliases}
if ($Added -or $Removed -or $aliasesAdded -or $aliasesRemoved) {
    try {
        $updateModuleManifestParams = @{}
        $updateModuleManifestParams.Add("Path", $ManifestPath)
        $updateModuleManifestParams.Add("ErrorAction", "Stop")
        if ($aliasesAdded.Count -gt 0) { $updateModuleManifestParams.Add("AliasesToExport", $aliases) }
        if ($Added.Count -gt 0) { $updateModuleManifestParams.Add("FunctionsToExport", $public.BaseName) }

        Update-ModuleManifest @updateModuleManifestParams
    }
    catch {
        $_ | Write-Error
    }
}
