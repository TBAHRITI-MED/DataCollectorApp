import Foundation
import Combine
// import CocoaMQTT // <-- Décommente si tu veux publier MQTT depuis ce manager

/// Gère les capteurs internes (humidité, température) ou simulés
class SensorManager: ObservableObject {
    @Published var humidity: Double?
    @Published var temperature: Double?
    
    // var mqttClient: CocoaMQTT? // <-- Si tu veux un accès MQTT ici
    
    private var simulationTimer: Timer?
    
    init() {
        // Si l'appareil n'a pas de capteur physique d'humidité/temperature,
        // on peut simuler ou se baser sur d'autres API.
    }
    
    /// Simule des valeurs aléatoires (ou lit de vrais capteurs si disponibles)
    func startSimulating() {
        stopSimulating()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            // Simulation: humidité entre 30-70%, température entre 15-25°C
            let hum = Double.random(in: 30...70)
            let temp = Double.random(in: 15...25)
            
            DispatchQueue.main.async {
                self.humidity = hum
                self.temperature = temp
                
                // Ex: Publier MQTT
                // let msg = "Sensors: humidity=\(hum), temp=\(temp)"
                // self.publishMQTT(msg)
            }
        }
    }
    
    func stopSimulating() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    // private func publishMQTT(_ message: String) {
    //     guard let client = mqttClient else { return }
    //     client.publish("DataCollector/Sensors", withString: message)
    // }
}
