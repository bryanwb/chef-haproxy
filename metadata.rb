name "haproxy"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures haproxy 1.5dev"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.7"

recipe "haproxy", "Installs and configures haproxy 1.5dev"

%w{ debian ubuntu redhat centos fedora}.each do |os|
  supports os
end
