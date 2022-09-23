# -*- coding: utf-8 -*-

"""
Pytest testing configuration.
"""

# def pytest_collectreport(report):
#     print(f'[+] {__file__} loaded')


def pytest_sessionstart(session):
    print("pytest_sessionstart() has been called")


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
