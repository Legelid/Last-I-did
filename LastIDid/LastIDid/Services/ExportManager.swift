//
//  ExportManager.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import PDFKit
import UIKit

class ExportManager {
    static let shared = ExportManager()

    private init() {}

    // MARK: - CSV Export

    func exportToCSV(activities: [Activity]) -> URL? {
        var csvContent = "Activity Name,Last Completed,Days Since,Categories,Total Completions,Notes\n"

        for activity in activities {
            let name = escapeCSV(activity.name)
            let lastCompleted = activity.lastCompletedDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never"
            let daysSince = activity.daysSinceLastCompleted == Int.max ? "N/A" : "\(activity.daysSinceLastCompleted)"
            let categories = activity.categories.map { $0.name }.joined(separator: "; ")
            let completionCount = activity.completions.count
            let notes = escapeCSV(activity.notes ?? "")

            csvContent += "\(name),\(lastCompleted),\(daysSince),\(categories),\(completionCount),\(notes)\n"
        }

        return saveToFile(content: csvContent, filename: "lastidid_activities.csv")
    }

    func exportCompletionHistoryToCSV(activities: [Activity]) -> URL? {
        var csvContent = "Activity Name,Completed Date,Recorded Date,Was Backdated,Notes\n"

        for activity in activities {
            for completion in activity.completions.sorted(by: { $0.completedDate > $1.completedDate }) {
                let name = escapeCSV(activity.name)
                let completedDate = completion.completedDate.formatted(date: .abbreviated, time: .shortened)
                let recordedDate = completion.recordedDate.formatted(date: .abbreviated, time: .shortened)
                let wasBackdated = completion.wasBackdated ? "Yes" : "No"
                let notes = escapeCSV(completion.notes ?? "")

                csvContent += "\(name),\(completedDate),\(recordedDate),\(wasBackdated),\(notes)\n"
            }
        }

        return saveToFile(content: csvContent, filename: "lastidid_history.csv")
    }

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }

    // MARK: - PDF Export

    func exportToPDF(activities: [Activity]) -> URL? {
        let pageWidth: CGFloat = 612 // Letter size
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfMetaData = [
            kCGPDFContextCreator: "Last I Did",
            kCGPDFContextTitle: "Activity Report"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight),
            format: format
        )

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let title = "Last I Did - Activity Report"
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40

            // Date
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let dateString = "Generated: \(Date().formatted(date: .long, time: .shortened))"
            dateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30

            // Summary
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]

            let freshCount = activities.filter { $0.agingState == .fresh }.count
            let agingCount = activities.filter { $0.agingState == .aging }.count
            let staleCount = activities.filter { $0.agingState == .stale }.count
            let score = ScoreCalculator.calculateScore(for: activities)

            let summary = """
            Total Activities: \(activities.count)
            Maintenance Score: \(score)/100
            Fresh: \(freshCount) | Aging: \(agingCount) | Overdue: \(staleCount)
            """
            summary.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: summaryAttributes)
            yPosition += 70

            // Activities list
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]

            let rowAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]

            "Activities".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 25

            for activity in activities.sorted(by: { $0.daysSinceLastCompleted > $1.daysSinceLastCompleted }) {
                if yPosition > pageHeight - margin - 50 {
                    context.beginPage()
                    yPosition = margin
                }

                let statusEmoji = activity.agingState == .fresh ? "✅" :
                                  activity.agingState == .aging ? "⚠️" : "🔴"
                let lastDone = activity.lastCompletedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never"
                let row = "\(statusEmoji) \(activity.name) - Last: \(lastDone) (\(activity.daysSinceLastCompleted == Int.max ? "Never" : "\(activity.daysSinceLastCompleted) days ago"))"

                row.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: rowAttributes)
                yPosition += 20
            }
        }

        return saveDataToFile(data: data, filename: "lastidid_report.pdf")
    }

    // MARK: - File Helpers

    private func saveToFile(content: String, filename: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write file: \(error.localizedDescription)")
            return nil
        }
    }

    private func saveDataToFile(data: Data, filename: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write file: \(error.localizedDescription)")
            return nil
        }
    }
}
