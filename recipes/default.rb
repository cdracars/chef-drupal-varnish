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

execute "download-and-enable-varnish-module" do
  cwd "#{ node['drupal']['dir'] }/sites/default"
  command "drush dl -y varnish --destination=sites/all/modules/contrib/; \
           drush en -y varnish;"
  not_if "drush pml --no-core --type=module --status=enabled | grep varnish"
end

template "#{ node['drupal']['dir'] }/varnish.conf" do
  source "varnish.conf.erb"
  mode 0755
  not_if do
    File.exists?("#{ node['drupal']['dir'] }/varnish.conf")
  end
end

execute "append-varnish-config-to-bottom-of-settings.php" do
  cwd "#{ node['drupal']['dir'] }/sites/default"
  command "cp settings.php settings.php.varnish; \
           cat #{ node['drupal']['dir'] }/varnish.conf >> settings.php.varnish; \
           mv settings.php.varnish settings.php;"
  not_if "grep VarnishCache settings.php"
end

# Varnish
if node.varnish.attribute?("start")
  include_recipe "varnish"

  node.default['varnish']['instance'] = node['hostname']

  template "/etc/varnish/default.vcl" do
    source "default.vcl.erb"
    mode "0644"
    notifies(:restart, "service[varnish]", :delayed)
    only_if do
      File.exists?("/etc/varnish/")
    end
  end
end
