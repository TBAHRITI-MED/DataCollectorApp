import Foundation
import CoreMotion
import Combine
// import CocoaMQTT  // <-- Décommente si tu veux publier MQTT depuis ce manager

class ActivityManager: ObservableObject {
    private let activityManager = CMMotionActivityManager()
    
    @Published var currentActivity: String = "Unknown"
    
    // var mqttClient: CocoaMQTT? // <-- Si tu veux un accès MQTT ici

    /// Lance la détection d'activité
    func startUpdates() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            currentActivity = "NotAvailable"
            return
        }

        activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
            guard let act = activity else { return }
            DispatchQueue.main.async {
                self?.currentActivity = self?.interpretActivity(act) ?? "Unknown"
                // Exemple MQTT
                // let msg = "Activity: \(self?.currentActivity ?? "Unknown")"
                // self?.publishMQTT(msg)
            }
        }
    }
    
    /// Arrête la détection d'activité
    func stopUpdates() {
        activityManager.stopActivityUpdates()
    }
    
    private func interpretActivity(_ act: CMMotionActivity) -> String {
        if act.automotive == true {
            return "Driving"
        } else if act.running == true {
            return "Running"
        } else if act.walking == true {
            return "Walking"
        } else if act.cycling == true {
            return "Cycling"
        } else if act.stationary == true {
            return "Stationary"
        }
        return "Unknown"
    }
    
    // private func publishMQTT(_ message: String) {
    //     guard let client = mqttClient else { return }
    //     client.publish("DataCollector/Activity", withString: message)
    // }
}
