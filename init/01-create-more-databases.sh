# Keep this file plain. Do not `chmod +x` to make it executable.

create_more_databases() {
    local databases=( $MORE_DATABASES )
    local db
    for db in "${databases[@]}"; do
        #mysql_note "Creating database ${db}"
        docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$db\` ;"

        if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
            #mysql_note "Giving user ${MYSQL_USER} access to schema ${db}"
            docker_process_sql --database=mysql <<<"GRANT ALL ON \`${db//_/\\_}\`.* TO '$MYSQL_USER'@'%' ;"
        
        fi
    done
}

if [ -n "$MORE_DATABASES" ]; then
    create_more_databases
fi