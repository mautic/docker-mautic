This example shows how to configure nginx to act as a reverse proxy with ssl support for mautic container.

#### What is handled in this docker-compose.yml:

* Setup of mysql and mautic containers
* Setup of a nginx container with custom vhost configuration (nginx.conf)
* Automatic creation of self-signed certificate

#### How to use this example:

1. run ```docker-compose up``` in this directory
2. add this line to your /etc/hosts file ```127.0.4.123 mautic.local```
3. access https://mautic.local
4. add the presented certificate to a trusted certificates list in your browser (the certificate is a self-signed certificate created on the first run of this example)
5. go through Mautic setup (fill ```mauticdbpass``` as mysql password on db setup page
6. test Mautic

#### Notes
* The certificate should be made trustworthy. It may not be enough to just click trough the warning in some browsers.
* The hosts mapping is needed to make the certificate trustworthy (name must match with certificate's CN).
* If you want to access the container remote machine you should replace 127.0.4.123 with address of your docker host.
