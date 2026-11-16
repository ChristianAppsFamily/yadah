import Foundation
import UIKit

enum ProfilePhotoStore {
    static let defaultFileName = "yadah_profile_photo.jpg"

    private static var directoryURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent("Yadah", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func fileURL(fileName: String = defaultFileName) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }

    static func loadImage(fileName: String?) -> UIImage? {
        guard let fileName, !fileName.isEmpty else { return nil }
        let url = fileURL(fileName: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func saveJPEG(_ image: UIImage, fileName: String = defaultFileName, quality: CGFloat = 0.82) -> String? {
        guard let data = image.jpegData(compressionQuality: quality) else { return nil }
        let url = fileURL(fileName: fileName)
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }

    static func delete(fileName: String?) {
        guard let fileName, !fileName.isEmpty else { return }
        try? FileManager.default.removeItem(at: fileURL(fileName: fileName))
    }
}
