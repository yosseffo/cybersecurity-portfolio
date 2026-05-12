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
   scp~/Desktop/splunk*.deb usernam@<VM-IP>:/home/username
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
- Infrastructure troubleshooting and adaptation. 
