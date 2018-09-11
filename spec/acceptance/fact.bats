@test "fact present: lastrun_code_manager_status" {
    grep "code_manager_status" /tmp/lastrun_facts.txt
}

@test "fact_present: lastrun_filesync_status" {
    grep "filesync_status" /tmp/lastrun_facts.txt
}

@test "fact_present: lastrun_static_catalogs_status" {
    grep "static_catalogs_status" /tmp/lastrun_facts.txt
}
