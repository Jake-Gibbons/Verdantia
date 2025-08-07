//
//  PlantDetailView.swift
//  Verdantia
//
//  Created by Jake Gibbons on 02/08/2025.
//

import SwiftUI
import SwiftData

struct PlantDetailView: View {
    let plant: PlantSummary
    @State private var detail: PlantDetail?
    @State private var isLoading = true
    @State private var error: Error?
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...")
            } else if let detail {
                VStack(spacing: 12) {
                    Text(detail.display_pid)
                        .font(.title2).bold()

                    if let imageUrl = detail.image_url, let url = URL(string: imageUrl) {                                       
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {                                                                                          img.resizable().scaledToFit()
                            } else {
                                Image(systemName: "photo")
                            }
                        }.frame(height: 200)
                    }

                    if let min = detail.min_temp, let max = detail.max_temp {
                        Text("🌡️ Temperature: \(min)–\(max)°C")
                    }

                    if let minH = detail.min_env_humid, let maxH = detail.max_env_humid {
                        Text("💧 Humidity: \(minH)–\(maxH)%")
                    }

                    Button {
                        let gardenPlant = GardenPlant(
                            pid: detail.pid,
                            displayName: detail.display_pid,
                            imageUrl: detail.image_url,
                            minTemp: detail.min_temp,
                            maxTemp: detail.max_temp,
                            minHumidity: detail.min_env_humid,
                            maxHumidity: detail.max_env_humid
                        )
                        context.insert(gardenPlant)
                        try? context.save()
                    } label: {
                        Label("Add to My Garden", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            } else if let error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Plant Info")
        .task {
            await loadDetail()
        }
    }

    private func loadDetail() async {
        do {
            detail = try await OpenPlantbookService.shared.fetchPlantDetail(pid: plant.pid)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
