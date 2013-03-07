#!/Usr/bin/env ruby
#
#
# == Synopsis
#
# LdapMapper : LDAP CRUD Object 
#
# == Usage
#
# ./ldapmapper.rb [-u|--usage] : usage of the library CLI mode
# ./ldapmapper.rb [-h|--help] : Help for this library, man page
# ./ldapmapper.rb [-V|--version] : version display for this library
# ./ldapmapper.rb [-t|--tests   --dn|-d < a dn > [--rootdn|-r <user>]
#                          [--passdn|p <password>  ] [-v|--verbose] ] 
#                          -> run test mode of the library
#
# == Date
#
# 2007-11-05
# 
# == file
#
# ldapmapper.rb
#
# == Copyright Ultragreen (c) 2005-2007
#
# * Version : 1.5
#
# == About :
# 
# * Author:: Romain GEORGES 
# * type:: class definition Ruby
# * obj:: Generic LDAP class 
# 
# == Source :
# 
# * http://www.ultragreen.net
# * Project : http://www.ultragreen.net/projects/show/27
# * Wiki : http://www.ultragreen.net/wiki/27
# * Downloads : http://www.ultragreen.net/projects/list_files/27
# * Forum : http://www.ultragreen.net/projects/27/boards
# 
# == Exemples :
#
#   #!/usr/local/bin/ruby
#   require 'rubygems'
#   require 'ldapmapper'
#   include Ldapmapper
#   _basedn = 'dc=__domaine__,dc=__tld__'
#   _dn = "ou=toto,#{_basedn}"
#   record = LdapMapper.new(_dn,'__secret__',"cn=root,#{_basedn}")
#   puts "- Could create it ? : #{record.can_create?}"
#   puts "- Already exist ? : #{record.exist?}"
#   puts "- Is it a node ? : #{record.is_node?}"
#   puts "- Is it the base ? : #{record.is_base?}"
#   if record.exist? then
#     puts "- ObjectClasses list :"
#     record.list_objectclass.each{|objectclass|
#       puts "  * #{objectclass}"
#     }
#     puts "- Attributes list : "
#     record.list_attributs.each{|attribute,value|
#       if value.size > 1 then
#         puts "* #{attribute} ="
#         value.each{|val| puts "  - #{val}"
#         }
#       else
#         puts "* #{attribute} = #{value}"
#       end
#     }
#     puts record.description
#     record.description = `date`
#     record.commit!
#   elsif record.can_create?
#     record.add_objectclass!('organizationalUnit')
#     record.ou = 'toto'
#     record.description = "Test"
#     p record.must
#     p record.may
#     record.commit!
#   else
#     puts "kaboum!"
#   end
#
# <b>first running :</b>
#
#    - Could create it ? : true
#    - Already exist ? : false
#    - Is it a node ? : false
#    - Is it the base ? : false
#    ["ou", "objectClass", "dn"]
#    ["physicalDeliveryOfficeName", "l", "st", "telexNumber", "destinationIndicator", "businessCategory",
#    "postalAddress", "telephoneNumber", "searchGuide", "internationaliSDNNumber", "preferredDeliveryMethod",
#    "description", "postalCode", "teletexTerminalIdentifier", "userPassword", "street",
#    "registeredAddress", "postOfficeBox", "facsimileTelephoneNumber", "seeAlso", "x121Address"]
#
# <b>second ruuning :</b>
#
#    - Could create it ? : false
#    - Already exist ? : true
#    - Is it a node ? : false
#    - Is it the base ? : false
#    - ObjectClasses list :
#      * top
#      * organizationalUnit
#    - Attributes list : 
#      * description = Jeu  7 sep 2006 16:11:44 CEST
#      * ou = toto
#      * objectClass =
#        - top
#        - organizationalUnit
#      * dn = ou=toto,dc=__domain__,dc=__tld__
#    Jeu  7 sep 2006 16:11:44 CEST 


# require the LDAP's scheme and LDAP librairies
require 'ldap'
require "ldap/schema"

def output(_string)
   puts _string
end

# Set debug default to 0
$verbose = 0

# General module for LDAP CRUD Ojects
module Ldapmapper

  # identity lib
  # Library name
  LIB_NAME = "Ldapmapper"
  # version of the library
  LIB_VERSION='1.5'
  # name of the author
  AUTHOR='Romain GEORGES'
  # date of creation
  CREATION_DATE='2005-07-30'
  DATE = '2009-12-10'
  # valuable observations
  OBS='Generic LDAP class'

  # Module method for version display
  def version
    output "#{LIB_NAME} : file  => #{File::basename(__FILE__)}:"
    output 'this is a RUBY library file'
    output "Copyright (c) Ultragreen Software"
    output "Version : #{LIB_VERSION}"
    output "Author : #{AUTHOR}"
    output "Date release : #{DATE}"
    output "Observation : #{OBS}"
  end

  # Module method for version display
  def tests(_dn,_rootdn,_passdn)
   output "Running tests on #{_dn}"
   _dn = "ou=toto,#{_dn}"
   output "test on ou=toto in node : #{_dn}"
   record = LdapMapper.new(_dn,_rootdn,_passdn)
   output "- Could create it ? : #{record.can_create?}"
   output "- Already exist ? : #{record.exist?}"
   output "- Is it a node ? : #{record.is_node?}"
   output "- Is it the base ? : #{record.is_base?}"
    if record.can_create?
     output "- Create ou=toto in node : #{_dn}"
     record.add_objectclass!('organizationalUnit')
     record.ou = 'toto'
     record.description = "Test"
     output "- Is it valid ? : #{record.valid?}"
      record.commit!
   end
   if record.exist? then
     output "- ObjectClasses list :"
     record.list_objectclass.each{|objectclass|
       output "  * #{objectclass}"
     }
     output "- Attributes list : "
     record.list_attributs.each{|attribute,value|
       if value.size > 1 then
         output "* #{attribute} ="
         value.each{|val| puts "  - #{val}"
         }
       else
         output "* #{attribute} = #{value}"
       end
     }
     record.description = `date`
     record.commit!
#     output "deleting ou=toto..."
#     record.delete! 
     output ">> test done."
   end
  end


  # generic class for LDAP object 
  class LdapTemplate

    # attributs for LDAP connection

    # hostname of the LDAP server
    attr_accessor :host_ldap 
    # TCP/IP port of the LDAP server
    attr_accessor :port_ldap 
    # LDAP scope for search
    attr_accessor :scope_ldap 
    # current filter for search
    attr_accessor :filter_ldap 
    # LDAP base DN for the instance
    attr_accessor :basedn_ldap 
    # credential for the instance
    attr_accessor :passdn_ldap 
    # LDAP rootdn for LDAP
    attr_accessor :rootdn_ldap

    # constructor for LdapTemplate
    #
    # _passdn is required, _rootdn, _host, _filter, _port and _scope are optionals
    #
    # return a boolean
    def initialize(_host='localhost', _port=389, _rootdn='', _passdn='', _filter='(objectClass=*)', _scope=LDAP::LDAP_SCOPE_SUBTREE )  
      @host_ldap = _host # default localhost
      @port_ldap = _port # default 389
      @scope_ldap = _scope # default to SUBTREE
      @filter_ldap = _filter # default (objectClass=*)
      @basedn_ldap = get_basedn(_host,_port,_rootdn,_passdn)
      @passdn_ldap = _passdn # default empty
      @rootdn_ldap = _rootdn # default empty
      return true
    end



  end

  # Mapping LDAP object class 
  #
  # This is the real CRUD Class 
  # 
  # contructor arguments :
  #
  # _dn and _passdn are required, _rootdn, _host and  _port are optionals
  class LdapMapper < LdapTemplate

    # DN binding point attribut
    attr_accessor :dn_ldap
    # Hash of attributes with optional or mandatory aspects in value
    attr_accessor :list_attributs_type
    # Array of objectclass for the current record
    attr_accessor :list_objectclass
    # Hash of attributes in LDIF mapping, value should be an array in case of multivalue data
    attr_accessor :list_attributs
    attr_accessor :list_attributs_rollback	

    # constructor with dn_ldap initialisation
    #
    # _dn and _passdn are required, _rootdn, _host and  _port are optionals
    #
    # return a boolean 
    def initialize(_dn,  _rootdn='', _passdn='', _host = 'localhost', _port = 389)
      _scope = LDAP::LDAP_SCOPE_SUBTREE
      _filter = '(objectClass=*)'
      super( _host, _port, _rootdn, _passdn, _filter, _scope )
      @dn_ldap = _dn
      @list_objectclass = Array::new
      @list_attributs_type = Hash::new
      @list_attributs = Hash::new
      add_objectclass!
      @list_attributs_rollback = @list_attributs
    end



    # add an objectclass in the list and map attribut 
    # 
    # _objectclass is optional
    # 
    # return an Hash
    def add_objectclass!(_objectclass = 'top')
      @list_objectclass = @list_objectclass.concat(get_objectclass_list(self.dn_ldap, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap))
      @list_objectclass.push(_objectclass).uniq!
      @list_attributs_type = get_attributs_list(self.list_objectclass, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap)
      @list_attributs = map_record(self.dn_ldap, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap)
      if not @list_attributs.nil? or @list_attributs.empty? then
        @list_attributs.each{|_key,_value|
          @list_attributs_type.each{|_attr,_trash|
	    @list_prov = get_alias(_key,self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap) 
            if @list_prov then
              if @list_prov.include?(_attr) then
                @list_attributs.delete(_key)
                @list_attributs[_attr] = _value
              end	
            end
          }
        }
      end
      @list_attributs["objectClass"] = @list_objectclass
      @list_attributs_type.each_key {|_key|
        eval("
        def #{_key.downcase}
          return @list_attributs['#{_key}']
        end
        def #{_key.downcase}=(_value)
          @list_attributs['#{_key}'] = _value
        end
        ")
      }
    end

    # existance of an LDAP instance test method
    #
    # return a boolean
    def exist?
      if list_arbitrary_node(self.dn_ldap, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap).empty? then
        return false
      else
        return true
      end
    end

    # rollback to beggining of transaction
    #
    # return a boolean
    def rollback!
      @list_attributs = @list_attributs_rollback
    end

    # test methode for LDAP instance situation node or termination  
    #
    # return a boolean
    def is_node?
      if  list_arbitrary_node(self.dn_ldap, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap).length > 1 then
        return true
      else
        return false
      end
    end

    # test methode to check the ability to create the instance, already exist or not bindable
    #
    # return a boolean 
    def can_create?
      return false if self.is_base? 
      if list_arbitrary_node(self.get_previous,self.host_ldap,self.port_ldap, self.rootdn_ldap, self.passdn_ldap).length >= 1 and not self.exist? then
        return true
      else
        return false
      end
    end

    # return true if the dn to search is the basedn of the tree
    #
    # return a boolean
    def is_base?
      if self.dn_ldap == self.basedn_ldap then
        return true
      else
        return false
      end
    end

    # return the list of the attributes how must be present for add a record
    #
    # return an Array 
    def must
      _must_list = Array::new
      self.list_attributs_type.each{|_key,_value|
        _must_list.push(_key) if _value == 'MUST'  
      }
      _must_list.delete('dn') if _must_list.include?('dn')
      return _must_list
    end

    # return the attributes list how may be present in the record 
    #
    # return an Array
    def may
      _may_list = Array::new
      self.list_attributs_type.each{|_key,_value|
        _may_list.push(_key) if _value == 'MAY'
      }
      return _may_list
    end

    # return true if the must attributes is completed in record before commit!
    #
    # return a boolean
    def valid?
      _result = true
      self.must.each{|attribute|
        _result = false if not self.list_attributs.include?(attribute)
      }
      return _result
    end

    # get the previous record if exist and if the record is not the basedn
    #
    # return a String
    def get_previous
      _rec_res = String::new('')
      if not self.is_base? then
        _rdn = String::new('')
        _dn_table = Array::new
        _rdn,*_dn_table = self.dn_ldap.split(',')
        _rec_res = _dn_table.join(',')
      end
      return _rec_res
    end

    # method to list dn after the node in the the LDAP tree for the first level, 
    #
    # return an Array
    def list_node
      _my_res = Array::new
      _my_res = list_arbitrary_node(self.dn_ldap,self.host_ldap,self.port_ldap, self.rootdn_ldap, self.passdn_ldap, LDAP::LDAP_SCOPE_ONELEVEL) 
      _my_res.delete(self.dn_ldap) if _my_res.include?(self.dn_ldap)
      return _my_res
    end
    
    # delete the dn object in LDAP server
    #
    # return a boolean    
    def delete!
      if self.exist? and not self.is_node? then
	return delete_object(self.dn_ldap, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap)
      else
        return false
      end
    end	

    # commit the modification or the adding of the object in LDAP server 
    #
    # return a boolean
    def commit!
      if self.exist? and self.valid? then
        # case modifying an LDAP object
        return mod_object(self.dn_ldap, self.list_attributs.merge(self.list_attributs_rollback), self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap)
      elsif self.can_create? and self.valid? then
        # case creating new object  
        return add_object(self.dn_ldap, self.list_attributs, self.host_ldap, self.port_ldap, self.rootdn_ldap, self.passdn_ldap)
      else
        return false
        # case can't commit
      end
    end

  end


 


  # global connector for LDAP instanciate at the first request
  #
  # _host, _port, _rootdn and _passdn are optional
  #
  # return a global connecter handler 
  def connector(_host='localhost', _port=389, _rootdn='', _passdn='')
    begin 
      if not $connection then
        output "connecting to #{_host} on port : #{_port}" if $verbose
        $connection = LDAP::Conn.new(_host,_port)
        $connection.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
      end
        if _rootdn.empty? and not $bind then
          output 'Anonymous binding' if $verbose 
          $connection = $connection.bind
          $bind = true
        elsif not _rootdn.empty? and not $authenticated then
          output 'Authenticated binding' if $verbose
          $connection.unbind if $connection.bound?
          $connection = $connection.bind("#{_rootdn}", "#{_passdn}")
          $authenticated = true
        end
      return $connection
    rescue Exception
      raise LdapmapperConnectionError
    end
  end

  # global method that list objectclass for a speficique dn 
  #
  # server free methode 
  #
  # _dn is required, _host, _port, _rootdn, _passdn, _scope and _filter are optionals
  #
  # return an Array
  def get_objectclass_list(_dn,_host='localhost',_port=389,_rootdn='',_passdn='',_scope=LDAP::LDAP_SCOPE_BASE,_filter='(objectClass=*)')
    _table_res = Array::new
    begin
      connector(_host, _port, _rootdn, _passdn).search(_dn,_scope,_filter){|_e|
        _table_res = _e.to_hash()['objectClass']
      }
    rescue
    ensure
      return _table_res
    end
  end

  # get the base dn of an LDAP tree
  #
  # _host, _port, _rootdn and _passdn are optionals
  #
  # return a String
  def get_basedn(_host='localhost',_port=389,_rootdn='',_passdn='')
    _my_basedn = String::new('')
    begin
      _my_basedn = connector(_host,_port,_rootdn,_passdn).root_dse[0]["namingContexts"].to_s
    rescue
      raise LdapmapperGetBaseDnError
    ensure
      return _my_basedn
    end
  end

  # get the alias list of an attribute in Schema 
  #
  # _attribute is required, _host and _port are optionals
  #
  # return an Array
  def get_alias(_attribute,_host='localhost',_port=389,_rootdn='',_passdn='') 
    _my_list_attributs = Array::new
    begin
      _schema = connector(_host,_port,_rootdn,_passdn).schema()
      _my_list_attributs = _schema.alias(_attribute)
    rescue
      raise LdapmapperGetAttributAliasError
    ensure
      return _my_list_attributs
    end
  end

  #  global method that list dn after the precised dn in the LDAP tree
  #
  # server free methode
  #
  # _dn id required, _host, _port, _rootdn, _passdn, _scope, _filter are optionals
  #
  # return an Array
  def list_arbitrary_node(_dn,_host=localhost,_port=389,_rootdn='',_passdn='',_scope=LDAP::LDAP_SCOPE_SUBTREE,_filter='(objectClass=*)')
    _table_res = Array::new
    begin
      connector(_host,_port,_rootdn,_passdn).search(_dn,_scope,_filter){|_e|
        _table_res.push(_e.dn)
      }
    rescue
      raise LdapmapperGetDnsListError
    ensure
      return _table_res
    end
  end

  # get the attributs list of an objectclass list 
  # 
  # server free method
  #
  # _list_objectclass is required, _host, _port, _rootdn and _passdn are optionals
  #
  # return an Hash
  def get_attributs_list(_list_objectclass,_host='localhost',_port=389,_rootdn='',_passdn='')
    _my_list_attributs = Hash::new
    begin
      _schema = connector(_host,_port,_rootdn,_passdn).schema()
      _list_objectclass.each{|objectclass|
        if objectclass != 'top' then
          _prov_must = _schema.must(objectclass)
          _prov_may = _schema.may(objectclass)
          _prov_must.each{|attributs| _my_list_attributs[attributs] = 'MUST'} unless _prov_must.nil? or _prov_must.empty?
          _prov_may.each{|attributs| _my_list_attributs[attributs] = 'MAY'} unless _prov_may.nil? or _prov_may.empty?
        end
      }
    rescue
      raise LdapmapperGetAttributsListError
    ensure
      _my_list_attributs["dn"] = "MUST"
      _my_list_attributs["objectClass"] = "MUST"
      return _my_list_attributs
    end
  end

  # map the attributs of class at run time for the current LDAP Object at precise DN
  # 
  # _dn is required, _host, _port, _rootdn, _passdn, _scope and _filter are optionals
  # 
  # return an Hash
  def map_record(_dn,_host='localhost',_port=389,_rootdn='',_passdn='',_scope=LDAP::LDAP_SCOPE_BASE,_filter='(objectClass=*)')
    _prov_hash = Hash::new
    begin
      connector(_host,_port,_rootdn,_passdn).search(_dn,_scope,_filter){|_e|
        _prov_hash = _e.to_hash()
      }
    rescue

    ensure
      return _prov_hash
    end
  end

  # add an ldap object 
  # 
  # _dn and _record are required, _host, _port, _rootdn and _passdn are optional
  # 
  # return a boolean
  def add_object(_dn, _record, _host='localhost',_port=389, _rootdn='', _passdn='')
    _record.delete('dn') 
    _data = _record
    _data.each{|_key,_value|
      _data[_key] = _value.to_a 
    }
    begin
      connector(_host,_port,_rootdn,_passdn).add("#{_dn}", _data)
      return true
    rescue LDAP::ResultError
      raise LdapmapperAddRecordError  
      return false
    end
  end

  # modify an ldap object
  # 
  # _dn and _record are required, _host, _port, _rootdn and _passdn are optional
  # 
  # return a boolean
  def mod_object(_dn, _mod, _host='localhost',_port=389, _rootdn='', _passdn='')
#    begin
      _mod.delete('dn')
      _data = _mod
      _data.each{|_key,_value|
        _data[_key] = _value.to_a
      }
      connector(_host,_port,_rootdn,_passdn).modify("#{_dn}", _data)
      return true
#    rescue LDAP::ResultError
#      raise LdapmapperModRecordError
#      return false
#    end
  end

  # delete an ldap object
  #
  # _dn is required, _host, _port, _rootdn and _passdn  are optional
  #
  # return a boolean
  def delete_object(_dn, _host='localhost',_port=389, _rootdn='', _passdn='')
    begin
      connector(_host,_port,_rootdn,_passdn).delete("#{_dn}")
      return true
    rescue LDAP::ResultError
      raise LdapmapperDeleteRecordError
      return false
    end
  end


  # exceptions definitions for Ldapmapper
  # raise when a LDAP Cconnection failed of a record failed
  class LdapmapperConnectionError < Exception; end
  # raise when an modification of a record failed
  class LdapmapperModRecordError < Exception; end
  # raise when an adding of a record failed
  class LdapmapperAddRecordError < Exception; end
  # raise when the retrieving of a record failed
  class LdapmapperGetRecordError < Exception; end
  # raise when the retrieving of Schema's data failed
  class LdapmapperGetAttibutAliasError < Exception; end
  # raise when the browsing of an LDAP tree failed
  class LdapmapperGetDnsListError < Exception; end
  # raise when the retrieving of root DSE record failed
  class LdapmapperGetBaseDnError < Exception; end
  # raise when the retrieving of Attributs list failed
  class LdapmapperGetAttributsListError < Exception; end
  # raise when the retrieving of objectclasses list failed
  class LdapmapperGetObjectClassListError < Exception; end
  # raise when the removing of a dn failed
  class LdapmapperDeleteRecordError < Exception; end
end

# run description of the library in interactive mode  
if $0 == __FILE__ then
  require 'getoptlong'
  require 'rdoc/usage'

  include Ldapmapper

  $command_name =  File::basename(__FILE__)
  $arguments = Hash::new
  # option catching
  opts = GetoptLong.new(
  [ "--help", "-h", GetoptLong::NO_ARGUMENT ],
  [ "--usage", "-u", GetoptLong::NO_ARGUMENT ],
  [ "--tests", "-t", GetoptLong::NO_ARGUMENT ],
  [ "--verbose", "-v", GetoptLong::NO_ARGUMENT ],
  [ "--passdn", "-p", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--rootdn", "-r", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--dn", "-d", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--version", "-V", GetoptLong::NO_ARGUMENT ]

  )
  # process the parsed options
  begin
    opts.each do |_opt, _arg|
      $arguments[_opt] = _arg
    end
    RDoc::usage('usage') and exit 0 if $arguments.include?("--usage")
    RDoc::usage and exit 0 if $arguments.include?("--help")
    version if $arguments.include?("--version")
  rescue GetoptLong::MissingArgument,GetoptLong::InvalidOption
    output 'ERROR : Invalid or missing argument'
    RDoc::usage('usage')
    exit 1
  end
  if $arguments.include?("--tests") then
    RDoc::usage('usage') and exit 0 unless $arguments.include?("--dn")
    $verbose = 1 if $arguments.include?("--verbose")
    output "Debbugging verbose mode activated." if $verbose
    _dn = $arguments["--dn"]
    _passdn = ($arguments.include?("--passdn"))? $arguments["--passdn"] : ''
    _rootdn = ($arguments.include?("--rootdn"))? $arguments["--rootdn"] : ''
    tests(_dn,_rootdn,_passdn)
  end



end



#==END==#
