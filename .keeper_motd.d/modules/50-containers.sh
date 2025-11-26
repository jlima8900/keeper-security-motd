#!/bin/bash
# Module: Container Status
# Priority: 50

[ "${ENABLE_CONTAINERS:-true}" != "true" ] && exit 0
[ "${SHOW_DOCKER:-true}" != "true" ] && exit 0

# Check if Docker is available
require_dependency docker "Container Status" || exit 0

loading_dots "Checking containers"

# Get Docker info with caching
CACHE_FILE="${CACHE_DIR}/docker_info"
if cache_is_fresh "$CACHE_FILE" "${CACHE_DOCKER_TTL:-15}"; then
    DOCKER_INFO=$(cache_read "$CACHE_FILE")
    DOCKER_RUNNING=$(echo "$DOCKER_INFO" | cut -d'|' -f1)
    KEEPER_SERVICES=$(echo "$DOCKER_INFO" | cut -d'|' -f2)
else
    DOCKER_RUNNING=$(docker ps -q 2>/dev/null | wc -l)
    KEEPER_SERVICES=$(docker ps 2>/dev/null | grep -i keeper | wc -l)
    cache_write "$CACHE_FILE" "${DOCKER_RUNNING}|${KEEPER_SERVICES}"
fi

echo -e "${KEEPER_BLACK}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${KEEPER_GOLD}🐳 ACTIVE CONTAINERS${RESET}                                                       ${KEEPER_BLACK}║${RESET}"
echo -e "${KEEPER_BLACK}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Docker:${RESET}         ${KEEPER_GOLD}${DOCKER_RUNNING}${RESET} containers running"

if [ "${SHOW_KEEPER_SERVICES:-true}" = "true" ]; then
    if [ "$KEEPER_SERVICES" -gt 0 ]; then
        echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Keeper Services:${RESET} ${BGREEN}✓${RESET} ${KEEPER_GOLD}${KEEPER_SERVICES}${RESET} service(s) ${BGREEN}ACTIVE${RESET}"
    else
        echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Keeper Services:${RESET} ${DIM}No Keeper containers detected${RESET}"
    fi
fi

echo -e "${KEEPER_BLACK}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Keeper-branded footer with timestamp
echo -e "${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${KEEPER_BLACK}⚡ Access granted: ${BWHITE}$(date '+%Y-%m-%d %H:%M:%S %Z')${RESET} ${KEEPER_BLACK}│ ${KEEPER_GOLD}Stay secure! 🔐${RESET}"
echo -e "${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
