#!/bin/bash -
CELLBLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$CELLBLOCK_DIR/../bash/forest.functions.sh"

# Load gradle.properties into associative array
declare -A properties
forest_load_properties properties "$CELLBLOCK_DIR/gradle.properties"

ROOT_SECRET="$CELLBLOCK_DIR/${properties[cellblock.root.secret]}"
USER_SECRET="$CELLBLOCK_DIR/${properties[cellblock.user.secret]}"

# Verify that the secret files exist
check_secret_file "$ROOT_SECRET"
check_secret_file "$USER_SECRET"
verify_storage_directory "${properties[cellblock.storage]}"

forest_network_name=$(forest_resolve_network_name "$CELLBLOCK_DIR/../gradle.properties")

log_lgreen "Running ${properties[cellblock.image.name]}:${properties[cellblock.image.version]} image"
# Run the docker container for CellBlock
docker run -v "${properties[cellblock.storage]}":/var/lib/mysql  \
        -p "${properties[cellblock.port]}":3306 \
        --mount type=bind,src=${ROOT_SECRET},target=/run/secrets/mariadb_root,readonly \
        --mount type=bind,src=${USER_SECRET},target=/run/secrets/mariadb_admin,readonly \
        -d \
        -e MARIADB_PASSWORD_FILE=/run/secrets/mariadb_admin \
        -e MARIADB_ROOT_PASSWORD_FILE=/run/secrets/mariadb_root \
        -e MARIADB_USER="cellblock" \
        -e MARIADB_DATABASE="cellblock" \
        --name "cellblock-moon" \
        --network ${forest_network_name} \
        "${properties[cellblock.image.name]}":"${properties[cellblock.image.version]}"

log_green "Started"
log_nc ""