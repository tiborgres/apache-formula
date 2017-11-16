# apache formula

This is another example of SaltStack apache formula.

Original purpose was to give the output to one company during my job hunting.

Requst was:

- write the SaltStack formula for installation of httpd 2.4 on RedHat family Linux (for example CentOS)
- formula must support the installation of httpd from various sources (repo, rpm, web)
- requirements for pillar:
	- arbitrary number of virtualhosts
	- defined hostname, alias, port and wwwroot for every virtualhost
	- for every virtualhost must be available to define arbitrary number of proxypassreverse records
	- for arbitrary virtualhost must be available option to define the https settings
		- in this case it is needed to define the SSL certificates in pillar
		- formula must support the copying over these certificates from saltmaster to saltminion
- formula must support these states:
	- install
	- setup - provide the reload/restart of the apache in the case of changed configuration files
	- certificates - installing the certificates on saltminion
	- firewall - opening the relevant ports on server firewall according to apache configuration and virtualhosts ports
	- uninstall

---
My respond:

Delivered SSl certificate inside the pillar is invalid and you should replace it with actual one.
Formula is written for CentOS 6 and 7. In the case of CentOS 6 the `httpd24-httpd` package from SCL repo will be installed.
Installation from local RPM or from external site is supported.
Jinja formatting is not my cup of tea (still).


States:

**install** - install package  
**setup** - package configuration, folders, etc.  
**certificates** - install SSL certificates  
**firewall** - manage firewall rules  
**uninstall** - remove the package and firewall rules from the server
