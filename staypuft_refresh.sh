#!/bin/bash

set -euxo pipefail

pushd /usr/share/foreman_git
runuser -s /bin/bash foreman -c "scl enable ruby193 'RAILS_ENV=production bundle exec rake db:migrate apipie:cache assets:precompile'"
# runuser -s /bin/bash foreman -c "scl enable ruby193 'RAILS_ENV=production bundle exec rake db:seed'"
popd

service httpd restart
service foreman-tasks restart
