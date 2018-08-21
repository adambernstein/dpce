#!/bin/bash
#@TODO colors
echo -e "Drupal config partial export helper v1\n"

test_root_dir () {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
    
    # Test which directory path syntax to use.
    if [ "$machine" == "Cygwin" ] || [ "$machine" == "MinGw" ]; then
        pwdOut="$(pwd -W)"
        pwdCommand="pwd -W"
    else 
        pwdOut="$(pwd)"
        pwdCommand="pwd"
    fi
    
    # Test if not in Drupal root nor an alias provided. (Drush bootstrap will fail.)
    drush_drupal_root=$(drush $d_alias eval "print drush_get_context('DRUSH_DRUPAL_ROOT')")
        # Remove? drupal_root=$(readlink -f "$drush_drupal_root")
    drupal_root=$(cd $drush_drupal_root && eval $pwdCommand)
    if [ "$pwdOut" != "$drupal_root" ] && [ -z "$d_alias" ]; then
        echo -e "[Fail] Please provide a Drush alias or run dpce from your Drupal docroot."
        exit 2
    fi

    # Test provided drush alias 
    if [ ! -d "$drush_drupal_root" ]; then
        echo "[Fail] Can't find Drush alias $d_alias"
        exit 2;
    elif [ -z "$d_alias" ]; then
        echo -e "[Success] Site found - using local directory.\n"
    else 
        echo -e "[Success] Site found.\n"
    fi


}

collect_data_export () {
    read -e -p "Drush alias? (optional - e.x., @alias): " d_alias
    test_root_dir
    read -e -p "Directory to export config (this should be outside of your Drupal repository): " export_dir_in    
    while [ -z "$export_dir_in" ];
        do
            read -e -p "Directory to export config (this should be outside of your Drupal repository): " export_dir_in
        done
    export_dir=$(eval readlink -f $export_dir_in)
    if [ -d "$export_dir" ]; then        
        #drush $d_alias cex --destination="$export_dir"
        echo "simulated export"
    else
        read -e -p "Directory $export_dir does not exist. Create? [y/n]:" create_export_dir
        if [ "$create_export_dir" != "y" ]; then
            echo -e "[Fail] Export failed. Please run dpce again and choose an export directory outside of your Drupal repository."
            exit 2
        else             
            mkdir $export_dir
            echo -e "[Success] Export directory created at $export_dir\n"
            drush $d_alias cex --destination="$export_dir"
        fi
    fi

}

find_configs () {
    read -e -p "Find config files containing [glob]?: " glob
    read -e -p "Exclude files containing [glob]?: " notglob
    findresult=$(find "$export_dir" -name "$glob" ! -name "$notglob" -type f)
    resultcount=$("$findresult" | grep -c /)
    #echo -e "Found $($findresult | wc -l) files."
    echo -e "$findresult\n Found $resultcount files." 
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

collect_data_export
while [ "$isconfirmed" != "y" ]; 
    do
        find_configs
    done
import