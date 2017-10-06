`
cat >/etc/apt/sources.list.d/dummy.list <<EOF
deb      [trusted=yes] "https://dummy.net/stable-apt" wheezy main
EOF
`

apt_repository 'chef-stable' do
  uri 'https://packages.chef.io/stable-apt'
  components ['main']
  trusted true
  cache_rebuild false
end

include_recipe 'zap::apt_repos'
