import SwiftUI
import SwiftData

struct MyGardenView: View {
    @Query private var savedPlants: [SavedPlant]
    @Environment(\.modelContext) private var context
    @State private var selectedPlant: SavedPlant?

    var body: some View {
        List {
            ForEach(savedPlants) { plant in
                VStack(alignment: .leading) {
                    HStack {
                        AsyncImage(url: URL(string: plant.imageUrl)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(plant.commonName).font(.headline)
                            if let last = plant.lastWatered {
                                let next = Calendar.current.date(byAdding: .day, value: plant.wateringIntervalDays, to: last)!
                                Text("Next water: \(next.formatted(.dateTime.day().month().year()))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not yet watered")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }

                        Spacer()

                        Button("Water") {
                            plant.lastWatered = Date()
                            NotificationManager.shared.scheduleReminder(for: plant)
                        }
                    }
                }
                .onTapGesture {
                    selectedPlant = plant
                }
            }
        }
        .sheet(item: $selectedPlant) { GardenNoteView(plant: $0) }
        .navigationTitle("My Garden")
    }
}
