include_recipe 'apt'
package 'apt-transport-https'

apt_repository 'phusion' do
  action        :nothing
  uri           'https://oss-binaries.phusionpassenger.com/apt/passenger'
  distribution  node['lsb']['codename']
  components    ['main']
  keyserver     'hkp://keyserver.ubuntu.com:80'
  key           '561F9B9CAC40B2F7'
end.run_action(:add)

package 'nginx-common' do
  options '-o DPkg::Options::="--force-confold"'
end

package 'passenger'
package 'nginx-extras'
package 'libnginx-mod-http-passenger'

template '/etc/nginx/nginx.conf' do
  action :create
  notifies :restart, 'service[nginx]'
end

template '/etc/nginx/conf.d/mod-http-passenger.conf' do
  action :create
  notifies :restart, 'service[nginx]'
end

directory node['nginx_passenger']['sites_dir'] do
  action      :create
  recursive   true
  mode        0755
end

directory node['nginx_passenger']['log_dir'] do
  action :create
  recursive true
  mode 0755
  owner 'www-data'
end

template "#{node['nginx_passenger']['sites_dir']}/DEFAULT" do
  action node['nginx_passenger']['catch_default'] ? :create : :delete
  notifies :reload, "service[nginx]"
end

service 'nginx' do
  action    [:enable,:start]
  supports  [:enable,:start,:stop,:disable,:reload,:restart]
end
