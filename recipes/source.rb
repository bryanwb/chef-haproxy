#
# Cookbook Name:: haproxy
# Recipe:: source
#
# Copyright 2012, CX inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"
include_recipe "ark"

user "haproxy"

case node.platform
when "redhat","centos","fedora"
  package "pcre-devel"
  init_script = "haproxy.init.el"
when "ubuntu","debian"
  package "libpcre3-dev"
  init_script = "haproxy.init.deb"
end

ark "haproxy" do
  url node['haproxy']['dev']['download_url']
  version "1.5"
  checksum node['haproxy']['dev']['checksum']
  make_opts [ "TARGET=linux26", "USE_LINUX_SPLICE=1", "USE_VSYSCALL=1", "USE_PCRE=1" ] 
  action :install_with_make
end

execute "halog_make" do
  cwd "#{node['haproxy']['dev']['src_dir']}/contrib/halog"
  case node['kernel']['machine']
  when "x86_64"
    command "make halog64"
  when "i686"
    command "make halog"
  end
  user node['haproxy']['user']
  only_if do File.exists?("#{node['haproxy']['dev']['src_dir']}/contrib/halog/Makefile") end
  notifies :run, "execute[halog_make_install]", :immediately
  action :nothing
end


execute "halog_make_install" do
  cwd "#{node['haproxy']['dev']['src_dir']}/contrib/halog"
  command "cp halog /usr/local/bin"
  user "root"
  only_if do File.exists?("#{node['haproxy']['dev']['src_dir']}/contrib/halog/halog") end
  action :nothing
end

cookbook_file "/etc/init.d/haproxy" do
  source init_script
  owner "root"
  group "root"
  mode 0755
  notifies :restart, "service[haproxy]"
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action :nothing
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[haproxy]"
end

directory "/etc/haproxy"

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[haproxy]"
end

service "haproxy" do
  action [:enable, :start]
end

file "/etc/rsyslog.d/haproxy.conf" do
  owner  "root"
  group  "root"
  mode   "0755"
  content <<-EOF
  # dropped off by Chef 
  local0.*       /var/log/haproxy.log
  EOF
end

  
