import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedUserType") private var selectedUserType = UserType.landlord.rawValue
    @State private var hasAcceptedDisclaimer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "house.and.flag")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(PSITheme.accent)
                        Text("Welcome to PropertyScan IQ")
                            .font(.largeTitle.bold())
                        Text("AI-assisted photo inspections, room findings, and professional PDF reports for property work.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose user type")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                            ForEach(UserType.allCases) { userType in
                                Button {
                                    selectedUserType = userType.rawValue
                                } label: {
                                    HStack {
                                        Text(userType.displayName)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        if selectedUserType == userType.rawValue {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        selectedUserType == userType.rawValue ? PSITheme.accent.opacity(0.16) : PSITheme.panel,
                                        in: RoundedRectangle(cornerRadius: PSITheme.radius)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("AI disclosure", systemImage: "exclamationmark.shield")
                            .font(.headline)
                        disclaimerRow("AI findings are visual suggestions only.")
                        disclaimerRow("Not a replacement for certified surveyors, electricians, gas engineers, or structural engineers.")
                        disclaimerRow("User must verify findings before relying on reports.")
                        disclaimerRow("Urgent safety concerns should be checked by qualified professionals.")

                        Toggle("I understand and accept this disclosure", isOn: $hasAcceptedDisclaimer)
                            .font(.subheadline.weight(.semibold))
                    }
                    .psiCard()

                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Label("Start inspecting", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!hasAcceptedDisclaimer)
                }
                .padding()
            }
        }
    }

    private func disclaimerRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
