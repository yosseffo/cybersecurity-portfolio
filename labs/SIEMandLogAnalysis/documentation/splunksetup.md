## Splunk Installation Troubleshooting Workaround

During the deployment of Splunk Enterprise, there was an issue on the Ubunty Server SIEM VM regrding file transfering and networking.

There were initial attempts to transfer the Splunk '.deb' package into Ubuntu by using VMware Fusion's drag and drop feature as well as shared folders but both options failed due to VMware Tools not being installed on the server environment.

The most efficient work around was to utilize 'wget' in order to download the Splunk package within the VM. 
This method also ended up failing due to hostname resolution and network issues that were occuring within the Ubuntu Server.

In order to resolve this issue, Secure Copy Protocol (SCP) was utilized in order to effectively transfer the Splunk '.deb' package from the macOS Host machine to Ubuntu Server VM over Secure Shell (SSH)

### Steps Taken
1. Verified SSH accessibility on the Ubuntu Server VM
2. Identified VM IP address using;
   '''bash
   ip a
   '''
3. Opened macOS terminal on host machine
4. Used SCP to transfer package
   '''bash
   scp~/Desktop/splunk*.deb username@<VM-IP>:/home/username
5. Verified file transfer within Ubuntu using;
   '''bash
   sudo dpkg -i splunk*.deb
   '''

### Key Takeaways
Throughout this process of troubleshooting, I was able to familiarize myself with:
- Linux package management
- SSH and SCP file transfering
- VMware virtualization limitations
- Ubuntu Server networking behavior
- Alternative deployment methodologies
- Infrastructure troubleshooting and adaptation
______________

## Splunk Service User Configuration
During initial deployment, Splunk was installed under the root user, which resulted in service startup instability and failure of Splunkd (daemon) to function. 
This was due to policy changes from Splunk where running as a root user is deprecated and blocked by default. 
To resolve this issue, a dedicated service account was created where ownership of the Splunk installation directory was reallocated.
Splunk was configured to run as a non-root service using its built in boot-start

## Commands used:
``` bash
sudo useradd -m splunk
sudo chown -R splunk:splunk /opt/splunk
sudo /opt/splunk/bin/splunk enable boot-start -user splunk

## Outcome
Splunkd was able to run stablized under the dedicated account.

(Splunk confirmation screenshot)
