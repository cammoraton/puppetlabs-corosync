module Puppet
  newtype(:cs_location) do
    @doc = "Type for manipulating resource location constraints.  A resource constraint
      in pacemaker can be one of two types, a modifier that applies to certain nodes.
      
      As in:
      crm configure location name resource -inf: node 
      to prevent a resource from running on a node
      
      or
      crm configure location name resource inf: node 
      to ensure a resource always runs on a given node
      
      Or it can be a set of rules based on primitives or other executables or primitives that modify the score 
      of a given node for a given resource.

      As in:
      crm configure location name resource rule id=\"rulename\" 1000: #uname eq node1 or #uname eq node2
      Which will modify the node score by 1000 if the output of uname matches node1 or node2.
      
      or
      crm configure primitive name ocf:pacemaker:pingd host=\"www.google.com\"
      crm configure location name resource rule id=\"rulename\" -inf: pingd not_defined or pingd lte 0
      which will remove any resource from any node which can not reach the host.
      
      Available operators are your standard boolean ops, and/or.  Although these aren't necessary for single rules.
      
      This latter type is often used in combination with ping primitives(as in the example) to modify resource 
      location on the basis of network connectivity.  Especially in geo-clusters where a 3rd location is unavailable for some
      reason.  It is also probably the least documented type of constraint from the standpoint of the crm command
      line.
      
      This puppet type self-modifies which type of location constraint it works with on the basis of whether or 
      not the rule variable is set.  If rule is set, then operations also needs to be set.
      
      Right now this type does not support score_attribute based configurations.
      
      More information on Corosync/Pacemaker location constraints can be found in the following places:
      
      * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/ch-constraints.html
      * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/ch-rules.html
      * http://www.suse.com/documentation/sle_ha/book_sleha/?page=/documentation/sle_ha/book_sleha/data/book_sleha.html"

    ensurable

    newparam(:name) do
      desc "Identifier of the location entry.  This value needs to be unique
        across the entire Corosync/Pacemaker configuration since it doesn't have
        the concept of name spaces per type."

      isnamevar
    end

    newproperty(:primitive) do
      desc "The corosync primitive that this location rule applies to"
    end

    newproperty(:nodename) do
      desc "The node that this location rule applies to.  This only needs to be set
        for what we'll call basic rules.'"
    end

    newproperty(:score) do
      desc "The priority of this location.  Primitives can be a part of
        multiple location rules and the score can be used to manipulate what runs
        where and under what conditions.
        This value can be an integer but is often defined as the string
        INFINITY or -INFINITY.  To ensure a resource is always on or always off a node."
    end
    
    # Need to add validations.  If rule is set then operations has to be set.  If there is more than one
    # operation then operator needs to be set.  Right now you just need to know this, which brings to mind
    # the classic badthingswillhappen page.
    newproperty(:rule) do
      desc "The name of a rule. This value needs to be unique
        across the entire Corosync/Pacemaker configuration since it doesn't have
        the concept of name spaces per type."
    end
    
    newproperty(:operator) do
      desc "The boolean operation that the rule applies to.  and/or.  Required if there is more
      operation defined."

    end
    
    # This is intentionally unordered because evaluations in pacemaker occur left to right
    # and having control over this for rules might be useful.
    # I kind of waffled back and forth here on whether to sort or not sort.
    newproperty(:operations,  :array_matching => :all) do
      desc "Operations or evaluations to use in evaluating the rule."
      def should=(value)
        super
        if value.is_a? Array
          @should
        else
          raise Puppet::Error, "Puppet::Type::Cs_Location: operations property must be an array." unless value.is_a? Array
        end
      end
    end
  end
end
