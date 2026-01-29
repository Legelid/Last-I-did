//
//  ExportView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query private var activities: [Activity]

    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var isExporting = false
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Export your activity data for backup or analysis.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Export Formats") {
                    // CSV - Activities Summary
                    Button {
                        exportActivitiesCSV()
                    } label: {
                        ExportOptionRow(
                            icon: "tablecells",
                            title: "Activities Summary (CSV)",
                            description: "All activities with their current status",
                            color: .green
                        )
                    }
                    .disabled(isExporting)

                    // CSV - Full History
                    Button {
                        exportHistoryCSV()
                    } label: {
                        ExportOptionRow(
                            icon: "clock.arrow.circlepath",
                            title: "Completion History (CSV)",
                            description: "Every completion record with dates and notes",
                            color: .blue
                        )
                    }
                    .disabled(isExporting)

                    // PDF Report
                    Button {
                        exportPDF()
                    } label: {
                        ExportOptionRow(
                            icon: "doc.richtext",
                            title: "PDF Report",
                            description: "Formatted report with summary and activity list",
                            color: .red
                        )
                    }
                    .disabled(isExporting)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Data Summary", systemImage: "info.circle")
                            .font(.headline)

                        HStack {
                            Text("Activities")
                            Spacer()
                            Text("\(activities.count)")
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Total Completions")
                            Spacer()
                            Text("\(activities.reduce(0) { $0 + $1.completions.count })")
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Categories")
                            Spacer()
                            let uniqueCategories = Set(activities.flatMap { $0.categories.map { $0.name } })
                            Text("\(uniqueCategories.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = exportError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .overlay {
                if isExporting {
                    ProgressView("Exporting...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
    }

    private func exportActivitiesCSV() {
        isExporting = true
        exportError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let url = ExportManager.shared.exportToCSV(activities: activities)

            DispatchQueue.main.async {
                isExporting = false
                if let url = url {
                    exportURL = url
                    showingShareSheet = true
                } else {
                    exportError = "Failed to create CSV file"
                }
            }
        }
    }

    private func exportHistoryCSV() {
        isExporting = true
        exportError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let url = ExportManager.shared.exportCompletionHistoryToCSV(activities: activities)

            DispatchQueue.main.async {
                isExporting = false
                if let url = url {
                    exportURL = url
                    showingShareSheet = true
                } else {
                    exportError = "Failed to create CSV file"
                }
            }
        }
    }

    private func exportPDF() {
        isExporting = true
        exportError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let url = ExportManager.shared.exportToPDF(activities: activities)

            DispatchQueue.main.async {
                isExporting = false
                if let url = url {
                    exportURL = url
                    showingShareSheet = true
                } else {
                    exportError = "Failed to create PDF file"
                }
            }
        }
    }
}

struct ExportOptionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "square.and.arrow.up")
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
