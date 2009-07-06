#
# = Ruby Whois
#
# A pure Ruby WHOIS client.
#
#
# Category::    Net
# Package::     WWW::Delicious
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'yaml'


module Whois
  
  class Server
    
    # Parses an user-supplied string and tries to guess the right server.
    def self.whichwhois(string)
      # TODO: IPv6 address
      # TODO: RPSL hierarchical objects
      
      # Email Address
      if string =~ /@/
        find_for_email(string)
      end
      
      # TODO: NSI NIC
      # TODO: ASN32
      # TODO: IP
      
      # Domain
      find_for_domain(string)
      
      # TODO: guessing
      # TODO: game-over
    end
    
    
    def self.find_for_email(string)
      raise ServerNotSupported, "No whois server is known for email objects"
    end
    
    def self.find_for_domain(string)
      server = servers.each do |ext, srv|
        break(srv) if /#{ext}$/ =~ string
      end
      
      if server.nil?
        # you might want to remove this raise statement
        # to make the guessing more clever.
        raise ServerNotFound, "Unable to find a whois server for `#{string}'"
      elsif server =~ /^WEB (.*)/
        raise WebInterfaceError,  "This TLD has no whois server, " +
                                  "but you can access the whois database at `#{$1}'"
      elsif server == "NONE"
        raise NoInterfaceError,   "This TLD has no whois server"
      elsif server == "CRSNIC"
        query_crsnic(string)
      elsif server == "PIR"
        query_pir(string)
      elsif server == "AFILIAS"
        raise NotImplementedError
      elsif server == "NICCC"
        raise NotImplementedError
      elsif server == "ARPA"
        raise NotImplementedError
      else
        server
      end
    end
    
    def self.servers
      @@servers ||= YAML.load_file(File.dirname(__FILE__) + "/servers.yml")
    end
    
    private
      
      def self.ask_the_socket(query, server, port = 43)
        client = TCPSocket.open(server, port)
        client.write("#{query}\r\n")
        client.read
      ensure
        client.close if client
      end
      
      
      def self.query_crsnic(query)
        response = ask_the_socket("=#{query}", "whois.crsnic.net")
        if response =~ /Domain Name:/ && response =~ /Whois Server: (.*)/
          return $1
        else
          # FIXME: Here's the full response. ARGH!
          # Usually this happens when domain is not registered.
        end
      end
      
      def self.query_pir(query)
        response = ask_the_socket("FULL #{query}", "whois.publicinterestregistry.net")
        puts response
        if response =~ /Registrant Name:SEE SPONSORING REGISTRAR/ && 
           response =~ /Registrant Street1:Whois Server:(.*)/
          return $1
        else
          # FIXME: Here's the full response. ARGH!
          # Usually this happens for the 95% of queries. Isn't that wonderful?
        end
      end
    
  end
  
end