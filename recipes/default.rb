#
# Cookbook Name:: Drupal Varnish
# Recipe:: default
#
# Copyright 2012, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#
# To-Do add attributes to abstract values

execute "set-varnish-port" do
  cwd "/etc/apache2/sites-enabled"
  command "sed -i "s/:80/:8080/g" drupal.conf;"
do

execute "append-varnish-config-to-settings.php" do
  command "sed '$a \
           // Add Varnish as the page cache handler. \
           $conf['cache_backends'][] = 'sites/all/modules/contrib/varnish/varnish.cache.inc'; \
           $conf['cache_class_cache_page'] = 'VarnishCache'; \
           // Drupal 7 does not cache pages when we invoke hooks during bootstrap. This needs \
           // to be disabled. \
           $conf['page_cache_invoke_hooks'] = FALSE;' > #{ node[:drupal][:dir] }/sites/default/settings.php"
end
