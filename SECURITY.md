# Security Policy

## Supported Versions

This repository contains a static project review template and local generation scripts. The latest `main` branch is the supported version.

## Reporting a Vulnerability

Please open a private security advisory or contact the repository owner before publishing details if you find:

- a credential, token, or personal path accidentally committed
- a script behavior that could overwrite files outside the repository
- a template payload that causes unsafe behavior in supported import tools

Do not include secrets in public issues or pull requests.

## Local Script Safety

The scripts are intended to run from this repository root and generate template/export artifacts only inside the repository or a temporary directory.
