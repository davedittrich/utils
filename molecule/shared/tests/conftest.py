# -*- coding: utf-8 -*-

"""
Pytest testing configuration.
"""


# import sys
from pathlib import Path

from setuptools import setup, find_packages

setup(
  name = 'utils',
  packages = find_packages('../..')
)

# sys.path.append(Path(__file__).parents[2])


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
