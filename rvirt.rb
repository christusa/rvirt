#!/usr/bin/env jruby
=begin

    Program: rvirt
Description: Accessing the RHEV API using JRuby
     Author: Chris Tusa <christusa@redhat.com>
    License: GPL v3 
-------------------------------------------------------------------------------
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
=end

require 'java'
require 'optparse'
require 'rubygems'
require 'yaml'
require 'rest-client'
require 'xmlsimple'
require 'pp'

Configfile = "/opt/rvirt/rvirt.conf.yaml"
RVIRT_VERSION = 20121025

# Builds a default YAML configuration and outputs the filename specified.
def create_config
  if File.exist?(Configfile) == false
    cfghash = {
        "rhevm" => {
	        "hostname"  => "rhevm.devbox.local",
	        "http_port" => "8080",
	        "https_port"=> "8443",
		"use_ssl"   => false,
	        "user"      => "admin",
        	"domain"    => "internal",
	        "password"  => "secret",
	        "cacert"    => "rhevm-ca.cert"
      }
    }
    f = File.open(Configfile, "w")
    f.puts YAML::dump(cfghash) 
    f.close
  else
    puts "Warning: Configuration file exists, not creating."
  end
end

# Load in the YAML configuration file, check for errors, and return as hash 'cfg'
def load_config
  cfg = File.open(Configfile)  { |yf| YAML::load( yf ) } if File.exists?(Configfile)
  # => Ensure loaded data is a hash. ie: YAML load was OK
  if cfg.class != Hash
     raise "ERROR: Configuration - invalid format or parsing error."
  # => If all is well, perform deeper validation
  else
    # => PARSE & CHECK: rhevm
    if cfg['rhevm'].nil?
      raise "ERROR: Configuration: rhevm not defined."
    end
  end #-> /if !Hash

  # => If all is well, return the configuration
  return cfg
end #/def

# Fetch the RHEV CA Certificate and store it locally.
def fetch_ca_cert
  local_cafile  = ($cfg['rhevm']['cacert'])
  unless File.exists?(local_cafile) == true
    remote_cafile = "http://#{$cfg['rhevm']['hostname']}:#{$cfg['rhevm']['http_port']}/ca.crt"
    print "Fetching CA File from #{remote_cafile} "
    require 'open-uri'
    open(remote_cafile) do |w| 
      f = File.open(local_cafile, "w") 
      f.write(w.read)
      f.close
    end
    puts '[OK]'
  end
end

# Easily create RHEV API URI's from connction settings and a specified target.
def create_uri(target)
   if $cfg['rhevm']['use_ssl'] == true then
     proto = "https"
     port = $cfg['rhevm']['https_port']
   else
     proto = "http"
     port = $cfg['rhevm']['http_port']
   end
   return "#{proto}://#{$cfg['rhevm']['user']}%40#{$cfg['rhevm']['domain']}:#{$cfg['rhevm']['password']}@#{$cfg['rhevm']['hostname']}:#{port}/api/#{target}"

end

# Use the xml-simple gem to parse the API data into a Ruby Hash
def parse_api_data(xmlstring)
 return XmlSimple.xml_in(xmlstring)
end

# Get a list of hosts from RHEV
def list_hosts
  apicall = create_uri("hosts")
  puts "Listing hosts (#{apicall})"
  hosts = parse_api_data(RestClient.get(create_uri("hosts")))
  hosts['host'].each { |h| puts h['name'] }
end

# Get a list of vms from RHEV
def list_vms
  apicall = create_uri("vms")
  puts "Listing vms (#{apicall})"
  vms = parse_api_data(RestClient.get(create_uri("vms")))
  puts "Name                State    Description"
  puts "------------------- -------- -------------------------"
  vms['vm'].each do |v|
    ws = ' ' * (20 - v['name'][0].length).abs
    print v['name'][0] + ws
    ws = ' ' * (9 - v['status'][0]['state'][0].length )
    print v['status'][0]['state'][0] + ws
    unless v['description'].nil? then 
      print v['description'][0]
    end
    puts
  end

#  pp vms
end

# Get a Virtual Machine's Status by name search.
def get_vmstatus_byname(vmname)
  puts "Getting status of (#{vmname})"
  vms = parse_api_data(RestClient.get(create_uri("vms?search=#{vmname}")))
  vms['vm'].each do |v|
    puts "Status = " + v['status'][0]['state'][0]
  end
end

# Get a Virtual Machine's Status by name search.
def is_vm_up?(vmname)
  vms = parse_api_data(RestClient.get(create_uri("vms?search=#{vmname}")))
  state = vms['vm'][0]['status'][0]['state'][0]
  case state
    when 'up'
     return true
    else
     return false
  end
end

# Resolves a Virtual Machine's UUID by retriveing from DB using a name search
def get_vmid_byname(vmname)
  puts "Getting UUID of (#{vmname})"
  vms = parse_api_data(RestClient.get(create_uri("vms?search=#{vmname}")))
  unless vms.empty?
    return vms['vm'].first['id']
  else
    puts "Unable to retrieve vmid_byname"
    exit 1
  end
end

# Resolves a Host's UUID by retriveing from DB using a name search
def get_hostid_byname(hostname)
  puts "Getting UUID of (#{hostname})"
  hosts = parse_api_data(RestClient.get(create_uri("hosts?search=#{hostname}")))
  unless hosts.empty?
    return hosts['host'].first['id']
  else
    puts "Unable to retrieve hostid_byname"
    exit 1
  end
end

# Toggle a host maintenance state
def change_host_maintenance(hostname)
  hostid = get_hostid_byname(hostname)
  puts "ACTION=#{action} NAME=#{vmname} ID=#{vmid}"
  payload = "<action/>"
  header = {:accept => "application/xml", :content_type=> "application/xml"}
end


# Change a virtual machine's power state
def change_vm_state(vmname, action)
     vmid   = get_vmid_byname(vmname)
     puts "ACTION=#{action} NAME=#{vmname} ID=#{vmid}"
     payload = "<action/>"
     header = {:accept => "application/xml", :content_type=> "application/xml"}
     case action
       when 'start'
         unless is_vm_up?(vmname)
           begin
  	     RestClient.post(create_uri("vms/#{vmid}/start"), payload, header)
           rescue RestClient::BadRequest => rce
	     pp rce
           end
	 else 
	   puts "VM is already running."
         end
       when 'poweroff' || 'stop'
         if is_vm_up?(vmname)
           RestClient.post(create_uri("vms/#{vmid}/stop"), payload, header)
	 else
	   puts "VM status is not currently 'up'. Please try again later."
	 end
       when 'shutdown'
         if is_vm_up?(vmname)
           RestClient.post(create_uri("vms/#{vmid}/shutdown"), payload, header)
	 else
	   puts "VM status is not currently 'up'. Please try again later."
	 end
     end
end

# Parse the command line options.
def getoptions(args)
	options = {}
	opts = OptionParser.new do |opts|
        opts.banner = "rvirt :: Copyright (c) 2011-2012, Red Hat, Inc.\nThis program comes with ABSOLUTELY NO WARRANTY\nUsage: "
        opts.separator ""
	opts.on("-g", "--genconfig", "Build sample configuration.") do |g|
		options[:genconfig] = g
	end
	opts.on("-H", "--listhosts", "List RHEV Hypervisors.") do |lh|
		options[:listhosts] = lh
	end
        opts.on("-V", "--listvms", "List Virtual Machines.") do |lv|
		options[:listvms] = lv
	end
	opts.on("-M", "--hostmaint HOST", String, "Toggle Host Maintentance mode.") do |hm|
		options[:hostmaint] = hm
	end
	opts.on("-S", "--vmstatus NAME", String, "Get VM status by name") do |vs|
		options[:vmstatus] = vs
	end
	opts.on("-A", "--action ACTION", String, "VM Action: start|shutdown|poweroff") do |ac|
		options[:action] = ac
	end
	opts.on("-N", "--vmname NAME", String, "Specify VM name (used with --action") do |nm|
		options[:vmname] = nm
	end
	opts.on("-c", "--cacert", "Retrieve CA Cert.") do |c|
		options[:cacert] = c
        end
	opts.on("-v", "--version", "Print version and exit.") do |v|
		options[:version] = v
	end
         opts.on_tail("-h", "--help", "Show this help message.") do |h|
 	 puts opts; return 0 
	end
  end  # end opts do
  begin opts.parse!
   rescue OptionParser::InvalidOption => invalidcmd
		puts "Invalid command options specified: #{invalidcmd}\n #{opts}"
		return 1
	rescue OptionParser::ParseError => error
		puts error
  end # end begin
	if options.empty? == true  # DEFAULT BEHAVIOR
         #options[:main] = true
         puts "try 'rvirt -h' for syntax"
	end
  options
end	# end def

cmdswitch = getoptions(ARGV)
  # Generate a default configuration.
  if cmdswitch[:genconfig]
    create_config
  else
    $cfg = load_config
  end
  # Retrieve SSL CA certificate from manager node.
  if cmdswitch[:cacert]
    fetch_ca_cert
  end
  # Get version of Software
  if cmdswitch[:version]
    puts RVIRT_VERSION
    exit 0
  end
  # Get listing of hypervisor hosts
  if cmdswitch[:listhosts]
    list_hosts
  end
  # Retrieve listing of all virtual machines
  if cmdswitch[:listvms]
	puts "Getting VMs list"
    list_vms
  end
  # Check status of a single Virtual Machine by name
  if cmdswitch[:vmstatus]
     get_vmstatus_byname(cmdswitch[:vmstatus])
  end
  # Perform state change on Virtual Machine
  if cmdswitch[:action]
     change_vm_state(cmdswitch[:vmname], cmdswitch[:action])
  end
  # Change Host Maintenance Mode
  if cmdswitch[:hostmaint]
     change_host_maintenance(cmdswitch[:hostmaint])
  end

  if cmdswitch[:main]
    main
  end

