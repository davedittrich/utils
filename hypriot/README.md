# HypriotOS demonstration deployment

This directory holds content used for producing a demonstration
deployment of the `davedittrich.utils` Ansible collection onto a
Raspberry Pi using Hypriot's `hypriotos` operating system
distribution customized with the playbook `davedittrich.utils.workstation_setup`
from configuration settings and secrets managed with `python_secrets`
(`psec`).

## Secure by default installation using ``psec``

You can avoid having a default password and automatically apply working defaults for
most variables you may later want to change using [``psec``](https://pypi.org/project/python-secrets/).

The steps that accomplish initial configuration are the following, but they will
be done automatically in later steps:

```
$ psec environments create --clone-from sample/hypriot.json
$ psec secrets generate --from-options
```

When ever you need to see the current variable settings (including the
generated password), do:

```
$ psec secrets show --no-redact
+--------------------------+------------------------+--------------------------+
| Variable                 | Value                  | Export                   |
+--------------------------+------------------------+--------------------------+
| hypriot_user             | pirate                 | hypriot_user             |
| hypriot_password         | HAMLET.usher.LEND.lazy | hypriot_password         |
| hypriot_hostname         | hypriot                | hypriot_hostname         |
| hypriot_eth0_addr        | 192.168.50.1           | hypriot_eth0_addr        |
| hypriot_client_psk       | None                   | hypriot_client_psk       |
| hypriot_client_ssid      | None                   | hypriot_client_ssid      |
| hypriot_pubkey           | None                   | hypriot_pubkey           |
| hypriot_locale           | en_US.UTF-8            | hypriot_locale           |
| hypriot_timezone         | America/Los_Angeles    | hypriot_timezone         |
| hypriot_wifi_country     | US                     | hypriot_wifi_country     |
| hypriot_keyboard_model   | pc105                  | hypriot_keyboard_model   |
| hypriot_keyboard_layout  | us                     | hypriot_keyboard_layout  |
| hypriot_keyboard_options | ctrl:swapcaps          | hypriot_keyboard_options |
+--------------------------+------------------------+--------------------------+
```

To facilitate logging in right away with SSH (or using `molecule` with the
`delegated` driver to test against your Raspberry Pi), set the `hypriot_pubkey`
variable with the public key you want to use.

```
$ psec secrets set hypriot_pubkey="$(cat ~/.ssh/id_rpi.pub)"


To create your SD card using the variables above, do:

```
$ make flash
```

Now log in with username (``pirate``, by default) and the password generated for you.

```
$ ssh pirate@hypriot.local
```

# References

* https://linuxhint.com/set_screen_resolution_linux_kernel_boot/
* https://pimylifeup.com/raspberry-pi-screen-resolution/
