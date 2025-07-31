import SwiftUI
import SwiftData

/// Displays an ordered list of upcoming watering dates for each saved plant.
/// This view recomputes the schedule whenever the underlying data changes.
struct WateringScheduleView: View {
    @Query private var savedPlants: [SavedPlant]

    /// A simple identifiable wrapper for a watering schedule entry. Using a
    /// custom type avoids the need to construct complex key paths for the
    /// `ForEach` `id` parameter.
    private struct WateringItem: Identifiable {
        let plant: SavedPlant
        let date: Date
        var id: Int { plant.id }
    }

    /// Computes upcoming watering dates by adding each plant's interval to its
    /// last watered date. Plants that have never been watered are excluded.
    private var upcoming: [WateringItem] {
        savedPlants.compactMap { plant in
            guard let last = plant.lastWatered else { return nil }
            guard let next = Calendar.current.date(byAdding: .day,
                                                   value: plant.wateringIntervalDays,
                                                   to: last) else { return nil }
            return WateringItem(plant: plant, date: next)
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        List {
            if upcoming.isEmpty {
                Text("No upcoming watering tasks")
                    .foregroundColor(.secondary)
            } else {
                ForEach(upcoming) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.plant.commonName)
                                .bold()
                            Text("Water on \(item.date.formatted(.dateTime.day().month().year()))")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Watering Schedule")
    }
}
