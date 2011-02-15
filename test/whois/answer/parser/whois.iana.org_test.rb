require 'test_helper'
require 'whois/answer/parser/whois.iana.org'

class AnswerParserWhoisIanaOrgTest < Whois::Answer::Parser::TestCase

  def setup
    @klass  = Whois::Answer::Parser::WhoisIanaOrg

    @host   = "whois.iana.org"


    @registrant = Whois::Answer::Contact.new(
      :type         => Whois::Answer::Contact::TYPE_REGISTRANT,
      :name         => nil,
      :organization => "North Atlantic Treaty Organization",
      :address      => "Blvd Leopold III",
      :city         => "1110 Brussels",
      :zip          => "Brussels",
      :country      => "Belgium",
      :phone        => nil,
      :fax          => nil,
      :email        => nil
    )

    @admin =      Whois::Answer::Contact.new(
      :type         => Whois::Answer::Contact::TYPE_ADMIN,
      :name         => "Aidan Murdock",
      :organization => nil,
      :address      => "SHAPE",
      :city         => "NCSA/SDD/SAL",
      :zip          => "Casteau Hainaut 7010",
      :country      => "Belgium",
      :phone        => "+32 65 44 7244",
      :fax          => "+32 65 44 7221",
      :email        => "aidan.murdock@ncsa.nato.int"
    )

    @technical =  Whois::Answer::Contact.new(
      :type         => Whois::Answer::Contact::TYPE_TECHNICAL,
      :name         => "Jack Smits",
      :organization => nil,
      :address      => "SHAPE",
      :city         => "NCSA/SMD",
      :zip          => "Casteau Hainaut 7010",
      :country      => "Belgium",
      :phone        => "+32 65 44 7534",
      :fax          => "+32 65 44 7556",
      :email        => "jack.smits@ncsa.nato.int"
    )

  end


  def test_status
    parser    = @klass.new(load_part('registered.txt'))
    expected  = :registered
    assert_equal_and_cached expected, parser, :status

    parser    = @klass.new(load_part('available.txt'))
    expected  = :available
    assert_equal_and_cached expected, parser, :status

    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = :available
    assert_equal_and_cached expected, parser, :status
  end

  def test_available?
    parser    = @klass.new(load_part('registered.txt'))
    expected  = false
    assert_equal_and_cached expected, parser, :available?

    parser    = @klass.new(load_part('available.txt'))
    expected  = true
    assert_equal_and_cached expected, parser, :available?

    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = true
    assert_equal_and_cached expected, parser, :available?
  end

  def test_registered?
    parser    = @klass.new(load_part('registered.txt'))
    expected  = true
    assert_equal_and_cached expected, parser, :registered?

    parser    = @klass.new(load_part('available.txt'))
    expected  = false
    assert_equal_and_cached expected, parser, :registered?

    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = false
    assert_equal_and_cached expected, parser, :registered?
  end


  def test_created_on
    parser    = @klass.new(load_part('registered.txt'))
    expected  = Time.parse("1997-08-26")
    assert_equal_and_cached expected, parser, :created_on

    parser    = @klass.new(load_part('available.txt'))
    expected  = nil
    assert_equal_and_cached expected, parser, :created_on

    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = nil
    assert_equal_and_cached expected, parser, :created_on
  end

  def test_updated_on
    parser    = @klass.new(load_part('registered.txt'))
    expected  = Time.parse("2009-11-10")
    assert_equal_and_cached expected, parser, :updated_on

    parser    = @klass.new(load_part('available.txt'))
    expected  = nil
    assert_equal_and_cached expected, parser, :updated_on

    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = Time.parse("1999-09-27")
    assert_equal_and_cached expected, parser, :updated_on
  end

  def test_expires_on
    assert_raise(Whois::PropertyNotSupported) { @klass.new(load_part('registered.txt')).expires_on }
    assert_raise(Whois::PropertyNotSupported) { @klass.new(load_part('available.txt')).expires_on }
    assert_raise(Whois::PropertyNotSupported) { @klass.new(load_part('not_assigned.txt')).expires_on }
  end


  def test_contacts
    parser    = @klass.new(load_part('registered.txt'))
    assert_equal @registrant, parser.registrant_contact
    assert_equal @admin, parser.admin_contact
    assert_equal @technical, parser.technical_contact
        
    parser    = @klass.new(load_part('available.txt'))
    assert_equal nil, parser.registrant_contact
    assert_equal nil, parser.admin_contact
    assert_equal nil, parser.technical_contact
        
    parser    = @klass.new(load_part('not_assigned.txt'))
    assert_equal nil, parser.registrant_contact
    assert_equal nil, parser.admin_contact
    assert_equal nil, parser.technical_contact
    
  end


  def test_nameservers
    # parser    = @klass.new(load_part('registered.txt'))
    # expected  = %w( ... )
    # see test_nameservers_with_registered

    parser    = @klass.new(load_part('available.txt'))
    expected  = %w()
    assert_equal_and_cached expected, parser, :nameservers
    
    parser    = @klass.new(load_part('not_assigned.txt'))
    expected  = %w()
    assert_equal_and_cached expected, parser, :nameservers
  end

  def test_nameservers_with_registered
    parser    = @klass.new(load_part('registered.txt'))
    names     = %w( max.nra.nato.int maxima.nra.nato.int ns.namsa.nato.int ns.nc3a.nato.int )
    ipv4s     = %w( 192.101.252.69   193.110.130.68      208.161.248.15    195.169.116.6    )
    expected  = names.zip(ipv4s).map { |name, ipv4| nameserver(name, ipv4) }
    assert_equal_and_cached expected, parser, :nameservers
  end

end