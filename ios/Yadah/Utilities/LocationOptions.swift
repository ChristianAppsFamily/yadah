import Foundation

enum LocationOptions {
    static let writeMyOwn = "Write my own"
    static let unitedStates = "United States"

    static let countries: [String] = [
        "United States", "Canada", "United Kingdom", "Australia", "New Zealand",
        "Ireland", "South Africa", "Nigeria", "Kenya", "Ghana", "India",
        "Philippines", "Singapore", "Malaysia", "Indonesia", "Japan",
        "South Korea", "China", "Taiwan", "Hong Kong", "Brazil", "Mexico",
        "Argentina", "Colombia", "Chile", "Peru", "Germany", "France",
        "Spain", "Italy", "Portugal", "Netherlands", "Belgium", "Switzerland",
        "Austria", "Sweden", "Norway", "Denmark", "Finland", "Poland",
        "Romania", "Ukraine", "Russia", "Turkey", "Israel", "United Arab Emirates",
        "Saudi Arabia", "Egypt", "Morocco", "Jamaica", "Trinidad and Tobago",
        "Bahamas", "Barbados", "Dominican Republic", "Puerto Rico", "Costa Rica",
        "Panama", "Guatemala", "Honduras", "El Salvador", "Nicaragua",
        writeMyOwn
    ]

    static let usStates: [String] = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming", "Washington DC",
        writeMyOwn
    ]

    static let usCities: [String] = [
        "Atlanta", "Austin", "Baltimore", "Boston", "Charlotte", "Chicago",
        "Cleveland", "Columbus", "Dallas", "Denver", "Detroit", "Houston",
        "Indianapolis", "Jacksonville", "Kansas City", "Las Vegas",
        "Los Angeles", "Louisville", "Memphis", "Miami", "Milwaukee",
        "Minneapolis", "Nashville", "New Orleans", "New York", "Oklahoma City",
        "Orlando", "Philadelphia", "Phoenix", "Pittsburgh", "Portland",
        "Raleigh", "Sacramento", "San Antonio", "San Diego", "San Francisco",
        "San Jose", "Seattle", "St. Louis", "Tampa", "Washington",
        writeMyOwn
    ]

    static func isUnitedStates(_ country: String) -> Bool {
        let c = country.trimmingCharacters(in: .whitespacesAndNewlines)
        return c == unitedStates || c == "USA" || c == "US"
    }
}
