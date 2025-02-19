# 📱 DataCollectorApp 📊


**DataCollectorApp** est une application iOS dédiée à la collecte en temps réel des données de capteurs du téléphone, afin d'effectuer le suivi de trajectoire et d'analyser le flux de circulation sur une rue. L'application permet de sélectionner des points (ex. A, B, C, …) sur un parcours pour définir des segments et calculer la vitesse moyenne ainsi que le flux de circulation sur ces segments.

## 📋 Table des Matières

- [✨ Fonctionnalités](#-fonctionnalités)
- [🎯 But du Projet](#-but-du-projet)
- [🏗️ Architecture du Projet](#️-architecture-du-projet)
- [📁 Structure des Fichiers](#-structure-des-fichiers)
- [⚙️ Installation et Configuration](#️-installation-et-configuration)
  - [📱 Côté iOS](#-côté-ios)
  - [🖥️ Côté Serveur Python](#️-côté-serveur-python)
- [🚀 Utilisation](#-utilisation)
- [📝 Exemples de Logs](#-exemples-de-logs)
- [🔧 Dépannage](#-dépannage)
- [📜 Licence](#-licence)

## ✨ Fonctionnalités

- **📡 Collecte en temps réel** des données issues des capteurs du téléphone :
  - 🌍 Localisation (latitude, longitude, altitude, vitesse)
  - ⚡ Accélération (accéléromètre)
  - 🌡️ Capteurs additionnels (température, humidité, etc.)
  - 📶 Informations réseau (type, opérateur)
  - 🔋 État de la batterie
  - 🏃 Activité (marche, course, conduite, etc.)
- **💾 Enregistrement local** et export des données au format CSV et JSON.
- **☁️ Envoi des données** vers un serveur Python via HTTP POST.
- **📊 Analyse et calculs** :  
  - Suivi de la trajectoire.
  - Sélection de points (ex. A, B, C, ...) pour définir des segments.
  - Calcul de la vitesse moyenne et du flux de circulation sur un segment (par exemple, entre A et B).

## 🎯 But du Projet

Le but de **DataCollectorApp** est double :
1. **🛣️ Suivi de trajectoire** : Collecter les données de localisation en temps réel pour suivre le parcours d'un véhicule ou d'un utilisateur.
2. **🚦 Analyse du flux de circulation** : En permettant de sélectionner des points clés (par exemple, A et B sur une rue), l'application permet de calculer le nombre de points (correspondant au trafic ou flux) et la vitesse moyenne sur ce segment. Ces mesures peuvent servir pour comparer le trafic entre différentes rues ou analyser la fluidité du trafic.

## 🏗️ Architecture du Projet

Le projet est composé de deux parties principales :

1. **📱 Application iOS (DataCollectorApp)**
   - Réalisée en Swift et SwiftUI.
   - Gère la collecte des données via plusieurs managers (LocationManager, MotionManager, etc.).
   - Envoie les données en temps réel via des requêtes HTTP au serveur Python.
   - Permet d'exporter les données en CSV/JSON et de sélectionner une zone sur la carte.

2. **🖥️ Serveur Python**
   - Construit avec Flask et Flask-CORS.
   - Charge initialement un fichier CSV de données.
   - Reçoit les nouvelles données envoyées en temps réel par l'application iOS via la route `/api/push_data`.
   - Expose des routes pour renvoyer les données, calculer des statistiques (vitesse moyenne, nombre de points sur un segment, etc.), et pour servir une page HTML.

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
│   └── logo.png  # Votre logo ou icône de l'application
├── 📊 sensor_data_*.csv  # Fichier(s) CSV contenant des données initiales
└── 📄 README.md  # Ce fichier
```

## ⚙️ Installation et Configuration

### 📱 Côté iOS

1. **🔧 Configuration du Projet Xcode :**
   - Ouvrez le projet dans Xcode.
   - Vérifiez que le fichier **Info.plist** contient bien toutes les clés requises pour la localisation, le mouvement, etc.
   - Dans le code, la fonction `sendHTTP(...)` envoie les données au serveur. Assurez-vous que l'URL utilisée pointe vers l'IP locale de votre PC (ex. `http://192.168.0.34:5001/api/push_data`).

2. **📲 Compilation et Installation :**
   - Compilez et installez l'application sur votre iPhone.
   - Assurez-vous que l'iPhone et le PC sont sur le même réseau local.

### 🖥️ Côté Serveur Python

1. **📋 Prérequis :**
   - Installez Python 3.
   - Installez les dépendances nécessaires via pip :
     ```bash
     pip install flask flask-cors
     ```

2. **⚙️ Configuration :**
   - Placez le fichier CSV (ex. `sensor_data_1739009536.298178.csv`) dans le dossier spécifié dans la variable `CSV_FILE` dans `server.py`.
   - Modifiez le chemin CSV si nécessaire.

3. **🚀 Lancement du Serveur :**
   - Dans le dossier contenant `server.py`, lancez :
     ```bash
     python3 server.py
     ```
   - Le serveur sera accessible sur le port 5001 et écoutera sur toutes les interfaces.

## 🚀 Utilisation

### 📱 Application iOS :
  - Lancez l'application sur votre iPhone.
  - Appuyez sur **"Autoriser la localisation"** pour activer le service de localisation.
  - Utilisez **"Choisir la zone"** pour définir une zone spécifique (optionnel).
  - Appuyez sur **"Start"** ▶️ pour démarrer la collecte des données. L'application envoie ensuite les données en temps réel au serveur via HTTP.
  - Vous pouvez exporter les données collectées en CSV ou JSON 💾.

### 🖥️ Serveur Python :
  - Le serveur reçoit les données via la route `/api/push_data` et les stocke dans `all_points`.
  - Vous pouvez consulter les données actuelles en accédant à la route `/get_all_points` depuis un navigateur 🌐.
  - Les routes `/compute` et `/compute_multiple` permettent de calculer des statistiques (par exemple, la vitesse moyenne sur un segment défini entre des points sélectionnés) 📊.

## 📝 Exemples de Logs

### 🖥️ Serveur Python (console) :

```
78789 points chargés depuis /Users/mohammedtbahriti/Documents/suivi_trajectoire_voie/sensor_data_1739009536.298178.csv

Serving Flask app 'server'
Debug mode: on
192.168.0.33 - - [19/Feb/2025 22:30:34] "POST /api/push_data HTTP/1.1" 200 -
📡 Nouveau point ajouté: lat=48.8566, lon=2.3522, speed=1.23
192.168.0.33 - - [19/Feb/2025 22:30:35] "POST /api/push_data HTTP/1.1" 200 -
```

### 📱 Application iOS (console Xcode) :

```
Collecte: lat=48.8566, lon=2.3522, alt=35.0, speed=1.23 📍
JSON envoyé: {"timestamp":"2025-02-19T21:47:38Z", "latitude":48.8566, "longitude":2.3522, "altitude":35.0, "speed":1.23, ...} 📤
HTTP Status: 200 ✅
Réponse du serveur: {"status": "Point added", "count": 78790} 📥
```

## 🔧 Dépannage

- **❌ Erreur HTTP 403/404 :**  
  Vérifiez l'URL dans la fonction `sendHTTP(...)` et assurez-vous que le serveur est accessible depuis votre réseau local.

- **⚠️ Données nulles (0.0) reçues :**  
  Ajoutez des logs dans `collectData()` pour vérifier que les valeurs collectées sont correctes avant l'envoi.

- **📶 Problèmes de connexion réseau :**  
  Assurez-vous que l'iPhone et le PC sont sur le même réseau et que le port (5001) est ouvert dans le pare-feu.

- **🔍 Logs de Flask :**  
  Consultez la console du serveur pour voir les messages d'erreur ou de succès lors de la réception des données.
