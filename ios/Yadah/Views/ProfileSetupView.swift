import PhotosUI
import SwiftUI
import UIKit

struct ProfileSetupView: View {
    @Environment(\.themePalette) private var theme
    let initialProfile: UserProfile?
    var embeddedInSettings: Bool = false
    var saveButtonTitle: String = "Done"
    let onDone: (String, String, String, String, String?) -> Void

    @State private var firstName: String
    @State private var selectedCountry: String
    @State private var customCountry: String
    @State private var selectedCity: String
    @State private var customCity: String
    @State private var selectedState: String
    @State private var customState: String
    @State private var didJustSave = false
    @State private var photoItem: PhotosPickerItem?
    @State private var photoImage: UIImage?
    @State private var photoFileName: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case firstName, customCountry, customCity, customState
    }

    init(
        initialProfile: UserProfile? = nil,
        embeddedInSettings: Bool = false,
        saveButtonTitle: String = "Done",
        onDone: @escaping (String, String, String, String, String?) -> Void
    ) {
        self.initialProfile = initialProfile
        self.embeddedInSettings = embeddedInSettings
        self.saveButtonTitle = saveButtonTitle
        self.onDone = onDone

        let draft = Self.draft(from: initialProfile)
        _firstName = State(initialValue: draft.firstName)
        _selectedCountry = State(initialValue: draft.selectedCountry)
        _customCountry = State(initialValue: draft.customCountry)
        _selectedCity = State(initialValue: draft.selectedCity)
        _customCity = State(initialValue: draft.customCity)
        _selectedState = State(initialValue: draft.selectedState)
        _customState = State(initialValue: draft.customState)
        _photoFileName = State(initialValue: draft.photoFileName)
        _photoImage = State(initialValue: ProfilePhotoStore.loadImage(fileName: draft.photoFileName))
    }

    private var isUSA: Bool {
        LocationOptions.isUnitedStates(resolvedCountry)
    }

    var body: some View {
        VStack(spacing: embeddedInSettings ? 16 : 0) {
            if embeddedInSettings {
                formContent
                SkyBlueButton(title: didJustSave ? "Saved" : saveButtonTitle) {
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

                        formContent
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                SkyBlueButton(title: saveButtonTitle) {
                    save()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .scrollDismissesKeyboard(.interactively)
        .background {
            if !embeddedInSettings {
                theme.background.ignoresSafeArea()
            }
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                await loadPhoto(from: newItem)
            }
        }
        .onChange(of: selectedCountry) { _, _ in
            if !isUSA {
                selectedCity = LocationOptions.writeMyOwn
                selectedState = LocationOptions.writeMyOwn
            }
        }
    }

    private var formContent: some View {
        VStack(spacing: 14) {
            photoPickerRow

            focusableField(placeholder: "First name", text: $firstName, field: .firstName)
                .textContentType(.givenName)
                .submitLabel(.done)
                .onSubmit { focusedField = nil }

            locationMenu(
                title: "Country",
                selection: $selectedCountry,
                options: LocationOptions.countries,
                customText: $customCountry,
                customField: .customCountry
            )

            if isUSA {
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
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("City")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.warmGray)
                    focusableField(placeholder: "City", text: $customCity, field: .customCity)
                        .textContentType(.addressCity)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("State / Province / Region")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.warmGray)
                    focusableField(placeholder: "State or region", text: $customState, field: .customState)
                        .textContentType(.addressState)
                }
            }
        }
    }

    private var photoPickerRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.accentLight.opacity(0.55))
                    .frame(width: 64, height: 64)

                if let photoImage {
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(theme.navy.opacity(0.55))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text(photoImage == nil ? "Add photo (optional)" : "Change photo")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.accentDark)
                }

                if photoImage != nil {
                    Button("Remove photo") {
                        ProfilePhotoStore.delete(fileName: photoFileName)
                        photoFileName = nil
                        photoImage = nil
                        photoItem = nil
                    }
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
                }

                Text("Stored only on this device.")
                    .font(.caption2)
                    .foregroundStyle(theme.warmGray.opacity(0.8))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private func save() {
        focusedField = nil
        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? "Friend" : trimmedName
        onDone(displayName, resolvedCountry, resolvedCity, resolvedState, photoFileName)

        guard embeddedInSettings else { return }
        didJustSave = true
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            didJustSave = false
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            await MainActor.run {
                if let saved = ProfilePhotoStore.saveJPEG(image) {
                    photoFileName = saved
                    photoImage = image
                }
            }
        } catch {
            // Keep existing photo if picker fails.
        }
    }

    private static func draft(from profile: UserProfile?) -> (
        firstName: String,
        selectedCountry: String,
        customCountry: String,
        selectedCity: String,
        customCity: String,
        selectedState: String,
        customState: String,
        photoFileName: String?
    ) {
        guard let profile else {
            return (
                "",
                LocationOptions.unitedStates,
                "",
                LocationOptions.usCities.first ?? LocationOptions.writeMyOwn,
                "",
                LocationOptions.usStates.first ?? LocationOptions.writeMyOwn,
                "",
                nil
            )
        }

        let savedName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = (savedName.isEmpty || savedName == "Friend") ? "" : savedName
        let countryPick = locationDraft(value: profile.country, options: LocationOptions.countries)
        let isUS = LocationOptions.isUnitedStates(
            countryPick.selection == LocationOptions.writeMyOwn ? countryPick.custom : countryPick.selection
        )

        let cityPick: (selection: String, custom: String)
        let statePick: (selection: String, custom: String)
        if isUS {
            cityPick = locationDraft(value: profile.city, options: LocationOptions.usCities)
            statePick = locationDraft(value: profile.state, options: LocationOptions.usStates)
        } else {
            cityPick = (LocationOptions.writeMyOwn, profile.city)
            statePick = (LocationOptions.writeMyOwn, profile.state)
        }

        return (
            firstName,
            countryPick.selection,
            countryPick.custom,
            cityPick.selection,
            cityPick.custom,
            statePick.selection,
            statePick.custom,
            profile.localPhotoFileName
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

    private var resolvedCountry: String {
        if selectedCountry == LocationOptions.writeMyOwn {
            return customCountry.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedCountry
    }

    private var resolvedCity: String {
        if !isUSA || selectedCity == LocationOptions.writeMyOwn {
            return customCity.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedCity
    }

    private var resolvedState: String {
        if !isUSA || selectedState == LocationOptions.writeMyOwn {
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
