<?php
define('WP_DEBUG_LOG', true);
define('FORCE_SSL_ADMIN', true);

if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
  $_SERVER['HTTPS']='on';


/* Production */
ini_set('display_errors', 0);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', false);
define('DISALLOW_FILE_MODS', true); // this disables all file modifications including updates and update notifications
