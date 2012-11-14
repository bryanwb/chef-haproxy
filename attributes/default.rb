#
# Cookbook Name:: haproxy
# Default:: default
#
# Copyright 2010, Opscode, Inc.
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

default['haproxy']['incoming_port'] = "80"
default['haproxy']['member_port'] = "8080"
default['haproxy']['enable_admin'] = true
default['haproxy']['app_server_role'] = "webserver"
default['haproxy']['balance_algorithm'] = "roundrobin"
default['haproxy']['member_max_connections'] = "100"
default['haproxy']['x_forwarded_for'] = false
default['haproxy']['enable_ssl'] = false
default['haproxy']['ssl_incoming_port'] = "443"
default['haproxy']['ssl_member_port'] = "8443"
default['haproxy']['src_url'] = "http://haproxy.1wt.eu/download/1.5/src/devel/haproxy-1.5-dev12.tar.gz"
default['haproxy']['src_checksum'] = "e4e5c144544a3303550229fe60fba2f1d45f1a034a56c16f6e4e0b256280a416"
default['haproxy']['patches_url'] = "http://haproxy.1wt.eu/download/1.5/src/snapshot/haproxy-1.5-dev12-patches-20121114.tar.gz"
default['haproxy']['patches_checksum'] = "2f7b7f334f20758a5d94b895ea5a05fabfe95f268e963d1fdea1c611a50c9572"

default['haproxy']['backends'] = []
default['haproxy']['vhosts_data_bag'] = 'proxy/vhosts'

case node.platform
when "redhat","centos","fedora"
  default['haproxy']['install_package']  = "pcre-devel"
  default['haproxy']['sysv_init_template'] = "haproxy.init.el"
when "ubuntu","debian"
  default['haproxy']['install_package'] = "libpcre3-dev"
  default['haproxy']['sysv_init_template'] = "haproxy.init.deb"
end
