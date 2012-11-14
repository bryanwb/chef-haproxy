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

require 'open3'
require 'fileutils'

include_recipe "build-essential"
include_recipe "ark"

user "haproxy"

case node['platform_family']
when "debian"
  %w{ libpcre3 libpcre3-dev patch }
when "rhel"
  %w{ pcre pcre-static pcre-devel patch openssl-devel }
end.each { |pkg| package pkg }

make_opts = [
             "TARGET=linux26",
             "USE_LINUX_SPLICE=1",
             "CPU=native",
             "USE_VSYSCALL=1",
             "USE_STATIC_PCRE=1",
             "USE_OPENSSL=1"
            ]

patches_path = "#{node['ark']['prefix_home']}/haproxy/patches"
haproxy_home = "#{node['ark']['prefix_home']}/haproxy"

ark "haproxy" do
  url node['haproxy']['src_url']
  version "1.5-dev12"
  checksum node['haproxy']['src_checksum']
end


ark "patches" do
  url node['haproxy']['patches_url']
  version "20121114"
  checksum  node['haproxy']['patches_checksum']
  prefix_home haproxy_home
end

bash "patch haproxy source" do
  user "root"
  cwd "/usr/local/haproxy"
  code <<-EOF
  for i in patches/*.diff ; do
     patch -p1 < $i
  done
  touch patches/patches.installed
  EOF
  creates "#{patches_path}/patches.installed"
end

bash "make and install haproxy" do
  cwd haproxy_home
  code <<-EOF
  make #{make_opts.join(' ')}
  make install
  touch haproxy.installed
  EOF
  creates "#{haproxy_home}/haproxy.installed"
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


  
