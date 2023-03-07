GAMEVER=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)
RAM=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)
HOMEDIR=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)
BACKUP_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)
ARCHIVE_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)
LATEST_JAR=$(cat $HOMEDIR/jars/latest)



worldOptions() {
    echo $(ls $HOMEDIR/servers/$1/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)
}



worldExists() {
    if [[ -d "$HOMEDIR/servers/$1/$2" ]]; then
        echo "true"
    else
        echo "false"
    fi
}



activeWorld() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'level-name=' | cut -d '=' -f2)
}



serverPort() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'server-port=' | cut -d '=' -f2)
}



serverExists() {
    if [[ -d "$HOMEDIR/servers/$1" ]]; then
        echo true
    else
        echo false
    fi
}



serverRunning() {
    echo $(gorp -s $1 | jq .status[].running 2> /dev/null)
}