#!/usr/local/bin/ruby
 
require 'rubygems'
require_gem 'ldapmapper'
include Ldapmapper
require 'cgi'

cgi = CGI.new('html4')

puts cgi.header



puts '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
puts '<html>'
puts '<head>'
puts '<title>LDAP Admin Web interface</title>'
puts '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
puts '</head>'
puts '<body>'
puts '<h1>LDAP Admin Web interface</h1>'

if cgi['dn'].empty? then
  _dn = "dc=domain,dc=tld" 
else
  _dn = cgi['dn'] 
end

record = LdapMapper.new(_dn,'cn=root,dc=domain,dc=tld','secret')

puts "<form name=page>"
puts "<input type=text size=80 name=dn value='#{_dn}'><input type=submit>"
puts "</form>"

puts '<table style="background-color:white;text-align:left;border-spacing=10px;color:black;margin-left:0.5em;margin-right:0.5em;margin-top:0.5em;margin-bottom:0.5em;">'
puts '<tr><td style="padding-right:0.5em;vertical-align: top;">'
      
if record.exist? then

  puts "<h3>Descripion :</h3> "
  puts "- <b>ObjectClasses list</b> :<ul>" 
  record.list_objectclass.each{|objectclass|
    puts "<li>#{objectclass}</li>"
  }
  puts "</ul>"
  puts "- <b>Attributes list<b>:"
  puts "<form name=change><ul>"
  record.list_attributs_type.sort{|a,b| b[1]<=>a[1]}.each{|attribut,value|
    puts "<li><b>#{attribut} : </b> "
    puts "<table>"
    if not record.list_attributs[attribut].nil?  then
      record.list_attributs[attribut].each{|multivalue|
	puts "<tr><td><input type=text size=80 name=#{attribut} value='#{multivalue}'>"
	puts '<i><b>(mandatory)</b></i>' if value == 'MUST'
	puts "</td></tr>"
      }
    else
      puts "<tr><td><input type=text size=80 name=#{attribut}>"
        puts '<i><b>(mandatory)</b></i>' if value == 'MUST'
        puts "</td></tr>"
    end
    puts "</table>"
    puts "</li>"
  }
  puts "<input type=submit></ul></form>"

  puts "</td><td>"

  puts "<h3>Situation :</h3> "
  puts "- <b>Can create ? </b>: #{record.can_create?}<br/>"
  puts "- <b>Is exist ? </b>: #{record.exist?}<br/>"
  puts "- <b>Is a node ? </b>: #{record.is_node?}<br/>"
  puts "- <b>Is the base ? </b>: #{record.is_base?}<br/>"
  
  puts "<h3>Navigation :</h3> "
  if not record.list_node.empty?  then 
    if record.list_node.size == 1 then
      puts "- <b> Next Object : </b> : <br>"
    else
      puts "- <b> Next Objects : </b> : <br>"
    end
    puts '<ul>'
    record.list_node.each{|_next_dn|
      puts "<li> <a href=?dn=#{_next_dn}>#{_next_dn}</a></li>"
    }
    puts '</ul>'
  end
  if not record.is_base? then
    puts "- <b> Previous Objet : </b>: <br>"
    puts "<a href=?dn=#{record.get_previous}>#{record.get_previous}</a>"
  end
  puts "</td></tr></table>"

end

record.commit
