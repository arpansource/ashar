#!/bin/bash
set -euo pipefail


# === 1. Ask for installation ===
read -rp "Do you want to setup postgresql on this machine? (y/N): " INSTALL_POSTGRES </dev/tty
if [[ ! "$INSTALL_POSTGRES" =~ ^[Yy]$ ]]; then
    echo "Aborting postgresql setup..."
    exit 0
fi

# Function to check if PostgreSQL is installed
check_postgresql_installed() {
    if pacman -Q postgresql >/dev/null 2>&1; then
        echo "PostgreSQL is already installed."
        return 0
    else
        echo "PostgreSQL is not installed. Installing..."
        return 1
    fi
}

# Function to install PostgreSQL using paru
install_postgresql() {
    if ! command -v paru >/dev/null 2>&1; then
        echo "Paru is not installed. Please install paru first."
        exit 1
    fi
    paru -S --noconfirm postgresql
}

# Function to initialize PostgreSQL database (idempotent)
initialize_postgresql() {
    # Dynamically find the PostgreSQL data directory from the systemd service
    DATA_DIR=$(systemctl cat postgresql 2>/dev/null | awk -F'=' '/^Environment=PGDATA/ {print $2}' | head -1)

    # Fallback: If not found in service, search for an existing data directory or use default
    if [ -z "$DATA_DIR" ]; then
        # Try to find an existing data directory by looking for PG_VERSION in common locations
        POSSIBLE_DIRS=("/var/lib/postgres/data" "/var/lib/pgsql/data")
        for dir in "${POSSIBLE_DIRS[@]}"; do
            if sudo test -f "$dir/PG_VERSION"; then
                DATA_DIR="$dir"
                break
            fi
        done
        # If still not found, default to Arch's standard
        if [ -z "$DATA_DIR" ]; then
            DATA_DIR="/var/lib/postgres/data"
        fi
    fi

    # Check if already initialized (using sudo to handle read-protected directory)
    if sudo test -f "$DATA_DIR/PG_VERSION"; then
        echo "PostgreSQL database already initialized at $DATA_DIR."
        read -p "Do you want to re-initialize it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping initialization."
            return 0
        fi
        # Remove the existing data directory for re-initialization
        echo "Removing existing data directory..."
        sudo rm -rf "$DATA_DIR"
    fi

    # If directory exists but not initialized, remove it (no prompt, as per your request)
    if sudo test -d "$DATA_DIR"; then
        echo "Removing uninitialized data directory at $DATA_DIR..."
        sudo rm -rf "$DATA_DIR"
    fi

    echo "Initializing PostgreSQL database at $DATA_DIR..."
    sudo -u postgres initdb -D "$DATA_DIR"
}

# Function to start PostgreSQL service (idempotent)
start_postgresql() {
    if systemctl is-active --quiet postgresql; then
        echo "PostgreSQL service is already running."
        return 0
    fi
    echo "Starting PostgreSQL service..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
}

# Function to set postgres user password (runs every time; consider making it optional)
set_postgres_password() {
    echo "Enter the password for the PostgreSQL 'postgres' user:"
    read -s POSTGRES_PASSWORD
    echo "Setting password for postgres user..."
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRES_PASSWORD';" || {
        echo "Failed to set password. PostgreSQL may not be running or accessible."
        exit 1
    }
    echo "Password set successfully."
}

# Function to find and edit pg_hba.conf (idempotent)
edit_pg_hba_conf() {
    # Dynamically find the PostgreSQL data directory (same method as initialize_postgresql for consistency)
    DATA_DIR=$(systemctl cat postgresql 2>/dev/null | awk -F'=' '/^Environment=PGDATA/ {print $2}' | head -1)

    # Fallback: If not found in service, search for an existing data directory or use default
    if [ -z "$DATA_DIR" ]; then
        POSSIBLE_DIRS=("/var/lib/postgres/data" "/var/lib/pgsql/data")
        for dir in "${POSSIBLE_DIRS[@]}"; do
            if sudo test -f "$dir/PG_VERSION"; then
                DATA_DIR="$dir"
                break
            fi
        done
        if [ -z "$DATA_DIR" ]; then
            DATA_DIR="/var/lib/postgres/data"
        fi
    fi

    PG_HBA_CONF="$DATA_DIR/pg_hba.conf"

    # Check if the file exists (using sudo to handle read-protected files)
    if ! sudo test -f "$PG_HBA_CONF"; then
        echo "pg_hba.conf not found at $PG_HBA_CONF. Please check PostgreSQL installation."
        exit 1
    fi

    # Check if the change is already applied (idempotent; using sudo for protected files)
    if sudo grep -q "^local.*all.*all.*md5" "$PG_HBA_CONF"; then
        echo "pg_hba.conf already configured for md5 authentication."
        return 0
    fi

    echo "Editing $PG_HBA_CONF for password authentication..."

    # Backup the original file
    sudo cp "$PG_HBA_CONF" "$PG_HBA_CONF.bak"

    # Change local connections to use md5 (password authentication)
    # Note: This assumes a standard format; adjust the sed pattern if your file differs
    sudo sed -i 's/^local.*all.*all.*trust/local   all             all                                     md5/' "$PG_HBA_CONF"

    # Reload PostgreSQL to apply changes
    sudo systemctl reload postgresql
    echo "pg_hba.conf updated and PostgreSQL reloaded."
}

# Main script
echo "PostgreSQL Setup Script for Arch Linux"

# Check and install if necessary
if ! check_postgresql_installed; then
    install_postgresql
fi

# Initialize database
initialize_postgresql

# Start service
start_postgresql

# Set password
set_postgres_password

# Edit pg_hba.conf
edit_pg_hba_conf

echo "Setup complete. You should now be able to login to PostgreSQL using: psql -U postgres"
