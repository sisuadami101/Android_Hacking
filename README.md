
# ERROR MASK - Advanced Android Exploitation Framework

### Version: 3.0

### Author: GrayHAT (SojiB)

## Overview

ERROR MASK is an advanced Android exploitation framework designed to assist security professionals and researchers in generating and binding payloads for Android devices. This tool provides a user-friendly graphical interface, making it suitable for both novice and expert users.

## Features

- **Generate Standard Payload**: Easily create Android payloads using `msfvenom`.
- **Bind Payload to APK**: Inject payloads into existing APK files.
- **Start Listener**: Set up a Metasploit listener to handle incoming connections.
- **View Logs**: Access detailed logs for troubleshooting and verification.
- **Advanced GUI**: Enhanced graphical interface using `zenity` for better user experience.
- **Dependency Check**: Automatic check for required dependencies and installation guidance.
- **Secure Mode**: Ensures all actions are performed in a safe environment, preventing accidental harm to the system.

## Requirements

Ensure the following dependencies are installed on your system:

- `msfvenom` (part of the Metasploit framework)
- `zenity`
- `figlet`
- `lolcat`
- `apktool`
- `openjdk-11-jdk`
- `zipalign`

## Installation

1. Clone the repository:
    ```bash
   git clone https://github.com/sisuadami101/Android_Hacking.git
    
    cd Android_Hacking
    ```

2. Make the script executable:
    ```bash
    chmod +x an-hack.sh
    ```

3. Install the required dependencies:
    ```bash
    sudo apt install metasploit-framework zenity figlet lolcat apktool openjdk-11-jdk zipalign
    ```

## Usage

Run the script with the following command:
```bash
./an-hack.sh
```

### Main Menu Options

1. **Generate Standard Payload**: 
    - Enter connection details (LHOST, LPORT, Payload Type) and save the generated payload APK.
    - Default LHOST is automatically detected.
    - Validates LPORT to ensure it is within the range 1-65535.
    - Displays progress and success/failure messages.

2. **Bind Payload to APK**: 
    - Select the original APK and specify the output infected APK file.
    - Decompiles the APK, injects the payload, rebuilds, and signs the APK.
    - Displays progress and success/failure messages.

3. **Start Listener**: 
    - Configure and start a Metasploit listener to handle incoming connections.
    - Uses the specified payload type, LHOST, and LPORT.
    - Runs in a separate terminal window.

4. **Show Logs**: 
    - View detailed logs for all actions performed by the tool.
    - Logs are stored in `/tmp/errormask/activity.log`.

5. **Exit**: 
    - Exit the tool and clean up temporary files.

### Detailed Steps for Each Operation

#### Generate Standard Payload
1. Select "Generate Standard Payload" from the main menu.
2. Enter the connection details (LHOST, LPORT, Payload Type) in the form.
3. Save the generated payload APK to the desired location.
4. A progress dialog will show the status of the payload generation.
5. Upon completion, a success message will be displayed with the output file path.

#### Bind Payload to APK
1. Select "Bind Payload to APK" from the main menu.
2. Choose the original APK file.
3. Specify the output path for the infected APK.
4. The tool will decompile the APK, inject the payload, rebuild and sign the APK.
5. A progress dialog will show the status of each step.
6. Upon completion, a success message will be displayed with the output file path.

#### Start Listener
1. Select "Start Listener" from the main menu.
2. The listener configuration will be created and executed in a new terminal.
3. The Metasploit console will start and begin listening for incoming connections.

#### Show Logs
1. Select "Show Logs" from the main menu.
2. A text viewer will display the contents of the log file.
3. Logs are useful for troubleshooting and verifying actions.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Disclaimer

This tool is intended for educational purposes only. The author is not responsible for any misuse of this tool. Always obtain proper authorization before testing or exploiting systems.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

## Contact

For any questions or issues, please open an issue on the GitHub repository or contact the author at [error.mask.101@gmail.com].

## Changelog

### Version 3.0
- Enhanced user interface with `zenity`.
- Improved dependency check mechanism.
- Added detailed progress indicators.
- Included secure mode to prevent accidental harm to the system.
- Enhanced error handling and validation.
- Updated the README with detailed usage instructions.

### Version 2.1
- Initial release with basic payload generation and binding capabilities.
- Basic error handling and logging.
