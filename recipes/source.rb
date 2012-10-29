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

case node['platform_family']
when "debian"
  %w{ libpcre3 libpcre3-dev }
when "rhel"
  %w{ pcre pcre-devel }
end.each { |pkg| package pkg }

ark "haproxy" do
  url node['haproxy']['dev']['download_url']
  version "1.5"
  checksum node['haproxy']['dev']['checksum']
  make_opts [ "TARGET=linux26", "USE_LINUX_SPLICE=1", "USE_VSYSCALL=1", "USE_PCRE=1" ] 
  action :install_with_make
end


cookbook_file "/etc/init.d/haproxy" do
  source node['haproxy']['sysv_init_template']
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


  
