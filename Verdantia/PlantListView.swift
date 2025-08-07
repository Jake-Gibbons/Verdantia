import SwiftUI
import SwiftData

struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @Environment(\.modelContext) private var context
    @Query private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    /// Local filtering for UI responsiveness.  Once all plants are downloaded,
    /// search simply filters the local array instead of issuing additional requests.
    private var filteredPlants: [APIPlant] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
            ? viewModel.plants
            : viewModel.plants.filter {
                $0.common_name?.lowercased().contains(trimmed.lowercased()) ?? false
            }
    }

    var body: some View {
        VStack {
            if viewModel.isDownloadingAll {
                // Show a linear progress bar while all pages are downloading
                VStack {
                    ProgressView(value: viewModel.downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .padding()
                    Text("Downloading all plants…")
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                // Show an error message with a retry button if the download failed
                VStack(spacing: 8) {
                    Text("Failed to download plants: \(error.localizedDescription)")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await viewModel.loadAllPlants() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Display the list of all plants, filtered locally by searchText
                List {
<<<<<<< Updated upstream
                    ForEach(viewModel.plants) { plant in
                        let isSaved = savedPlants.contains { $0.id == plant.id }
=======
                    ForEach(filteredPlants) { plant in
>>>>>>> Stashed changes
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
                                Text(plant.common_name ?? "Unknown")
                                    .font(.headline)
                                Text(plant.scientific_name?.joined(separator: ", ") ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Toggle favourite: insert if not saved, delete if already saved
                            Button {
<<<<<<< Updated upstream
                                if !isSaved {
=======
                                if let existing = savedPlants.first(where: { $0.id == plant.id }) {
                                    context.delete(existing)
                                } else {
>>>>>>> Stashed changes
                                    let saved = viewModel.convertToSavedPlant(from: plant)
                                    context.insert(saved)
                                }
                            } label: {
<<<<<<< Updated upstream
=======
                                let isSaved = savedPlants.contains(where: { $0.id == plant.id })
>>>>>>> Stashed changes
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                                    .foregroundStyle(isSaved ? Color.red : Color.blue)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
            }
        }
        .navigationTitle("Plant Encyclopedia")
        .task {
            // Download all plants once when the view appears, then persist them
            if viewModel.plants.isEmpty {
                await viewModel.loadAllPlants()
                await viewModel.persistDownloadedPlants(using: context)
            }
        }
    }
}
