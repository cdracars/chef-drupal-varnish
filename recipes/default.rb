#
# Cookbook Name:: Drupal Varnish
# Recipe:: default
#
# Copyright 2012, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#
# To-Do add attributes to abstract values

node.override["drupal"]["apache"]["port"]="8080"

execute "download-and-enable-varnish-module" do
  cwd "#{ node['drupal']['dir'] }/sites/default"
  command "drush dl -y varnish --destination=sites/all/modules/contrib/; \
           drush en -y varnish;"
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
end
