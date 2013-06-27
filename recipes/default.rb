#
# Cookbook Name:: Drupal Varnish
# Recipe:: default
#
# Copyright 2013, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#
# To-Do add attributes to abstract values

include_recipe "drupal"
include_recipe "varnish"

node.override["drupal"]["apache"]["port"]="8080"

execute "download-varnish-module" do
  cwd "#{ node['drupal']['dir'] }/sites/default"
  command "drush dl -y varnish --destination=sites/all/modules/contrib/;"
  not_if "drush pml --no-core --type=module | grep varnish"
end

execute "enable-varnish-module" do
  cwd "#{ node['drupal']['dir'] }/sites/default"
  command "drush en -y varnish;"
  not_if "drush pml --no-core --type=module --status=enabled | grep varnish"
end

template "#{ node['drupal']['dir'] }/varnish.conf" do
  source "varnish.conf.erb"
  mode 0755
  not_if do
    File.exists?("#{ node['drupal']['dir'] }/varnish.conf")
  end
end

conf_plain_file "#{ node['drupal']['dir'] }/sites/default/settings.php" do
  pattern /\/\/ Add Varnish as the page cache handler./
  new_line "\n// Add Varnish as the page cache handler.
  \n$conf['cache_backends'][] = 'sites/all/modules/contrib/varnish/varnish.cache.inc';
  $conf['cache_class_cache_page'] = 'VarnishCache';
  \n// Drupal 7 does not cache pages when we invoke hooks during bootstrap. This needs
  // to be disabled.
  \n$conf['page_cache_invoke_hooks'] = FALSE;"
  action :insert_if_no_match
end

node.default['varnish']['instance'] = node['hostname']

template "/etc/varnish/default.vcl" do
  source "default.vcl.erb"
  mode "0644"
  notifies(:restart, "service[varnish]", :delayed)
  only_if do
    File.exists?("/etc/varnish/")
  end
end
