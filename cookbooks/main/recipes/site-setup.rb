package "checkinstall"
package "libjpeg62-dev"
package "libxml2-dev"


script "Set proper default groups" do
    interpreter "bash"
    user "root"
    code <<-EOH
    usermod -g www-pub vagrant
    usermod -g www-pub www-data
    EOH
end

directory "/var/www/basicproject/" do
    owner "www-data"
    group "www-pub"
    mode 0775
    recursive true
end

directory "/var/www/basicproject/logs/" do
    owner "www-data"
    group "www-pub"
    mode 0775
end

directory "/var/www/basicproject/emails/" do
    owner "www-data"
    group "www-pub"
    mode 0775
end

directory "/var/www/basicproject/site_media/static/" do
    owner "www-data"
    group "www-pub"
    mode 0775
    recursive true
end

directory "/var/www/basicproject/site_media/media/" do
    owner "www-data"
    group "www-pub"
    mode 0775
end

cookbook_file "/etc/nginx/sites-available/basicproject" do
    source "nginx/sites-available/basicproject.conf"
    owner "root"
    group "root"
    mode 0644
end

link "/etc/nginx/sites-enabled/basicproject" do
    to "/etc/nginx/sites-available/basicproject"
    notifies :restart, resources(:service => "nginx")
end

cookbook_file "/home/vagrant/.django_bash_completion" do
    source "django_bash_completion"
    owner "vagrant"
    group "vagrant"
    mode 0755
end

cookbook_file "/home/vagrant/.bashrc" do
    source "bashrc"
    owner "vagrant"
    group "vagrant"
    mode 0755
end

script "Purge pyc files" do
    interpreter "bash"
    user "root"
    cwd "/var/www/basicproject/"
    code "find . -name '*.pyc' -exec rm -rf {} \\;"
end

directory "/var/www/envs/" do
    owner "www-data"
    group "www-pub"
    mode 0775
end

execute "Create virtualenv" do
    user "vagrant"
    group "www-pub"
    command "virtualenv /var/www/envs/basicproject"
    not_if "test -f /var/www/envs/basicproject/bin/python"
end

script "Install Requirements" do
    interpreter "bash"
    user "vagrant"
    group "www-pub"
    cwd "/var/www/basicproject/"
    code <<-EOH
    /var/www/envs/basicproject/bin/pip install -r /var/www/basicproject/basicproject/requirements.txt --exists-action=w
    EOH
end

script "Syncdb and migrate" do
    interpreter "bash"
    user "vagrant"
    cwd "/var/www/basicproject/basicproject/"
    code <<-EOH
    /var/www/envs/basicproject/bin/python manage.py syncdb --migrate --noinput
    EOH
end
