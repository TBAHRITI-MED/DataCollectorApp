//
//  SelectZoneView.swift
//  datav2
//
//  Created by Mohammed TBAHRITI on 19/02/2025.
//


import SwiftUI
import MapKit

/// Une vue SwiftUI qui utilise MapViewRepresentable (ou un Map SwiftUI) pour
/// laisser l'utilisateur cliquer sur deux points et définir un bounding box.
struct SelectZoneView: View {
    // Région de base (ex. autour de Paris), à adapter
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    /// Les points tapés (on s'attend à 2).
    @State private var tappedPoints: [CLLocationCoordinate2D] = []
    
    /// Callback appelé quand on valide la zone : (minLat, maxLat, minLon, maxLon)
    var onZoneSelected: (Double, Double, Double, Double) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sélectionnez deux points sur la carte")
                .font(.headline)
                .padding(.top)
            
            Map(coordinateRegion: $region,
                annotationItems: tappedPoints.map { MappedPoint(coord: $0) }) { mp in
                MapPin(coordinate: mp.coord, tint: .blue)
            }
            .frame(height: 400)
            .cornerRadius(8)
            .onTapGesture {
                // Dans SwiftUI Map, il n’y a pas de onTap avec lat/lon direct;
                // Il faut un UIViewRepresentable ou un trick. Ex: “MapTapGesture”
                // Si tu utilises un “MapViewRepresentable”, tu peux y intercepter le tap
                // Ici, on simule juste qu'on rajoute "region.center" comme point
                let center = region.center
                tappedPoints.append(center)
            }
            
            if tappedPoints.count >= 2 {
                Button("Valider la zone") {
                    let p1 = tappedPoints[0]
                    let p2 = tappedPoints[1]
                    
                    let minLat = Swift.min(p1.latitude, p2.latitude)
                    let maxLat = Swift.max(p1.latitude, p2.latitude)
                    let minLon = Swift.min(p1.longitude, p2.longitude)
                    let maxLon = Swift.max(p1.longitude, p2.longitude)
                    
                    onZoneSelected(minLat, maxLat, minLon, maxLon)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("Touchez la carte deux fois pour définir la zone.")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
}

/// Permet de conformer annotationItems : on a besoin d'un `Identifiable`.
struct MappedPoint: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}
