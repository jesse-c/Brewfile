#!/bin/sh

set -euo pipefail

ts=$(date -u +"%Y%m%d%H%M%S")
package_dir=package
package_tar=package_$ts.tar.gz

# Cleanup
rm -rf $package_dir

# Setup
mkdir $package_dir
mkdir -p $package_dir/{css,js}

# HTML
cp ./public/index.html $package_dir

# CSS
cp ./public/css/app.css $package_dir/css

# Javascript
npm run release

cp ./public/js/main.{js,js.map} $package_dir/js

# Bundle
tar cvf $package_tar -C $package_dir .

echo "Wrote package to $package_tar"
