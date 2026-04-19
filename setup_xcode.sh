#!/bin/bash

echo "🔧 Configuration du projet Xcode..."

# Chemins absolus
PROJECT_DIR="$(pwd)/Frontend/TradingApp"
BACKEND_BUILD="$(pwd)/Backend/build"
HEADER_PATH="$(pwd)/Backend/Include"
LIB_PATH="$BACKEND_BUILD"

# Vérifier que la librairie existe
if [ ! -f "$LIB_PATH/libTradingBackend.dylib" ]; then
    echo "❌ Erreur: libTradingBackend.dylib non trouvée. Compilez d'abord le backend."
    exit 1
fi

echo "✅ Librairie trouvée: $LIB_PATH/libTradingBackend.dylib"
echo "✅ Headers: $HEADER_PATH"

# Créer un fichier de configuration pour Xcode
cat > "$PROJECT_DIR/BuildConfig.xcconfig" << XCCONFIG
HEADER_SEARCH_PATHS = $HEADER_PATH
LIBRARY_SEARCH_PATHS = $LIB_PATH
OTHER_LDFLAGS = -lTradingBackend
LD_RUNPATH_SEARCH_PATHS = @loader_path/../Frameworks $(inherited)
XCCONFIG

echo ""
echo "📋 Instructions manuelles pour Xcode:"
echo "======================================"
echo "1. Ouvrez Frontend/TradingApp/TradingApp.xcodeproj (ou créez un nouveau projet)"
echo "2. Dans Build Settings:"
echo "   - Header Search Paths: Ajoutez $(pwd)/Backend/Include"
echo "   - Library Search Paths: Ajoutez $(pwd)/Backend/build"
echo "   - Other Linker Flags: Ajoutez -lTradingBackend"
echo "3. Copiez libTradingBackend.dylib dans le bundle:"
echo "   - Product → Add Build Phase → New Copy Files Phase"
echo "   - Destination: Frameworks"
echo "   - Ajoutez libTradingBackend.dylib"
echo ""
echo "📄 Fichier de config créé: $PROJECT_DIR/BuildConfig.xcconfig"
echo "   (Vous pouvez l'importer dans votre projet .xcodeproj)"
