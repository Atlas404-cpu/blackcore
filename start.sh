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
# ESCOLHER MODO
# ==============================

echo ""
echo "Escolha o modo de mineração:"
echo "1 - TOTAL 🔥"
echo "2 - EQUILIBRADO ⚖️"
echo "3 - ECONÔMICO 💤"
read -p "Opção: " MODE

CPU_THREADS=$(nproc)

case $MODE in
  1)
    THREADS=$CPU_THREADS
    NICE=0
    MODE_NAME="TOTAL"
    ;;
  2)
    THREADS=$((CPU_THREADS - 2))
    [ $THREADS -lt 1 ] && THREADS=1
    NICE=10
    MODE_NAME="EQUILIBRADO"
    ;;
  3)
    THREADS=1
    NICE=19
    MODE_NAME="ECONÔMICO"
    ;;
  *)
    echo "Opção inválida"
    exit 1
    ;;
esac

# ==============================
# ESCOLHER LOG
# ==============================

echo ""
echo "Deseja mostrar os logs no terminal?"
echo "1 - Sim"
echo "2 - Não (invisível)"
read -p "Opção: " SHOW_LOG

# ==============================
# LIMPAR LOG
# ==============================

rm -f "$LOG_FILE"

# ==============================
# INICIAR MINERADOR
# ==============================

echo "Iniciando minerador..."
echo "Modo: $MODE_NAME, Threads: $THREADS"

if [ "$SHOW_LOG" == "1" ]; then
  # Mostrar log no terminal
  nice -n $NICE "$XMRIG_BIN" \
    -o $POOL \
    -u $WALLET \
    -k \
    --tls \
    --threads=$THREADS \
    -p $WORKER \
    | tee "$LOG_FILE" &
else
  # Invisível
  nice -n $NICE "$XMRIG_BIN" \
    -o $POOL \
    -u $WALLET \
    -k \
    --tls \
    --threads=$THREADS \
    -p $WORKER \
    > /dev/null 2>&1 &
fi

PID=$!

sleep 2

# ==============================
# VERIFICAR SE INICIOU
# ==============================

if ! ps -p $PID > /dev/null; then
  echo "❌ Erro: minerador não iniciou"
  exit 1
fi

echo "✅ Minerador rodando. PID: $PID"