Drupal Partial Config Export helper
===================================

(WIP, do not use yet)

This is a simple shell script to help with partial configuration exports when your environments differ significantly. For example, you develop a Drupal feature locally and only wnat to import the config for that feature on your server, not your entire config. As long as your .yml config files are named appropriately, this script will help you locate the files and drop them into your repository so you can push them up to the server and import:

1. Develop local feature, for example a new bundle/content type named "Landing page"
2. Run dpce.sh from within your Drupal docroot. It will help you locate and move the appropriate config files to a git-tracked directory. 
3. Commit and push your changes to server.
4. SSH to your server repo, and run `drush cim --partial --source="/path/to/your/source/dir"` to review and import config changes.
5. Profit.


# Requirements
- Drupal 8
- Drush version > 8.1.12

# Note to git bash users on Windows:
You *must* install mysql and have the command globally available from your bash terminal, or else Drush will not work properly. Git Bash does not ship with mysql by default. 