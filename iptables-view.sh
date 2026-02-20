#!/usr/bin/env bash
set -euo pipefail

command -v fzf >/dev/null || { echo "fzf not installed"; exit 1; }

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

color_target() {
    case "$1" in
        ACCEPT) echo -e "${GREEN}$1${RESET}" ;;
        DROP) echo -e "${RED}$1${RESET}" ;;
        DROP) echo -e "${RED}$1${RESET}" ;;
        *) echo -e "${YELLOW}$1${RESET}" ;;
    esac
}

RULES="$(iptables-save)"

get_tables() {
    echo "$RULES" | awk '/^\*/ {print substr($1,2)}'
}

get_chains() {
    local table="$1"
    echo "$RULES" | awk -v t="$table" '
        $0 == "*"t {flag=1; next}
        /^\*/ {flag=0}
        flag && /^:/ {print substr($1,2)}
'
}

get_rules() {
    local table="$1"
    local chain="$2"

    echo "$RULES" | awk -v t="$table" -v c="$chain" '
        $0 == "*"t {flag=1; next}
        /^\*/ {flag=0}
        flag && $1 == "-A" && $2 == c {print}
    ' | while read -r line; do

        proto=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="-p") print $(i+1)}')
        src=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="-s") print $(i+1)}')
        dst=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="-d") print $(i+1)}')
        dport=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="--dport") print $(i+1)}')
        target=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="-j") print $(i+1)}')

        proto=${proto:-any}
        src=${src:-any}
        dst=${dst:-any}
        dport=${dport:-"-"}
        target=${target:-"-"}

        target_colored=$(color_target "$target")

        printf "%-6s %-18s %-18s %-6s %s\n" \
            "$proto" "$src" "$dst" "$dport" "$target_colored"
    done
}

main() {
    while true; do
        table=$(get_tables | fzf --prompt="Select table > ") || true
        [[ -z "${table:-}" ]] && exit 0

        while true; do
            chain=$(get_chains "$table" | fzf --prompt="[$table] Select chain > ") || true
            [[ -z "${chain:-}" ]] && break

            get_rules "$table" "$chain" | \
                fzf --ansi \
                    --header="PROTO  SOURCE             DESTINATION        DPORT  TARGET" \
                    --prompt="[$table/$chain] > " || true
        done
    done
}

main
