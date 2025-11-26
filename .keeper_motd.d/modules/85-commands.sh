#!/bin/bash
# Module: Quick Commands
# Priority: 85

[ "${ENABLE_COMMANDS:-true}" != "true" ] && exit 0

echo -e "${KEEPER_BLACK}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${KEEPER_GOLD}⚡ QUICK COMMANDS${RESET}                                                             ${KEEPER_BLACK}║${RESET}"
echo -e "${KEEPER_BLACK}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}keeper-status${RESET}  ${DIM}│${RESET} Check Keeper services"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}lapd-report${RESET}    ${DIM}│${RESET} Full LAPD security analysis"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}docker ps${RESET}      ${DIM}│${RESET} List containers"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}htop${RESET}           ${DIM}│${RESET} System monitor"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}tmux attach${RESET}    ${DIM}│${RESET} Attach to session"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}git status${RESET}     ${DIM}│${RESET} Check repository status"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}claude${RESET}         ${DIM}│${RESET} Launch Claude Code"
echo -e "${KEEPER_BLACK}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
