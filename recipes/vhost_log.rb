template  "/etc/rsyslog.d/haproxy.conf"  do
  owner "root" 
  group "root" 
  source "haproxy_vhost_rsyslog.erb" 
end


