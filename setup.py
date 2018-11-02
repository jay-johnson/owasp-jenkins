import os
import sys
import warnings
import unittest

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

try:
    from distutils.command.build_py import build_py_2to3 as build_py
except ImportError:
    from distutils.command.build_py import build_py

"""
https://packaging.python.org/guides/making-a-pypi-friendly-readme/
check the README.rst works on pypi as the
long_description with:
twine check dist/*
"""
long_description = open('README.rst').read()

cur_path, cur_script = os.path.split(sys.argv[0])
os.chdir(os.path.abspath(cur_path))

install_requires = [
    'ansible>=2.4',
    'bandit',
    'coverage',
    'docker-compose',
    'flake8',
    'future',
    'mock',
    'paramiko',
    'pep8',
    'pycurl',
    'pylint',
    'python-owasp-zap-v2.4',
    'safety',
    'unittest2'
]


if sys.version_info < (2, 7):
    warnings.warn(
        'Less than Python 2.7 is not supported.',
        DeprecationWarning)


def owasp_jenkins_test_suite():
    test_loader = unittest.TestLoader()
    test_suite = test_loader.discover('tests', pattern='test_*.py')
    return test_suite


# Don't import owasp-jenkins module here, since deps may not be installed
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'owasp_jenkins'))

setup(
    name='owasp-jenkins',
    cmdclass={'build_py': build_py},
    version='1.0.2',
    description=(
        'Automate your OWASP analysis within a '
        'Jenkins docker '
        'container that is preconfigured to use Ansible to '
        'scan and report on potential python security issues '
        'before they are deployed to production.'),
    long_description=long_description,
    author='Jay Johnson',
    author_email='jay.p.h.johnson@gmail.com',
    url='https://github.com/jay-johnson/owasp-jenkins',
    packages=[
        'owasp_jenkins',
        'owasp_jenkins.log'
    ],
    package_data={},
    install_requires=install_requires,
    test_suite='setup.owasp_jenkins_test_suite',
    tests_require=[
    ],
    scripts=[
    ],
    use_2to3=True,
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: Implementation :: PyPy',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ])
