#!/bin/bash
# Module: Footer with Quotes and Security Tips
# Priority: 90 (runs last)

# Random motivational quote
if [ "${ENABLE_QUOTES:-true}" = "true" ]; then
    QUOTES=(
        "\"Lock it down, keep it secure!\" - Keeper Security"
        "\"Zero-knowledge architecture: What we don't know can't hurt you.\""
        "\"Your vault, your rules, your security.\""
        "\"Passwords are like underwear: change them often and don't share them.\""
        "\"Security is not a product, but a process.\""
        "\"In cryptography we trust.\""
        "\"The best password is the one you don't have to remember.\""
        "\"Encrypted today, secure tomorrow.\""
    )
    RANDOM_QUOTE=${QUOTES[$RANDOM % ${#QUOTES[@]}]}

    echo -e "${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${KEEPER_BLACK}💡 ${BWHITE}${RANDOM_QUOTE}${RESET}"
    echo -e "${KEEPER_GOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
fi

# Security Tip of the Day
if [ "${ENABLE_SECURITY_TIP:-true}" = "true" ]; then
    SECURITY_TIP=""
    if [ -f "${SECURITY_TIPS_FILE:-$HOME/.keeper_security_tips.txt}" ]; then
        SECURITY_TIP=$(shuf -n 1 "${SECURITY_TIPS_FILE}" 2>/dev/null)
    else
        SECURITY_TIP="Keeper Security: Your digital vault in the cloud. Stay secure!"
    fi

    # Calculate the width needed for the security tip
    TIP_LENGTH=${#SECURITY_TIP}
    BOX_WIDTH=$((TIP_LENGTH + 6))
    [ $BOX_WIDTH -lt 56 ] && BOX_WIDTH=56

    # Generate dynamic borders
    BORDER_LINE=$(printf '═%.0s' $(seq 1 $((BOX_WIDTH - 2))))

    # Header calculation
    HEADER_TEXT="  🛡️  SECURITY TIP OF THE DAY"
    HEADER_LENGTH=$((${#HEADER_TEXT} + 2))
    HEADER_PADDING=$((BOX_WIDTH - HEADER_LENGTH - 2))
    HEADER_SPACES=$(printf ' %.0s' $(seq 1 $HEADER_PADDING))

    # Tip content padding
    TIP_PADDING=$((BOX_WIDTH - TIP_LENGTH - 4))
    TIP_SPACES=$(printf ' %.0s' $(seq 1 $TIP_PADDING))

    echo -e "${KEEPER_GOLD}╔${BORDER_LINE}╗${RESET}"
    echo -e "${KEEPER_GOLD}║${RESET}${BWHITE}${HEADER_TEXT}${RESET}${HEADER_SPACES}${KEEPER_GOLD}║${RESET}"
    echo -e "${KEEPER_GOLD}╠${BORDER_LINE}╣${RESET}"
    echo -e "${KEEPER_GOLD}║${RESET}"
    echo -e "${KEEPER_GOLD}║${RESET}  ${BCYAN}${SECURITY_TIP}${RESET}${TIP_SPACES}${KEEPER_GOLD}║${RESET}"
    echo -e "${KEEPER_GOLD}║${RESET}"
    echo -e "${KEEPER_GOLD}╚${BORDER_LINE}╝${RESET}"
    echo ""
fi
