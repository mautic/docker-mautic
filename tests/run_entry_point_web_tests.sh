#!/bin/bash

SUT=./common/entrypoint_mautic_web.sh

testThatMissingConfigVolumeFails() {
    local command="$SUT"

    assertEquals "Entrypoint should fail with expected exit code" "1" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: volume /var/www/html/config does not exist or is not a directory." "$(eval $command)"
}

testThatMissingLogsVolumeFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local command="MAUTIC_VOLUME_CONFIG=$volume_config $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "1" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: volume /var/www/html/var/logs does not exist or is not a directory." "$(eval $command)"
}

testThatMissingMediaVolumeFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local command="MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "1" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: volume /var/www/html/docroot/media does not exist or is not a directory." "$(eval $command)"
}

testThatMissingPermissionsFail() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local volume_media="$root_dir/var/www/html/docroot/media"
    mkdir -p $volume_media

    local command="MAUTIC_WWW_USER=nobody MAUTIC_WWW_GROUP=nogroup MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs MAUTIC_VOLUME_MEDIA=$volume_media $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "2" "$(eval $command > /dev/null; echo $?)"
}

testThatMissingMauticDbHostFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local volume_media="$root_dir/var/www/html/docroot/media"
    mkdir -p $volume_media

    local command="MAUTIC_WWW_USER=$(id -u) MAUTIC_WWW_GROUP=$(id -g) MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs MAUTIC_VOLUME_MEDIA=$volume_media $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "3" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: MAUTIC_DB_HOST is not set." "$(eval $command)"
}

testThatMissingMauticDbPortFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local volume_media="$root_dir/var/www/html/docroot/media"
    mkdir -p $volume_media

    local command="MAUTIC_WWW_USER=$(id -u) MAUTIC_WWW_GROUP=$(id -g) MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs MAUTIC_VOLUME_MEDIA=$volume_media MAUTIC_DB_HOST=localhost $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "3" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: MAUTIC_DB_PORT is not set." "$(eval $command)"
}

testThatMissingMauticDbUserFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local volume_media="$root_dir/var/www/html/docroot/media"
    mkdir -p $volume_media

    local command="MAUTIC_WWW_USER=$(id -u) MAUTIC_WWW_GROUP=$(id -g) MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs MAUTIC_VOLUME_MEDIA=$volume_media MAUTIC_DB_HOST=localhost MAUTIC_DB_PORT=4711 $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "3" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: MAUTIC_DB_USER is not set." "$(eval $command)"
}

testThatMissingMauticDbPasswordFails() {
    local root_dir=$(mktemp -d)
    mkdir -p $root_dir

    local volume_config="$root_dir/var/www/html/config"
    mkdir -p $volume_config

    local volume_logs="$root_dir/var/www/html/var/logs"
    mkdir -p $volume_logs

    local volume_media="$root_dir/var/www/html/docroot/media"
    mkdir -p $volume_media

    local command="MAUTIC_WWW_USER=$(id -u) MAUTIC_WWW_GROUP=$(id -g) MAUTIC_VOLUME_CONFIG=$volume_config  MAUTIC_VOLUME_LOGS=$volume_logs MAUTIC_VOLUME_MEDIA=$volume_media MAUTIC_DB_HOST=localhost MAUTIC_DB_PORT=4711 MAUTIC_DB_USER=root $SUT"
    
    assertEquals "Entrypoint should fail with expected exit code" "3" "$(eval $command > /dev/null; echo $?)"
    assertEquals "Entrypoint should fail with error message" "error: MAUTIC_DB_PASSWORD is not set." "$(eval $command)"
}

# Load shUnit2 and run tests
. ./tests/shunit2