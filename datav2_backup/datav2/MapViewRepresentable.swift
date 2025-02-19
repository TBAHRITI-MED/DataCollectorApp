import SwiftUI
import MapKit

/// Un UIViewRepresentable pour afficher un MKMapView et capturer les clics
/// en coordonnées latitude/longitude.
struct MapViewRepresentable: UIViewRepresentable {
    
    // Région initiale de la carte
    @Binding var region: MKCoordinateRegion
    
    /// Tableau des points tapés
    @Binding var tappedPoints: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Ajouter un UITapGestureRecognizer pour capturer les clics
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        // Configurer la région initiale
        let mkRegion = MKCoordinateRegion(center: region.center,
                                          span: region.span)
        mapView.setRegion(mkRegion, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Mettre à jour la région
        let mkRegion = MKCoordinateRegion(center: region.center, span: region.span)
        uiView.setRegion(mkRegion, animated: true)
        
        // Retirer et réajouter les annotations
        uiView.removeAnnotations(uiView.annotations)
        for coord in tappedPoints {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            if gesture.state == .ended {
                let locationInView = gesture.location(in: mapView)
                let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                
                // Ajouter ce point dans tappedPoints
                parent.tappedPoints.append(coordinate)
            }
        }
        
        // Ex: pour renderer polylines, etc. si besoin
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
