#!/bin/bash
echo "🚀 Build Trading System..."
echo "Nettoyage des anciens fichiers..."
rm -f Frontend/TradingApp/TradingBackend.swift \
      Frontend/TradingApp/TradingViewModel.swift \
      Frontend/TradingApp/ContentView.swift \
      Frontend/TradingApp/TradingAppApp.swift

echo "Compilation SwiftUI..."
swiftc -o TradingApp \
  -framework SwiftUI \
  -framework Foundation \
  Frontend/TradingApp/main.swift 2>&1 | grep -v "warning:"

if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie ! Lancement..."
    ./TradingApp
else
    echo "❌ Erreur de compilation"
    exit 1
fi
