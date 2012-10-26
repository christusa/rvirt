rvirt
=====

JRuby script for using oVirt and RHEV-M REST API. 

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


