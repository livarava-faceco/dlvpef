#!/bin/sh

#                                                                             #
# CREATE A CONFIG FILE FOR THE LOCAL LAUNCH AND/OR TO RUN ON PRODUCTION.      #
#                                                                             #
# Run as:                                                                     #
#     On develop server: ./createconfigs.csh --develop                        #
#     On production server: ./createconfigs.csh --production                  #
#                                                                             #

# Determine the root directory of the project.
# *** Root directory - the directory that contains: `src`, `venv`, `world` etc,
#     a 100% `src/manage.py` file exists.
BASE_DIR_FILE_MARKER="src/manage.py"
ABSOLUTE_FILENAME=`readlink -e "$0"`
BASE_DIR=`dirname "$ABSOLUTE_FILENAME"`
while [ true ]
do
    if [ -e $BASE_DIR/$BASE_DIR_FILE_MARKER ]; then
        # Directory exist.
        break
    fi # ...

    BASE_DIR=`dirname "$BASE_DIR"`
    if [ $BASE_DIR = "/" ]; then
        # The directory was not found - use the current directory.
        BASE_DIR=`dirname "$ABSOLUTE_FILENAME"`
    fi # ...
done # end while ().

# Load settings.
LOCAL_SETTINGS="$BASE_DIR/world/etc/local_settings.sh"

# Import config file.
settings_is_loaded="false"
if [ -e $LOCAL_SETTINGS ]; then
    . $LOCAL_SETTINGS
    if [ $LOCAL_PORT = "0000" -o $SERVER_PORT = "0000" ]; then
        settings_is_loaded="error"
    else
        settings_is_loaded="true"
    fi
fi # end if ($LOCAL_SETTINGS).

# Information about import the configuration file.
if [ $settings_is_loaded = "false" ]; then
    # File does not exist!
    echo ""
    echo "Warning!"
    echo "You do not create a configuration file!"
    echo ""
    echo "Please, copy the template for configurations in \`etc\`" \
        "directory and adjust the settings: "
    echo "    cp $BASE_DIR/world/usr/options/local_settings.sh.ex" \
        "$LOCAL_SETTINGS"
    echo ""

    exit 1
elif [ $settings_is_loaded = "error" ]; then
    # The file is not configured!
    echo ""
    echo "Warning!"
    echo "You are not setting the configuration file!"
    echo ""
    echo "Please, open the configuration file and adjust the settings!"
    echo "    vim $LOCAL_SETTINGS"
    echo ""

    exit 2
else
    # All ok.
    echo "Settings successfully loaded..."
fi # end if ().

# Determine the type of settings (server/local).
is_server="true"
show_help="false"
if [ ! $# ]; then
    show_help="true"
else
    if [ "$1" = "-h" ]; then
        show_help="true"
    else
        if [ "$1" = "--develop" ]; then
            is_server="false"
        elif [ "$1" = "--production" ]; then
            is_server="true"
        else
            show_help="true"
        fi # end if (cmd).
    fi # end if (-help)
fi # end if (no args).

# Show help.
if [ "$show_help" = "true" ]; then
    echo ""
    echo "HELP"
    echo " ** Adjust the configuration file: ${LOCAL_SETTINGS}"
    echo ""
    echo "Run script with parameters:"
    echo "    --develop - if the project is running locally for development."
    echo "    --production - if the project is running on the server."
    echo ""

    exit 0
fi # end if (help).

if [ "$is_server" = "true" ]; then
    SOCKET=$SERVER_SOCKET
    PORT=$SERVER_PORT
    USER=$SERVER_USER
    HOST=$SERVER_HOST
    NGINX_UPSTREAM_NAME=$SERVER_NGINX_UPSTREAM_NAME
else
    SOCKET=$LOCAL_SOCKET
    PORT=$LOCAL_PORT
    USER=$LOCAL_USER
    HOST=$LOCAL_HOST
    NGINX_UPSTREAM_NAME=$LOCAL_NGINX_UPSTREAM_NAME
fi # end if (server).

echo ""
echo "The server will be configured with the following parameters:"
echo "    PROJECT NAME: $PROJECT_NAME"
echo "    SOCKET: $SOCKET"
echo "    PORT: $PORT"
echo "    USER: $USER"
echo "    HOST: $HOST"
echo "    BASE_DIR: $BASE_DIR"
echo "    NGINX UPSTREAM NAME: $NGINX_UPSTREAM_NAME"
echo ""

# ---------------------- CREATE CONFIGURATIONS FILES ------------------------ #

# NGINX.CONF
filename="$BASE_DIR/world/etc/nginx.conf"
rm -f $filename

cat "$BASE_DIR/world/usr/samples/nginx.conf.ex" |                           \
awk -v port="${PORT}" -v domain="${HOST}" -v base_dir="${BASE_DIR}"         \
    -v socket="${SOCKET}" -v nginx_upstream_name="${NGINX_UPSTREAM_NAME}"   \
'{                                                                          \
    gsub("<PORT>", port, $0);                                               \
    gsub("<HOST>", domain, $0);                                             \
    gsub("<BASE_DIR>", base_dir, $0);                                       \
    gsub("<SOCKET>", socket, $0);                                           \
    gsub("<NGINX_UPSTREAM_NAME>", nginx_upstream_name, $0);                 \
    print $0;                                                               \
}' >> $filename

echo "***"
echo "Create a link to the Nginx configurations:"
echo "sudo ln -s $filename /etc/nginx/conf.d/$PROJECT_NAME.conf"
echo "sudo nginx -s reload"
echo ""


# SUPERVISOR.CONF
filename="$BASE_DIR/world/etc/supervisor.conf"
rm -f $filename

cat "$BASE_DIR/world/usr/samples/supervisor.conf.ex" |                      \
awk -v user="${USER}" -v project_name="${PROJECT_NAME}"                     \
    -v base_dir="${BASE_DIR}"                                               \
'{                                                                          \
    gsub("<USER>", user, $0);                                               \
    gsub("<PROJECT_NAME>", project_name, $0);                               \
    gsub("<BASE_DIR>", base_dir, $0);                                       \
    print $0;                                                               \
}' >> $filename

echo "***"
echo "Create a link to the Supervisor configurations:"
echo "sudo ln -s $filename /etc/supervisor/conf.d/$PROJECT_NAME.conf"
echo "sudo supervisorctl update"
echo ""


# RUNSERVER.SH
goaldir="$BASE_DIR/world/etc/init.d"
mkdir -p $goaldir

filename="$goaldir/runserver.sh"
rm -f $filename

cat "$BASE_DIR/world/usr/samples/runserver.sh.ex" |                         \
awk -v port="${PORT}" -v socket="${SOCKET}"                                 \
'{                                                                          \
    gsub("<PORT>", port, $0);                                               \
    gsub("<SOCKET>", socket, $0);                                           \
    print $0;                                                               \
}' >> $filename
chmod a+x $filename

exit 0
