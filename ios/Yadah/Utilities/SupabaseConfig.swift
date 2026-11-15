import Foundation

/// Public Supabase project credentials (anon key is safe with RLS).
enum SupabaseConfig {
    static let projectURL = URL(string: "https://cftzaeoqkepvvnfavphw.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmdHphZW9xa2VwdnZuZmF2cGh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5NTkyMjYsImV4cCI6MjA5NjUzNTIyNn0.34ds8QR0VjFpWkYPDhQAc4irHeaZe0iGxROkAcAsqHs"

    static let wallEntriesPath = "/rest/v1/wall_entries"
}
