import SwiftUI
import SwiftData

/// Displays a searchable list of plants returned from the Perenual API. Plants
/// can be saved into the user's garden by tapping the heart button. The view
/// reacts to changes in the view model's published properties.
struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @Environment(\.modelContext) private var context
    @Query private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    /// Filters the fetched plants based on the current search text.
    private var filteredPlants: [APIPlant] {
        guard !searchText.isEmpty else { return viewModel.plants }
        return viewModel.plants.filter { $0.common_name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                // Display a loading indicator while the network request is in flight.
                ProgressView("Loading plants…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                // Provide a user friendly error message and a retry button.
                VStack(spacing: 8) {
                    Text("Failed to load plants: \(error.localizedDescription)")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await viewModel.loadPlants() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Show the list of plants once loaded.
                List(filteredPlants) { plant in
                    HStack {
                        AsyncImage(url: URL(string: plant.default_image?.original_url ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable().scaledToFit()
                                    .foregroundColor(.secondary)
                            case .empty:
                                Color.gray.opacity(0.2)
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(plant.common_name)
                                .font(.headline)
                            Text(plant.scientific_name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button {
                            // Avoid saving duplicates; insert a new SavedPlant only if it doesn't already exist.
                            guard !savedPlants.contains(where: { $0.id == plant.id }) else { return }
                            let saved = viewModel.convertToSavedPlant(from: plant)
                            context.insert(saved)
                        } label: {
                            Image(systemName: savedPlants.contains(where: { $0.id == plant.id }) ? "heart.fill" : "heart")
                                .foregroundStyle(savedPlants.contains(where: { $0.id == plant.id }) ? Color.red : Color.blue)
                        }
                    }
                    .glassCard()
                }
                .searchable(text: $searchText)
                .listStyle(.plain)
            }
        }
        .navigationTitle("Plant Encyclopedia")
        .task {
            // Trigger the initial data load when the view appears. Using .task
            // instead of .onAppear avoids being called when the view hierarchy
            // rebuilds.
            if viewModel.plants.isEmpty {
                await viewModel.loadPlants()
            }
        }
    }
}