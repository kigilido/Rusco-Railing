//
//  MapScreen.swift
//  DashApp iOS
//
//  Map screen with vehicle locations, search, and "My Location"
//

import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var locationManager = LocationManager()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // NYC default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchText = ""
    @State private var vehicleLocations: [VehicleLocation] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map
                Map(coordinateRegion: $region, annotationItems: vehicleLocations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )) {
                        VehicleMarker()
                    }
                }
                .ignoresSafeArea()

                // Search bar
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Search location...", text: $searchText)
                                .textFieldStyle(.plain)

                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                        Button(action: searchLocation) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "3A86FF"))
                        }
                    }
                    .padding()

                    Spacer()
                }

                // My Location button
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "3A86FF"))
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestPermission()
                loadVehicleLocations()
            }
            .alert("Notice", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func loadVehicleLocations() {
        Task {
            do {
                let locations: [VehicleLocation] = try await authManager.client
                    .from("vehicle_locations")
                    .select()
                    .execute()
                    .value

                await MainActor.run {
                    self.vehicleLocations = locations
                }
            } catch {
                print("Error loading vehicle locations: \(error)")
            }
        }
    }

    func centerOnUserLocation() {
        locationManager.requestLocation { location in
            if let location = location {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }

                // Update user location in database
                updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

                alertMessage = "Map centered on your location"
                showAlert = true
            } else {
                alertMessage = "Unable to get your location. Please check permissions."
                showAlert = true
            }
        }
    }

    func updateUserLocation(latitude: Double, longitude: Double) {
        guard let userId = authManager.userId else { return }

        Task {
            do {
                let locationData: [String: Any] = [
                    "user_id": userId,
                    "latitude": latitude,
                    "longitude": longitude,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ]

                try await authManager.client
                    .from("vehicle_locations")
                    .upsert(locationData)
                    .execute()
            } catch {
                print("Error updating location: \(error)")
            }
        }
    }

    func searchLocation() {
        guard !searchText.isEmpty else { return }

        Task {
            do {
                // Get Mapbox token from Supabase function
                let tokenResponse = try await authManager.client.functions.invoke("get-mapbox-token")

                // Note: You would need to parse the token from the response
                // For now, we'll use MKLocalSearch as a fallback

                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = searchText

                let search = MKLocalSearch(request: searchRequest)
                let response = try await search.start()

                if let firstResult = response.mapItems.first {
                    await MainActor.run {
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: firstResult.placemark.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Error searching location: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Vehicle Marker
struct VehicleMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "3A86FF"))
                .frame(width: 30, height: 30)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)

            Image(systemName: "car.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?

    private var locationCompletion: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.locationCompletion = completion
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCompletion?(locations.first)
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        locationCompletion?(nil)
        locationCompletion = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

// MARK: - Models
struct VehicleLocation: Identifiable, Codable {
    let id: String
    let user_id: String
    let latitude: Double
    let longitude: Double
    let last_updated: String
}

#Preview {
    MapScreen()
}
