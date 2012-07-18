module Puppet
  newtype(:cs_clone) do
    @doc = "Type for manipulating Corosync/Pacemakaer clone entries.
      Clones are additional copies of resources so that you can run the same resource
      on more the one node.  IE: an ocfs2 or gfs2 filesystem on a dual-primary drbd.

      More information can be found at the following link:

      * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/s-resource-clone.html"

    ensurable

    newparam(:name) do
      desc "Name identifier of this clone entry. This value needs to be unique
across the entire Corosync/Pacemaker configuration since it doesn't have
the concept of name spaces per type."
      isnamevar
    end

    newparam(:primitive) do
      desc "The primitive or group that should be cloned"
    end
    
    newproperty(:metadata) do
      desc "A hash of metadata for the clone."

      validate do |value|
        raise Puppet::Error, "Puppet::Type::Cs_Clone: metadata property must be a hash." unless value.is_a? Hash
      end

      defaultto Hash.new
    end
  end
end