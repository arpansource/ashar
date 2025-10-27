#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/var/lib/postgres/data"
PG_HBA="$DATA_DIR/pg_hba.conf"

# === 1. Ask for installation ===
read -rp "Do you want to setup PostgreSQL on this machine? (y/N): " INSTALL_PSQL </dev/tty
if [[ ! "$INSTALL_PSQL" =~ ^[Yy]$ ]]; then
    echo "Aborting PostgreSQL setup."
    exit 0
fi

# === 2. Install PostgreSQL ===
echo "→ Installing PostgreSQL..."
paru -S postgresql --needed --noconfirm


# === 3. Handle data directory initialization ===
if sudo -u postgres test -d "$DATA_DIR"; then
    echo "⚠️  Data directory already exists at: $DATA_DIR"
    read -rp "Do you want to reinitialize it (this will DELETE existing data)? (y/N): " REINIT </dev/tty
    if [[ "$REINIT" =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing old data directory..."
        sudo rm -rf "$DATA_DIR"
        echo "→ Initializing a new PostgreSQL data directory..."
        sudo -iu postgres initdb --locale=en_US.UTF-8 -D "$DATA_DIR"
    else
        echo "⏩ Skipping initialization (keeping existing data)."
    fi
else
    echo "→ Initializing PostgreSQL data directory..."
    sudo -iu postgres initdb --locale=en_US.UTF-8 -D "$DATA_DIR"
fi

# === 4. Start and enable service ===
echo "→ Enabling and starting PostgreSQL service..."
sudo systemctl enable postgresql --now

# === 5. Set password for postgres user (always re-prompts safely) ===
echo "→ Setting password for default 'postgres' user..."
read -rsp "Enter new password for postgres user: " POSTGRES_PWD </dev/tty
echo
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PWD}';"

# === 6. Optionally create another DB user ===
read -rp "Do you want to create another database user? (y/N): " CREATE_USER </dev/tty
if [[ "$CREATE_USER" =~ ^[Yy]$ ]]; then
    read -rp "Enter new database username: " DB_USER </dev/tty
    read -rsp "Enter password for ${DB_USER}: " DB_PASS </dev/tty
    echo
    EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}';" || true)
    if [[ "$EXISTS" == "1" ]]; then
        echo "⚠️  User '${DB_USER}' already exists. Skipping."
    else
        sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';"
        echo "✅ User '${DB_USER}' created."
    fi
fi

# === 7. Configure authentication method ===
if [[ ! -f "$PG_HBA" ]]; then
    echo "❌ Could not find pg_hba.conf at $PG_HBA"
    exit 1
fi

echo "🎨 Select an authentication method for PostgreSQL:"
AUTH_METHOD=$(printf "md5\nscram-sha-256\n" | fzf --prompt="Choose authentication method: " --height=10 --border --ansi < /dev/tty > /dev/tty)

if [[ -z "$AUTH_METHOD" ]]; then
    AUTH_METHOD="md5"
    echo "No selection made. Defaulting to 'md5'."
fi

echo "→ Updating pg_hba.conf to use '$AUTH_METHOD'..."
sudo cp "$PG_HBA" "$PG_HBA.bak"

sudo awk -v method="$AUTH_METHOD" '
/^host/ { $NF = method }
{ print }
' "$PG_HBA.bak" | sudo tee "$PG_HBA" >/dev/null

echo "🔐 Authentication method set to '$AUTH_METHOD'."
sudo systemctl restart postgresql

echo
echo "✅ PostgreSQL setup complete!"
echo "You can now connect using:"
echo "  psql -U postgres -h localhost"
