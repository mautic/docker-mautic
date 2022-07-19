This example shows how to configure nginx to act as a reverse proxy with ssl support for mautic container.

#### What is handled in this docker-compose.yml:

* Setup of mysql and mautic containers
* Setup of mysql db on managed or remote server
* Setup of a nginx container with custom vhost configuration (nginx.conf)and secure with letsencrypt certs

#### How to use this example:

1. run ```docker-compose up``` in this directory
2. add these lines to your /etc/hosts file 
```127.0.0.1       pilotdev9.eastbayinfo.org ```
``` 127.0.4.123 mautic.local ```
3. access https://pilotdev9.eastbayinfo.org
4. go through Mautic setup (fill ```mauticdbpass``` as mysql password on db setup page
6. test Mautic

#### Notes
* The certificate should be made trustworthy. It may not be enough to just click trough the warning in some browsers.
* The hosts mapping is needed to make the certificate trustworthy (name must match with certificate's CN).
* If you want to access the container remote machine you should replace 127.0.4.123 with address of your docker host.
