#!/bin/bash
# Module: Recent Activity
# Priority: 80

[ "${ENABLE_ACTIVITY:-true}" != "true" ] && exit 0

loading_dots "Analyzing activity"

echo -e "${KEEPER_GOLD}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${BWHITE}📊 RECENT ACTIVITY${RESET}                                                        ${KEEPER_GOLD}║${RESET}"
echo -e "${KEEPER_GOLD}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"

# Recent commands (from history)
RECENT_CMD_COUNT=$(history 2>/dev/null | wc -l || echo "0")
echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Shell History:${RESET}   ${KEEPER_GOLD}${RECENT_CMD_COUNT}${RESET} commands recorded"

# Git commits today
if [ "${SHOW_GIT:-true}" = "true" ] && [ -d ".git" ]; then
    TODAY=$(date +%Y-%m-%d)
    COMMITS_TODAY=$(git log --since="$TODAY 00:00:00" --oneline 2>/dev/null | wc -l)
    if [ "$COMMITS_TODAY" -gt 0 ]; then
        echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Commits Today:${RESET}   ${BGREEN}✓${RESET} ${KEEPER_GOLD}${COMMITS_TODAY}${RESET} commit(s)"
    else
        echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Commits Today:${RESET}   ${DIM}No commits yet${RESET}"
    fi
fi

# Docker events
if [ "${SHOW_DOCKER:-true}" = "true" ] && check_dependency docker; then
    DOCKER_EVENTS=$(docker events --since 1h --until 0s 2>/dev/null | wc -l)
    if [ "$DOCKER_EVENTS" -gt 0 ]; then
        echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Docker Events:${RESET}   ${KEEPER_GOLD}${DOCKER_EVENTS}${RESET} events in last hour"
    fi
fi

echo -e "${KEEPER_GOLD}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
