import SwiftUI

struct ContentView: View {
    @StateObject private var fileServer = FileServer()
    @State private var isTargeted = false
    @State private var qrCodeImage: Image?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if let qrCode = qrCodeImage {
                    qrCode
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            // Reset on tap
                            fileServer.stop()
                            qrCodeImage = nil
                        }
                    
                    Text("Scan to Download")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top)
                } else {
                    BlackholeView()
                        .scaleEffect(isTargeted ? 1.2 : 1.0)
                        .animation(.spring(), value: isTargeted)
                }
            }
        }
        .frame(width: 300, height: 300)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                if let data = urlData as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        startServer(with: url)
                    }
                }
            }
            return true
        }
        .onChange(of: fileServer.serverURL) { newURL in
            if let urlString = newURL {
                qrCodeImage = QRCodeGenerator.generate(from: urlString)
            }
        }
    }
    
    private func startServer(with url: URL) {
        fileServer.stop()
        fileServer.start(with: url)
    }
}
