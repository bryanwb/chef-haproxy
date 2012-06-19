#
# Cookbook Name:: haproxy
# Recipe:: users
#
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

include_recipe "sudo"
include_recipe "users"

haproxy_user = "haproxy"

# get public key
public_key = data_bag_item("users", "haproxy")["ssh_keys"]

# get secret key
private_key = Chef::EncryptedDataBagItem.load("certificates", "haproxy")['key']

users_manage_noid haproxy_user do
  action [ :remove, :create ]
end


directory "/home/haproxy/.ssh" do
  owner "haproxy"
  group "haproxy"
  mode "0700"
end

file "/home/haproxy/.ssh/id_rsa.pub" do
  content public_key
  owner "haproxy"
  group "haproxy"
  mode "0600"
end


file "/home/haproxy/.ssh/id_rsa" do
  content private_key
  owner "haproxy"
  group "haproxy"
  mode "0600"
end

# add sudoers
sudo "haproxy" do
  template "sudoers.erb"
end
