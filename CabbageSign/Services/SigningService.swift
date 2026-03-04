import Foundation
import Security

class SigningService {
    static func requiresPassword(p12Data: Data) -> Bool {
        let options: [String: Any] = [kSecImportExportPassphrase as String: ""]
        var items: CFArray?
        let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)
        return status == errSecAuthFailed
    }
}
