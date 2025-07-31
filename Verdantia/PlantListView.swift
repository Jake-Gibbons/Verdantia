import SwiftUI
import SwiftData

struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @Environment(\.modelContext) private var context
    @Query private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    /// Filters plants based on search text.
    /// Uses an empty string for nil names to avoid nil comparisons.
    private var filteredPlants: [APIPlant] {
        guard !searchText.isEmpty else { return viewModel.plants }
        return viewModel.plants.filter {
            ($0.common_name ?? "").lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading plants…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
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
                List(filteredPlants) { plant in
                    HStack {
                        // AsyncImage and heart button unchanged ...
                        VStack(alignment: .leading) {
                            // Use default values when names are nil.
                            Text(plant.common_name ?? "Unknown")
                                .font(.headline)
                            Text(plant.scientific_name ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        // Heart button and other UI remain the same.
                    }
                }
                .searchable(text: $searchText)
                .listStyle(.plain)
            }
        }
        .navigationTitle("Plant Encyclopedia")
        .task {
            if viewModel.plants.isEmpty {
                await viewModel.loadPlants()
            }
        }
    }
}
