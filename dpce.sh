#!/bin/bash
#@TODO colors
echo -e "Drupal config partial export helper v1\n"
test_root_dir () {
    drush_drupal_root=$(drush eval "print drush_get_context('DRUSH_DRUPAL_ROOT')")
    drupal_root=$(readlink -f $drush_drupal_root)
    unameOut="$(uname -s)"

    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac

    if [ "$machine" == "Cygwin" ] || [ "$machine" == "MinGw" ]; then
        pwdOut="$(pwd -W)"
    else 
        pwdOut="$(pwd)"
    fi
    
    if [ "$pwdOut" != "$drupal_root" ]; then
        echo -e "Please run dpce from your Drupal docroot."
        exit 2
    fi
        
}

collect_data_export () {
    # read -e -p "Drush alias? (optional - e.x., @alias): " d_alias
    read -e -p "Directory to export config (this should be outside of your Drupal repository): " export_dir
    # @TODO test if export_dir blank
    realdir=$(readlink -f $export_dir)
    # drush $d_alias cex --destination="$realdir"
    #drush config-export --destination="$realdir"
}

find_configs () {
    read -e -p "Find config files containing [glob]?: " glob
    read -e -p "Exclude files containing [glob]?: " notglob
    findresult=$(find "$realdir" -name "$glob.yml" ! -name "$notglob")
    echo -e "Found $($findresult | wc -l) files."
    confirm
}

confirm () {
    read -e -p "Confirm list? [y/n]: " isconfirmed
    if [ -z "$isconfirmed" ]; then
        confirm
    fi

}

import () {
    read -e -p "Import directory? (This should be inside your Drupal repository but outside your docroot): " import_dir
    realimportdir=$(readlink -f $import_dir)

    if [ -d "$import_dir" ]; then
        
        cd "$realdir" && find . -name "$glob" ! -name "$notglob" | xargs cp -t "$realimportdir"
        echo -e "Success.\nPlease commit these files to your git repository and push to your remote. Then ssh to your remote and run:\ndrush config-import --partial --source=\""$realimportdir"\""
    else
        read -e -p "Directory "$import_dir" does not exist. Create it? [y/n]: " create_confirm
        if ["$create_confirm" == "y" ]; then
            mkdir "$realimportdir"
            import
        else exit 2
        fi
    fi   
}

test_root_dir
collect_data_export
while [ "$isconfirmed" != "y" ]; 
    do
        find_configs
    done
import