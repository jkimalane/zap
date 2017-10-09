zap
===

Library cookbook for garbage collecting chef controlled resource sets.

One of the common pitfalls in chef land is the pattern of one deleting a
resource definition from a recipe and the user wondering why the resource still
exists on the system.

For example, on Monday a cronjob is added:

```ruby
cron 'collect stats' do
  action	:create
  minute	0
  command '/usr/local/bin/collect-stats | mailto ops@nvwls.com'
end
```

After a few days, the issue is figured out and that cron resource is removed
from the recipe.  After uploading the new cookbook, they wonder why they are
still receiving email.

The issue that chef is great for describing actions.  I mean, *action* is part
of the DSL.

At the 2013 Opscode Communit Summit, Matt Ray and I had a discussion regarding
this issue.  The name *authoritative cookbook* was coined.  If chef is deploying
files to a .d directory, if there are files in that directory not converged by a
resource, those files should be removed.

This pattern has been added to https://github.com/Youscribe/sysctl-cookbook

I presented the zap pattern at ChefConf 2014. You can check out the
video
http://www.youtube.com/watch?v=4-So4AJlBI4&list=PL11cZfNdwNyMmx0msapJfuGsLV43C7XsA&feature=share&index=53
and the slides
https://speakerdeck.com/nvwls/building-authoritative-resource-sets

Thanks
======

Users and groups support was provided by Sander Botman <sbotman@schubergphilis.com>.
Yum_repository support was provided by Sander van Harmelen <svanharmelen@schubergphilis.com>
Apt_repository support was provided by Helgi Þormar Þorbjörnsson <helgi@php.net>
firewall support was provided by Ronald Doorn <rdoorn@schubergphilis.com>.

Resource/Provider
=================

zap_directory
-------------

## Actions

- **:delete** - Delete files and symlinks in a directory

## Attribute Parameters

- **pattern** - Pattern of files to match, i.e. `*.conf`, defaults to `*`
- **recursive** - Recurse into subdirectories, defaults to `false`

### Examples

```ruby
zap_directory '/etc/sysctl.d' do
  pattern '*.conf'
end
```

zap_crontab
-----------

## Actions

- **:delete** - Delete jobs from a user's crontab

## Attribute Parameters

- **pattern** - Pattern of job names match, i.e. `test \#*`, defaults to `*`

### Examples

```ruby
zap_crontab 'root' do
  pattern 'test \#*'
end
```

zap_users
---------

Delete users from `/etc/passwd` style files.
`node['zap']['users']['keep']` contains an array of user names to
keep, i.e. `root`.

## Actions

- **:remove**

## Example

```ruby
zap_users '/etc/passwd' do
  # only zap users whose uid is greater than 500
  filter { |u| u.uid > 500 }
end
```

zap_groups
----------

Delete groups from `/etc/group` style files.
`node['zap']['groups']['keep']` contains an array of group names to
keep, i.e. `wheel`.

## Actions

- **:remove**

## Example

```ruby
zap_groups '/etc/group' do
  # only zap groups whose gid is greater than 500
  filter { |g| g.gid > 500 && g.name != 'nrpe' }
end
```

zap_firewall
------------

Delete all firewall rules that were not defined in Chef using the firewall cookbook.

## Actions

- **:remove**

## Example

```ruby
zap_firewall 'cleaning up firewall'
```

zap
---

This the base HWRP.

## Example

```ruby
zap '/etc/sysctl.d' do
  register :file, :template
  collect { Dir.glob("#{base}/*") }
end
```

Recipes
=======

zap::apt_repos
--------------

Remove extraneous repos from `/etc/apt/sources.list.d`

zap::cron_d
-----------

Remove `/etc/cron.d` entries.

zap::iptables_d
----------------

Remove `/etc/iptables.d` entries created by the iptables cookbook

zap::yum_repos
--------------

Remove extraneous repos from `/etc/yum.repos.d`
