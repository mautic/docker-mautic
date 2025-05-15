# Mautic's Docker Security Policy

## Goals of the Mautic Docker Image Security Policy
- Maintain a secure official Docker image for Mautic
- Resolve reported security issues specific to the Docker image configuration
- Provide clear documentation on securely deploying and operating the Mautic Docker image
- Establish a transparent process for handling Docker-specific security vulnerabilities

## Scope of Mautic's Docker Security Team
The Mautic Docker Security Team's scope is limited to security issues specific to the official Mautic Docker image, including:

- Docker image configuration
- PHP secure configuration best practices
- Dockerfile security best practices
- Container runtime security concerns
- Docker-specific deployment guidance

The team does not directly handle:

- Mautic core application vulnerabilities (these are handled by the Mautic Security Team and should be raised [here](https://github.com/mautic/mautic/security/advisories/new))
- Third-party plugins not included in the official image
- Custom Docker deployments modified from the official image
- Individual user deployment configurations

## How are vulnerabilities in the underlying base image handled?
Mautic's Docker image is automatically rebuilt every Monday at 00:00 UTC to incorporate the latest security updates from the base image and any updated Debian packages, ensuring that known vulnerabilities are addressed regularly.

## Which Docker image releases get security advisories?

- Security updates will be provided for the most recent minor version of each supported major Mautic version
- Development, alpha, beta, or release candidate Docker images will not receive security advisories
- Docker images for unsupported Mautic versions will not receive security updates

## How to report a Docker security issue

If you discover a potential security vulnerability specific to the Mautic Docker image:

1. Keep it confidential - Do not discuss it publicly in issues, pull requests, forums, or Slack
2. Submit your concern as a private disclosure via GitHub's Security Advisory feature at https://github.com/mautic/docker/security
3. Provide detailed information about the vulnerability, including steps to reproduce and potential impact
4. If possible, you may create a private fork to propose a fix

## How Docker security issues are resolved

Mautic's Docker Security Team follow the [same process as the Mautic Security Team](https://mautic.org/security/how-security-issues-are-resolved/) when resolving issues.

1. The Security Team will triage incoming reports to determine validity and severity
2. Valid issues will be acknowledged within 24 hours and triaged within 7 business days
3. The team will develop and test fixes for confirmed vulnerabilities within 21 business days
4. Security patches are integrated into new Docker image builds on the 2nd and 4th Wednesdays of each month, if applicable
5. Where an urgent fix is required, an out-of-cycle release is made in collaboration with the Mautic Security Team
6. Coordination with the Mautic Security Team will occur when issues overlap with core application security

## Security fix announcements and releases

- Security fixes are announced alongside new Docker image builds
- Critical vulnerabilities may prompt immediate out-of-sequence releases
- Announcements include the severity, affected builds, and remediation steps
- Users will be encouraged to update to the latest secure image version

## Disclosure policy

Mautic's Docker Security Team follows the same Coordinated Disclosure policy as the Mautic Security Team:

- Issues remain private until a fix is available
- Public announcements occur only after secure versions are released
- All community members should adhere to this policy when reporting issues

## Team Membership

Membership in the Docker Image Security Team will follow similar guidelines to those governing [joining the Mautic Security Team](https://mautic.org/security/how-to-join-the-security-team/):

- Limited to individuals with proven track records in the Mautic community
- Members should have Docker expertise and security knowledge
- Regular participation is expected