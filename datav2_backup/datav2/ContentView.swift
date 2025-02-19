import SwiftUI
import Combine
import MapKit

struct ContentView: View {
    
    // Managers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var networkManager = ConnectivityManager()
    @StateObject private var sensorManager = SensorManager()
    @StateObject private var batteryManager = BatteryManager()
    @StateObject private var activityManager = ActivityManager()

    // Data Logger
    private var dataLogger = DataLogger()
    
    // Pour gérer le timer
    @State private var collectionTimer: Timer?
    @State private var isCollecting = false

    @State private var minLat: Double = 48.8560
    @State private var maxLat: Double = 48.8570
    @State private var minLon: Double = 2.3500
    @State private var maxLon: Double = 2.3530

    @State private var showZoneSelector = false

    @State private var zonePassageCount = 0
    @State private var wasInZone = false

    // Région de la carte
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        VStack(spacing: 20) {
            Text("Data Collector")
                .font(.title)
            
            // Bouton d’autorisation Localisation
            Button(action: {
                locationManager.requestAuthorization()
            }) {
                Text("Autoriser la localisation")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Carte
            Map(coordinateRegion: $region, showsUserLocation: true)
                .frame(height: 250)
                .onReceive(locationManager.$currentLocation) { newLocation in
                    guard let loc = newLocation else { return }
                    region.center = loc.coordinate
                }
            
            // Bouton pour Choisir la zone
            Button("Choisir la zone") {
                showZoneSelector = true
            }
            .sheet(isPresented: $showZoneSelector) {
                SelectZoneView { minLat, maxLat, minLon, maxLon in
                    // Mettre à jour vos variables
                    self.minLat = minLat
                    self.maxLat = maxLat
                    self.minLon = minLon
                    self.maxLon = maxLon
                    // Fermer la vue modale
                    showZoneSelector = false
                }
            }

            Text("Location: \(locationText)")
            Text("Speed: \(String(format: "%.2f", locationManager.currentSpeed)) m/s")
            Text("Acceleration: x=\(motionManager.accelerationX, specifier: "%.2f"), y=\(motionManager.accelerationY, specifier: "%.2f"), z=\(motionManager.accelerationZ, specifier: "%.2f")")
            Text("Humidity: \(sensorManager.humidity ?? 0, specifier: "%.2f")%")
            Text("Temperature: \(sensorManager.temperature ?? 0, specifier: "%.2f")°C")
            Text("Network: \(networkInfo)")
            Text("Battery: \((batteryManager.batteryLevel * 100), specifier: "%.0f")% (\(batteryManager.batteryStateDescription))")
            Text("Activity: \(activityManager.currentActivity)")
            Text("Zone passages : \(zonePassageCount)")
            Text(wasInZone ? "Dans la zone" : "Hors de la zone")
                .foregroundColor(wasInZone ? .green : .gray)

            // Boutons Start/Stop + Export
            HStack {
                Button(action: {
                    if isCollecting {
                        stopCollecting()
                    } else {
                        startCollecting()
                    }
                }) {
                    Text(isCollecting ? "Stop" : "Start")
                        .padding()
                        .background(isCollecting ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button("Export CSV") {
                    exportCSV()
                }
                
                Button("Export JSON") {
                    exportJSON()
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private var locationText: String {
        if let loc = locationManager.currentLocation {
            return String(format: "%.4f, %.4f (alt: %.1f)",
                          loc.coordinate.latitude,
                          loc.coordinate.longitude,
                          loc.altitude)
        }
        return "Unknown"
    }
    
    private var networkInfo: String {
        if networkManager.isWifi {
            return "Wi-Fi - \(networkManager.carrierName)"
        } else {
            return "\(networkManager.networkType) - \(networkManager.carrierName)"
        }
    }

    private func isInZone(lat: Double, lon: Double) -> Bool {
        (lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon)
    }
    
    // MARK: - Collecte des données
    
    private func startCollecting() {
        isCollecting = true
        
        // Démarrer les managers
        locationManager.startUpdatingLocation()
        motionManager.startUpdates()
        sensorManager.startSimulating()
        activityManager.startUpdates()
        
        // Timer pour collecter à une fréquence donnée (ex : 100 Hz)
        collectionTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            collectData()
        })

        // ✅ Envoyer une requête HTTP "Start collecting data"
        sendHTTP(status: "Start collecting data")
    }
    
    private func stopCollecting() {
        isCollecting = false
        locationManager.stopUpdatingLocation()
        motionManager.stopUpdates()
        sensorManager.stopSimulating()
        collectionTimer?.invalidate()
        collectionTimer = nil
        activityManager.stopUpdates()

        // ✅ Envoyer une requête HTTP "Stop collecting data"
        sendHTTP(status: "Stop collecting data")
    }
    
    private func collectData() {
        let now = Date()
        let lat = locationManager.currentLocation?.coordinate.latitude ?? 0
        let lon = locationManager.currentLocation?.coordinate.longitude ?? 0
        let alt = locationManager.currentLocation?.altitude ?? 0
        let spd = locationManager.currentSpeed
        
        // Vérifier la zone
        let inZoneNow = isInZone(lat: lat, lon: lon)
        if inZoneNow && !wasInZone {
            zonePassageCount += 1
        }
        wasInZone = inZoneNow
        
        // Créer le SensorData
        let data = SensorData(
            timestamp: now,
            latitude: lat,
            longitude: lon,
            altitude: alt,
            speed: spd,
            accelerationX: motionManager.accelerationX,
            accelerationY: motionManager.accelerationY,
            accelerationZ: motionManager.accelerationZ,
            humidity: sensorManager.humidity,
            temperature: sensorManager.temperature,
            networkSignal: networkInfo,
            batteryLevel: batteryManager.batteryLevel,
            batteryState: batteryManager.batteryStateDescription,
            activity: activityManager.currentActivity
        )

        dataLogger.addData(data)

        // ✅ Envoyer la requête HTTP (JSON) avec la donnée
        let jsonString = data.jsonDescription()
        print("JSON envoyé: \(jsonString)")
        sendHTTP(dataJSON: jsonString)
    }
    
    // MARK: - Export
    
    private func exportCSV() {
        guard let csvURL = dataLogger.exportAsCSV() else { return }
        presentShareSheet(url: csvURL)
    }
    
    private func exportJSON() {
        guard let jsonURL = dataLogger.exportAsJSON() else { return }
        presentShareSheet(url: jsonURL)
    }
    
    private func presentShareSheet(url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }

    // MARK: - HTTP Approach

    /// Ex : fonction simplifiée pour envoyer un message "status" en JSON
    private func sendHTTP(status: String? = nil, dataJSON: String? = nil) {
        // Construire un body JSON minimal
        var bodyDict: [String: Any] = [:]
        if let s = status {
            bodyDict["status"] = s
        }
        if let j = dataJSON {
            bodyDict["data"] = j
        }
        
        // Remplace par l'URL de ton serveur Python
        guard let url = URL(string: "http://192.168.0.34:5001/api/push_data") else {
            print("URL invalide")
            return
        }

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convertir le dictionnaire en Data JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            request.httpBody = jsonData
        } catch {
            print("Erreur de conversion du body en JSON: \(error)")
            return
        }
        
        // Envoyer la requête
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                print("Erreur HTTP: \(err)")
                return
            }
            // Analyser la réponse si besoin
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let str = String(data: data, encoding: .utf8) {
                print("Réponse du serveur: \(str)")
            }
        }.resume()
    }
}

// MARK: - Extension pour convertir SensorData en JSON (exemple)
extension SensorData {
    func jsonDescription() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self),
              let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }
}
