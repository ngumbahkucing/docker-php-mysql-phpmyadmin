# Keep this file plain. Do not `chmod +x` to make it executable.

mysql_note() {
	mysql_log Note "$@"
}
docker_process_sql() {
	passfileArgs=()
	if [ '--dont-use-mysql-root-password' = "$1" ]; then
		passfileArgs+=( "$1" )
		shift
	fi
	# args sent in can override this db, since they will be later in the command
	if [ -n "$MYSQL_DATABASE" ]; then
		set -- --database="$MYSQL_DATABASE" "$@"
	fi

	mysql --defaults-extra-file=<( _mysql_passfile "${passfileArgs[@]}") --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" --comments "$@"
}
_mysql_passfile() {
	# echo the password to the "file" the client uses
	# the client command will use process substitution to create a file on the fly
	# ie: --defaults-extra-file=<( _mysql_passfile )
	if [ '--dont-use-mysql-root-password' != "$1" ] && [ -n "$MYSQL_ROOT_PASSWORD" ]; then
		cat <<-EOF
			[client]
			password="${MYSQL_ROOT_PASSWORD}"
		EOF
	fi
}
mysql_log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}

create_more_databases() {
    local databases=( $MORE_DATABASES )
    local db
    for db in "${databases[@]}"; do
        mysql_note "Creating database ${db}"
        docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$db\` ;"

        if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
            mysql_note "Giving user ${MYSQL_USER} access to schema ${db}"
            docker_process_sql --database=mysql <<<"GRANT ALL ON \`${db//_/\\_}\`.* TO '$MYSQL_USER'@'%' ;"
        
        fi
    done
}

if [ -n "$MORE_DATABASES" ]; then
    create_more_databases
fi