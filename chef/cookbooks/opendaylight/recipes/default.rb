#
# Cookbook Name:: opendaylight
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

if node[:platform_family] == "suse"

  package "opendaylight-java"

  bash "start opendaylight controller" do
    user "root"
    code <<-EOF
      case "$(pidof karaf | wc -w)" in
      0) echo "Restarting OpenDayLight Karaf"
         /opt/distribution-karaf-0.4.0-Beryllium/bin/start
         ;;
      1) echo "Karaf already running. Nothing to do"
         ;;
      *) echo "More than one Containers running. Stopping few."
         kill $(pidof karaf | awk '{print $1}')
         ;;
      esac
    EOF
  end
end

