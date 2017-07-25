#
# Cookbook Name:: opendaylight
# Attributes:: default
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

default[:opendaylight][:features] = "odl-netvirt-openstack"
default[:opendaylight][:port] = "8070"

default[:contrail][:controller_ip] = ""
default[:contrail][:admin_ip] = ""

case node[:platform_family]
when "suse"
  default[:contrail][:platform] = {
    general_pkgs: ["python-devel",
                   "haproxy",
                   "zookeeper",
                   "libzookeeper",
                   "libzookeeper-devel",
                   "python-zookeeper",
                   "cassandra",
                   "cassandra-cpp-driver",
                   "cassandra-tools",
                   "libcassandra2",
                   "rabbitmq-server",
                   "redis",
                   "redis-py",
                   "yum", 
                   "ifmap-server",
                   "cyrus-sasl-plain",
                   "python-cassandra-driver",
                   "opscenter"],
    contrail_pkgs: ["contrail-database",
                    "contrail-database-common",
                    "contrail-analytics",
                    "contrail-config",
                    "contrail-control",
                    "contrail-web-controller",
                    "contrail-config-openstack",
                    "contrail-dns",
                    "contrail-docs",
                    "contrail-nodemgr",
                    "python-contrail",
                    "contrail-openstack-webui",
                    "contrail-setup",
                    "contrail-utils",
                    "contrail-lib"]
  }
when "rhel"
  default[:contrail][:platform] = {
    general_pkgs: ["python-devel",
                   "haproxy",
                   "zookeeper",
                   "libzookeeper",
                   "libzookeeper-devel",
                   "python-zookeeper",
                   "cassandra",
                   "cassandra-cpp-driver",
                   "cassandra-tools",
                   "libcassandra2",
                   "rabbitmq-server",
                   "redis",
                   "redis-py",
                   "yum", 
                   "ifmap-server",
                   "cyrus-sasl-plain",
                   "python-cassandra-driver",
                   "opscenter"],
    contrail_pkgs: ["contrail-database",
                    "contrail-database-common",
                    "contrail-analytics",
                    "contrail-config",
                    "contrail-control",
                    "contrail-web-controller",
                    "contrail-config-openstack",
                    "contrail-dns",
                    "contrail-docs",
                    "contrail-nodemgr",
                    "python-contrail",
                    "contrail-openstack-webui",
                    "contrail-setup",
                    "contrail-utils",
                    "contrail-lib"]
  }
else
  default[:contrial][:platform] = {
    general_pkgs: [],
    contrail_pkgs: []
  }
end
