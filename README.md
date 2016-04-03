# lastrun_face

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with lastrun_face](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

A Puppet Face to display the classes and resources used in your last Puppet run.

## Setup

Just install the module on the Puppet Master and run the puppet agent (or wait
for it to run).

You will have access to the new subcommand after this


## Usage

Once installed, you will have access to two new Puppet sub-commands on all
nodes:

```shell
puppet lastrun classes
```
Classes loaded during last Puppet run


```shell
puppet lastrun resources
```
Resources loaded during last Puppet run


## Limitations

Requires the module to be installed on your Puppet Master and run on each
agent node at least once before the command becomes available

## Development
PR's please :)

