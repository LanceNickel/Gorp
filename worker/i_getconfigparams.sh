GAMEVER=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)
RAM=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)
HOMEDIR=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)
BACKUP_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)
ARCHIVE_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)
LATEST_JAR=$(cat $HOMEDIR/jars/latest)

if [[ "$GAMEVER" == "" ]] || [[ "$RAM" == "" ]] || [[ "$HOMEDIR" == "" ]] || [[ "$BACKUP_DEST" == "" ]] || [[ "$ARCHIVE_DEST" == "" ]] || [[ "$LATEST_JAR" == "" ]]; then
    echo "One or more required options in gorp.conf not set. Exit (15)."
    exit 15
fi



worldOptions() {
    echo $(ls $HOMEDIR/servers/$1/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)
}

activeWorld() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'level-name=' | cut -d '=' -f2)
}

serverPort() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'server-port=' | cut -d '=' -f2)
}