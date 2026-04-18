#!/bin/bash

# Script de build complet pour le Système de Trading
# Exécuter sur macOS avec Xcode installé

set -e

echo "🚀 Build du Système de Trading/Broker"
echo "======================================"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Build du backend C++
echo -e "${BLUE}[1/3] Compilation du backend C++...${NC}"
cd Backend
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
cd ../..

# Vérifier que la librairie a été créée
if [ ! -f "Backend/build/lib/libTradingBackend.so" ]; then
    echo -e "${YELLOW}⚠️  Note: Sur macOS, la librairie sera libTradingBackend.dylib${NC}"
fi

# 2. Instructions pour Xcode
echo -e "${GREEN}✅ Backend compilé avec succès!${NC}"
echo ""
echo -e "${BLUE}[2/3] Configuration du projet Xcode:${NC}"
echo ""
echo "   1. Ouvrez Xcode et créez un nouveau projet:"
echo "      - Template: macOS > App"
echo "      - Interface: SwiftUI"
echo "      - Language: Swift"
echo ""
echo "   2. Ajoutez les fichiers Swift au projet:"
echo "      - Frontend/TradingApp/TradingAppApp.swift"
echo "      - Frontend/TradingApp/ContentView.swift"
echo "      - Frontend/TradingApp/TradingViewModel.swift"
echo "      - Frontend/TradingApp/TradingBackend.swift"
echo ""
echo "   3. Configurez les paths de build:"
echo "      - Dans 'Build Settings' > 'Header Search Paths':"
echo "        \$(SRCROOT)/../Backend/Include"
echo ""
echo "   4. Liez la bibliothèque C++:"
echo "      - Dans 'Build Phases' > 'Link Binary With Libraries':"
echo "        Ajoutez libTradingBackend.dylib"
echo ""
echo "   5. Configurez le runpath:"
echo "      - Dans 'Build Settings' > 'Runpath Search Paths':"
echo "        @executable_path/../Frameworks"
echo "        \$(SRCROOT)/../Backend/build/lib"
echo ""

# 3. Alternative avec Swift Package Manager
echo -e "${BLUE}[3/3] Alternative: Swift Package Manager${NC}"
echo ""
echo "   Pour utiliser SPM à la place d'Xcode:"
echo "   cd /workspace/TradingSystem"
echo "   swift build"
echo "   swift run"
echo ""

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Build prêt! 🎉${NC}"
echo -e "${YELLOW}Note: Ce script génère la librairie C++.${NC}"
echo -e "${YELLOW}      L'interface SwiftUI nécessite Xcode sur macOS.${NC}"
echo -e "${GREEN}======================================${NC}"
