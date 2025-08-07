import SwiftUI
import SwiftData

struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @Environment(\.modelContext) private var context
    @Query private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.plants.isEmpty {
                ProgressView("Loading plants…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 8) {
                    Text("Failed to load plants: \(error.localizedDescription)")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await viewModel.loadNextPage(query: searchText) }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.plants) { plant in
                        let isSaved = savedPlants.contains { $0.id == plant.id }
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

                            Button {
                                if !isSaved {
                                    let saved = viewModel.convertToSavedPlant(from: plant)
                                    context.insert(saved)
                                }
                            } label: {
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                                    .foregroundStyle(isSaved ? Color.red : Color.blue)
                            }
                        }
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: plant, query: searchText)
                        }
                    }

                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
            }
        }
        .navigationTitle("Plant Encyclopedia")
        .onChange(of: searchText) { _, newQuery in
            Task {
                await viewModel.loadNextPage(query: newQuery)
            }
        }
        .task {
            if viewModel.plants.isEmpty {
                await viewModel.loadNextPage()
            }
        }
    }
}
