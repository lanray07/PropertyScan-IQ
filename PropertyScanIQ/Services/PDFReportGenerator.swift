import Foundation
import UIKit

struct PDFReportGenerator {
    func generatePDF(content: ReportContent, includeBranding: Bool, logoData: Data? = nil) throws -> URL {
        let safeTitle = content.title
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
        let fileName = "\(safeTitle)-\(Int(Date().timeIntervalSince1970)).pdf"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Reports", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(fileName)

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let margin: CGFloat = 44
        let contentWidth = pageRect.width - margin * 2

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            var y = margin

            func ensureSpace(_ height: CGFloat) {
                if y + height > pageRect.height - margin {
                    context.beginPage()
                    y = margin
                }
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 10) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.lineSpacing = 2
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
                let nsText = text as NSString
                let bounding = nsText.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                let height = ceil(bounding.height)
                ensureSpace(height)
                nsText.draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                y += height + spacing
            }

            func drawRule() {
                ensureSpace(12)
                UIColor.systemGray4.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
                path.lineWidth = 1
                path.stroke()
                y += 16
            }

            if includeBranding, let logoData, let logo = UIImage(data: logoData) {
                ensureSpace(52)
                logo.draw(in: CGRect(x: margin, y: y, width: 50, height: 50))
                y += 58
            }

            drawText(includeBranding ? "PropertyScan IQ" : "PropertyScan IQ Basic Report", font: .boldSystemFont(ofSize: 13), color: .systemTeal)
            drawText(content.title, font: .boldSystemFont(ofSize: 28), spacing: 14)
            drawText("Generated \(content.generatedAt.shortReportDate)", font: .systemFont(ofSize: 11), color: .secondaryLabel)
            drawRule()

            drawText("Property overview", font: .boldSystemFont(ofSize: 18))
            drawText("\(content.property.name)\n\(content.property.address)\nType: \(content.property.propertyTypeLabel)\nClient: \(content.property.clientName.isEmpty ? "Not specified" : content.property.clientName)", font: .systemFont(ofSize: 12))

            drawText("Inspection summary", font: .boldSystemFont(ofSize: 18))
            drawText(content.inspection.summary.isEmpty ? "No written summary has been generated yet." : content.inspection.summary, font: .systemFont(ofSize: 12))

            drawText("Severity breakdown", font: .boldSystemFont(ofSize: 18))
            let breakdown = content.severityBreakdown.map { "\($0.0.displayName): \($0.1)" }.joined(separator: "    ")
            drawText(breakdown, font: .systemFont(ofSize: 12))

            drawText("Room-by-room findings", font: .boldSystemFont(ofSize: 18))
            for room in content.rooms {
                let roomIssues = content.issues.filter { $0.roomAreaId == room.id }
                drawText("\(room.name) - \(room.conditionLabel)", font: .boldSystemFont(ofSize: 14), spacing: 4)
                drawText(room.notes.isEmpty ? "No room notes." : room.notes, font: .italicSystemFont(ofSize: 11), color: .secondaryLabel, spacing: 6)

                if roomIssues.isEmpty {
                    drawText("No approved findings for this area.", font: .systemFont(ofSize: 11), color: .secondaryLabel)
                } else {
                    for issue in roomIssues {
                        drawText("\(issue.severityValue.displayName): \(issue.title)\n\(issue.issueDescription)\nAction: \(issue.suggestedAction)\nConfidence: \(Int(issue.confidence * 100))%", font: .systemFont(ofSize: 11))
                    }
                }

                if let photos = content.photosByRoom[room.id], !photos.isEmpty {
                    drawText("Photo evidence", font: .boldSystemFont(ofSize: 12), spacing: 6)
                    for photo in photos.prefix(3) {
                        guard let data = photo.imageData, let image = UIImage(data: data) else { continue }
                        ensureSpace(120)
                        image.draw(in: CGRect(x: margin, y: y, width: 150, height: 110))
                        y += 116
                        if !photo.caption.isEmpty {
                            drawText(photo.caption, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 6)
                        } else {
                            y += 4
                        }
                    }
                }
            }

            drawText("Recommended next actions", font: .boldSystemFont(ofSize: 18))
            let actions = content.priorityIssues.prefix(10).map { "- \($0.suggestedAction)" }.joined(separator: "\n")
            drawText(actions.isEmpty ? "No action list available yet." : actions, font: .systemFont(ofSize: 12))

            drawText("Client notes", font: .boldSystemFont(ofSize: 18))
            drawText(content.clientNotes.isEmpty ? "No client notes added." : content.clientNotes, font: .systemFont(ofSize: 12))

            drawText("AI disclaimer", font: .boldSystemFont(ofSize: 18))
            drawText(ReportContentBuilder.safetyDisclaimer, font: .systemFont(ofSize: 11), color: .secondaryLabel)
            drawText("Inspector/user signature: ________________________________", font: .systemFont(ofSize: 12))
        }

        return url
    }
}
