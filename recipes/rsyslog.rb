# This recipe configures rsyslog to log the haproxy log facility

include_recipe "logrotate"

directory "/var/log/haproxy" do
  owner "root"
  group "root"
  mode "0755"
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

logrotate_app "haproxy" do
  path "/var/log/haproxy/*.log"
  frequency "daily"
  rotate "90"
  create  "664 root root"
end
