The app continues to run in production mode to keep the responses
fast. However, after each change you need to run ./refresh.sh to
precompile assets and refresh the app.

If you want to run the app in development mode (auto refresh on source
code change, slow responses), there's a few additional things to do in
Passenger configuration and database configuration. See
[Staypuft dev env instructions](https://github.com/theforeman/staypuft/blob/master/doc/setup_centos.md).

How i run the script:

    RENAME_ORIGIN_TO_UPSTREAM=true GITHUB_NAME=jistr /usr/share/staypuft-devel-setup/staypuft_devel_setup.sh

And when i update the source code:

    /usr/share/staypuft-devel-setup/staypuft_refresh.sh
