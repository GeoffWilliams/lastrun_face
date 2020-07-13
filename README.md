[![Build Status](https://travis-ci.org/GeoffWilliams/lastrun_face.svg?branch=master)](https://travis-ci.org/GeoffWilliams/lastrun_face)
# lastrun_face

## Deprecated
Puppet faces are not working correctly in latest PE and are no [longer supported](https://puppet.com/docs/puppet/5.5/deprecated_api.html#puppet-faces-is-a-private-api).

Do not use this module, its no longer supported


#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with lastrun_face](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

A Puppet Face to display the classes and resources used in your last Puppet run
and the last known status of some of the new Puppet Enterprise sub-systems which
are also made available via Facter as custom facts.  This allows the current 
status to be checked via the console.

## Setup

Just install the module on the Puppet Master and run the puppet agent (or wait
for it to run).

You will have access to the new subcommand and custom facts after this


## Usage

### Lastrun face
Once installed, you will have access to two new Puppet sub-commands on all
nodes:


#### Information about last puppet run
This is designed to be a simple interface to enable monitoring of Puppet systems
using external tools such as Nagios, Pager Duty, Sumo, etc

```shell
puppet lastrun info
```

Will return a JSON hash with very limited information about the last puppet run.
The data is parsed from the YAML file at 
`puppet agent --configprint lastrunreport` so if you want more info (there's a 
lot...) you could just parse this file directly.  The advantage of this command
is that this logic is already done for you and we also check to see if the agent
is disabled.

Inside the returned JSON, the key `alarm` indicates whether there is a problem
running puppet on this host.  The following conditions will cause an alarm:
* `status` != `unchanged` and `changed`
* Report is older then 1 hour
* No report is found
* Agent is disabled (`puppet agent --disable`)

Alarms are aways accompanied by a human-readable translation of the problem
encountered, see examples below.

Of course, if your not able to run the command at all or it returns an error, 
then your system has even bigger problems, such as no puppet agent installed, 
face not installed on master (or in this environment), or hell.. maybe SSH 
doesn't even work ;-).  Be sure to catch such conditions as well with your 
reporting system and alarm on them appropriately.

##### Example output

###### System running normally
```json
{
  "message": "",
  "alarm": false,
  "agent_disabled": false,
  "time": "2017-04-20 21:31:44 -0400",
  "status": "unchanged",
  "noop": false,
  "environment": "production",
  "corrective_change": false,
  "report_age": 2014
}
```

###### Puppet agent disabled by user
```json
{
  "message": "Puppet agent disabled by user",
  "alarm": true,
  "agent_disabled": true,
  "time": "2017-04-20 21:31:44 -0400",
  "status": "unchanged",
  "noop": false,
  "environment": "production",
  "corrective_change": false,
  "report_age": 2039
}
```

###### Puppet agent hasn't run for a long time
```json
{
  "message": "puppet report older then 3600 seconds, check running?",
  "alarm": true,
  "agent_disabled": false,
  "time": "2017-04-20 20:31:44 -0400",
  "status": "unchanged",
  "noop": false,
  "environment": "production",
  "corrective_change": false,
  "report_age": 5576
}
```

###### Puppet errored during last run
```json
{
  "message": "status indicates error, check report",
  "alarm": true,
  "agent_disabled": false,
  "time": "2017-04-20 21:31:44 -0400",
  "status": "error",
  "noop": false,
  "environment": "production",
  "corrective_change": false,
  "report_age": 1936
}
```

###### A whole bunch of errors
```json
{
  "message": "Puppet agent disabled by user; status indicates error, check report; puppet report older then 3600 seconds, check running?",
  "alarm": true,
  "agent_disabled": true,
  "time": "2017-04-20 20:31:44 -0400",
  "status": "error",
  "noop": false,
  "environment": "production",
  "corrective_change": false,
  "report_age": 5425
}
```


#### Classes loaded during last Puppet agent run

```shell
puppet lastrun classes
```

#### Resources loaded during last Puppet agent run

```shell
puppet lastrun resources
```

#### Last Puppet catalog applied by agent

```shell
puppet lastrun catalog
```

#### Was Code Manager configured to be active during last Puppet agent run?

```shell
puppet lastrun code_manager
```

Note:  Only makes sense on a PE Master

#### Was filesync configured to be active during last Puppet run?

```shell
puppet lastrun filesync
```

Note:  Only makes sense on a PE Master

#### Was Puppet configured to use a static catalogue on the last Puppet run?

```shell
puppet lastrun static_catalogs
```

### Custom facts
The `lastrun` custom structured fact will be present after installation and 
contains:
* `code_manager_status`
* `filesync_status`
* `static_catalogs_status`

**Example**

```json
"lastrun": {
  "code_manager_status": "off",
  "filesync_status": "indeterminate",
  "static_catalogs_status": "indeterminate"
}
```

These correspond to executing the corresponding `puppet lastface` comand 
_before_ running the Puppet agent.

## Limitations

Requires the module to be installed on your Puppet Master and run on each
agent node at least once before the command becomes available

## Testing
This module supports testing using [PDQTest](https://github.com/declarativesystems/pdqtest).


Test can be executed with:

```
bundle install
make
```

See `.travis.yml` for a working CI example


## Development
PR's please :)
