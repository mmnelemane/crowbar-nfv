#
# Cookbook Name:: contrail
# Recipe:: default
#
# Copyright 2016, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node[:contrail][:platform][:general_pkgs].each { |p| package p }

contrail_node = node_search_with_cache("roles::contrail").first
contrail_controller_ip = contrail_node[:neutron][:my_ip]

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "contrail"
  group "contrail"
  mode "0640"
  variables(
    control_plane_ip: contrail_controller_ip
  )
  notifies :restart, "service[haproxy]", :immediately
end

template "/etc/cassandra/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner "contrail"
  group "contrail"
  mode "0640"
  variables(
    control_plane_ip: contrail_controller_ip
  )
  notifies :restart, "service[haproxy]", :immediately
end

template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  owner "contrail"
  group "contrail"
  mode "0640"
  variables(
    control_plane_ip: contrail_controller_ip
  )
  notifies :restart, "service[haproxy]", :immediately
end

file "/usr/bin/zkServer.sh" do
  owner "contrail"
  group "contrail"
  mode "0755"
  action :create_if_missing
  content ""
end
# echo 1 > /var/lib/zookeeper/data/myid

template "/etc/cassandra/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner "contrail"
  group "contrail"
  mode "0640"
  variables(
    control_plane_ip: contrail_controller_ip
  )
  notifies :restart, "service[haproxy]", :immediately
end
