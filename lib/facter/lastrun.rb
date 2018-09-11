require 'puppet_x/lastrun'
# Custom fact exposing status of
# * code manager
# * filesync
# * static catalogs
#
# @example Sample output
#   "lastrun": {
#     "code_manager_status": "off",
#     "filesync_status": "indeterminate",
#     "static_catalogs_status": "indeterminate"
#   }
Facter.add(:lastrun) do
  setcode do
    {
        "code_manager_status"     => PuppetX::LastRun.code_manager_status,
        "filesync_status"         => PuppetX::LastRun.filesync_status,
        "static_catalogs_status"  => PuppetX::LastRun.static_catalogs_status,
    }
  end
end
