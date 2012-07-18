module Puppet
  newtype(:cs_ms) do
    @doc = "Another very specific type, you can think of it as a variation of a clone resource.
    Generally used for things like drbd, where an underlying primitive can be in a master or
    slave state.
    
    I split this off the primitive type because doing so more closely mirrors how you 
    configure pacemaker/corosync and so I think it's a bit more intuitive this way.
    
    There are also a slew of options, but only the most basic are supported right now.
    
    For information on multi-state resource see:
    
    * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/s-resource-multistate.html"

    ensurable

    newparam(:name) do
      desc "Name identifier of this multi-state resource. This value needs to be unique
across the entire Corosync/Pacemaker configuration since it doesn't have
the concept of name spaces per type."
      isnamevar
    end

    newparam(:primitive) do
      desc "The primitive or group that should be a multi-state resource."
    end
    
    newproperty(:metadata) do
      desc "A hash of metadata for the multi-state resource."

      validate do |value|
        raise Puppet::Error, "Puppet::Type::Cs_Ms: metadata property must be a hash." unless value.is_a? Hash
      end

      defaultto Hash.new
    end
  end
end