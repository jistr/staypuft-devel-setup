#!/bin/bash

set -euxo pipefail

pushd /usr/share/foreman_git
scl enable ruby193 'RAILS_ENV=production su foreman -c "bundle exec rake db:migrate apipie:cache assets:precompile"'
# scl enable ruby193 'bundle exec rake db:seed'
popd

service httpd restart
