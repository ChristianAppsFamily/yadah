import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.themePalette) private var theme
    let initialProfile: UserProfile?
    var embeddedInSettings: Bool = false
    var saveButtonTitle: String = "Done"
    let onDone: (String, String, String, String?) -> Void

    @State private var firstName: String
    @State private var initials: String
    @State private var selectedCity: String
    @State private var customCity: String
    @State private var selectedState: String
    @State private var customState: String
    @FocusState private var focusedField: Field?

    private enum Field {
        case firstName, initials, customCity, customState
    }

    init(
        initialProfile: UserProfile? = nil,
        embeddedInSettings: Bool = false,
        saveButtonTitle: String = "Done",
        onDone: @escaping (String, String, String, String?) -> Void
    ) {
        self.initialProfile = initialProfile
        self.embeddedInSettings = embeddedInSettings
        self.saveButtonTitle = saveButtonTitle
        self.onDone = onDone

        let draft = Self.draft(from: initialProfile)
        _firstName = State(initialValue: draft.firstName)
        _initials = State(initialValue: draft.initials)
        _selectedCity = State(initialValue: draft.selectedCity)
        _customCity = State(initialValue: draft.customCity)
        _selectedState = State(initialValue: draft.selectedState)
        _customState = State(initialValue: draft.customState)
    }

    var body: some View {
        VStack(spacing: embeddedInSettings ? 16 : 0) {
            if embeddedInSettings {
                formFields
                SkyBlueButton(title: saveButtonTitle) {
                    save()
                }
            } else {
                ScrollView {
                    VStack(spacing: 28) {
                        YadahWordmark()
                            .padding(.top, 20)

                        VStack(spacing: 8) {
                            Text("Lets get started.")
                                .font(.system(.title2, design: .serif, weight: .bold))
                                .foregroundStyle(theme.navy)

                            Text("Stay safe enter ONLY the basics.")
                                .font(.subheadline)
                                .foregroundStyle(theme.warmGray)
                                .multilineTextAlignment(.center)
                        }

                        formFields
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                SkyBlueButton(title: saveButtonTitle) {
                    save()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background {
            if !embeddedInSettings {
                theme.background.ignoresSafeArea()
            }
        }
    }

    private var formFields: some View {
        VStack(spacing: 14) {
            focusableField(placeholder: "First Name only", text: $firstName, field: .firstName)
                .textContentType(.givenName)
                .submitLabel(.next)
                .onSubmit { focusedField = .initials }

            focusableField(placeholder: "or Initials", text: $initials, field: .initials)
                .textInputAutocapitalization(.characters)
                .submitLabel(.done)
                .onSubmit { focusedField = nil }
                .onChange(of: initials) { _, newValue in
                    if newValue.count > 3 {
                        initials = String(newValue.prefix(3))
                    }
                }

            locationMenu(
                title: "City",
                selection: $selectedCity,
                options: LocationOptions.usCities,
                customText: $customCity,
                customField: .customCity
            )

            locationMenu(
                title: "State",
                selection: $selectedState,
                options: LocationOptions.usStates,
                customText: $customState,
                customField: .customState
            )
        }
    }

    private func save() {
        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInitials = initials.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = !trimmedName.isEmpty
            ? trimmedName
            : (!trimmedInitials.isEmpty ? trimmedInitials : "Friend")
        let wallInitials = !trimmedInitials.isEmpty ? trimmedInitials : nil
        onDone(displayName, resolvedCity, resolvedState, wallInitials)
    }

    private static func draft(from profile: UserProfile?) -> (
        firstName: String,
        initials: String,
        selectedCity: String,
        customCity: String,
        selectedState: String,
        customState: String
    ) {
        guard let profile else {
            return (
                "",
                "",
                LocationOptions.usCities.first ?? LocationOptions.writeMyOwn,
                "",
                LocationOptions.usStates.first ?? LocationOptions.writeMyOwn,
                ""
            )
        }

        let savedInitials = profile.wallInitials?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let savedName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName: String
        if savedName.isEmpty || savedName == "Friend" || savedName.caseInsensitiveCompare(savedInitials) == .orderedSame {
            firstName = ""
        } else {
            firstName = savedName
        }

        let cityPick = locationDraft(value: profile.city, options: LocationOptions.usCities)
        let statePick = locationDraft(value: profile.state, options: LocationOptions.usStates)

        return (
            firstName,
            savedInitials,
            cityPick.selection,
            cityPick.custom,
            statePick.selection,
            statePick.custom
        )
    }

    private static func locationDraft(value: String, options: [String]) -> (selection: String, custom: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (options.first ?? LocationOptions.writeMyOwn, "")
        }
        if options.contains(trimmed) {
            return (trimmed, "")
        }
        return (LocationOptions.writeMyOwn, trimmed)
    }

    private var resolvedCity: String {
        if selectedCity == LocationOptions.writeMyOwn {
            return customCity.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedCity
    }

    private var resolvedState: String {
        if selectedState == LocationOptions.writeMyOwn {
            return customState.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedState
    }

    private func focusableField(placeholder: String, text: Binding<String>, field: Field) -> some View {
        YadahTextField(placeholder: placeholder, text: text)
            .focused($focusedField, equals: field)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = field
            }
    }

    @ViewBuilder
    private func locationMenu(
        title: String,
        selection: Binding<String>,
        options: [String],
        customText: Binding<String>,
        customField: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(theme.warmGray)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue)
                        .foregroundStyle(theme.navy)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(theme.warmGray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.background)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.accent.opacity(0.4), lineWidth: 1.5)
                }
                .contentShape(Rectangle())
            }

            if selection.wrappedValue == LocationOptions.writeMyOwn {
                focusableField(placeholder: "Enter \(title.lowercased())", text: customText, field: customField)
            }
        }
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.accent.opacity(0.4), lineWidth: 1.5)
            }
            .clipShape(.rect(cornerRadius: 12))
            .contentShape(Rectangle())
    }
}
