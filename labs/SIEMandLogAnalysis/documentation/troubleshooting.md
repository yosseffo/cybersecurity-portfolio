# Troubleshooting Notes

## Overview

This document records the main issues I ran into while building the SIEM Implementation and Log Analysis lab.

I included this section because a lot of the value of this lab came from troubleshooting. The setup was not a clean install from start to finish. I had to work through VMware limitations, Splunk startup problems, Linux disk sizing, network issues, and older Metasploitable logging behavior.

These notes document what went wrong, how I investigated it, and how I fixed each issue.

---

## VMware Drag and Drop and Shared Folder Issue

### Problem

After downloading the Splunk `.deb` installer on macOS, I initially tried to drag the file into the Ubuntu Server VM.

Drag and drop did not work. VMware shared folders also did not appear inside Ubuntu.

### Cause

VMware Tools were not installed and running inside the Ubuntu Server VM. Since this was a server installation without a desktop environment, drag and drop and shared folders were not immediately available.

### Fix

Instead of spending time troubleshooting VMware Tools during the Splunk installation, I used SCP to transfer the file from macOS to Ubuntu over SSH.

```bash
scp ~/Desktop/splunk*.deb <ubuntu-user>@<ubuntu-ip>:/home/<ubuntu-user>/
```

### Lesson Learned

SCP was a better workaround than relying on VMware drag and drop because it is a real Linux administration method and worked cleanly over the network.

---

## Splunk Download and URL Pasting Issue

### Problem

I attempted to use `wget` inside Ubuntu to download the Splunk `.deb` package directly, but copying and pasting the long Splunk download URL into the VMware console was unreliable.

At one point, the URL was entered incorrectly and `wget` attempted to resolve `https` as a hostname.

### Cause

Clipboard sharing was not working properly in the fresh Ubuntu Server VM, and the VMware console was not convenient for pasting long URLs.

### Fix

I stopped trying to paste the URL and transferred the downloaded `.deb` package from macOS to Ubuntu using SCP.

### Lesson Learned

When clipboard sharing is unreliable, SCP is a cleaner and more repeatable method for transferring files into a Linux VM.

---

## Splunk Running as Root / Service User Issue

### Problem

After installing Splunk, I attempted to start it with:

```bash
sudo /opt/splunk/bin/splunk start --accept-license
```

Splunk displayed a warning that running Splunk Enterprise as root is deprecated. The service also did not remain stable at first.

### Cause

Splunk was installed under `/opt/splunk`, but it needed to run more reliably under a dedicated service account instead of root.

### Fix

I created a dedicated `splunk` user, changed ownership of the Splunk directory, and enabled boot-start under that user.

```bash
sudo useradd -m splunk
sudo chown -R splunk:splunk /opt/splunk
sudo /opt/splunk/bin/splunk enable boot-start -user splunk
```

Verification commands:

```bash
id splunk
ls -ld /opt/splunk
ps -ef | grep splunk
sudo /opt/splunk/bin/splunk status
```

### Lesson Learned

Security services should not normally run as root. Using a dedicated service account improves stability and better reflects real-world service management.

---

## Port 8000 Binding Issue

### Problem

Splunk Web failed to start because port `8000` was already in use.

At the same time, Splunk status showed that `splunkd` was not running.

### Cause

A stale Splunk process was still holding port `8000`, even though Splunk did not report itself as running.

### Investigation

I checked the process using port `8000`:

```bash
sudo ss -tulpn | grep :8000
```

This showed that a `splunkd` process was still bound to the port.

### Fix

I terminated the stale process by PID.

```bash
sudo kill <PID>
```

After the port was released, Splunk was able to bind to port `8000` again.

### Lesson Learned

A service can appear stopped from the application’s perspective while a leftover process still holds a network port at the OS level.

---

## Disk Space and Ubuntu LVM Issue

### Problem

Splunk failed during startup with errors similar to:

```text
No space left on device
```

### Cause

The VMware virtual disk had been expanded to `50GB`, but Ubuntu’s LVM root volume was still much smaller. The root filesystem was mounted at:

```text
/dev/mapper/ubuntu--vg-ubuntu--lv
```

and was at `100%` usage.

### Investigation

I checked disk usage and volume layout with:

```bash
df -h
lsblk
sudo vgs
sudo lvs
```

This showed that the virtual disk was larger than the filesystem Ubuntu was actually using.

### Fix

I extended the logical volume and resized the filesystem.

```bash
sudo lvextend -r -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```

Then I confirmed the new available space:

```bash
df -h
```

### Lesson Learned

Increasing a VM disk does not automatically mean the guest OS filesystem is using the extra space. LVM may need to be extended manually.

---

## Splunk Web Access from macOS

### Problem

Splunk was running inside Ubuntu, but Safari on macOS could not connect to the Splunk web interface.

### Investigation

Inside Ubuntu, I confirmed Splunk worked locally:

```bash
curl http://localhost:8000
```

This returned HTML, which meant Splunk Web was functioning inside the VM.

I also checked that Splunk was listening on all interfaces:

```bash
sudo ss -tulpn | grep :8000
```

Then I checked the VM IP:

```bash
ip a
```

### Cause

The VM had multiple IP addresses, and I initially used the wrong one. After moving to VMware’s **Private to My Mac** network, the active interface IP changed.

### Fix

I used the correct IPv4 address under the active VMware interface and tested from macOS:

```bash
curl http://<splunk-ip>:8000
```

Once the curl test returned HTML from macOS, I opened Splunk in Safari:

```text
http://<splunk-ip>:8000
```

### Lesson Learned

When a VM has multiple addresses or changes network modes, always verify the active interface IP before testing web access.

---

## Nmap Scan Appeared to Stall

### Problem

When scanning Metasploitable from Kali, Nmap appeared to stall at:

```text
Starting Nmap...
```

Ping worked, so the target was reachable.

<img src="../screenshots/kali/07-Kali-nmap%20-n%20on%20kali%20not%20starrting%20host%20resoluton.png" width="750">

### Cause

The issue was likely related to DNS resolution or host discovery behavior in the isolated lab network.

### Fix

I used `-n` to disable DNS resolution and `-Pn` to skip host discovery.

```bash
nmap -n -Pn -p 22 <metasploitable-ip>
```

Then I scanned the discovered open ports:

```bash
nmap -n -Pn -sV -p 21,22,23,25,80,139,445 <metasploitable-ip>
```

### Lesson Learned

In isolated labs, disabling DNS resolution with `-n` and skipping host discovery with `-Pn` can make Nmap scans more reliable.

---

## Metasploitable SSH Compatibility Issue

### Problem

When trying to SSH from Kali into Metasploitable, Kali rejected the connection because Metasploitable only offered older SSH host key algorithms.

The error mentioned:

```text
ssh-rsa
ssh-dss
```

### Cause

Metasploitable is old and uses deprecated SSH algorithms. Modern Kali disables those by default.

### Fix

For this isolated lab only, I allowed the older SSH algorithm for the connection:

```bash
ssh -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa msfadmin@<metasploitable-ip>
```

### Lesson Learned

Older vulnerable systems may require legacy compatibility options. These should only be used in controlled labs, not production environments.

---

## Metasploitable Syslog Forwarding Issue

### Problem

I wanted Metasploitable to forward authentication logs to Splunk.

At first, I configured Splunk to listen on UDP port `5515` and tried to forward logs from Metasploitable to:

```text
@<SPLUNK-IP>:5515
```

Manual UDP tests worked, but Metasploitable’s syslog forwarding did not reliably send authentication logs into Splunk.

### Cause

Metasploitable uses the older `sysklogd` service, not modern `rsyslog`.

The older `sysklogd` implementation did not reliably support specifying a custom remote syslog port in `/etc/syslog.conf`.

### Investigation

I confirmed manual UDP traffic worked with:

```bash
echo "manual syslog test from metasploitable" | nc -u -w1 <splunk-ip> 5515
```

The event appeared in Splunk, proving that:

- the network path worked
- Splunk’s UDP input worked
- UDP port `5515` was reachable

The problem was specifically Metasploitable’s syslog forwarding behavior.

### Fix

I configured Metasploitable to forward logs using the default syslog destination format:

```text
*.*    @<SPLUNK-IP>
```

This sends syslog to the default UDP port `514`.

Since Splunk was listening on UDP `5515`, I added an iptables redirect on the Splunk VM:

```bash
sudo iptables -t nat -A PREROUTING -p udp --dport 514 -j REDIRECT --to-ports 5515
```

I verified the redirect with:

```bash
sudo iptables -t nat -L PREROUTING -n -v
```

After restarting `sysklogd`, Metasploitable forwarded logs successfully and Splunk received failed SSH login events.

### Lesson Learned

Legacy systems may not support the same logging syntax as modern systems. When working with older syslog implementations, using default syslog behavior and adapting the receiver side can be more reliable.

---

## Final Result

After troubleshooting the issues above, the lab successfully produced an end-to-end SIEM workflow:

```text
Kali Linux failed SSH login
        ↓
Metasploitable authentication log
        ↓
sysklogd forwarding over UDP 514
        ↓
Splunk VM iptables redirect 514 → 5515
        ↓
Splunk UDP input
        ↓
Searchable failed SSH event in Splunk
```

This confirmed that the lab could generate security activity, log it on a vulnerable system, forward it into Splunk, and analyze it through Splunk Search.

---

## Overall Lessons Learned

This lab taught me that cybersecurity projects often involve more than installing tools.

The biggest lessons were:

- Verify each layer separately before assuming where the problem is
- Check local logs before troubleshooting forwarding
- Confirm ports with `ss`
- Confirm storage with `df`, `lsblk`, `vgs`, and `lvs`
- Use manual test events before testing real attack logs
- Older systems may require different approaches than modern Linux systems
- Screenshots and notes should be captured during troubleshooting because terminal scrollback is limited
- Real troubleshooting makes the lab more valuable as a portfolio project
