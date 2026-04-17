#!/usr/bin/env bash

# ==============================
# CONFIGURAÇÕES
# ==============================

WALLET="421ss7ueQayehJme51PBnUSLj4oP6tVDGMVhU6ZAAkYtisqJyo8Me7oY3T19guRaPxEYMSfWN4yqsPpytCTVWUdG7JJ8ZKZ"
POOL="pool.supportxmr.com:443"
WORKER="ZombieWorker"
LOG_FILE="miner.log"

XMRIG_BIN=$(which xmrig)

# ==============================
# VERIFICAÇÃO
# ==============================

if [ -z "$XMRIG_BIN" ]; then
  echo "Erro: xmrig não encontrado!"
  exit 1
fi

# ==============================
# ATIVAR HUGE PAGES
# ==============================

sudo -n sysctl -w vm.nr_hugepages=1280 2>/dev/null || \
  echo "⚠️ Não foi possível ativar Huge Pages automaticamente"

# ==============================
# CONFIGURAÇÃO DE EXECUÇÃO
# ==============================

CPU_THREADS=$(nproc)
THREADS=$CPU_THREADS
NICE=0
MODE_NAME="TOTAL"

# ==============================
# INICIAR MINERADOR
# ==============================

nice -n "$NICE" "$XMRIG_BIN" \
  -o "$POOL" \
  -u "$WALLET" \
  -k \
  --tls \
  --threads="$THREADS" \
  -p "$WORKER" \
  > /dev/null 2>&1 &

PID=$!

sleep 2

# ==============================
# VERIFICAÇÃO DE EXECUÇÃO
# ==============================

if ! ps -p "$PID" > /dev/null; then
  echo "❌ Erro: minerador não iniciou"
  exit 1
fi

echo "✅ Minerador rodando. PID: $PID"
