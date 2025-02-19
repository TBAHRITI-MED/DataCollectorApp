import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0
    
    /// Démarre la collecte d'accélération à un certain intervalle (ex. 50 Hz)
    func startUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 50.0
            motionManager.startAccelerometerUpdates(to: queue) { data, error in
                if let accelData = data {
                    let x = accelData.acceleration.x
                    let y = accelData.acceleration.y
                    let z = accelData.acceleration.z
                    
                    DispatchQueue.main.async {
                        self.accelerationX = x
                        self.accelerationY = y
                        self.accelerationZ = z
                    }
                }
                if let err = error {
                    print("Erreur d'accéléromètre: \(err)")
                }
            }
        } else {
            print("Accelerometer non disponible.")
        }
    }
    
    /// Arrête la collecte d'accélération
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
