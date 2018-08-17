#!/bin/bash
echo "Drupal config partial-export helper v1"

read -e -p "Drush alias? (optional - e.x., @alias): " d_alias
read -e -p "Directory to export config? (This should be outside of your Drupal repository): " export_dir
# @TODO test if export_dir blank
realdir=$(readlink -f $export_dir)

## drush $d_alias cex --destination="$realdir"
read -e -p "Find config files containing [glob]?: " glob
read -e -p "Exclude files containing [glob]?: " notglob

# @TODO print files list, number found & confirm
find_configs () {
   find "$realdir" -name "$glob" ! -name "$notglob" 
}

find_configs
# @TODO confirm/retry

read -e -p "Import directory? (This should be inside your Drupal repository but outside your docroot): " import_dir
# @TODO test if import_dir blank

realimportdir=$(readlink -f $import_dir)

cd "$realdir" && find . -name "$glob" ! -name "$notglob" | xargs cp -t "$realimportdir"

# @TODO print drush command to run on server