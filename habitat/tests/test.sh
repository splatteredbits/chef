#!/usr/bin/env bash

set -euo pipefail

export CHEF_LICENSE="accept-no-persist"
export HAB_LICENSE="accept-no-persist"

project_root="$(git rev-parse --show-toplevel)"
pkg_ident="$1"

# print error message followed by usage and exit
error () {
  local message="$1"

  echo -e "\nERROR: ${message}\n" >&2

  exit 1
}

[[ -n "$pkg_ident" ]] || error 'no hab package identity provided'

cd "${project_root}"

echo "--- :mag_right: Testing ${pkg_ident} executables"
for executable in 'chef-client' 'ohai' 'chef-shell' 'chef-apply' 'knife' 'chef-solo'; do
	echo -en "\t$executable = "
  pkg_ident="$pkg_ident" hab pkg exec ${pkg_ident} "${executable}" --version || error "${executable} failed to execute properly"
done

echo "--- :hammer_and_wrench: Installing rspec test dependencies"
pkg_ident="$pkg_ident" hab pkg exec ${pkg_ident} bundle install --with test || error 'failed to install rspec test dependencies'

echo "--- :mag_right: Testing ${pkg_ident} functionality"
pkg_ident="$pkg_ident" hab pkg exec ${pkg_ident} bundle exec rspec spec/functional || error 'failures during rspec functional tests'
