import SwiftUI
import CoreImage.CIFilterBuiltins

class QRCodeGenerator {
    static func generate(from string: String) -> Image? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return Image(decorative: cgImage, scale: 1.0, orientation: .up)
            }
        }
        return nil
    }
}
