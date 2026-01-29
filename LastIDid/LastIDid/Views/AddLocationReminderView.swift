//
//  AddLocationReminderView.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddLocationReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var locationManager = LocationReminderManager.shared

    // Form state
    @State private var title = ""
    @State private var locationName = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var radius: Double = 100
    @State private var cooldownHours: CooldownDuration = .twentyFourHours

    // Map state
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false

    var canSave: Bool {
        !title.isEmpty && !locationName.isEmpty && selectedCoordinate != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Title section
                Section {
                    TextField("What do you need to do?", text: $title)
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("e.g., \"Buy milk\", \"Pick up prescription\"")
                }

                // Location section
                Section {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search for a place", text: $searchText)
                            .textContentType(.location)
                            .autocorrectionDisabled()
                            .onSubmit {
                                searchLocation()
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                searchResults = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Search results
                    if isSearching {
                        HStack {
                            ProgressView()
                            Text("Searching...")
                                .foregroundStyle(.secondary)
                        }
                    } else if !searchResults.isEmpty {
                        ForEach(searchResults, id: \.self) { item in
                            Button {
                                selectLocation(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "Unknown")
                                        .foregroundStyle(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }

                    // Selected location display
                    if let coordinate = selectedCoordinate {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                Text(locationName)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Change") {
                                    clearSelection()
                                }
                                .font(.caption)
                            }

                            // Mini map preview
                            Map(position: .constant(.region(MKCoordinateRegion(
                                center: coordinate,
                                latitudinalMeters: radius * 3,
                                longitudinalMeters: radius * 3
                            )))) {
                                MapCircle(center: coordinate, radius: radius)
                                    .foregroundStyle(.blue.opacity(0.2))
                                    .stroke(.blue, lineWidth: 2)
                                Marker(locationName, coordinate: coordinate)
                            }
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .disabled(true)
                        }
                    }
                } header: {
                    Text("Location")
                }

                // Radius section
                if selectedCoordinate != nil {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Trigger radius")
                                Spacer()
                                Text("\(Int(radius))m")
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $radius, in: 50...500, step: 25)
                        }
                    } footer: {
                        Text("How close you need to be to trigger the reminder.")
                    }
                }

                // Cooldown section
                Section {
                    Picker("Cooldown after trigger", selection: $cooldownHours) {
                        ForEach(CooldownDuration.allCases) { duration in
                            Text(duration.label).tag(duration)
                        }
                    }
                } footer: {
                    Text("How long to wait before the reminder can trigger again. \(cooldownHours.description.lowercased()).")
                }

                // Current location button
                if selectedCoordinate == nil {
                    Section {
                        Button {
                            useCurrentLocation()
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Use Current Location")
                            }
                        }
                        .disabled(!locationManager.hasLocationPermission)
                    }
                }
            }
            .navigationTitle("New Location Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                locationManager.setModelContext(modelContext)
                if locationManager.hasLocationPermission {
                    locationManager.requestCurrentLocation()
                    // Center map on user location
                    if let location = locationManager.userLocation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            latitudinalMeters: 1000,
                            longitudinalMeters: 1000
                        ))
                    }
                }
            }
        }
    }

    // MARK: - Search

    private func searchLocation() {
        guard !searchText.isEmpty else { return }

        isSearching = true
        searchResults = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        // Search near user location if available
        if let location = locationManager.userLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                if let response = response {
                    searchResults = Array(response.mapItems.prefix(5))
                }
            }
        }
    }

    private func selectLocation(_ item: MKMapItem) {
        locationName = item.name ?? "Selected Location"
        selectedCoordinate = item.placemark.coordinate
        searchText = ""
        searchResults = []
    }

    private func clearSelection() {
        locationName = ""
        selectedCoordinate = nil
    }

    private func useCurrentLocation() {
        guard let location = locationManager.userLocation else { return }

        // Reverse geocode to get address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    locationName = placemark.name ?? placemark.locality ?? "Current Location"
                } else {
                    locationName = "Current Location"
                }
                selectedCoordinate = location.coordinate
            }
        }
    }

    // MARK: - Save

    private func saveReminder() {
        guard let coordinate = selectedCoordinate else { return }

        let reminder = LocationReminder(
            title: title.trimmingCharacters(in: .whitespaces),
            locationName: locationName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: radius,
            cooldownHours: cooldownHours.rawValue
        )

        locationManager.addReminder(reminder)
        dismiss()
    }
}

#Preview {
    AddLocationReminderView()
        .modelContainer(for: [LocationReminder.self], inMemory: true)
        .preferredColorScheme(.dark)
}
