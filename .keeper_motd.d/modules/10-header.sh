#!/bin/bash
# Module: Header with Keeper + LAPD Logo
# Priority: 10 (runs first)

[ "${ENABLE_HEADER:-true}" != "true" ] && exit 0

# Keeper + LAPD logo with normal letters
show_keeper_logo() {
    echo ""
    echo -e "        ${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "                   ${BWHITE}${BOLD}KEEPER${RESET}  ${KEEPER_GOLD}+${RESET}  ${BWHITE}${BOLD}LAPD${RESET}"
    echo -e "                ${DIM}Security Vault & Threat Detection${RESET}"
    echo -e "        ${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "              ${BWHITE}🔐 INTEGRATED SECURITY & THREAT DETECTION 🚨${RESET}"
    echo -e "        ${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

clear
show_keeper_logo
