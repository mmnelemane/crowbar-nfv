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

class OpendaylightService < ServiceObject
  def initialize(thelogger)
    super(thelogger)
    @bc_name = "opendaylight"
  end

  class << self
    def role_constraints
      {
        "opendaylight" => {
          "unique" => false,
          "count" => -1,
          "admin" => false,
          "exclude_platform" => {
            "windows" => "/.*/"
          }
        }
      }
    end
  end

  def create_proposal
    @logger.debug("opendaylight create_proposal: entering")
    base = super

    nodes = NodeObject.all
    # Don't include the admin node by default, you never know...
    nodes.delete_if { |n| n.nil? or n.admin? }

    # Ignore nodes that are being discovered
    base["deployment"]["opendaylight"]["elements"] = {
      "updater" => nodes.select { |x| not ["discovering", "discovered"].include?(x.status) }.map { |x| x.name }
    }

    @logger.debug("opendaylight create_proposal: exiting")
    base
  end

end
