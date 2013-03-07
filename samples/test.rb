#!/usr/local/bin/ruby
require 'rubygems'
require_gem 'ldapmapper'
include Ldapmapper
_basedn = 'dc=domain,dc=tldt'
_dn = "ou=toto,#{_basedn}"                                                                                                                                                
record = LdapMapper.new(_dn,'secret',"cn=root,#{_basedn}")
puts "- Could create it ? : #{record.can_create?}"
puts "- Already exist ? : #{record.exist?}"
puts "- Is it a node ? : #{record.is_node?}"
puts "- Is it the base ? : #{record.is_base?}"
if record.exist? then
  puts "- ObjectClasses list :"
  record.list_objectclass.each{|objectclass|
    puts "  * #{objectclass}"
  }
  puts "- Attributes list : "
  record.list_attributs.each{|attribute,value|
    if value.size > 1 then
      puts "* #{attribute} ="
      value.each{|val| puts "  - #{val}"
      }
    else 
      puts "* #{attribute} = #{value}"
    end
  }
  puts record.description
  record.description = `date`
  record.commit!
elsif record.can_create?
  record.add_objectclass!('organizationalUnit')
  record.ou = 'toto'
  record.description = "Test" 
  p record.must
  p record.may
  record.commit!
else
  puts "kaboum!"
end             
