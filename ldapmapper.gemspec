require 'lib/ldapmapper'


Gem::Specification.new do |s|
  s.name = %q{ldapmapper}
  s.version = Ldapmapper::LIB_VERSION
  s.date = Ldapmapper::DATE
  s.summary = %q{Ldapmapper : CRUD Objects for LDAP mapping }
  s.email = %q{romain@ultragreen.net}
  s.homepage = %q{http://www.ultragreen.net}
  s.author = Ldapmapper::AUTHOR
  s.rubyforge_project = 'ldapmapper'
  s.description = %q{Ldapmapper : provide CRUD object for LDAP data manipulations}
  s.has_rdoc = true
  s.files = Dir['lib/*']
  s.bindir = nil
  s.test_file = 'test/testldapmapper.rb'		
  s.required_ruby_version = '>= 1.8.1'
  s.summary = Ldapmapper::OBS
end
