# Fresh install setup

This entry includes the basic commands that must be run after a fresh install of the OS and are the same for Control Plane and workers. The following instructions target Debian 12 Bookworm installations without desktop environment and with preinstalled SSH server.

## Root user access

Debian doesn't ships with the sudo tool by default. It has to be installed from the root account, for which:

1. Change to the root account

```
su -
```

The password would be the one set in the "setup root password" when installing the system

2. Use standard apt installation

```
apt update && apt install sudo -y
```

3. Add the user to the sudo group

```
usermod -aG sudo <user-name>
```

4. Log out and log back in

> [!WARNING]
>
> In my case, even after following this steps, the error `user is not in sudoers file...` kept showing even after adding the user to the group (and after rebooting). If that happens, it must be manually added to sudoers. For that, from the root user:
> 1. Open the sudoers file using visudo (**very important to avoid accidental corruptions of the file**)
>
>       ```sh
>       visudo
>       # It tends to work out of the box, if not, refer to the full path:
>       usr/sbin/visudo
>       ```
>
> 2. Search for the line referring to the root account
>
>       ```root    ALL=(ALL:ALL) ALL```
>
> 3. Add the following line below:
>
>       ```user-name ALL=(ALL:ALL) ALL```
>
> 4. Save the file and exit the root account, sudo should work now (may be necessary to reboot)

### Automation scripts

Within the scripts folder the `sudo-setup.sh` script automates the workflow to install sudo if needed and to set up the current user. Copy it to a .sh file inside the machine and run:

```sh
    bash <script-name>.sh -u <username>
```

While it contains some basic security features and validations, it's still potentially vulnerable and only intended for setup within this project, hence it should not be considered for real world use cases.

## Remote Access

This section heavily depends on the real layout of the cluster. Physical nodes wouldn't require initial setup to be accessed over the network (as stated before, SSH server was included in the install). The developed scenario used virtual nodes running as VirtualBox guests. In such case (and in virtualized scenarios, but instructions are related to VirtualBox), it is required to set the network adapter to Bridged Adapter, for which:

1. Go to the virtual machine settings

2. Go to Network (or Networking) section

3. In adapter 1 (or the active network adapter) set the "Connected to" field to Bridged Adapter

4. If not auto-filled, set the name of the adapter to that of the host machine from the dropdown menu

### Static IP address

In order to effectively interconnect the instances (and avoid more complex methods), the nodes should have an static IP address assigned in the local network. The following steps describe the process:
 
1. Identify the DHCP range of the local network (for routed-based networks, it is found on the router configuration page, usually 192.168.1.1)

2. Identify the mask (usually 255.255.255.0)

3. Define an IP address that complies with the mask but falls outside the DHCP range (for instance, for a range between 192.168.1.10 and 192.168.1.100 and mask 255.255.255.0, a safe address would be 192.168.1.150)

4. Find the name of the network interface in use

```sh
ip -c link show
```

It should be the one displaying the "UP" state

5. Create a backup of the network interfaces file

```sh
sudo cp /etc/network/interfaces /root/
```

6. And edit it (`sudo nano /etc/network/interfaces`) replacing the lines corresponding to the name of the identified network interface with:

```sh
auto <interface name>
iface <interface name> inet static
 address <desired ip address>
 netmask <local network mask>
 gateway <local network gateway>
```

7. Restart the networking service

```sh
sudo systemctl restart networking
```

> [!WARNING]
>
> If done via SSH will cause the session to end