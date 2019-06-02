This example shows how to configure nginx to act as a reverse proxy with ssl support for mautic container.

#### What is handled in this docker-compose.yml:

* Setup of mysql and mautic containers
* Setup of a nginx container with custom vhost configuration (nginx.conf)
* Automatic creation of self-signed certificate

#### How to use this example:

1. `cp .env.example .env`
1. change the passwords if you care about security
1. run `docker-compose up` in this directory
1. add this line to your /etc/hosts file:

        127.0.4.123 mautic.local

1. access https://mautic.local
1. add the presented certificate to a trusted certificates list in your browser (the certificate is a self-signed certificate created on the first run of this example)
1. go through Mautic setup (on the database setup page, use whatever password is set for `MYSQL_MAUTIC_PASSWORD` in your `.env` file)
1. test Mautic

#### Notes
* The certificate should be made trustworthy. It may not be enough to just click trough the warning in some browsers.
* The hosts mapping is needed to make the certificate trustworthy (name must match with certificate's CN).
* If you want to access the container remote machine you should replace 127.0.4.123 with address of your docker host.
