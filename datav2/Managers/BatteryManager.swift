import Foundation
import Combine
import UIKit
// import CocoaMQTT  // <-- Décommente si tu veux publier MQTT depuis ce manager

class BatteryManager: ObservableObject {
    @Published var batteryLevel: Float = 1.0        // [0.0 ... 1.0]
    @Published var batteryStateDescription: String = "Unknown"
    
    // var mqttClient: CocoaMQTT? // <-- Si tu veux un accès MQTT ici
    
    init() {
        // Activer la surveillance de la batterie
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryInfo()
        
        // Écouter les notifications quand la batterie change
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryLevelDidChange),
                                               name: UIDevice.batteryLevelDidChangeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryStateDidChange),
                                               name: UIDevice.batteryStateDidChangeNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func batteryLevelDidChange(_ notification: Notification) {
        updateBatteryInfo()
    }
    
    @objc private func batteryStateDidChange(_ notification: Notification) {
        updateBatteryInfo()
    }
    
    private func updateBatteryInfo() {
        batteryLevel = UIDevice.current.batteryLevel // 0.0 ... 1.0 ou -1 si inconnu
        batteryStateDescription = interpretBatteryState(UIDevice.current.batteryState)
        
        // Exemple d'envoi MQTT
        // let msg = "Battery level=\(batteryLevel), state=\(batteryStateDescription)"
        // publishMQTT(msg)
    }
    
    private func interpretBatteryState(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging:  return "En charge"
        case .full:      return "Pleine"
        case .unplugged: return "Débranchée"
        default:         return "Inconnue"
        }
    }
    
    // private func publishMQTT(_ message: String) {
    //     guard let client = mqttClient else { return }
    //     client.publish("DataCollector/Battery", withString: message)
    // }
}
