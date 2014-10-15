#!/bin/bash

set -euxo pipefail

STAYPUFT_INSTALLER_DIR=${STAYPUFT_INSTALLER_DIR:-/usr/share/foreman-installer-staypuft_git}

FOREMAN_INSTALLER_DIR=${FOREMAN_INSTALLER_DIR:-/usr/share/foreman-installer_git}

if [ ! -d "$FOREMAN_INSTALLER_DIR" ]; then
    echo "FOREMAN_INSTALLER_DIR doesn't exist: '$FOREMAN_INSTALLER_DIR'"
fi

if [ ! -d "$STAYPUFT_INSTALLER_DIR" ]; then
    echo "STAYPUFT_INSTALLER_DIR doesn't exist: '$STAYPUFT_INSTALLER_DIR'"
fi

cp -r "$STAYPUFT_INSTALLER_DIR/modules" "$FOREMAN_INSTALLER_DIR"
cp -r "$STAYPUFT_INSTALLER_DIR/hooks" "$FOREMAN_INSTALLER_DIR"

if [[ "$STAYPUFT_INSTALLER_BIN" = 'true' ]]; then
    cp "$STAYPUFT_INSTALLER_DIR/bin/staypuft-installer" /usr/sbin
    chmod a+x /usr/sbin/staypuft-installer
    cp "$STAYPUFT_INSTALLER_DIR/bin/staypuft-client-installer" /usr/sbin
    chmod a+x /usr/sbin/staypuft-client-installer
fi

if [[ "$STAYPUFT_INSTALLER_CONFIG" = 'true' ]]; then
    cp "$STAYPUFT_INSTALLER_DIR/config/staypuft-installer.answers.yaml" /etc/foreman
    cp "$STAYPUFT_INSTALLER_DIR/config/staypuft-installer.yaml" /etc/foreman
    cp "$STAYPUFT_INSTALLER_DIR/config/staypuft-client-installer.yaml" /etc/foreman
    pushd /etc/foreman
    sed -i 's#share/foreman-installer$#share/foreman-installer_git#g' ./staypuft-installer.yaml
    sed -i 's#share/foreman-installer$#share/foreman-installer_git#g' ./staypuft-client-installer.yaml
    sed -i 's#share/foreman-installer/#share/foreman-installer_git/#g' ./staypuft-installer.yaml
    sed -i 's#share/foreman-installer/#share/foreman-installer_git/#g' ./staypuft-client-installer.yaml
    popd
fi

if [[ "$STAYPUFT_INSTALLER_MODULES" = 'true' ]]; then
    rm -rf /etc/puppet/environments/production/modules/foreman
    cp -r "$FOREMAN_INSTALLER_DIR/modules/foreman" /etc/puppet/environments/production/modules/foreman
fi
