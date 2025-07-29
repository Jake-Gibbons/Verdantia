import SwiftUI
import SwiftData

struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @Environment(\.modelContext) private var context
    @Query private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    var filteredPlants: [APIPlant] {
        if searchText.isEmpty {
            return viewModel.allPlants
        } else {
            return viewModel.allPlants.filter {
                $0.common_name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        VStack {
            List(filteredPlants) { plant in
                HStack {
                    AsyncImage(url: URL(string: plant.default_image?.original_url ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading) {
                        Text(plant.common_name).font(.headline)
                        Text(plant.scientific_name).font(.subheadline).foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        if !savedPlants.contains(where: { $0.id == plant.id }) {
                            let saved = viewModel.convertToSavedPlant(from: plant)
                            context.insert(saved)
                        }
                    } label: {
                        Image(systemName: savedPlants.contains(where: { $0.id == plant.id }) ? "heart.fill" : "heart")
                    }
                }
                .glassCard()
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Plant Encyclopedia")
        .onAppear {
            viewModel.loadPlants()
        }
    }
}
