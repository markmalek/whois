#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>, Moritz Heidkamp <moritz.heidkamp@bevuta.com>
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
      # = whois.co.ug parser
      #
      # Parser for the whois.co.ug server.
      #
      # NOTE: This parser is just a stub and provides only a few basic methods
      # to check for domain availability and get domain status.
      # Please consider to contribute implementing missing methods.
      # See WhoisNicIt parser for an explanation of all available methods
      # and examples.
      #
      class WhoisCoUg < Base

        property_supported :status do
          if content_for_scanner =~ /^Status:\s+(.+?)\n/
            case $1.downcase
              when "active" then :registered
              else
                Whois.bug!(ParserError, "Unknown status `#{$1}'.")
            end
          else
            :available
          end
        end

        property_supported :available? do
          !!(content_for_scanner =~ /^% No entries found for the selected source/)
        end

        property_supported :registered? do
          !available?
        end


        property_supported :created_on do
          if content_for_scanner =~ /Registered:\s+(.+)$/
            Time.parse($1)
          end
        end

        property_supported :updated_on do
          if content_for_scanner =~ /Updated:\s+(.+)$/
            DateTime.strptime($1, '%d/%m/%Y %H:%M:%S').to_time
          end
        end

        property_supported :expires_on do
          if content_for_scanner =~ /Expiry:\s(.+)$/
            Time.parse($1)
          end
        end


        property_supported :nameservers do
          content_for_scanner.scan(/Nameserver:\s+(.+)\n/).flatten.map do |name|
            Answer::Nameserver.new(name.downcase)
          end
        end

      end

    end
  end
end
