#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'whois/answer/parser/base'


module Whois
  class Answer
    class Parser

      #
      # = whois.nic.tl parser
      #
      # Parser for the whois.nic.tl server.
      #
      # NOTE: This parser is just a stub and provides only a few basic methods
      # to check for domain availability and get domain status.
      # Please consider to contribute implementing missing methods.
      # See WhoisNicIt parser for an explanation of all available methods
      # and examples.
      #
      class WhoisNicTl < Base

        property_supported :status do
          if available?
            :available
          else
            :registered
          end
        end

        property_supported :available? do
          !!(content_for_scanner =~ /Status: Not Registered/)
        end

        property_supported :registered? do
          !available?
        end


        property_supported :created_on do
          if content_for_scanner =~ /Created:\s+(.*)\n/
            Time.parse($1)
          end
        end

        property_supported :updated_on do
          if content_for_scanner =~ /Modified:\s+(.*)\n/
            Time.parse($1)
          end
        end

        property_supported :expires_on do
          if content_for_scanner =~ /Expires:\s+(.*)\n/
            Time.parse($1)
          end
        end


        property_supported :nameservers do
          if content_for_scanner =~ /Name Servers:\n((.+\n)+)\n/
            $1.split("\n").map do |name|
              Answer::Nameserver.new(name.strip)
            end
          end || []
        end

      end

    end
  end
end
