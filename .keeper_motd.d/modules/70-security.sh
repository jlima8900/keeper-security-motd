#!/bin/bash
# Module: SSH & Connection Security
# Priority: 70

[ "${ENABLE_SECURITY:-true}" != "true" ] && exit 0

loading_dots "Security scan"

echo -e "${KEEPER_BLACK}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${KEEPER_GOLD}🔌 CONNECTION & SECURITY STATUS${RESET}                                           ${KEEPER_BLACK}║${RESET}"
echo -e "${KEEPER_BLACK}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"

# SSH connections
SSH_CONNECTIONS=$(who | wc -l)

# Tmux sessions
TMUX_SESSIONS=0
if check_dependency tmux; then
    TMUX_SESSIONS=$(tmux list-sessions 2>/dev/null | wc -l)
fi

echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Active SSH:${RESET}      ${KEEPER_GOLD}${SSH_CONNECTIONS}${RESET} connection(s) ${DIM}│${RESET} ${CYAN}Tmux:${RESET} ${KEEPER_GOLD}${TMUX_SESSIONS}${RESET} session(s)"

# Last login info
if check_dependency last; then
    LAST_LOGIN=$(last -1 -w 2>/dev/null | head -n 1 | awk '{print $1, $3, $4, $5, $6, $7}')
    if [ -n "$LAST_LOGIN" ]; then
        echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Last Login:${RESET}      ${DIM}${LAST_LOGIN}${RESET}"
    fi
fi

# Network interfaces
if check_dependency ip; then
    ACTIVE_IPS=$(ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | wc -l)
    echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Network IPs:${RESET}     ${KEEPER_GOLD}${ACTIVE_IPS}${RESET} active interface(s)"
fi

echo -e "${KEEPER_BLACK}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
