require 'puppet_x/bsd/hostname_if/carp'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_carp,
              :type => :rvalue) do |args|

    config       = args.shift

    c = {}
    c[:id]      = config["id"]
    c[:device]  = config["device"]
    c[:address] = config["address"]
    c[:advbase] = config["advbase"] if config["advbase"]
    c[:advskew] = config["advskew"] if config["advskew"]

    return PuppetX::BSD::Hostname_if::Carp.new(c).content
  end
end
