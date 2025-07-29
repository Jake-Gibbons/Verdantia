import SwiftUI

struct GardenNoteView: View {
    @Bindable var plant: SavedPlant

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Notes")) {
                    TextEditor(text: $plant.notes)
                        .frame(height: 120)
                }

                Section {
                    Button("Water Now") {
                        plant.lastWatered = Date()
                        NotificationManager.shared.scheduleReminder(for: plant)
                    }
                }
            }
            .navigationTitle(plant.commonName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
