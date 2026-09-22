import requests
import time
import csv
import os
import sys
from colorama import Fore, Style, init

init(autoreset=True)

# Define "Gold" color (Bright Yellow)[cite: 1]
GOLD = Fore.YELLOW + Style.BRIGHT

def monitor_telemetry_feed():
    print(Fore.CYAN + "=== Live Event Telemetry & Heartbeat Monitor ===")
    
    # --- SECURITY: PULL CREDENTIALS FROM ENVIRONMENT VARIABLES ---
    api_key = os.environ.get("VENDOR_API_KEY")
    if not api_key:
        print(Fore.RED + "CRITICAL ERROR: 'VENDOR_API_KEY' environment variable is missing.")
        print(Fore.YELLOW + "Please set it securely before launching the monitor.")
        sys.exit(1)
    
    target_ip = input("Enter Server IP: ").strip() #[cite: 1]
    target_port = input("Enter Port: ").strip() #[cite: 1]
    event_id = input("Enter Event ID: ").strip()

    url = f"http://{target_ip}:{target_port}/ws" #[cite: 1]
    log_file = f"latency_log_{event_id}.csv" #[cite: 1]
    record_count = 0 #[cite: 1]

    print(f"\n{Fore.YELLOW}Monitoring Event: {event_id}")
    session = requests.Session() #[cite: 1]
    headers = {"Content-Type": "application/xml"} #[cite: 1]

    try:
        with open(log_file, mode='a', newline='') as f: #[cite: 1]
            writer = csv.writer(f) #[cite: 1]
            if os.path.getsize(log_file) == 0: #[cite: 1]
                writer.writerow(["Timestamp", "EventID", "Latency_ms", "Event_Status"])

            while True:
                auth_xml = (
                    f"<AuthenticationMessage>"
                    f"<type>authentication</type>"
                    f"<apikey>{api_key}</apikey>"
                    f"<gameId>{event_id}</gameId>"
                    f"</AuthenticationMessage>"
                ) #[cite: 1]

                start_time = time.perf_counter() #[cite: 1]
                try:
                    response = session.post(url, data=auth_xml, headers=headers, timeout=5) #[cite: 1]
                    latency = (time.perf_counter() - start_time) * 1000 #[cite: 1]
                    timestamp = time.strftime("%H:%M:%S") #[cite: 1]
                    
                    raw_data = response.text #[cite: 1]
                    status_label = "ACTIVE" #[cite: 1]
                    display_text = f"{Fore.GREEN}🟢 OK" #[cite: 1]

                    # 1. CHECK FOR PERIOD ENDS (Gold)[cite: 1]
                    # We check 1, 2, 3, and 4[cite: 1]
                    for p in range(1, 5): #[cite: 1]
                        search_term = f'"periodNumber":{p}' #[cite: 1]
                        if search_term in raw_data: #[cite: 1]
                            status_label = f"Period {p} End" #[cite: 1]
                            display_text = f"{GOLD}📍 {status_label}"
                            break # Stop checking once we find the current period[cite: 1]

                    # 2. CHECK FOR FINALBOX (Gold - Overrides Period)[cite: 1]
                    if '"status":"finalbox"' in raw_data: #[cite: 1]
                        status_label = "FINALIZED" #[cite: 1]
                        display_text = f"{GOLD}🏆 FINALIZED" #[cite: 1]

                    # 3. CHECK FOR HIGH LATENCY (Red - if not Gold)[cite: 1]
                    elif latency > 500 and status_label == "ACTIVE": #[cite: 1]
                        display_text = f"{Fore.RED}⚠️  HIGH LATENCY" #[cite: 1]

                    print(f"[{timestamp}] {display_text}{Style.RESET_ALL} | {latency:.2f}ms") #[cite: 1]
                    
                    # Log to CSV[cite: 1]
                    writer.writerow([time.strftime("%Y-%m-%d %H:%M:%S"), event_id, f"{latency:.2f}", status_label]) #[cite: 1]
                    record_count += 1 #[cite: 1]
                    f.flush() #[cite: 1]

                except Exception as e:
                    print(f"[{time.strftime('%H:%M:%S')}] {Fore.RED}❌ ERROR: {str(e)[:40]}") #[cite: 1]
                
                time.sleep(1) #[cite: 1]

    except KeyboardInterrupt:
        print(f"\n\n{Fore.CYAN}--- SESSION SUMMARY ---") #[cite: 1]
        print(f"Total Records: {record_count}") #[cite: 1]
        choice = input(f"Keep log file '{log_file}'? (y/n): ").strip().lower() #[cite: 1]
        if choice == 'n': #[cite: 1]
            os.remove(log_file) #[cite: 1]
            print(Fore.RED + "Log disposed.") #[cite: 1]
        else:
            print(Fore.GREEN + f"Log saved.") #[cite: 1]

if __name__ == "__main__":
    monitor_telemetry_feed()
