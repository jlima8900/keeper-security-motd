#!/bin/bash
# Module: LAPD Integrated Threat Summary
# Priority: 75

[ "${ENABLE_LAPD:-true}" != "true" ] && exit 0
[ "${ENABLE_LAPD_THREATS:-true}" != "true" ] && exit 0

loading_dots "Threat detection (LAPD)"

echo -e "${KEEPER_BLACK}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_BLACK}║${RESET}  ${KEEPER_GOLD}🚨 THREAT DETECTION & PROTOCOL ANALYSIS (L.A.P.D.)${RESET}                       ${KEEPER_BLACK}║${RESET}"
echo -e "${KEEPER_BLACK}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"

# Comprehensive LAPD analysis
CURRENT_DATE=$(date '+%b %e' | sed 's/  / /')
TOTAL_THREATS=0

# Use cached threat data if available
CACHE_FILE="${CACHE_DIR}/threat_info"
if cache_is_fresh "$CACHE_FILE" "${CACHE_THREAT_TTL:-60}"; then
    THREAT_INFO=$(cache_read "$CACHE_FILE")
    SSH_FAILURES=$(echo "$THREAT_INFO" | cut -d'|' -f1)
    UNIQUE_ATTACKERS=$(echo "$THREAT_INFO" | cut -d'|' -f2)
    THREAT_IP=$(echo "$THREAT_INFO" | cut -d'|' -f3)
    THREAT_COUNT=$(echo "$THREAT_INFO" | cut -d'|' -f4)
    BANNED_TODAY=$(echo "$THREAT_INFO" | cut -d'|' -f5)
    ACTIVE_BANS=$(echo "$THREAT_INFO" | cut -d'|' -f6)
else
    # SSH Analysis
    SSH_FAILURES=0
    UNIQUE_ATTACKERS=0
    THREAT_IP=""
    THREAT_COUNT=0

    if [ -f "${SSH_LOG:-/var/log/secure}" ]; then
        SSH_FAILURES=$(grep -Ei "Failed|authentication failure" "${SSH_LOG}" 2>/dev/null | grep "$CURRENT_DATE" | wc -l)
        TOP_THREAT=$(grep -Ei "Failed|authentication failure" "${SSH_LOG}" 2>/dev/null | grep "$CURRENT_DATE" | grep -oP '(\d{1,3}\.){3}\d{1,3}' | sort | uniq -c | sort -nr | head -1)
        UNIQUE_ATTACKERS=$(grep -Ei "Failed|authentication failure" "${SSH_LOG}" 2>/dev/null | grep "$CURRENT_DATE" | grep -oP '(\d{1,3}\.){3}\d{1,3}' | sort -u | wc -l)

        if [ -n "$TOP_THREAT" ]; then
            THREAT_COUNT=$(echo "$TOP_THREAT" | awk '{print $1}')
            THREAT_IP=$(echo "$TOP_THREAT" | awk '{print $2}')
        fi
    fi

    # Fail2ban status
    BANNED_TODAY=0
    ACTIVE_BANS=0

    if [ -f "${FAIL2BAN_LOG:-/var/log/fail2ban.log}" ]; then
        BANNED_TODAY=$(grep "Ban" "${FAIL2BAN_LOG}" 2>/dev/null | grep "$CURRENT_DATE" | wc -l)
    fi

    if check_dependency fail2ban-client; then
        ACTIVE_BANS=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}' || echo "0")
    fi

    cache_write "$CACHE_FILE" "${SSH_FAILURES}|${UNIQUE_ATTACKERS}|${THREAT_IP}|${THREAT_COUNT}|${BANNED_TODAY}|${ACTIVE_BANS}"
fi

TOTAL_THREATS=$SSH_FAILURES

# Display SSH threats
if [ "$SSH_FAILURES" -gt 0 ]; then
    echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}SSH Threats:${RESET}     ${BRED}${SSH_FAILURES}${RESET} attempts ${DIM}│${RESET} ${YELLOW}${UNIQUE_ATTACKERS}${RESET} unique IPs ${DIM}│${RESET} Top: ${YELLOW}${THREAT_IP}${RESET} (${THREAT_COUNT}x)"
else
    echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}SSH Threats:${RESET}     ${BGREEN}✓${RESET} ${DIM}No failed attempts detected${RESET}"
fi

# Display fail2ban info
if [ -f "${FAIL2BAN_LOG}" ] || check_dependency fail2ban-client; then
    if [ "$BANNED_TODAY" -gt 0 ]; then
        echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Fail2ban:${RESET}        ${BRED}${BANNED_TODAY}${RESET} banned today ${DIM}│${RESET} ${YELLOW}${ACTIVE_BANS}${RESET} currently blocked"
    else
        echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Fail2ban:${RESET}        ${BGREEN}✓${RESET} ${DIM}No bans today ${DIM}│${RESET} ${YELLOW}${ACTIVE_BANS}${RESET} active blocks"
    fi
fi

# Overall threat level
THREAT_LEVEL=""
if [ "$TOTAL_THREATS" -ge "${THREAT_CRITICAL:-1000}" ]; then
    THREAT_LEVEL="${BRED}CRITICAL${RESET}"
elif [ "$TOTAL_THREATS" -ge "${THREAT_ELEVATED:-500}" ]; then
    THREAT_LEVEL="${YELLOW}ELEVATED${RESET}"
elif [ "$TOTAL_THREATS" -gt "${THREAT_MODERATE:-0}" ]; then
    THREAT_LEVEL="${BYELLOW}MODERATE${RESET}"
else
    THREAT_LEVEL="${BGREEN}NORMAL${RESET}"
fi

echo -e "${KEEPER_BLACK}║${RESET}  ${CYAN}Threat Level:${RESET}    ${THREAT_LEVEL} ${DIM}│${RESET} Total incidents: ${KEEPER_GOLD}${TOTAL_THREATS}${RESET}"

echo -e "${KEEPER_BLACK}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
