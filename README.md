rvirt
=====
This is a JRuby script for using oVirt and RHEV-M REST API. Right now, this script does very little. It is primarily a proof of concept to demonsrate accessing the Virualization Manager's API using a languae other than Python or pure Java.

Version
-------
20121026

Why JRuby?
----------
As of version 20121026, this program does not use any specific JRuby features, so in theory, and RVM should be able to execute this script. Th future of this tool does plan to leverage some JRuby specific features such as Swing.


GEM Dependencies
----------------
rvirt requires some 3rd-party gems in order to run. 

    jgem install rest-client
    jgem install xml-simple


Command Line Usage
------------------

    rvirt :: oVirt & RHEV-M API Client
    This program comes with ABSOLUTELY NO WARRANTY
    Usage: 
 
     -g, --genconfig                  Build sample configuration.
     -H, --listhosts                  List RHEV Hypervisors.
     -V, --listvms                    List Virtual Machines.
     -M, --hostmaint HOST             Toggle Host Maintentance mode.
     -S, --vmstatus NAME              Get VM status by name
     -A, --action ACTION              VM Action: start|shutdown|poweroff
     -N, --vmname NAME                Specify VM name (used with --action
     -c, --cacert                     Retrieve CA Cert.
     -v, --version                    Print version and exit.
     -h, --help                       Show this help message.

