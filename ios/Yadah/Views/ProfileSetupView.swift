import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.themePalette) private var theme
    let onDone: (String, String, String) -> Void

    @State private var firstName: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @FocusState private var focusedField: Field?

    private enum Field { case name, city, state }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    YadahWordmark()
                        .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("Let us get to know you")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(theme.navy)

                        Text("Just the basics — no clutter.")
                            .font(.subheadline)
                            .foregroundStyle(theme.warmGray)
                    }

                    VStack(spacing: 14) {
                        YadahTextField(placeholder: "First Name or Initials", text: $firstName)
                            .focused($focusedField, equals: .name)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .city }

                        YadahTextField(placeholder: "City", text: $city)
                            .focused($focusedField, equals: .city)
                            .textContentType(.addressCity)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .state }

                        YadahTextField(placeholder: "State", text: $state)
                            .focused($focusedField, equals: .state)
                            .textContentType(.addressState)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            SkyBlueButton(title: "Done") {
                let name = firstName.isEmpty ? "Friend" : firstName
                onDone(name, city, state)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(theme.background)
    }
}

struct YadahTextField: View {
    @Environment(\.themePalette) private var theme
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.body)
            .foregroundStyle(theme.navy)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.accent.opacity(0.4), lineWidth: 1.5)
            }
            .clipShape(.rect(cornerRadius: 12))
    }
}
