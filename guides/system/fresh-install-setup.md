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

## Static IP address

In order to effectively interconnect the instances (and avoid more complex methods), the nodes should have an static IP address assigned in the local network. The following steps describe the process