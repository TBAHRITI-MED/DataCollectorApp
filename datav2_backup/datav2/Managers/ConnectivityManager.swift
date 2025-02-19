import Foundation
import Combine
import Network
import CoreTelephony
// import CocoaMQTT // <-- Décommente si tu veux publier MQTT depuis ce manager

class ConnectivityManager: ObservableObject {
    /// Indique si on est en Wi-Fi ou non
    @Published var isWifi: Bool = false
    
    /// Nom de l'opérateur réseau (ex. “Orange”, “SFR”)
    @Published var carrierName: String = ""
    
    /// Type de réseau (ex. “4G”, “5G”)
    @Published var networkType: String = ""
    
    // var mqttClient: CocoaMQTT? // <-- Si tu veux un accès MQTT ici
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor")
    
    private let networkInfo = CTTelephonyNetworkInfo()
    
    init() {
        updateNetworkInfo()
        startMonitoring()
    }
    
    func updateNetworkInfo() {
        // Vérifie l’opérateur
        if let provider = networkInfo.serviceSubscriberCellularProviders?.first?.value {
            carrierName = provider.carrierName ?? "Unknown"
        }
        else {
            carrierName = "No Carrier"
        }
        
        // Déduis le type de réseau (approx) : 3G/4G/5G
        if let radioTech = networkInfo.serviceCurrentRadioAccessTechnology?.first?.value {
            networkType = interpretRadioTech(radioTech)
        } else {
            networkType = "Unknown"
        }
    }
    
    private func interpretRadioTech(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyLTE: return "4G"
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR: return "5G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyGPRS:
            return "3G or older"
        default:
            return "Unknown"
        }
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isWifi = (path.usesInterfaceType(.wifi))
                self.updateNetworkInfo()
                
                // Exemple MQTT
                // let statusMsg = "Network status changed: isWifi=\(self.isWifi), carrier=\(self.carrierName), type=\(self.networkType)"
                // self.publishMQTT(statusMsg)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // private func publishMQTT(_ message: String) {
    //     guard let client = mqttClient else { return }
    //     client.publish("DataCollector/Network", withString: message)
    // }
}
