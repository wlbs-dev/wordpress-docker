<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

$WORDPRESS_DB_HOST     = getenv('WORDPRESS_DB_HOST');
$WORDPRESS_DB_USER     = getenv('WORDPRESS_DB_USER');
$WORDPRESS_DB_PASSWORD = getenv('WORDPRESS_DB_PASSWORD');
$WORDPRESS_DB_NAME     = getenv('WORDPRESS_DB_NAME');
$URL              = getenv('URL');
$TABLE_PRE = getenv('TABLE_PREFIX');

// ** Database settings - You can get this info from your web host ** //
define( 'DB_NAME', $WORDPRESS_DB_NAME );

/** Database username */
define( 'DB_USER', $WORDPRESS_DB_USER );

/** Database password */
define( 'DB_PASSWORD', $WORDPRESS_DB_PASSWORD );

/** Database hostname */
define( 'DB_HOST', $WORDPRESS_DB_HOST . ':' . '3306' ); 

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',   'put your unique phrase here' );
define( 'LOGGED_IN_KEY',     'put your unique phrase here' );
define( 'NONCE_KEY',         'put your unique phrase here' );
define( 'AUTH_SALT',         'put your unique phrase here' );
define( 'SECURE_AUTH_SALT',  'put your unique phrase here' );
define( 'LOGGED_IN_SALT',    'put your unique phrase here' );
define( 'NONCE_SALT',        'put your unique phrase here' );
define( 'WP_CACHE_KEY_SALT', 'put your unique phrase here' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = $TABLE_PRE;


/* Add any custom values between this line and the "stop editing" line. */

define( 'WP_DEBUG', true );

// Enable Debug logging to the /wp-content/debug.log file
define('WP_DEBUG_LOG', true);

// Disable display of errors and warnings 
define('WP_DEBUG_DISPLAY', false);
@ini_set('display_errors',0);

// Use dev versions of core JS and CSS files (only needed if you are modifying these core files)
define('SCRIPT_DEBUG', true);

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

define( 'WP_HOME', $URL );
define( 'WP_SITEURL', $URL );

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', true );
}

/** Include WP debug helper */
if ( defined( 'WP_DEBUG' ) && WP_DEBUG && file_exists( ABSPATH . 'wp-debug.php' ) ) {
    include_once ABSPATH . 'wp-debug.php';
}
if ( ! function_exists( 'console_log' ) ) {
    function console_log() {
    }
}
// Fixes one FTP error
if ( ! defined( 'FS_METHOD' ) ) define( 'FS_METHOD', 'direct' );

/* That's all, stop editing! Happy publishing. */