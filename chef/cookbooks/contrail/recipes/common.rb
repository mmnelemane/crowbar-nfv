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

# create contrail user and group
bash "create user and group" do
  code <<-EOF
    useradd contrail
    groupadd contrail
    EOF
  user "root"
end

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

# Setup RabbitMQ server
file "/etc/rabbitmq/rabbitmq.config" do
  content "[
              {rabbit, [ {tcp_listeners, [{'#{contrail_controller_ip}', 5672}]},
              {loopback_users, []},
              {log_levels,[{connection, info},{mirroring, info}]} ]
               }
           ]."
  owner "contrail"
  group "contrail"
  mode "0640"
  notifies :restart, "service[rabbitmq-server]", :immediately
end

# Setup Redis
template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  owner "contrail"
  group "contrail"
  mode "0640"
  variables(
    tcp_backlog: tcp_backlog,
    bind_ip: bind_ip
  )
  notifies :restart, "service[redis]", :immediately
end

bash "set redis memory" do
  user "root"
  code <<-EOF
    sysctl -w net.core.somaxconn=4096 > /dev/null 2>&1
    sysctl -w vm.overcommit_memory=1 > /dev/null 2>&1
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
  EOF
end

file "/usr/lib/systemd/system/redis.service" do
  content "[Unit]
           Description=Redis In-Memory Data Store
           After=network.target

           [Service]
           ExecStart=/usr/sbin/redis-server /etc/redis/redis.conf
           ExecStop=/usr/bin/redis-cli shutdown
           Restart=always

           [Install]
           WantedBy=multi-user.target"
  owner "contrail"
  group "contrail"
  mode "0640"
end

# Setup opscenter
bash "start opscenter" do
  code <<-EOF
    PYTHONPATH=/usr/share/opscenter/lib/py-unpure/:/usr/share/opscenter/lib/py/ /usr/bin/python2.7 /usr/share/opscenter/bin/twistd -u $USERID -g $GROUPID --pidfile /var/run/opscenter/opscenterd.pid -oy /usr/share/opscenter/bin/start_opscenter.py
  EOF
end

# Setup Datastax
bash "start datastax" do
  code <<-EOF
    rpm -ivh /usr/share/opscenter/agent/datastax-agent.rpm
    nohup java -Xmx128M -Djclouds.mpu.parts.magnitude=100000 -Djclouds.mpu.parts.               size=16777216 -Dopscenter.ssl.trustStore=/var/lib/datastax-agent/ssl/agentKeyStore -            Dopscenter.ssl.keyStore=/var/lib/datastax-agessl/agentKeyStore -Dopscenter.ssl.                 keyStorePassword=opscenter -Dagent-pidfile=/var/run/datastax-agent/datastax-agent.pid -         Dlog4j.configuration=file:/etc/datastax-agent/log4j.properties -Djava.security.auth.login.      config=/etc/datastax-agent/kerberos.config -jar /usr/share/datastax-agent/datastax-agent-       5.2.4-standalone.jar /var/lib/datastax-agent/conf/address.yaml </dev/null &>/dev/null &
  EOF
  user "root"
end


