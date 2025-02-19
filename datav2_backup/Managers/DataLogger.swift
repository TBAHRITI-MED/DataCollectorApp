import Foundation
// import CocoaMQTT // <-- Décommente si tu veux publier MQTT depuis ce manager

/// Représente les mesures collectées
struct SensorData: Codable {
    let timestamp: Date
    
    // Localisation
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    // Vitesse
    let speed: Double
    
    // Accélération (optionnel)
    let accelerationX: Double?
    let accelerationY: Double?
    let accelerationZ: Double?
    
    // Capteurs (optionnel)
    let humidity: Double?
    let temperature: Double?
    
    // Réseau
    let networkSignal: String?
    
    // Batterie
    let batteryLevel: Float?
    let batteryState: String?
    
    // Activité
    let activity: String?
}

/// Gestionnaire d'enregistrement des données
class DataLogger {
    private var dataBuffer: [SensorData] = []
    
    // var mqttClient: CocoaMQTT? // <-- Si tu veux un accès MQTT ici
    
    func addData(_ data: SensorData) {
        dataBuffer.append(data)
        
        // Example MQTT
        // let msg = "NewData: lat=\(data.latitude), lon=\(data.longitude), speed=\(data.speed)"
        // publishMQTT(msg)
    }
    
    func clear() {
        dataBuffer.removeAll()
    }
    
    func getDataPoints() -> [SensorData] {
        return dataBuffer
    }
    
    // MARK: - Export en CSV
    func exportAsCSV() -> URL? {
        // Créer un CSV en mémoire
        var csvText = "Timestamp,Latitude,Longitude,Altitude,Speed,AccelerationX,AccelerationY,AccelerationZ,Humidity,Temperature,Network,BatteryLevel,BatteryState,Activity\n"
        
        let dateFormatter = ISO8601DateFormatter()
        
        for record in dataBuffer {
            let timestampStr = dateFormatter.string(from: record.timestamp)
            let line = """
            \(timestampStr),\(record.latitude),\(record.longitude),\(record.altitude),\(record.speed),\(record.accelerationX ?? 0),\(record.accelerationY ?? 0),\(record.accelerationZ ?? 0),\(record.humidity ?? 0),\(record.temperature ?? 0),\(record.networkSignal ?? "Unknown"),\(record.batteryLevel ?? -1),\(record.batteryState ?? "Unknown"),\(record.activity ?? "Unknown")
            """
            csvText.append(line + "\n")
        }
        
        // Enregistrer le CSV dans un fichier temporaire
        let fileName = "sensor_data_\(Date().timeIntervalSince1970).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Erreur d'écriture du CSV : \(error)")
            return nil
        }
    }
    
    // MARK: - Export en JSON
    func exportAsJSON() -> URL? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(dataBuffer)
            let fileName = "sensor_data_\(Date().timeIntervalSince1970).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try jsonData.write(to: tempURL)
            return tempURL
        } catch {
            print("Erreur d'écriture du JSON : \(error)")
            return nil
        }
    }
  


    
    // private func publishMQTT(_ message: String) {
    //     guard let client = mqttClient else { return }
    //     client.publish("DataCollector/Data", withString: message)
    // }
}
