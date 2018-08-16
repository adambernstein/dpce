#!/bin/bash
echo "Drupal config partial-export helper v1"

read -e -p "Drush alias? (optional - e.x., @alias): " d_alias
read -e -p "Directory to export config? (This should be outside of your Drupal repository): " export_dir
realdir=$(readlink -f $export_dir)
drush $d_alias cex --destination="$realdir"
read -e -p "Find config files containing [glob]?: " glob
read -e -p "Exclude files containing [glob]?: " notglob
read -e -p "Import directory? (This should be inside your Drupal repository but outside your docroot): " import_dir
realimportdir=$(readlink -f $import_dir)
cd "$realdir" && find . -name "$glob" ! -name "$notglob" | xargs cp -t "$realimportdir"

