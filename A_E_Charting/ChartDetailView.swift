import SwiftUI

struct ChartDetailView: View {
    let chart: ChartEntry
    let onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    HStack {
                        Text("Modality:")
                            .bold()
                        Spacer()
                        Text(chart.modality)
                    }

                    HStack {
                        Text("RF Level:")
                            .bold()
                        Spacer()
                        Text("\(chart.rfLevel)")
                    }

                    HStack {
                        Text("DC Level:")
                            .bold()
                        Spacer()
                        Text("\(chart.dcLevel)")
                    }

                    HStack {
                        Text("Probe:")
                            .bold()
                        Spacer()
                        Text(chart.probe)
                    }

                    HStack {
                        Text("Treatment Area:")
                            .bold()
                        Spacer()
                        Text(chart.treatmentArea)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .bold()
                    Text(chart.notes)
                        .padding(.top, 4)
                }

                HStack {
                    Text("Created At:")
                        .bold()
                    Spacer()
                    Text(chart.createdAt.formatted(date: .abbreviated, time: .shortened))
                }

                HStack {
                    Text("Last Edited:")
                        .bold()
                    Spacer()
                    Text(chart.lastEditedAt.formatted(date: .abbreviated, time: .shortened))
                }

                Button("Edit Chart") {
                    onEdit()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Chart Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
