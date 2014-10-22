#!/bin/bash

set -euxo pipefail

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

cd /usr/share


# === clone repos ===

git clone https://github.com/theforeman/foreman-installer foreman-installer_git || true
pushd foreman-installer_git
if [ "${RENAME_ORIGIN_TO_UPSTREAM:-}" = 'true' ]; then
    git remote rename origin upstream || true
fi
popd

git clone https://github.com/theforeman/foreman-installer-staypuft foreman-installer-staypuft_git || true
pushd foreman-installer-staypuft_git
if [ "${RENAME_ORIGIN_TO_UPSTREAM:-}" = 'true' ]; then
    git remote rename origin upstream || true
fi
if [ "${GITHUB_NAME:-}" != '' ]; then
    git remote add $GITHUB_NAME ssh://git@github.com/$GITHUB_NAME/foreman-installer-staypuft || true
fi
popd

# === initial misc setup ===

cp -ra /usr/share/foreman-installer/modules /usr/share/foreman-installer_git/modules

pushd /etc/foreman
sed -i 's#share/foreman-installer$#share/foreman-installer_git#g' ./staypuft-installer.yaml
sed -i 's#share/foreman-installer/#share/foreman-installer_git/#g' ./staypuft-installer.yaml
sed -i 's#share/foreman-installer$#share/foreman-installer_git#g' ./staypuft-client-installer.yaml || true
sed -i 's#share/foreman-installer/#share/foreman-installer_git/#g' ./staypuft-client-installer.yaml || true
sed -i 's#share/foreman$#share/foreman_git#g' ./staypuft-installer.answers.yaml
sed -i 's#share/foreman/#share/foreman_git/#g' ./staypuft-installer.answers.yaml
popd

# === use bundler + scl with foreman-rake ===
sed -i 's#-c "'\''RAILS_ENV=production $CMD'\''"#-c "scl enable ruby193 '\''RAILS_ENV=production $CMD'\''#g' /usr/sbin/foreman-rake

# === refresh all the things ===

"$DIR/installer_refresh.sh"
