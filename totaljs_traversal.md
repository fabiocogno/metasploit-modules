---
layout: default
---

# Generic HTTP Directory Traversal Utility
This module allows you to test if a Total.js web application is vulnerable to directory traversal with three different actions. The 'CHECK' action (default) is used to automatically find if directory traversal exists in the web server, and then return the Total.js version and application information. The 'DOWNLOAD' action shares the same ability as 'CHECK', but will take advantage of the payload to download a file of your choosing. The 'READ' action can be used to read a file of your choosing directly from the console.

# Module Name

auxiliary/scanner/http/totaljs_traversal

# Authors

Riccardo Krauter (Discovery)

Fabio Cogno (Metasploit Module)

# Disclosure date

Feb 18, 2019

# Actions

CHECK

DOWNLOAD

READ

# Reliability

[Normal](https://github.com/rapid7/metasploit-framework/wiki/Exploit-Ranking)

# Module Options

To display the available options, load the module within the Metasploit console and run the commands 'show options' or 'show advanced':

```
msf > use auxiliary/scanner/http/totaljs_traversal
msf auxiliary(http_traversal) > show actions
         ...actions...
msf auxiliary(http_traversal) > set ACTION <action-name>
msf auxiliary(http_traversal) > show options
         ...show and set options...
msf auxiliary(http_traversal) > run
```