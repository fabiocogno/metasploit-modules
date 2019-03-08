---
layout: default
---

# Total.js < 3.2.4 Traversal
This module allows you to test if a Total.js web application is vulnerable to directory traversal with three different actions. The 'CHECK' action (default) is used to automatically find if directory traversal exists in the web server, and then return the Total.js version and application information. The 'DOWNLOAD' action shares the same ability as 'CHECK', but will take advantage of the payload to download a file of your choosing. The 'READ' action can be used to read a file of your choosing directly from the console.

Here is a list of accepted extensions: flac, jpg, jpeg, png, gif, ico, js, css, txt, xml, woff, woff2, otf, ttf, eot, svg, zip, rar, pdf, docx, xlsx, doc, xls, html, htm, appcache, manifest, map, ogv, ogg, mp4, mp3, webp, webm, swf, package, json, md, m4v, jsx, heif, heic.

## Module Name

auxiliary/scanner/http/totaljs_traversal

## Authors

* Riccardo Krauter (Discovery)
* Fabio Cogno (Metasploit Module)

## Disclosure date

Feb 18, 2019

## Actions

* CHECK
* DOWNLOAD
* READ

## Reliability

[Normal](https://github.com/rapid7/metasploit-framework/wiki/Exploit-Ranking)

## References

* [CWE-22](https://cwe.mitre.org/data/definitions/22.html)
* [Total.js blog: A critical security fix for Total.js framework](https://blog.totaljs.com/blogs/news/20190213-a-critical-security-fix/)
* [snyk](https://snyk.io/vuln/SNYK-JS-TOTALJS-173710)

## Required Options

* RHOST - The target address
* RPORT - The target port (TCP)

## Not Required Options

* TARGETURI - Path to Total.js App installation ("/" is the default)
* DEPTH - Traversal depth ("1" is the default)
* FILE - File to obtain ("databases/settings.json" is the default for Total.js CMS App)

## Basic Usage

To display the available options, load the module within the Metasploit console and run the commands 'show options':

```
msf > use auxiliary/scanner/http/totaljs_traversal
msf auxiliary(http_traversal) > show actions
         ...actions...
msf auxiliary(http_traversal) > set ACTION <action-name>
msf auxiliary(http_traversal) > show options
         ...show and set options...
msf auxiliary(http_traversal) > run
```