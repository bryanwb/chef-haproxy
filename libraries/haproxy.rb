# if i choose to make this a regular module
# to include this module in your recipe
# ::Chef::Recipe.send(:include, Chef::Kookbook::Haproxy)


class HaproxyBlock < Hash

  def initialize(*args, &block)
    name = args[0].nil? ? "" : args[0]
    @backend = { 'name' => name, 'protocol' => 'http', 'port' => nil}
  end

  def protocol(protocol_num)
    @backend['protocol'] = protocol_num.to_s
  end

  def port(port_num)
    @backend['port'] = port_num.to_s
  end

  attr_reader :backend
  
end

def proxy_me(name=nil, backend=nil, &block)
  node['haproxy']['backends'] = [] if node['haproxy']['backends'].nil?
  if backend.kind_of? Hash
    remove_duplicates(node['haproxy']['backends'], backend)
    node['haproxy']['backends'].push backend
  else
    unless backend.nil?
      Chef::Application.fatal!("Invalid values passed to proxy method")
    end
  end
  if block
    new_backend = HaproxyBlock.new(name)
    new_backend.instance_eval(&block)
    remove_duplicates(node['haproxy']['backends'], new_backend.backend)
    node['haproxy']['backends'] << new_backend.backend
  end
  Chef::Log.debug("The proxy_backends are #{node['haproxy']['backends']} ") 
end

def remove_duplicates(backends, new_backend)
  backends.delete_if do |backend|
    backend['port'] == new_backend['port']
  end
end

def get_pool_members(vhosts)
  vhosts.each do |vhost|
    additional_roles = vhost['search_roles'].map { |r| "roles:#{r}"}
    more_roles = additional_roles.join(" AND ")
    more_roles = " AND #{more_roles}" unless additional_roles.empty?
    pool_members = search("node", "haproxy_backends_name:#{vhost['name']}  #{more_roles}").map do |member|
      ports = member['haproxy']['backends'].map { |b| b['port'] }
      ports.map do |port|
        { 'ipaddress' => member_get_ip(member) , 'port' => port }
      end
    end
    vhost['members'] = pool_members.flatten
  end
end
  

# get the IP of a pool member
def member_get_ip(pool_member)
  server_ip = begin
    if pool_member.attribute?('cloud')
      if node.attribute?('cloud') && (pool_member['cloud']['provider'] == node['cloud']['provider'])
         pool_member['cloud']['local_ipv4']
      else
        pool_member['cloud']['public_ipv4']
      end
    else
      pool_member['ipaddress']
    end
  end
  server_ip
end
