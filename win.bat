$WALLET = "421ss7ueQayehJme51PBnUSLj4oP6tVDGMVhU6ZAAkYtisqJyo8Me7oY3T19guRaPxEYMSfWN4yqsPpytCTVWUdG7JJ8ZKZ"
$POOL = "pool.supportxmr.com:443"
$WORKER = "ZombieWorker"
$XMRIG_URL = "https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-msvc-win64.zip"

$BASE = "$env:USERPROFILE\xmrig"
$ZIP = "$BASE\xmrig.zip"

if (!(Test-Path $BASE)) {
    New-Item -ItemType Directory -Path $BASE | Out-Null
}

Write-Host "Baixando XMRig..."
Invoke-WebRequest $XMRIG_URL -OutFile $ZIP

Write-Host "Descompactando..."
Expand-Archive -Path $ZIP -DestinationPath $BASE -Force

# encontra xmrig.exe corretamente
$XMRIG_EXE = Get-ChildItem -Path $BASE -Recurse -Filter xmrig.exe | Select-Object -First 1

if (!$XMRIG_EXE) {
    Write-Host "xmrig.exe não encontrado!"
    exit
}

Write-Host "Escolha modo:"
Write-Host "1 - Total"
Write-Host "2 - Balanceado"
Write-Host "3 - Econômico"

$mode = Read-Host

$threads = [Environment]::ProcessorCount

switch ($mode) {
    "1" { }
    "2" { $threads = [Math]::Max($threads - 2, 1) }
    "3" { $threads = 1 }
    default { Write-Host "Inválido"; exit }
}

$args = @(
    "-o", $POOL
    "-u", $WALLET
    "-p", $WORKER
    "--tls"
    "--threads=$threads"
)

Write-Host "Iniciando XMRig..."

Start-Process -FilePath $XMRIG_EXE.FullName -ArgumentList $args -WindowStyle Hidden
Write-Host "OK"
