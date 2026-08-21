import Foundation

actor OffDiskCache {
    private let folder: URL

    init(folder: URL) {
        self.folder = folder
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    func payload(for key: String) -> Data? {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    func store(_ data: Data, for key: String) {
        try? data.write(to: fileURL(for: key), options: .atomic)
    }

    private func fileURL(for key: String) -> URL {
        let safe = key
            .lowercased()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "+")
        var hash: UInt64 = 5381
        for byte in safe.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return folder.appendingPathComponent("off-\(String(hash, radix: 16)).json")
    }
}
