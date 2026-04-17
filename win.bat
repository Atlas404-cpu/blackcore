# ==============================
# CONFIGURAÇÕES
# ==============================

$WALLET = "421ss7ueQayehJme51PBnUSLj4oP6tVDGMVhU6ZAAkYtisqJyo8Me7oY3T19guRaPxEYMSfWN4yqsPpytCTVWUdG7JJ8ZKZ"
$POOL = "pool.supportxmr.com:443"
$WORKER = "ZombieWorker"
$LOG_FILE = "miner.log"
$XMRIG_URL = "https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-msvc-win64.zip"
$XMRIG_DIR = "$env:USERPROFILE\xmrig"

# ==============================
# BAIXAR XMRIG
# ==============================

if (-Not (Test-Path $XMRIG_DIR)) {
    Write-Host "Criando pasta para XMRig..."
    New-Item -ItemType Directory -Path $XMRIG_DIR
}

$zipFile = "$XMRIG_DIR\xmrig.zip"

if (-Not (Test-Path $zipFile)) {
    Write-Host "Baixando XMRig..."
    Invoke-WebRequest -Uri $XMRIG_URL -OutFile $zipFile
} else {
    Write-Host "XMRig já baixado."
}

# ==============================
# DESCOMPACTAR
# ==============================

Write-Host "Descompactando..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $XMRIG_DIR, $true)

# ==============================
# ESCOLHER MODO
# ==============================

Write-Host ""
Write-Host "Escolha o modo de mineração:"
Write-Host "1 - TOTAL 🔥"
Write-Host "2 - EQUILIBRADO ⚖️"
Write-Host "3 - ECONÔMICO 💤"
$MODE = Read-Host "Opção"

$CPU_THREADS = [Environment]::ProcessorCount

switch ($MODE) {
    "1" { $THREADS = $CPU_THREADS; $MODE_NAME = "TOTAL" }
    "2" { $THREADS = [Math]::Max($CPU_THREADS - 2, 1); $MODE_NAME = "EQUILIBRADO" }
    "3" { $THREADS = 1; $MODE_NAME = "ECONÔMICO" }
    default { Write-Host "Opção inválida"; exit }
}

# ==============================
# ESCOLHER LOG
# ==============================

Write-Host ""
Write-Host "Deseja mostrar os logs no terminal?"
Write-Host "1 - Sim"
Write-Host "2 - Não (invisível)"
$SHOW_LOG = Read-Host "Opção"

# ==============================
# LIMPAR LOG
# ==============================

if (Test-Path $LOG_FILE) { Remove-Item $LOG_FILE }

# ==============================
# INICIAR MINERADOR
# ==============================

Write-Host "Iniciando minerador..."
Write-Host "Modo: $MODE_NAME, Threads: $THREADS"

$XMRIG_EXE = Join-Path $XMRIG_DIR "xmrig.exe"

$Args = @(
    "-o", $POOL
    "-u", $WALLET
    "-k"
    "--tls"
    "--threads=$THREADS"
    "-p", $WORKER
)

if ($SHOW_LOG -eq "1") {
    # Mostrar log no terminal
    Start-Process -FilePath $XMRIG_EXE -ArgumentList $Args -NoNewWindow -RedirectStandardOutput $LOG_FILE -RedirectStandardError $LOG_FILE
} else {
    # Invisível
    Start-Process -FilePath $XMRIG_EXE -ArgumentList $Args -WindowStyle Hidden -RedirectStandardOutput $LOG_FILE -RedirectStandardError $LOG_FILE
}

Write-Host "✅ Minerador iniciado."