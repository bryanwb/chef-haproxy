#
# Cookbook Name:: haproxy
# Recipe:: vhost_lb
#
# Copyright 2011, Opscode, Inc.
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

db_bag, db_item = node['haproxy']['vhosts_data_bag'].split('/')
vhosts = data_bag_item(db_bag, db_item)['vhosts']
get_pool_members(vhosts)

include_recipe "haproxy::source_install"

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy-vhost_lb.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables :vhosts => vhosts
  notifies :restart, "service[haproxy]"
end
