#!/bin/bash
# Module: System Status
# Priority: 30

[ "${ENABLE_SYSTEM_STATUS:-true}" != "true" ] && exit 0

loading_dots "Loading system information"

# Get system info
HOSTNAME=$(get_system_info hostname)
UPTIME=$(get_system_info uptime)
LOAD=$(get_system_info load)
USERS=$(get_system_info users)

echo -e "${KEEPER_BLACK}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${KEEPER_GOLD}⚡ SYSTEM STATUS${RESET}                                                           ${KEEPER_BLACK}║${RESET}"
echo -e "${KEEPER_BLACK}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}System:${RESET} ${BWHITE}${HOSTNAME}${RESET} ${DIM}│${RESET} ${CYAN}Uptime:${RESET} ${KEEPER_GOLD}${UPTIME}${RESET} ${DIM}│${RESET} ${CYAN}Load:${RESET} ${BYELLOW}${LOAD}${RESET} ${DIM}│${RESET} ${CYAN}Users:${RESET} ${BWHITE}${USERS}${RESET}"
echo -e "${KEEPER_BLACK}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
