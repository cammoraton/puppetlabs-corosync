require 'puppet/provider/corosync'
Puppet::Type.type(:cs_ms).provide(:crm, :parent => Puppet::Provider::Corosync) do
  desc 'Provider to add, delete, manipulate mult-state resources'

  # Path to the crm binary for interacting with the cluster configuration.
  commands :crm => 'crm'
  commands :crm_attribute => 'crm_attribute'

  def self.instances
    
    block_until_ready

    instances = []
    
    cmd = []
    cmd << command(:crm)
    cmd << 'configure'
    cmd << 'show'
    cmd << 'xml'
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    doc = REXML::Document.new(raw)
    doc.root.elements['configuration'].elements['resources'].each_element('master') do |e|
      items = e.attributes
      master = { :name => items['id'].to_sym, :metadata => {} }
      if ! e.elements['primitive'].nil?
        master[:primitive] = e.elements['primitive'].attributes['id']
      elsif ! e.elements['group'].nil?
        master[:primitive] = e.elements['group'].attributes['id']
      end
      if ! e.elements['meta_attributes'].nil?
        e.elements['meta_attributes'].each_element do |m|
          master[:metadata][(m.attributes['name'])] = m.attributes['value']
        end
      end

      master_instance = {
        :name => master[:name],
        :ensure => :present,
        :primitive => master[:primitive],
        :metadata => master[:metadata],
        :provider => self.name
      }
      instances << new(master_instance)
    end
    instances
  end
  
  # Getters that obtains the parameters and operations defined in our primitive
  # that have been populated by prefetch or instances (depends on if your using
  # puppet resource or not).
  def metadata
    @property_hash[:metadata]
  end
  
  # Our setters for parameters and operations. Setters are used when the
  # resource already exists so we just update the current value in the
  # property_hash and doing this marks it to be flushed.
  def metadata=(should)
    @property_hash[:metadata] = should
  end
  
  # Create just adds our resource to the property_hash and flush will take care
  # of actually doing the work.
  def create
    @property_hash = {
      :name => @resource[:name],
      :ensure => :present,
      :primitive => @resource[:primitive],
      :metadata => @resource[:metadata]
    }
  end

  # Unlike create we actually immediately delete the item but first, like primitives,
  # we need to stop the group.
  def destroy
    cmd = [ command(:crm), 'resource', 'stop', @resource[:name] ]
    debug('Stopping group before removing it')
    Puppet::Util.exectute(cmd)
    cmd = []
    cmd << command(:crm)
    cmd << 'configure'
    cmd << 'delete'
    cmd << @resource[:name]
    debug('Removing master/slave')
    Puppet::Util.execute(cmd)
    @property_hash.clear
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash. It generates a temporary file with
  # the updates that need to be made. The temporary file is then used
  # as stdin for the crm command.
  def flush
    unless @property_hash.empty?
      unless @property_hash[:metadata].empty?
        metadatas = 'meta '
        @property_hash[:metadata].each_pair do |k,v|
          metadatas << "#{k}=#{v} "
        end
      end
      updated = ''
      updated << "ms "
      updated << "#{@property_hash[:name]} "
      updated << "#{@property_hash[:primitive]} "
      updated << "#{metadatas} " unless metadatas.nil?
      cmd = [ command(:crm), 'configure', 'load', 'update', '-' ]
      Tempfile.open('puppet_crm_update') do |tmpfile|
        tmpfile.write(updated)
        tmpfile.flush
        Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s)
      end
    end
  end
end