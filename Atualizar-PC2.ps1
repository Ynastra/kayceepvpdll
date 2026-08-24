param(
    [string]$ProfileName = "KayceePvP"
)

$ErrorActionPreference = "Stop"
$expectedHash = "F73F1EFA47AF1982CBC7C2C24E40A7BF739E86B4968FBCDC981A6A2055543B16"
$expectedApiVersion = "2.24.0"
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

    # A dependencia API_dev-API precisa estar na MESMA versao dos dois lados,
    # senao o mod pode falhar ao carregar ou os dois lados anunciam
    # protocolos diferentes no lobby. Checagem apenas informativa - nao
    # tenta atualizar a dependencia sozinho.
    $apiManifest = Join-Path $plugins "API_dev-API\manifest.json"
    if (Test-Path -LiteralPath $apiManifest) {
        $apiVersion = (Get-Content -LiteralPath $apiManifest -Raw | ConvertFrom-Json).version_number
        if ($apiVersion -ne $expectedApiVersion) {
            Write-Host "ATENCAO: API_dev-API neste profile esta na versao $apiVersion, mas o build atual foi feito contra $expectedApiVersion." -ForegroundColor Yellow
            Write-Host "Atualize a dependencia 'API' para $expectedApiVersion pelo Thunderstore Mod Manager antes de abrir o jogo." -ForegroundColor Yellow
        }
        else {
            Write-Host "API_dev-API confirmada na versao esperada ($apiVersion)." -ForegroundColor Green
        }
    }
    else {
        Write-Host "ATENCAO: nao encontrei API_dev-API em $plugins - confirme que a dependencia 'API' (autor API_dev) esta instalada nesse profile." -ForegroundColor Yellow
    }
}

Write-Host "PC2 pronto. Abra o jogo usando exatamente o profile '$ProfileName'." -ForegroundColor Green
