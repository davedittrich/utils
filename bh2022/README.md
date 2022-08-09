This directory contains Ansible playbooks and related files for running Ansible
ad-hoc commands against a lab full of laptops on a local WiFi network.

It contains an `ansible.cfg` file that over-rides specific variables to
simplify Ansible command lines. Make sure you are aware of the contents of this
file for situational awareness of how Ansible is going to behave.

The next critical file is the `inventory.yml` file, which you will have to
construct from some source like the cloud provider console, a log file from
connections originating from student laptops, or an Nmap scan processed with
Ansible to identify student laptops by connecting with the event SSH private
key.

When writing Ansible playbooks, run `ansible-lint` frequently to ensure the
playbooks are valid before testing. This helps immensely when testing playbooks
in development against a large number of hosts on an unstable network. :)
This is facilitated by a helper `Makefile` using `make lint`.

To facilitate SSH access, create an SSH configuration settings snippet for
remotely accessing all hosts with the event private key. Use the name that is
stored in the `ansible.cfg` file so Ansible knows to use it.

```shell
$ cat ~/.ssh/config.d/bh2022
Host 10.220.34.*
    IdentityFile /home/dittrich/.ssh/bh2022-laptops
    Port 22
    User root

Host 10.220.34.73 laptop
    Hostname 10.220.34.73
    IdentityFile /home/dittrich/.ssh/bh2022-laptops
    Port 22
    User root
```

Add the configuration to the SSH configuration.

```shell
$ update-dotdee ~/.ssh/config
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Reading file: ~/.ssh/config.d/antsle
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Reading file: ~/.ssh/config.d/bh2022
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Reading file: ~/.ssh/config.d/github
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Reading file: ~/.ssh/config.d/local
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Reading file: ~/.ssh/config.d/tanzanite
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Checking for local changes to ~/.ssh/config ..
2022-08-06 12:48:54 b2 update_dotdee[16685] INFO Writing file: ~/.ssh/config
```

To run Ansible ad-hoc commands or playbooks, you will need an inventory file. It is
recommended (and is assumed here) that you use a YAML-style inventory file, since
you can then use different variables for sub-groups of hosts for things like
debugging and more easily have visibility and control of those variables.
The first few lines of that file might look like this:

```shell
---
all:
  vars:
    resilio_sync_root: 'APKLC-BH2022'
    host_key_checking: false
    ansible_user: 'root'
    ansible_ssh_private_key_file: '~/.ssh/bh2022-laptops'
  hosts:
    "10.220.34.24":
      vars:
        serial_number "9ZZPXQ3"
    "10.220.34.26":
      vars:
        serial_number "877YXQ3"
    "10.220.34.30":
      vars:
        serial_number "GRWDXQ3"
    "10.220.34.36":
      vars:
        serial_number "3C1YXQ3"
    "10.220.34.21":
      vars:
        serial_number "737YXQ3"
. . .
```


