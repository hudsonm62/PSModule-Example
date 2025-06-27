function Use-PublicFunction {
    param ( [string]$Name = (Get-World) )
    Write-Output "Hello, $Name!"
}

Set-Alias -Name upf -Value Use-PublicFunction
