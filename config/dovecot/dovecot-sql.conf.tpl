#password_query = SELECT userid AS username, domain, password FROM users WHERE userid ='%n' AND domain ='%d'
#user_query = SELECT home, uid, gid FROM users WHERE userid = '%n' AND domain = '%d'

# This file is commonly accessed via passdb {} or userdb {} section in
# conf.d/auth-sql.conf.ext

# This file is opened as root, so it should be owned by root and mode 0600.
#
# http://wiki2.dovecot.org/AuthDatabase/SQL
#
# For the sql passdb module, you'll need a database with a table that
# contains fields for at least the username and password. If you want to
# use the user@domain syntax, you might want to have a separate domain
# field as well.
#
# If your users all have the same uig/gid, and have predictable home
# directories, you can use the static userdb module to generate the home
# dir based on the username and domain. In this case, you won't need fields
# for home, uid, or gid in the database.
#
# If you prefer to use the sql userdb module, you'll want to add fields
# for home, uid, and gid. Here is an example table:
#
# CREATE TABLE users (
#     username VARCHAR(128) NOT NULL,
#     domain VARCHAR(128) NOT NULL,
#     password VARCHAR(64) NOT NULL,
#     home VARCHAR(255) NOT NULL,
#     uid INTEGER NOT NULL,
#     gid INTEGER NOT NULL,
#     active CHAR(1) DEFAULT 'Y' NOT NULL
# );

# Database driver: mysql, pgsql, sqlite
driver = ${env:POSTFIXADMIN_DB_TYPE}

# Database connection string. This is driver-specific setting.
connect = ${env:SQLITE_DB}

# Default password scheme.
#
# List of supported schemes is in
# http://wiki2.dovecot.org/Authentication/PasswordSchemes
#
default_pass_scheme = MD5-CRYPT

# passdb query to retrieve the password. It can return fields:
#   password - The user's password. This field must be returned.
#   user - user@domain from the database. Needed with case-insensitive lookups.
#   username and domain - An alternative way to represent the "user" field.
#
# The "user" field is often necessary with case-insensitive lookups to avoid
# e.g. "name" and "nAme" logins creating two different mail directories. If
# your user and domain names are in separate fields, you can return "username"
# and "domain" fields instead of "user".
#
# The query can also return other fields which have a special meaning, see
# http://wiki2.dovecot.org/PasswordDatabase/ExtraFields
#
# Commonly used available substitutions (see http://wiki2.dovecot.org/Variables
# for full list):
#   %u = entire user@domain
#   %n = user part of user@domain
#   %d = domain part of user@domain
#
# Note that these can be used only as input to SQL query. If the query outputs
# any of these substitutions, they're not touched. Otherwise it would be
# difficult to have eg. usernames containing '%' characters.
#
# Example:
#   password_query = SELECT userid AS user, pw AS password \
#     FROM users WHERE userid = '%u' AND active = 'Y'
#
password_query = \
  SELECT username AS user, password \
  FROM mailbox WHERE username = '%u' AND active = '1'

# userdb query to retrieve the user information. It can return fields:
#   uid - System UID (overrides mail_uid setting)
#   gid - System GID (overrides mail_gid setting)
#   home - Home directory
#   mail - Mail location (overrides mail_location setting)
#
# None of these are strictly required. If you use a single UID and GID, and
# home or mail directory fits to a template string, you could use userdb static
# instead. For a list of all fields that can be returned, see
# http://wiki2.dovecot.org/UserDatabase/ExtraFields
#
# Examples:
#   user_query = SELECT home, uid, gid FROM users WHERE userid = '%u'
#   user_query = SELECT dir AS home, user AS uid, group AS gid FROM users where userid = '%u'
#   user_query = SELECT home, 501 AS uid, 501 AS gid FROM users WHERE userid = '%u'
#
user_query = \
  SELECT '/var/vmail/' || maildir AS home, 5000 AS uid, 5000 AS gid, '*:bytes=' || quota AS quota_rule \
  FROM mailbox WHERE username = '%u' AND active = '1'

# If you wish to avoid two SQL lookups (passdb + userdb), you can use
# userdb prefetch instead of userdb sql in dovecot.conf. In that case you'll
# also have to return userdb fields in password_query prefixed with "userdb_"
# string. For example:
#password_query = \
#  SELECT userid AS user, password, \
#    home AS userdb_home, uid AS userdb_uid, gid AS userdb_gid \
#  FROM users WHERE userid = '%u'

# Query to get a list of all usernames.
iterate_query = SELECT userid AS username, domain FROM users