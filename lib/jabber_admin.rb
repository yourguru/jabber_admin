# frozen_string_literal: true

require 'active_support/inflector'
require 'json'
require 'pathname'
require 'rest-client'

require 'jabber_admin/exceptions'
require 'jabber_admin/configuration'
require 'jabber_admin/commands'
require 'jabber_admin/api_call'
require 'jabber_admin/version'

# jabber_admin
#
# This gem allows making API calls to the ejabberd RESTful admin backend.  We
# support a bunch of predefined commands out of the box, just have a look at
# the +lib/jabber_admin/commands/+ directory or the readme file.
#
# All predefined commands can be called via +JabberAdmin.COMMAND!+ or via
# +JabberAdmin.COMMAND+.  The bang variant checks the result of the command
# (successful, or not) and raise a subclass of +JabberAdmin::Exception+ in case
# of issues. The non-bang variant just sends the commands in a fire and forget
# manner.
#
# When you're missing a command you want to use, you can use the
# +JabberAdmin::ApiCall+ class directly. It allows you to easily fulfill your
# custom needs with the power of error handling (if you like).
#
# You can also use your custom command directly on the +JabberAdmin+ module, in
# both banged and non-banged versions and we pass them as a shortcut to a new
# +JabberAdmin::ApiCall+ instance.
#
# @example Configure jabber_admin gem
#   JabberAdmin.configure do |config|
#     # The ejabberd REST API endpoint as a full URL.
#     # Take care of the path part, because this is individually
#     # configured on ejabberd. (See: https://bit.ly/2rBxatJ)
#     config.url = 'http://jabber.local/api'
#     # Provide here the full user JID in order to authenticate as
#     # a administrator.
#     config.username = 'admin@jabber.local'
#     # The password of the administrator account.
#     config.password = 'password'
#   end
#
# @example Restart the ejabberd service
#   JabberAdmin.restart!
#
# @example Register a new user to the XMPP service
#   JabberAdmin.register! user: 'peter@example.com', password: '123'
#
# @example Delete a user from the XMPP service, in fire and forget manner
#   JabberAdmin.unregister user: 'peter@example.com'
module JabberAdmin
  class << self
    attr_writer :configuration
  end

  # A simple getter to the global JabberAdmin configuration structure.
  #
  # @return [JabberAdmin::Configuration] the global JabberAdmin configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Class method to set and change the global configuration. This is just a
  # tapped variant of the +.configuration+ method.
  #
  # @yield [configuration]
  # @yieldparam [JabberAdmin::Configuration] configuration
  def self.configure
    yield(configuration)
  end

  # Allow an easy to use DSL on the +JabberAdmin+ module. We support predefined
  # (known) commands and unknown ones in bang and non-bang variants. This
  # allows maximum flexibility to the user. The bang versions perform the
  # response checks and raise in case of issues. The non-bang versions skip
  # this checks. For unknown commands the +JabberAdmin::ApiCall+ is directly
  # utilized with the method name as command. (Without the trailling bang, when
  # it is present)
  #
  # @param method [Symbol, String, #to_s] the name of the command to run
  # @param args all additional payload to pass down to the API call
  # @return [RestClient::Response] the actual response of the command
  if RUBY_VERSION < "3"
    def self.method_missing(method, *args)
      predefined_command(method).call(predefined_callable(method), *args)
    rescue NameError
      predefined_callable(method).call(method.to_s.chomp('!'), *args)
    end
  else
    def self.method_missing(method, *args, **kwargs)
      predefined_command(method).call(predefined_callable(method), **kwargs)
    rescue NameError
      predefined_callable(method).call(method.to_s.chomp('!'), **kwargs)
    end
  end

  # Try to find the given name as a predefined command. When there is no such
  # predefined command, we raise a +NameError+.
  #
  # @param name [Symbol, String, #to_s] the command name to lookup
  # @return [Class] the predefined command class constant
  def self.predefined_command(name)
    # Remove bangs and build the camel case variant
    "JabberAdmin::Commands::#{name.to_s.chomp('!').camelize}".constantize
  end

  # Generate a matching API call wrapper for the given command name. When we
  # have to deal with a bang version, we pass the bang down to the API call
  # instance. Otherwise we just run the regular +#perform+ method on the API
  # call instance.
  #
  # @param name [Symbol, String, #to_s] the command name to match
  # @return [Proc] the API call wrapper

  if RUBY_VERSION < "3"
    def self.predefined_callable(name)
      method = name.to_s.end_with?('!') ? 'perform!' : 'perform'
      proc { |*args| ApiCall.send(method, *args) }
    end
  else
    def self.predefined_callable(name)
      method = name.to_s.end_with?('!') ? 'perform!' : 'perform'
      proc { |*args, **kwargs| ApiCall.send(method, *args, **kwargs) }
    end
  end

  # Determine if a room exists. This is a convenience method for the
  # +JabberAdmin::Commands::GetRoomAffiliations+ command, which can be used
  # to reliably determine whether a room exists or not.
  #
  # @param room [String] the name of the room to check
  # @return [Boolean] whether the room exists or not
  def self.room_exist?(room)
    get_room_affiliations!(room: room)
    true
  rescue JabberAdmin::CommandError => e
    raise e unless /room does not exist/.match? e.response.body

    false
  end

  # We support all methods if you ask for. This is our dynamic command approach
  # here to support predefined and custom commands in the same namespace.
  #
  # @param method [String] the method to lookup
  # @param include_private [Boolean] allow the lookup of private methods
  # @return [Boolean] always +true+
  def self.respond_to_missing?(_method, _include_private = false)
    true
  end
end
