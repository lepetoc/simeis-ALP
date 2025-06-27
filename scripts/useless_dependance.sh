#!/bin/bash
set -euo pipefail

echo "🔎 Détection heuristique des dépendances inutilisées dans Cargo.toml..."

CARGO_TOML="Cargo.toml"
SRC_DIR="src"

# Extraire les dépendances simples (hors features, target, dev-dependencies, etc.)
mapfile -t deps < <(grep -E '^[a-zA-Z0-9_-]+\s*=' "$CARGO_TOML" | grep -vE 'features|workspace|target|patch|replace|profile' | cut -d'=' -f1 | tr -d ' ')

unused=()

for dep in "${deps[@]}"; do
  # Recherche dans tous les fichiers sources si le nom du crate est utilisé
  # On cherche : use <dep>::, extern crate <dep>, <dep>::, ou <dep>:
  if ! grep -R -E "use\s+${dep}::|extern\s+crate\s+${dep}|${dep}::|${dep}:" "$SRC_DIR" &>/dev/null; then
    unused+=("$dep")
  fi
done

if [ ${#unused[@]} -eq 0 ]; then
  echo "✅ Toutes les dépendances semblent utilisées."
else
  echo "⚠️ Dépendances potentiellement inutilisées :"
  for dep in "${unused[@]}"; do
    echo "  - $dep"
  done
  exit 1  # Échoue pour forcer la correction
fi
