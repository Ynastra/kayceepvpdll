param(
    [string]$ProfileName = "KayceePvP"
)

$ErrorActionPreference = "Stop"
$expectedHash = "86A058D82DF57E2E98ECA07700345D8C34A74AE6490A57AB86EDBA55BA0296E8"
$sourceDll = Join-Path $PSScriptRoot "KayceePvP.dll"

if (Get-Process -Name "Inscryption" -ErrorAction SilentlyContinue) {
    throw "Feche completamente o Inscryption antes de atualizar."
}

if (-not (Test-Path -LiteralPath $sourceDll)) {
    throw "KayceePvP.dll nao foi encontrada ao lado deste script."
}

$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceDll).Hash
if ($sourceHash -ne $expectedHash) {
    throw "A DLL baixada esta incorreta. Esperado=$expectedHash Obtido=$sourceHash"
}

$candidateRoots = @(
    (Join-Path $env:APPDATA "Thunderstore Mod Manager\DataFolder\Inscryption\profiles"),
    (Join-Path $env:APPDATA "r2modmanPlus-local\Inscryption\profiles"),
    (Join-Path $env:APPDATA "r2modmanPlus\Inscryption\profiles")
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -Unique

$profiles = foreach ($root in $candidateRoots) {
    Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $ProfileName }
}

if (-not $profiles) {
    Write-Host "Profiles de Inscryption encontrados:" -ForegroundColor Yellow
    foreach ($root in $candidateRoots) {
        Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { Write-Host ("  " + $_.FullName) }
    }
    throw "Profile '$ProfileName' nao encontrado. Execute novamente com: .\Atualizar-PC2.ps1 -ProfileName NOME_EXATO"
}

foreach ($profile in $profiles) {
    $plugins = Join-Path $profile.FullName "BepInEx\plugins"
    if (-not (Test-Path -LiteralPath $plugins)) {
        throw "Pasta de plugins nao encontrada em $($profile.FullName)"
    }

    $copies = @(Get-ChildItem -LiteralPath $plugins -Recurse -File -Filter "KayceePvP.dll")
    if (-not $copies) {
        $targetDir = Join-Path $plugins "KayceePvP"
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        $copies = @([System.IO.FileInfo](Join-Path $targetDir "KayceePvP.dll"))
    }

    foreach ($copy in $copies) {
        $target = $copy.FullName
        Copy-Item -LiteralPath $sourceDll -Destination $target -Force
        $installedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash
        if ($installedHash -ne $expectedHash) {
            throw "Falha ao validar $target. Obtido=$installedHash"
        }
        Write-Host "ATUALIZADA E VALIDADA: $target" -ForegroundColor Green
    }
}

Write-Host "PC2 pronto. Abra o jogo usando exatamente o profile '$ProfileName'." -ForegroundColor Green
