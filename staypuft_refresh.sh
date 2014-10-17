#!/bin/bash

set -euxo pipefail

pushd /usr/share/foreman_git
scl enable ruby193 'runuser -s /bin/bash foreman -c "RAILS_ENV=production bundle exec rake db:migrate apipie:cache assets:precompile"'
# scl enable ruby193 'runuser -s /bin/bash foreman -c "RAILS_ENV=production bundle exec rake db:seed"'
popd

service httpd restart
service foreman-tasks restart
