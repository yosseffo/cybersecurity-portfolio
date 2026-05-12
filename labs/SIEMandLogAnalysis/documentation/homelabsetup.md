# Homelab Setup

## Overview

This document covers the setup of my cybersecurity homelab for the SIEM Implementation and Log Analysis project.

The lab is built on a dedicated 2019 MacBook Pro running VMware Fusion. I chose to use this laptop instead of my personal computer so I could keep the lab separate from my daily-use system and safely run intentionally vulnerable machines.

The goal of this setup is to create a small, controlled environment where I can practice:

- Building and managing virtual machines
- Working with Linux servers
- Segmenting a lab network
- Running a vulnerable target machine
- Deploying Splunk as a SIEM
- Generating and reviewing security logs

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

## Hardware Restoration

Before using this MacBook as a homelab machine, I had to fix a hardware issue. The laptop had a swollen battery from prior long-term use and storage conditions.

Since this machine would be used to run multiple virtual machines, I did not want to build the lab on hardware that was already showing signs of battery failure. I replaced the battery first so the laptop could be used more safely and reliably during longer lab sessions.

Photos were taken during the replacement process and stored in the project folder.

### Battery Replacement Photos

![Swollen battery before replacement](../media/hardware/swollen-battery-before.jpg)

![Battery removed](../media/hardware/battery-removed.jpg)

![Replacement battery installed](../media/hardware/replacement-battery-installed.jpg)

---

## Host Preparation

The laptop was originally running macOS Mojave 10.14.6. Before installing VMware Fusion and the lab VMs, I upgraded it to macOS Sequoia.

This was needed because Mojave was outdated and could have caused compatibility issues with newer virtualization tools, Linux ISO files, and security software.

After the OS upgrade, I installed VMware Fusion and began building the VM environment.

---

## Virtualization Platform

I used VMware Fusion as the Type-2 hypervisor for this lab.

I chose VMware Fusion because it works well on macOS and gives me enough control over VM resources and networking for this project. It also gives me experience with a virtualization platform that is closer to what is used in professional environments compared to only using lightweight local tools.

---

## Lab Architecture

The lab is currently made up of three main systems:

| Zone | Virtual Machine | Purpose |
|---|---|---|
| Management Zone | Kali Linux | Attacker machine for scanning and testing |
| Server Zone | Metasploitable | Intentionally vulnerable target machine |
| Security Zone | Ubuntu Server + Splunk | SIEM and log analysis server |

This setup lets me practice both offensive and defensive workflows. Kali is used to generate activity, Metasploitable acts as the vulnerable target, and Splunk is used to review and analyze logs.
