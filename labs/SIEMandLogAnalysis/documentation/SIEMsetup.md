# SIEM Setup and Log Ingestion

## Overview

This document covers the SIEM setup portion of my homelab project.

The goal was to install Splunk on an Ubuntu Server VM, configure it to receive logs from Metasploitable, and confirm that activity generated from Kali Linux could appear as searchable events inside Splunk.

This part of the lab ended up being the most troubleshooting-heavy section of the project. The main challenges were getting Splunk installed, fixing service startup issues, dealing with disk space problems, and figuring out how to forward logs from Metasploitable’s older syslog service into Splunk.

---

## SIEM VM Base System

Splunk was installed on an Ubuntu Server VM inside VMware Fusion.

The Ubuntu VM was used as the dedicated SIEM server for the lab.

| Component | Details |
|---|---|
| Operating System | Ubuntu Server |
| SIEM Platform | Splunk Enterprise |
| Hypervisor | VMware Fusion |
| Network Mode | Private to My Mac |
| Role | Security / Monitoring Zone |

Ubuntu Server was chosen because it is lightweight, commonly used in server environments, and supports Splunk installation through a `.deb` package.

---

## Splunk Package Transfer

The Splunk `.deb` installer was originally downloaded on the macOS host machine.

At first, I tried to move the file into the Ubuntu VM using VMware drag-and-drop and shared folders, but those options were not available because VMware Tools were not installed and running inside the Ubuntu Server VM.

I also tried using `wget`, but copying and pasting the long Splunk download URL into the VM was unreliable.

The working solution was to transfer the package from macOS to Ubuntu using SCP.

```bash
scp ~/Desktop/splunk*.deb <ubuntu-user>@<ubuntu-ip>:/home/<ubuntu-user>/
```

This copied the Splunk installer from the MacBook desktop into the Ubuntu VM over SSH.

This was a useful workaround because it avoided relying on VMware shared folders and also gave me practice with secure file transfer between systems.

---

## Splunk Installation

After transferring the `.deb` package into Ubuntu, I installed it using `dpkg`.

```bash
sudo dpkg -i splunk*.deb
```

This unpacked and installed Splunk under:

```text
/opt/splunk
```

After installation, I attempted to start Splunk with:

```bash
sudo /opt/splunk/bin/splunk start --accept-license
```

At this point, Splunk displayed a warning about running Splunk Enterprise as root. This led to additional troubleshooting because Splunk did not stay running properly at first.

---

## Splunk Service User Configuration

During initial startup, Splunk was being run as root. Splunk warned that running as root is deprecated, and the service did not remain stable.

To fix this, I created a dedicated `splunk` service user, changed ownership of the Splunk installation directory, and configured Splunk to start under that user.

```bash
sudo useradd -m splunk
sudo chown -R splunk:splunk /opt/splunk
sudo /opt/splunk/bin/splunk enable boot-start -user splunk
```

After this change, Splunk was able to run more reliably under the dedicated service account.

Verification commands used:

```bash
id splunk
ls -ld /opt/splunk
ps -ef | grep splunk
sudo /opt/splunk/bin/splunk status
```

This step helped me better understand Linux service accounts, ownership, and why production services should not normally run as root.

---

## Splunk Startup and Port 8000 Issue

After Splunk was installed, I ran into an issue where Splunk reported that port `8000` was already in use.

Port `8000` is the default Splunk Web port. Even though Splunk status showed that `splunkd` was not running, the port was still being held by a stale Splunk process.

I identified the process using:

```bash
sudo ss -tulpn | grep :8000
```

After finding the stale `splunkd` process, I terminated it using its process ID.

```bash
sudo kill <PID>
```

After clearing the stale process, Splunk was able to bind to port `8000` again.

This showed me that a service can appear stopped from the application’s point of view while a leftover process is still holding a port at the operating system level.

---

## Disk Space and LVM Expansion

Another major issue was Splunk failing to start because Ubuntu reported:

```text
No space left on device
```

At first, I thought the VMware disk had enough space because the virtual disk was set to `50GB`. However, inside Ubuntu, the root filesystem was much smaller.

I checked disk usage with:

```bash
df -h
```

The root filesystem was mounted at:

```text
/dev/mapper/ubuntu--vg-ubuntu--lv
```

and was at `100%` usage.

I then checked the disk and logical volume layout with:

```bash
lsblk
sudo vgs
sudo lvs
```

This showed that the VMware disk was `50GB`, but the Ubuntu LVM root volume was only using a smaller portion of the available disk.

The fix was to extend the logical volume:

```bash
sudo lvextend -r -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```

After resizing, I confirmed the available space with:

```bash
df -h
```

The root filesystem showed significantly more available space, which allowed Splunk to start properly again.

This was one of the most useful troubleshooting moments in the lab because it showed the difference between increasing a virtual disk and actually expanding the guest operating system’s usable filesystem.

---

## Splunk Web Access

Once Splunk was running, I accessed the Splunk web interface from the macOS host browser.

The Splunk VM was moved to VMware Fusion’s **Private to My Mac** network, and I confirmed its IP address with:

```bash
ip a
```

I confirmed Splunk was listening on port `8000` with:

```bash
sudo ss -tulpn | grep :8000
```

Then I tested access from macOS using:

```bash
curl http://<splunk-ip>:8000
```

Once the curl test returned HTML, I opened the Splunk web interface in Safari:

```text
http://<splunk-ip>:8000
```

This confirmed that Splunk Web was reachable from the host machine while still keeping the lab isolated from the home network.

---

## UDP Syslog Input in Splunk

To receive logs from Metasploitable, I configured a UDP input in Splunk.

At first, I attempted to create the input through Splunk Web, but the input did not appear to save correctly. I verified this by checking Splunk’s input configuration files and not finding the port listed.

To fix this, I manually added a UDP input to Splunk’s `inputs.conf`.

```bash
echo -e '[udp://5515]\nsourcetype = syslog\nindex = main\ndisabled = 0' | sudo tee -a /opt/splunk/etc/system/local/inputs.conf
```

Then I restarted Splunk:

```bash
sudo /opt/splunk/bin/splunk restart
```

I verified that Splunk was listening on UDP port `5515` with:

```bash
sudo ss -ulpn | grep :5515
```

This confirmed that Splunk was ready to receive UDP syslog data.

---

## Metasploitable Syslog Forwarding

Metasploitable uses an older logging service called `sysklogd`.

At first, I tried to configure forwarding using `/etc/rsyslog.conf`, but Metasploitable was not using `rsyslog`, so that configuration did not apply.

I confirmed the older logging service and moved to configuring:

```text
/etc/syslog.conf
```

The working forwarding rule was:

```text
*.*    @<SPLUNK-IP>
```

This tells Metasploitable to forward all syslog messages to the Splunk VM using the default syslog UDP port `514`.

The rule was added with:

```bash
echo '*.*    @<SPLUNK-IP>' | /usr/bin/sudo tee -a /etc/syslog.conf
```

Then I restarted `sysklogd`:

```bash
/usr/bin/sudo /etc/init.d/sysklogd restart
```

The service restarted successfully.

---

## Why iptables Redirect Was Needed

Splunk was configured to listen on UDP port `5515`, not UDP port `514`.

Port `514` is the default syslog port, but it is a privileged port. Since Splunk was running as a non-root service user, using a higher port like `5515` was easier and safer for the lab.

The issue was that Metasploitable’s older `sysklogd` service did not reliably support forwarding to a custom remote syslog port using syntax like:

```text
@<SPLUNK-IP>:5515
```

Manual UDP testing with `nc` showed that Splunk could receive events on port `5515`, but syslog forwarding from Metasploitable did not work reliably when a custom port was specified.

The final working solution was:

```text
Metasploitable sends syslog to UDP 514
Splunk VM redirects UDP 514 to UDP 5515
Splunk receives the event on UDP 5515
```

The redirect was created on the Splunk VM with:

```bash
sudo iptables -t nat -A PREROUTING -p udp --dport 514 -j REDIRECT --to-ports 5515
```

I verified the redirect rule with:

```bash
sudo iptables -t nat -L PREROUTING -n -v
```

This allowed Metasploitable to use its default syslog behavior while Splunk continued listening on the non-privileged port `5515`.

---

## Manual Syslog Test

Before testing SSH logs, I generated a manual syslog message from Metasploitable.

```bash
logger "default syslog forwarding test through UDP 514 redirect"
```

This command creates a test syslog message locally on Metasploitable.

The event appeared in Splunk using the search:

```spl
index=main "default syslog forwarding test"
```

This confirmed that:

- Metasploitable could generate syslog messages
- `sysklogd` could forward logs
- UDP traffic was reaching the Splunk VM
- The iptables redirect was working
- Splunk was indexing the event

---

## SSH Log Ingestion Test

After confirming manual syslog forwarding worked, I generated a failed SSH login attempt from Kali Linux against Metasploitable.

```bash
ssh -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa fakeuser@<METASPLOITABLE-IP>
```

The extra SSH options were needed because Metasploitable uses older SSH host key algorithms that modern Kali disables by default.

The failed SSH attempt created an authentication log on Metasploitable. That log was then forwarded into Splunk.

I confirmed the event in Splunk with searches like:

```spl
index=main "fakeuser"
```

and:

```spl
index=main "Failed password" OR "Invalid user"
```

This confirmed that the end-to-end log pipeline was working.

---

## Final SIEM Pipeline

The final working pipeline was:

```text
Kali Linux
  → failed SSH login attempt

Metasploitable
  → writes authentication event to local logs
  → forwards syslog using sysklogd over UDP 514

Ubuntu Server / Splunk VM
  → redirects UDP 514 to UDP 5515 using iptables
  → Splunk UDP input receives the event
  → event is indexed into Splunk

Splunk Web
  → event is searchable through Search & Reporting
```

---

## Final Outcome

The SIEM setup was successful.

I was able to generate failed SSH login activity from Kali Linux, have Metasploitable log that activity, forward the log to Splunk, and search the event inside Splunk.

This completed the main technical goal of the lab: proving that attacker activity could be collected and analyzed through a SIEM.

---

## Lessons Learned

This part of the lab taught me that SIEM setup is not just about installing Splunk. A lot of the work came from making different systems communicate correctly.

The biggest lessons were:

- Service accounts matter for running security tools properly
- File ownership can prevent services from starting correctly
- A virtual disk being large does not always mean the Linux filesystem is using all of it
- `df`, `lsblk`, `vgs`, and `lvs` are useful for storage troubleshooting
- Old Linux systems may use older logging services like `sysklogd`
- UDP syslog forwarding behaves differently from TCP forwarding
- Default syslog port behavior matters with legacy systems
- `iptables` can be used to bridge compatibility gaps
- Manual test events are useful before troubleshooting real attack logs
- End-to-end validation is important before assuming a SIEM pipeline works
