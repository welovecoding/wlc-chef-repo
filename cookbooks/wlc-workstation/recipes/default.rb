#
# Cookbook Name:: wlc-workstation
# Recipe:: default
#
# Copyright (C) 2014 Michael Koppen
#
# All rights reserved - Do Not Redistribute
#

# install prequisites for chef tools
%w{qt-x11 gcc-c++ autoconf make libxslt-devel libxml2-devel}.each do |pkg|
  package pkg do
    action :install
  end
end

# RHEL ONLY!!!
remote_file "#{Chef::Config[:file_cache_path]}/gecode-3.7.3-3.el6.x86_64.rpm" do
    source "ftp://ftp.univie.ac.at/systems/linux/fedora/epel/6/x86_64/gecode-3.7.3-3.el6.x86_64.rpm"
    action :create
end
remote_file "#{Chef::Config[:file_cache_path]}/gecode-devel-3.7.3-3.el6.x86_64.rpm" do
    source "ftp://ftp.univie.ac.at/systems/linux/fedora/epel/6/x86_64/gecode-devel-3.7.3-3.el6.x86_64.rpm"
    action :create
end

rpm_package "gecode" do
    source "#{Chef::Config[:file_cache_path]}/gecode-3.7.3-3.el6.x86_64.rpm"
    action :install
end
rpm_package "gecode-devel" do
    source "#{Chef::Config[:file_cache_path]}/gecode-devel-3.7.3-3.el6.x86_64.rpm"
    action :install
end


# install chef development tools
ENV['NOKOGIRI_USE_SYSTEM_LIBRARIES'] = '1'
ENV['USE_SYSTEM_GECODE'] = '1'

%w{berkshelf chef-vault test-kitchen foodcritic bundler}.each do |pkg|
  gem_package pkg do
    gem_binary '/opt/chef/embedded/bin/gem'
    action :install
  end
end

link '/usr/bin/gem' do
  to '/opt/chef/embedded/bin/gem'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/gem'
end
link '/usr/bin/ruby' do
  to '/opt/chef/embedded/bin/ruby'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/ruby'
end


link '/usr/bin/bundle' do
  to '/opt/chef/embedded/bin/bundle'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/bundle'
end
link '/usr/bin/kitchen' do
  to '/opt/chef/embedded/bin/kitchen'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/kitchen'
end
link '/usr/bin/berks' do
  to '/opt/chef/embedded/bin/berks'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/berks'
end
link '/usr/bin/foodcritic' do
  to '/opt/chef/embedded/bin/foodcritic'
  owner 'root'
  group 'root'
  action :create
  only_if 'test -f /opt/chef/embedded/bin/foodcritic'
end

group node['wlc-workstation']['group'] do
  action :create
end

user node['wlc-workstation']['user'] do
  gid node['wlc-workstation']['group']
  system true
  shell "/bin/bash"
  home node['wlc-workstation']['user_home']
  action :create
end

directory "#{node['wlc-workstation']['user_home']}/.berkshelf" do
  owner node['wlc-workstation']['user']
  group node['wlc-workstation']['group']
  mode '0755'
  recursive true
  action :create
end

# copy berkshelf config
template "#{node['wlc-workstation']['user_home']}/.berkshelf/config.json" do
  source 'config.json.erb'
  owner "#{node['wlc-workstation']['user']}"
  group "#{node['wlc-workstation']['group']}"
  mode '0644'
end

include_recipe 'git'

git node['wlc-workstation']['repo_path_local'] do
  repository node['wlc-workstation']['repo_url']
  action :sync
end

include_recipe 'knife'