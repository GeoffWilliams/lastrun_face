# Custom facts exposing status of
# * code manager
# * filesync
# * static catalogs
#
# Fact names prefixed with lastrun_ to avoid possible future namespace 
# collisions if this functionality is addressed in-product
#
# Test functionality involves using the face that ships with this module


# code manager
Facter.add(:lastrun_code_manager_status) do
  setcode do
    Facter::Core::Execution.exec('puppet lastrun code_manager')
  end
end


# filesync
Facter.add(:lastrun_filesync_status) do
  setcode do
    Facter::Core::Execution.exec('puppet lastrun filesync')
  end
end

# static catalogs
Facter.add(:lastrun_static_catalogs_status) do
  setcode do
    Facter::Core::Execution.exec('puppet lastrun static_catalogs')
  end
end
