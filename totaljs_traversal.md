---
layout: default
---

# Generic HTTP Directory Traversal Utility
This module allows you to test if a web server (or web application) is vulnerable to directory traversal with three different actions. The 'CHECK' action (default) is used to automatically (or manually) find if directory traversal exists in the web server, and then return the path that triggers the vulnerability. The 'DOWNLOAD' action shares the same ability as 'CHECK', but will take advantage of the found trigger to download files based on a 'FILELIST' of your choosing. The 'PHPSOURCE' action can be used to download source against PHP applications. The 'WRITABLE' action can be used to determine if the trigger can be used to write files outside the www directory. To use the 'COOKIE' option, set your value like so: "name=value".

# Module Name

auxiliary/scanner/http/totaljs_traversal

# Authors

Riccardo Krauter (Discovery)

Fabio Cogno (Metasploit Module)

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