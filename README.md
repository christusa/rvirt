rvirt
=====
This is a JRuby script for using oVirt and RHEV-M REST API. 

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


Version
-------
20121026 - This program is versioned by the date of the current codebase. There are currently no official releases.


License
-------
GPLv3

FAQ
===

Why JRuby?
----------
As of version 20121026, this program does not use any specific JRuby features, so in theory, any RVM should be able to execute this script. Th future of this tool does plan to leverage some JRuby specific features such as Swing and FreeMarker.

Why not use Libvirt?
--------------------
Libvirt is an abstraction library for more low-level functions; whereas, rvirt is specific to the oVirt-engine/RHEV-M API, which in-turn leverages libvirt on the hypervisor nodes.

What about ovirt-CLI?
---------------------
oVirt-CLI is a great tool, and currently more complete than rvirt, but it is written in Python not Ruby. This project aims to create a Ruby based toolkit.

IRC Channel
-----------
Join #rhev on FreeNode to discuss the project and get assistance. 
  telegardian  (Chris Tusa)