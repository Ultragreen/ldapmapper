#!/usr/local/bin/ruby

require "ldapmapper"
require 'test/unit'

class TestLdapMapper < Test::Unit::TestCase

  def test_simple
    assert_equal(true,LdapMapper.new('ou=fetchmail,ou=mail,dc=ultragreen,dc=net','cn=root,dc=ultragreen,dc=net','l7isg00d').exist?)	
  end
end
