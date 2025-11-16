#!/bin/bash
# Module: Vault Animation
# Priority: 20

[ "${ENABLE_VAULT:-true}" != "true" ] && exit 0

show_vault() {
    # Show vault locked
    echo -e "${KEEPER_DARK}"
    echo "              ╔═══════════════════════════╗"
    echo -e "              ║    ${BRED}🔒 VAULT: LOCKED 🔒${KEEPER_DARK}    ║"
    echo "              ║         [LOCKED]          ║"
    echo "              ║    ═══════════════════    ║"
    echo -e "              ║    ${DIM}◉  AUTHENTICATING  ◉${KEEPER_DARK}   ║"
    echo "              ╚═══════════════════════════╝"
    echo -e "${RESET}"

    if [ "${ENABLE_ANIMATIONS:-true}" = "true" ]; then
        sleep "${VAULT_DELAY:-0.2}"

        # Extended validation steps
        local validations=(
            "Verifying credentials"
            "Checking biometrics"
            "Validating 2FA token"
            "Scanning certificates"
            "Verifying permissions"
            "Decrypting vault keys"
            "Initializing session"
        )

        for validation in "${validations[@]}"; do
            echo -ne "\r              ${KEEPER_GOLD}>>> ${BYELLOW}${validation}${RESET}"
            for dot in {1..3}; do
                echo -n "."
                sleep 0.08
            done
            echo -ne " ${BGREEN}✓${RESET}     \r"
            sleep 0.1
        done

        # Brief pause before unlock
        sleep 0.15
    fi

    # Clear and show unlocked vault
    tput cuu 7  # Move cursor up 7 lines
    echo -e "${KEEPER_GOLD}"
    echo "              ╔═══════════════════════════╗"
    echo -e "              ║   ${BGREEN}🔓 VAULT: UNLOCKED 🔓${KEEPER_GOLD}  ║"
    echo "              ║         [SECURED]         ║"
    echo "              ║    ═══════════════════    ║"
    echo -e "              ║   ${BGREEN}◉  ACCESS GRANTED  ◉${KEEPER_GOLD}   ║"
    echo "              ╚═══════════════════════════╝"
    echo -e "${RESET}"
}

show_vault
echo ""
