import SwiftUI
import SwiftData

struct WateringScheduleView: View {
    @Query private var savedPlants: [SavedPlant]

    var upcoming: [(plant: SavedPlant, date: Date)] {
        savedPlants.compactMap { plant in
            guard let last = plant.lastWatered else { return nil }
            let next = Calendar.current.date(byAdding: .day, value: plant.wateringIntervalDays, to: last)!
            return (plant, next)
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        List {
            ForEach(upcoming, id: \.plant.id) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.plant.commonName).bold()
                        Text("Water on \(item.date.formatted(.dateTime.day().month().year()))")
                            .foregroundColor(.secondary)
                    }
                }
                .glassCard()
            }
        }
        .navigationTitle("Watering Schedule")
    }
}
