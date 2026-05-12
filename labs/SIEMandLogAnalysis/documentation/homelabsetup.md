# Homelab Setup

## Overview

This document outlines the setup process for the cybersecurity homelab used in the **SIEM Implementation and Log Analysis** project.

The homelab was built on a dedicated 2019 MacBook Pro using VMware Fusion. The environment is designed to simulate a small security operations lab with an attacker machine, vulnerable target system, and SIEM monitoring server.

The purpose of this setup is to provide a safe, isolated environment for practicing:

- Virtualization
- Network segmentation
- Linux administration
- Vulnerability testing
- SIEM deployment
- Log analysis
- Security monitoring

---

## Host System

| Component | Details |
|---|---|
| Host Machine | MacBook Pro 2019 |
| Original OS | macOS Mojave 10.14.6 |
| Updated OS | macOS Sequoia |
| Hypervisor | VMware Fusion |
| Available Storage at Start | 98.95 GB |

---

## Hardware Restoration and Battery Replacement

Before being repurposed as a dedicated cybersecurity homelab machine, the 2019 MacBook Pro required hardware remediation due to a swollen battery from prior long-term usage and storage conditions.

Because the system would be used for virtualization workloads, including multiple virtual machines and SIEM services, restoring the hardware was an important first step before deploying the lab environment.

### Issue Identified

The laptop showed signs of battery swelling, which can create safety risks and affect device usability. Since the system was intended to run virtualized workloads for extended periods, the battery issue needed to be resolved before continuing with the homelab build.

### Remediation Performed

The battery was replaced before the laptop was used as the homelab host.

This process helped ensure:

- Safer operation during extended lab sessions
- More reliable power behavior
- Improved system stability
- Reduced risk during virtualization workloads
- A cleaner foundation for dedicated lab use

### Documentation

Photos were taken during the battery replacement process to document the hardware restoration stage of the project.

Example images documented:

- Swollen battery before replacement
- Battery removal process
- Replacement battery installed
- Restored MacBook Pro prepared for lab deployment

### Battery Replacement Photos

#### Swollen Battery Before Replacement

![Swollen battery before replacement](../media/hardware/swollen-battery-before.jpg)

#### Battery Removal Process

![Battery removal process](../media/hardware/battery-removed.jpg)

#### Replacement Battery Installed

![Replacement battery installed](../media/hardware/replacement-battery-installed.jpg)

#### Restored MacBook Pro

![Restored MacBook Pro](../media/hardware/restored-macbook.jpg)

### Security and Infrastructure Relevance

Although this was a hardware maintenance task, it was relevant to the overall project because reliable infrastructure is required for effective cybersecurity testing.

This step demonstrates awareness of:

- Hardware reliability
- Safe lab preparation
- Infrastructure readiness
- Operational risk management
- Responsible reuse of older equipment

### Outcome

After the battery replacement, the MacBook Pro was repurposed as a dedicated homelab host for VMware Fusion, Kali Linux, Metasploitable, Ubuntu Server, and Splunk Enterprise.

---

## Host System Preparation

The MacBook Pro was originally running macOS Mojave 10.14.6. Before building the lab, the host operating system was upgraded to macOS Sequoia to improve compatibility with modern virtualization software and security tooling.

This upgrade was important because older macOS versions may have limited support for newer versions of VMware Fusion, Linux ISO files, and modern virtual machine configurations.

The upgrade helped improve:

- Virtualization compatibility
- Security patching
- VMware Fusion stability
- Linux ISO support
- Long-term lab reliability

---

## Hypervisor Selection

VMware Fusion was selected as the Type-2 hypervisor for this lab.

### Reasons for Choosing VMware Fusion

- Supports Linux virtual machines on macOS
- Provides virtual networking options such as NAT and Private to My Mac
- Allows resource allocation for CPU, memory, and disk
- Supports VM snapshots and cloning
- Provides a realistic virtualization environment similar to enterprise infrastructure

---

## Lab Architecture

The lab is designed around three main systems:

| Zone | Virtual Machine | Purpose |
|---|---|---|
| Management Zone | Kali Linux | Attacker machine used for scanning, enumeration, and attack simulation |
| Server Zone | Metasploitable | Intentionally vulnerable target system |
| Security Zone | Ubuntu Server + Splunk | SIEM server used for monitoring and log analysis |

---

## Virtual Machines

### Kali Linux VM

Kali Linux was deployed as the attacker workstation in the lab.

Its purpose is to perform:

- Network scanning
- Service enumeration
- Vulnerability testing
- Exploitation practice
- Attack traffic generation for SIEM analysis

Kali will be used later to generate security events that can be reviewed inside Splunk.

---

### Metasploitable VM

Metasploitable was deployed as the vulnerable target system.

It was selected because it contains intentionally vulnerable services that are useful for practicing penetration testing and security monitoring.

Metasploitable allows safe testing of:

- Port scanning
- Service enumeration
- Exploitation
- Attack detection
- Log generation

The VM was imported using an existing virtual disk file rather than installing a new operating system from scratch.

---

### Ubuntu Server VM

Ubuntu Server was deployed as the base operating system for the SIEM server.

This VM is used to host Splunk Enterprise and act as the monitoring system for the lab.

Ubuntu Server was selected because:

- It is lightweight compared to a desktop Linux distribution
- It is commonly used in server environments
- It supports Splunk installation through `.deb` packages
- It provides a realistic Linux server administration experience

---

## Network Configuration

The lab used VMware virtual networking to separate the lab environment from the host machine and home network.

Two VMware networking modes were used during setup:

| Network Mode | Purpose |
|---|---|
| NAT | Used during installation and setup when internet access was required |
| Private to My Mac | Used for isolated lab testing between virtual machines |

---

## NAT Networking

NAT networking was used during the setup phase to allow the Ubuntu Server VM to access the internet through the MacBook’s network connection.

This was necessary for:

- Ubuntu updates
- Package installation
- Network troubleshooting
- Initial setup tasks

NAT was used as a temporary setup configuration rather than the final lab design.

---

## Private to My Mac Networking

Private to My Mac networking is used for the isolated lab environment.

This mode allows the virtual machines to communicate with each other while keeping intentionally vulnerable systems separated from the home network.

This is important because Metasploitable contains vulnerable services that should not be exposed to external networks.

### Purpose of Isolation

The lab was isolated to:

- Reduce risk to the host network
- Prevent vulnerable services from being exposed externally
- Safely simulate attacks
- Create a controlled testing environment
- Demonstrate network segmentation principles

---

## Resource Management

Because the lab is hosted on a laptop, resource management is important.

To avoid overloading the host system:

- Only required VMs are powered on during each task
- Kali and Metasploitable are shut down when not actively needed
- Splunk is started when monitoring or analysis is being performed
- VM resources are allocated carefully based on each machine’s role

This approach helps reduce CPU and memory usage while maintaining lab stability.

---

## Recommended VM Usage

| Task | VMs Needed |
|---|---|
| Installing Splunk | Ubuntu Server only |
| Testing Splunk web access | Ubuntu Server only |
| Scanning Metasploitable | Kali + Metasploitable |
| SIEM monitoring test | Kali + Metasploitable + Splunk |
| Documentation/screenshots | Only the VM being documented |

---

## Security Considerations

The homelab was designed with safety in mind.

Since Metasploitable is intentionally vulnerable, it should not be exposed directly to the internet or home network.

Security controls used in this setup include:

- Isolated virtual networking
- Dedicated lab machine
- Separation from personal daily-use computer
- Controlled VM startup and shutdown
- Limited internet access during active testing

---

## Challenges Encountered

Several setup challenges were encountered during the build process.

### Hardware Readiness

Before the lab could be safely deployed, the MacBook Pro required battery replacement due to swelling. This reinforced the importance of verifying hardware safety and reliability before using older equipment for virtualization workloads.

### VMware Networking

During Ubuntu Server installation, the VM initially had issues progressing through network configuration. NAT networking was used as a practical workaround to ensure stable internet access and DHCP assignment during setup.

### File Transfer Limitations

VMware shared folders and drag-and-drop were unavailable because VMware Tools were not installed on the Ubuntu Server VM. This was later addressed during the Splunk setup process using SSH-based file transfer.

### Resource Constraints

During Splunk installation, the VM experienced CPU strain, including a soft lockup warning. This highlighted the importance of limiting the number of running VMs and allocating resources carefully.

---

## Current Lab Status

| Component | Status |
|---|---|
| Hardware restoration completed | Complete |
| macOS upgraded | Complete |
| VMware Fusion installed | Complete |
| Kali Linux VM created | Complete |
| Metasploitable VM imported | Complete |
| Ubuntu Server VM installed | Complete |
| Splunk installed on Ubuntu | Complete |
| Splunk service user configured | Complete |
| Splunk daemon running | Complete |
| Log ingestion | Pending |
| Detection rules | Pending |
| Dashboards | Pending |

---

## Planned Improvements

Future improvements to the homelab may include:

- Adding pfSense as a firewall/router VM
- Creating separate virtual subnets for each zone
- Adding Windows Server and Active Directory
- Forwarding logs from Kali and Metasploitable into Splunk
- Creating custom Splunk dashboards
- Writing detection rules for brute force attempts and port scans
- Adding Sysmon logging for Windows-based telemetry
- Creating a formal network topology diagram

---

## Key Takeaways

This homelab setup provided hands-on experience with:

- Hardware restoration and infrastructure preparation
- Virtual machine deployment
- VMware Fusion configuration
- Linux server installation
- Network troubleshooting
- NAT and isolated networking
- Resource management
- Safe vulnerable machine handling
- Security lab architecture planning

The completed environment provides the foundation for future SIEM monitoring, log analysis, attack simulation, and detection engineering projects.
