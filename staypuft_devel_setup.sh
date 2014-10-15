#!/bin/bash

set -euxo pipefail

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

cd /usr/share


# === clone repos ===

git clone https://github.com/theforeman/foreman foreman_git || true
pushd foreman_git
if [ "${RENAME_ORIGIN_TO_UPSTREAM:-}" = 'true' ]; then
    git remote rename origin upstream || true
fi
popd

git clone https://github.com/theforeman/staypuft staypuft_git || true
pushd staypuft_git
if [ "${RENAME_ORIGIN_TO_UPSTREAM:-}" = 'true' ]; then
    git remote rename origin upstream || true
fi
if [ "${GITHUB_NAME:-}" != '' ]; then
    git remote add $GITHUB_NAME ssh://git@github.com/$GITHUB_NAME/staypuft || true
fi
popd


# === initial misc setup ===

yum install -y gcc ruby193-ruby-devel ruby-devel libxml2 libxml2-devel libxslt libxslt-devel postgresql-libs postgresql-devel gcc-c++
cp -a foreman/config/database.yml foreman_git/config/
cp -a foreman/config/settings.yaml foreman_git/config/
cp -a foreman/bundler.d/* foreman_git/bundler.d
echo "gem 'staypuft', :path => '/usr/share/staypuft_git'" > foreman_git/bundler.d/staypuft.rb

# need these latest versions available globally so passenger can preload them
scl enable ruby193 'gem install rake rack'


# === setup foreman_git directory, install bundle ===

pushd foreman_git
ln -sf /var/run/foreman tmp
touch log/development.log
chmod 0666 log/development.log
touch log/production.log
chmod 0666 log/production.log

scl enable ruby193 'bundle config build.nokogiri --use-system-libraries'
# need to install into system gems if we want staypuft-installer to work too
scl enable ruby193 'bundle install --without sqlite mysql mysql2 libvirt vmware gce'
# scl enable ruby193 'bundle install --path .bundle/data --without sqlite mysql mysql2 libvirt vmware gce'

chown -R foreman .
popd


# === passenger settings ===

pushd /etc/httpd/conf.d
sed -i "s#share/foreman/#share/foreman_git/#g" ./05-foreman.conf
sed -i 's#share/foreman$#share/foreman_git#g' ./05-foreman.conf
sed -i "s#share/foreman/#share/foreman_git/#g" ./05-foreman-ssl.conf
sed -i 's#share/foreman$#share/foreman_git#g' ./05-foreman-ssl.conf
popd


# === refresh all the things and restart httpd ===

# stop foreman-tasks, refresh.sh will start it with
# /usr/share/foreman_git as the foreman directory
service foreman-tasks stop

"$DIR/staypuft_refresh.sh"
