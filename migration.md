# WooCommerce Store Migration Guide

## Overview

This guide outlines the necessary steps to migrate from one WooCommerce store to another. You will need to use WP-CLI, a command line tool for WordPress, to backup, export, import, and replace URLs in your database. 

## Prerequisites

- Make sure you have installed and properly configured [WP-CLI](https://wp-cli.org/#installing) on your system.
- Both the source and destination WooCommerce stores should be fully functional.
- Access to the server hosting your WooCommerce site, preferably with SSH.

## Step-by-Step Migration Process

### Step 1: Backup Your WooCommerce Store

Before making any changes, it's crucial to have a backup of your WooCommerce store.

```bash
wp db export --allow-root
```

### Step 2: Export Your WooCommerce Data
Now, export your WooCommerce data using the export command.

```bash
wp db export woocommerce-data.sql --allow-root
```
### Step 3: Import Your WooCommerce Data to the New Store
Once you've exported your data, you can import it into your new WooCommerce store.

```bash
wp db import woocommerce-data.sql --allow-root
```
### Step 4: Search and Replace URLs
Now you will need to replace all instances of your old URL with your new URL.

```bash
wp search-replace 'old url' 'new url' --allow-root --all-tables
```
### Step 5: Deactivate Problematic Plugins
If certain plugins are causing warnings or errors, you can deactivate them.

```bash
wp plugin deactivate woocommerce-shipping-tracking --allow-root
```
### Step 6: Switch to the Old Theme
Before switching to the new theme, you may want to activate the old theme first.

```bash
wp theme activate old-theme --allow-root
```

### Step 7: Switch to the New Theme
Finally, switch to your new theme.

```bash
wp theme activate new-theme --allow-root
```

### Step 8: Increase Upload File Size Limit
Before installing the Neve theme, you might need to increase the maximum upload file size limit in your PHP configuration.

```bash
cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /usr/local/etc/php/php.ini
```
### Step 9: Download and Install Neve Pro Addon
You can only download the Neve Pro Addon from the official site. Once you've downloaded it, you can activate it on your site. To do this, you'll need your ThemeIsle store credentials.

Please visit [Neve Downloads](https://store.themeisle.com/downloads/neve) and use your credentials to download the Neve Pro Addon.

### Step 10: Export Specific Pages
Pages can be exported using the wp post command and the page-id in the body class. The page-id corresponds to the post id.

```bash
wp post list --field=ID --allow-root
```
wp export --dir=/path/to/export/directory --post__in=page_id_1,page_id_2,page_id_3 --allow-root
Replace page_id_1,page_id_2,page_id_3 with the IDs of the pages you want to export and /path/to/export/directory with the path where you want the export files to be saved.

### Step 11: Import Customizer Settings
You can migrate theme customizer settings using the wp theme_mods_[theme] option where [theme] should be replaced with your theme's text domain.

```bash
wp option get theme_mods_oldtheme --format=json --allow-root > theme_mods_oldtheme.json
wp option set theme_mods_newtheme --format=json --allow-root < theme_mods_newtheme.json
```
Replace oldtheme with your old theme's text domain and newtheme with your new theme's text domain.

Please note, this will only migrate base theme settings. If you have settings stored in other tables, you'll need to migrate those separately. For example, many themes store widgets in the wp_options table under widget_widgetname. Similarly, menu locations are stored in the wp_options table under theme_mods_{theme}. Depending on your theme and configuration, you may also need to migrate data from other tables.