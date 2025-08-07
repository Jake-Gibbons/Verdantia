import SwiftUI
import SwiftData

struct OpenPlantbookSearchView: View {
    @StateObject private var vm = OpenPlantbookViewModel()
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                    TextField("Search for a plant...", text: $vm.query)
                        .textFieldStyle(.plain)
                        .padding(.vertical, 10)
                    Button(action: {
                        Task { await vm.performSearch() }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.tertiary, lineWidth: 1)
                )
                .padding(.horizontal)

                if vm.isLoading {
                    ProgressView("Loading...")
                        .padding(.top)
                }

                if let error = vm.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                List(vm.results, id: \.pid) { plant in
                    NavigationLink(value: plant) {
                        HStack {
                            Text(plant.display_pid)
                            if let cached = try? context.fetch(FetchDescriptor<CachedOPBPlant>(
                                predicate: #Predicate { $0.pid == plant.pid }
                            )).first, cached.isFavourite {
                                Image(systemName: "heart.fill").foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationDestination(for: PlantSummary.self) { plant in
                PlantDetailView(plant: plant)
            }
            .navigationTitle("Open Plantbook")
        }
    }
}

#Preview {
    OpenPlantbookSearchView()
}
