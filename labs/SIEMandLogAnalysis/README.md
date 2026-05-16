# SIEM Implementation and Log Analysis

## Project Overview

The project documents the progress of a security home lab focusing on SIEM deployment, log analysis, networks segmentation, and attack simulation using virtualized infrastructure.

The environment used was a 2019 used Macbook Pro utilizing VMware Fusion to emulate an organization security architecture. This was setup with an attacker machine, vulnerable target machine, and a centralized SIEM server. 

## Goals of Project
- Deploy and configure a SIEM platform
- Simulate attacker and target systems
- Generate and analyze security logs
- Practice virtualization and network segmenting
- Learn hands on SOC/blue teaming skills
___________________

# Technologies Used
- VMware Fusion
- Kali Linux
- Metasploitable
- Ubuntu Server
- Splunk
- Linux CLI
- SSH
- Virtual Networking
- Nmap
- Metasploit Framework
____________________

# Objective Path

## Phase 1 - Developing Architecture
- Deploy VMware Fusion Environment
- Create isolated virtual network
- Install and Configure virtual machines
- Deploy Ubuntu Server SIEM host

## Phase 2 - SIEM Deployment
- Install Splunk Enterprise
- Configure data ingestion
- Centralize logs
- Validate SIEM accessibility

## Phase 3 - Offensive Security Simulation
- Perform network enumuration using Kali Linux
- Conduct scans against Metasploitable
- Generate attack telemetry
- Monitor activity in Splunk

## Phase 4 - Detection and Monitoring
- Create Splunk Dashboard
- Develop detection queries
- Monitor authentication activity
- Analyze suspicious traffic
____________________

# Skills Learned
- SIEM Deployment
- Log Analysis
- Network segmentation
- Linux administration
- Virtualization
- Hypervisor management
- Security monitoring
- Vulnerability Testing
- SSH configuration
- Infrastructure troubleshooting
______________________

# Challenges Encountered

During the project, there were several incidents where I came across infrastructure and network challenges that were later resolved

- VMware Fusion virtual networking issues
- DHCP troubleshooting within Ubuntu Server
- NAT vs host-only networking configuration
- Resource management limitations on laptop hardware
- Ubuntu Server installer configuration issues

From these issues, I was able to familiarize myself more with:
- Virtualized networking
- Linux server deployment
- Infrastructure stability
- Security architecture planning
_______________________

# Screenshots

## VMware Infrastructure
(Add screenshots here)

## Splunk Dashboard
(Add screenshots here)

## Kali Linux Enumeration
(Add screenshots here)

_______________________

# Documentation

Additional technical documentation can be found in the `/documentation` folder.

Topics include:
- Homelab setup
- VMware networking
- Splunk installation
- Attack simulation walkthroughs

_______________________

# Future Improvements

Planned future enhancements include:
- pfSense firewall integration
- Windows Active Directory deployment
- Sysmon log forwarding
- Custom Splunk alerts
- Detection engineering workflows
- VLAN simulation
- Security Onion integration

_______________________

# Key Takeaways

This project demonstrates the ability to design, deploy, troubleshoot, and document a segmented cybersecurity monitoring environment using enterprise-relevant technologies and security workflows.
