# -*- coding: utf-8 -*-

"""
Pytest testing configuration.
"""

from helpers import (
    get_ansible_vars_file,
    get_testinfra_hosts,
)


# def pytest_collectreport(report):
#     print(f'[+] {__file__} loaded')


def pytest_sessionstart(session):
    print("[+] pytest_sessionstart() has been called")
    if len(get_testinfra_hosts()) == 0:
        raise RuntimeError("[-] no hosts found")
    print(f"[+] using cached Ansible runtime variables from 'converge' stored in '{get_ansible_vars_file()}'")


# vim: set ts=4 sw=4 tw=0 et :
