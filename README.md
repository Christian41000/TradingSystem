# Système de Trading/Broker Personnel

## Architecture

Ce projet implémente un système de trading personnel avec :
- **Backend C++** : Moteur de broker pour la gestion des ordres, positions et comptes
- **Interface SwiftUI** : Application macOS native pour l'interaction utilisateur

## Structure du Projet

```
TradingSystem/
├── Backend/                    # C++ Broker Engine
│   ├── Include/
│   │   ├── Order.hpp          # Définition des types d'ordres
│   │   ├── Position.hpp       # Gestion des positions
│   │   ├── Account.hpp        # Moteur de broker
│   │   └── trading_bridge.h   # Interface C pour Swift
│   ├── Sources/
│   │   ├── Account.cpp        # Implémentation du moteur
│   │   └── trading_bridge.cpp # Pont C++ vers C
│   └── CMakeLists.txt         # Configuration CMake
│
└── Frontend/
    └── TradingApp/            # Application SwiftUI
        ├── TradingAppApp.swift
        ├── ContentView.swift
        ├── TradingViewModel.swift
        ├── TradingBackend.swift
        └── Info.plist
```

## Fonctionnalités

### Backend C++
- ✅ Gestion de compte (cash, buying power, equity)
- ✅ Soumission d'ordres (Market, Limit)
- ✅ Annulation d'ordres
- ✅ Suivi des positions
- ✅ Calcul du P&L (réalisé et non réalisé)
- ✅ Simulation de prix de marché

### Interface SwiftUI
- ✅ Dashboard avec vue d'ensemble du compte
- ✅ Liste des ordres avec annulation
- ✅ Positions ouvertes avec P&L
- ✅ Formulaire de trading (Buy/Sell)
- ✅ Mise à jour automatique des prix

## Compilation sur macOS

### 1. Compiler le Backend C++

```bash
cd TradingSystem/Backend
mkdir build && cd build
cmake ..
make
```

La bibliothèque dynamique sera générée dans `build/lib/libTradingBackend.dylib`

### 2. Configurer le Projet Xcode

1. Ouvrez Xcode et créez un nouveau projet macOS App
2. Ajoutez les fichiers Swift depuis `Frontend/TradingApp/`
3. Ajoutez la bibliothèque C++ aux "Link Binary With Libraries"
4. Configurez les "Header Search Paths" pour inclure `Backend/Include`
5. Ajoutez `libTradingBackend.dylib` au "Runpath Search Paths"

### 3. Exécuter l'Application

Lancez l'application depuis Xcode ou après build :
```bash
open TradingApp.app
```

## Utilisation

1. **Dashboard** : Vue d'ensemble de votre équité totale, cash et portefeuille
2. **Orders** : Historique des ordres avec possibilité d'annuler
3. **Positions** : Positions ouvertes avec P&L en temps réel
4. **Trade** : 
   - Sélectionnez un symbole (ex: AAPL, GOOGL, MSFT)
   - Choisissez le type d'ordre (Market/Limit)
   - Entrez la quantité
   - Cliquez sur Buy ou Sell

## Extension

Pour connecter à un vrai broker :
1. Implémentez un client API dans `Account.cpp`
2. Remplacez la simulation de prix par des données réelles
3. Ajoutez l'authentification et la sécurité appropriées

## Technologies

- **C++17** : Backend haute performance
- **SwiftUI** : Interface moderne macOS
- **CMake** : Build system cross-platform
- **Interopérabilité C** : Communication Swift/C++

## Licence

Usage personnel uniquement. Pour usage commercial, implémentez les conformités réglementaires nécessaires.
