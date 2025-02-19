import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0.0  // en m/s
    @Published var locationsHistory: [CLLocation] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestWhenInUseAuthorization() // ou via un bouton
    }
    
    func requestAuthorization() {
        // "Always" ou "When In Use" selon tes besoins
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Calculer la vitesse moyenne entre deux coordonnées (A et B)
    /// en filtrant `locationsHistory`.
    func calculateAverageSpeed(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double {
        // Filtrer les points "proches" du rectangle [A,B]
        let pointsInSegment = locationsHistory.filter { loc in
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            let minLat = Swift.min(start.latitude, end.latitude)
            let maxLat = Swift.max(start.latitude, end.latitude)
            let minLon = Swift.min(start.longitude, end.longitude)
            let maxLon = Swift.max(start.longitude, end.longitude)
            
            return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon
        }
        
        let totalSpeed = pointsInSegment.reduce(0.0) { sum, loc in sum + max(loc.speed, 0) }
        let count = Double(pointsInSegment.count)
        return (count > 0) ? (totalSpeed / count) : 0.0
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Localisation autorisée.")
        case .denied, .restricted:
            print("Localisation refusée ou restreinte.")
        case .notDetermined:
            print("L'utilisateur n'a pas encore choisi.")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        currentLocation = newLocation
        
        // Éviter speed < 0
        currentSpeed = max(newLocation.speed, 0)
        
        // Stocker dans l'historique
        locationsHistory.append(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erreur de localisation: \(error)")
    }
}
