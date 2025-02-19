# 📱 DataCollectorApp 📊

*Un outil de collecte et de traitement des données de capteurs en temps réel* ✨

DataCollectorApp est une application iOS qui collecte en temps réel les données des capteurs de votre téléphone et les envoie à un serveur Python. C'est comme avoir un petit laboratoire scientifique dans votre poche! 🔬🚀

---

## 📋 Table des Matières

- [✨ Fonctionnalités](#-fonctionnalités)
- [🏗️ Architecture du Projet](#️-architecture-du-projet)
- [📁 Structure des Fichiers](#-structure-des-fichiers)
- [⚙️ Installation et Configuration](#️-installation-et-configuration)
- [🚀 Utilisation](#-utilisation)
- [📝 Exemples de Logs](#-exemples-de-logs)
- [🔧 Dépannage](#-dépannage)
- [📜 Licence](#-licence)

---

## ✨ Fonctionnalités

- **📡 Collecte en temps réel** des données de capteurs:
  - **🌍 Localisation**: latitude, longitude, altitude, vitesse
  - **⚡ Mouvement**: mesures de l'accéléromètre
  - **🌡️ Capteurs additionnels**: température et humidité
  - **📶 Réseau**: type de connexion (Wi-Fi, 4G, 5G)
  - **🔋 Batterie**: niveau et état de charge
  - **🏃 Activité**: détection (marcher, courir, conduire)
- **💾 Enregistrement local** et export CSV/JSON
- **☁️ Envoi des données** vers serveur Python
- **🖥️ Serveur Python** avec Flask pour traitement et analyse

---

## 🏗️ Architecture du Projet

Le projet se divise en deux parties principales:

### 1. **📱 Application iOS (DataCollectorApp)**
   - Swift et SwiftUI pour une interface moderne
   - Gestion intelligente des capteurs 📊
   - Communication HTTP en temps réel 🚀

### 2. **🖥️ Serveur Python**
   - API Flask pour recevoir et traiter les données
   - Chargement initial depuis CSV et ajout de nouvelles données
   - Endpoints pour statistiques et visualisations 📈

---

## 📁 Structure des Fichiers

```
DataCollectorApp/
├── 📱 iOS-App/
│   ├── ContentView.swift
│   ├── LocationManager.swift
│   ├── MotionManager.swift
│   ├── ConnectivityManager.swift
│   ├── SensorManager.swift
│   ├── BatteryManager.swift
│   ├── ActivityManager.swift
│   ├── DataLogger.swift
│   ├── SelectZoneView.swift
│   └── MapViewRepresentable.swift
├── 🖥️ server/
│   └── server.py
├── 🖼️ assets/
│   └── logo.png
├── 📊 sensor_data_*.csv
└── 📄 README.md
```

---

## ⚙️ Installation et Configuration

### 📱 Côté iOS

1. **🔧 Configuration Xcode:**
   - Ouvre le projet dans Xcode
   - Vérifie les permissions dans **Info.plist** 🔍
   - Configure l'URL du serveur dans `sendHTTP(...)` (ex: `http://192.168.0.34:5001/api/push_data`)

2. **📲 Installation:**
   - Compile et installe sur ton iPhone
   - Assure-toi que l'iPhone et le PC sont sur le même réseau Wi-Fi 📶

### 🖥️ Côté Serveur Python

1. **📋 Prérequis:**
   - Python 3 installé
   - Dépendances: 
     ```bash
     pip install flask flask-cors 🚀
     ```

2. **⚙️ Configuration:**
   - Place ton CSV dans le dossier configuré dans `server.py`
   - Modifie `CSV_FILE` si nécessaire

3. **🚀 Lancement du Serveur:**
   - Dans le terminal:
     ```bash
     python3 server.py
     ```
   - Serveur accessible sur port **5001** 🌐

---

## 🚀 Utilisation

### 1. **📱 Lancement de l'app iOS:**
   - Ouvre l'app sur ton iPhone
   - Autorise la localisation 🌍
   - Choisis une zone (optionnel) 🗺️
   - Appuie sur **"Start"** ▶️
   - Exporte les données en CSV/JSON si besoin 💾

### 2. **🖥️ Vérification côté serveur:**
   - Console serveur affiche:
     ```
     78789 points chargés depuis [...] 📊
     📡 Nouveau point ajouté: lat=48.8566, lon=2.3522, speed=1.23
     ```
   - Accède à `/get_all_points` dans ton navigateur 🌐

### 3. **📊 Analyse et Calculs:**
   - Utilise `/compute` et `/compute_multiple` pour des stats avancées 📈

---

## 📝 Exemples de Logs

### 🖥️ Serveur Python (console):

```
78789 points chargés depuis [...] 📊
Serving Flask app 'server'
Debug mode: on
192.168.0.33 - - [19/Feb/2025 22:30:34] "POST /api/push_data HTTP/1.1" 200 -
📡 Nouveau point ajouté: lat=48.8566, lon=2.3522, speed=1.23
```

### 📱 Application iOS (console Xcode):

```
Collecte: lat=48.8566, lon=2.3522, alt=35.0, speed=1.23 📍
JSON envoyé: {"timestamp":"2025-02-19T21:47:38Z", "latitude":48.8566, ...} 📤
HTTP Status: 200 ✅
Réponse du serveur: {"status": "Point added", "count": 78790} 📥
```

---

## 🔧 Dépannage

- **❌ Erreur HTTP 403/404:**  
  Vérifie l'URL dans iOS et l'accessibilité du serveur sur le réseau local

- **⚠️ Données nulles (0.0):**  
  Ajoute des logs dans `collectData()` pour vérifier avant l'envoi

- **📶 Problèmes de réseau:**  
  Assure-toi que iPhone et PC sont sur le même réseau et que le port 5001 est ouvert

- **🔍 Logs de Flask:**  
  Consulte la console serveur pour les messages d'erreur ou de succès

---
