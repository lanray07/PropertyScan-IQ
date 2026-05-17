import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    private let freeFeatures = [
        "2 inspections per month",
        "10 photo scans per month",
        "Basic report export",
        "PropertyScan IQ footer on reports"
    ]

    private let proFeatures = [
        "Unlimited inspections",
        "More AI scans",
        "PDF exports",
        "Custom logo",
        "Client-ready reports",
        "Priority issue summary",
        "Maintenance checklist generation",
        "Before/after comparison placeholder"
    ]

    private let businessFeatures = [
        "Multiple properties",
        "Team-ready structure placeholder",
        "White-label report branding",
        "Unlimited reports",
        "Contractor-ready action lists"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upgrade PropertyScan IQ")
                        .font(.largeTitle.bold())
                    Text("Unlock professional property reports, branding, and maintenance workflows.")
                        .foregroundStyle(.secondary)
                }

                planCard(plan: .free, features: freeFeatures, symbol: "doc.text")
                planCard(plan: .proMonthly, features: proFeatures, symbol: "sparkles")
                planCard(plan: .proYearly, features: proFeatures + ["Best value for annual reporting"], symbol: "calendar.badge.clock")
                planCard(plan: .businessMonthly, features: businessFeatures, symbol: "building.2")

                Button("Restore purchases") {
                    Task { await subscriptionManager.restorePurchases() }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                if subscriptionManager.mockModeEnabled {
                    Text("Mock subscription mode is enabled for testing. Replace product IDs and disable mock mode for production StoreKit testing.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text("Subscriptions use StoreKit 2 auto-renewable products. Pricing and availability must be configured in App Store Connect before release.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Plans")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await subscriptionManager.loadProducts()
        }
    }

    private func planCard(plan: SubscriptionPlan, features: [String], symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(PSITheme.accent)
                VStack(alignment: .leading) {
                    Text(plan.displayName)
                        .font(.headline)
                    Text(plan.priceText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if subscriptionManager.currentPlan == plan && subscriptionManager.isActive == plan.isPaid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark")
                        .font(.subheadline)
                }
            }

            Button(plan == .free ? "Use Free" : "Choose \(plan.displayName)") {
                Task {
                    if plan == .free {
                        subscriptionManager.resetMockSubscription()
                    } else {
                        await subscriptionManager.purchase(plan: plan)
                    }
                    dismiss()
                }
            }
            .buttonStyle(plan.isPaid ? .borderedProminent : .bordered)
            .frame(maxWidth: .infinity)
        }
        .psiCard()
    }
}
