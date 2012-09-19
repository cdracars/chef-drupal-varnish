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
  cwd "#{ node[:drupal][:dir] }/sites/default"
  command "drush dl varnish; \
           drush en -y varnish;"
end

bash "append-varnish-config-to-settings.php" do
  cwd "#{ node[:drupal][:dir] }/sites/default"
  code <<-EOH
  cp settings.php settings.php.tmp
  cat <<\EOF >> settings.php.tmp
  // Add Varnish as the page cache handler.
  $conf['cache_backends'][] = 'sites/all/modules/contrib/varnish/varnish.cache.inc';
  $conf['cache_class_cache_page'] = 'VarnishCache';
  // Drupal 7 does not cache pages when we invoke hooks during bootstrap. This needs
  // to be disabled.
  $conf['page_cache_invoke_hooks'] = FALSE;
  EOF
  mv settings.php.tmp settings.php
  EOH
end
