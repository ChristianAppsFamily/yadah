import Foundation

/// Public Supabase project credentials for Yadah (anon key is safe with RLS).
enum SupabaseConfig {
    static let projectURL = URL(string: "https://zolnfbmmrikibykvpqas.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvbG5mYm1tcmlraWJ5a3ZwcWFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ3MDk5ODAsImV4cCI6MjExMDI4NTk4MH0.xKnRwypC8m8-Mg3ktQJdbQ4Trlrzu7BX6uwAgRSNDUY"

    static let wallEntriesPath = "/rest/v1/wall_entries"
}
