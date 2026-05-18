import Foundation
import Network

class FileServer: ObservableObject {
    private var listener: NWListener?
    private var fileURL: URL?
    
    @Published var serverURL: String?
    
    func start(with file: URL) {
        self.fileURL = file
        
        do {
            let listener = try NWListener(using: .tcp)
            self.listener = listener
            
            listener.newConnectionHandler = { connection in
                connection.start(queue: .global())
                self.handleConnection(connection)
            }
            
            listener.start(queue: .global())
            
            // Get local IP (simplified for MVP)
            if let ip = getWiFiAddress() {
                DispatchQueue.main.async {
                    self.serverURL = "http://\(ip):\(listener.port?.rawValue ?? 8080)/download"
                }
            }
        } catch {
            print("Failed to start server: \(error)")
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        serverURL = nil
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, let request = String(data: data, encoding: .utf8) {
                if request.contains("GET /download") {
                    self.sendFile(connection)
                } else {
                    connection.cancel()
                }
            }
        }
    }
    
    private func sendFile(_ connection: NWConnection) {
        guard let fileURL = fileURL,
              let fileData = try? Data(contentsOf: fileURL) else {
            connection.cancel()
            return
        }
        
        let filename = fileURL.lastPathComponent
        let fileSize = fileData.count
        
        let header = """
        HTTP/1.1 200 OK\r
        Content-Type: application/octet-stream\r
        Content-Disposition: attachment; filename="\(filename)"\r
        Content-Length: \(fileSize)\r
        Connection: close\r
        \r
        """
        
        connection.send(content: header.data(using: .utf8), completion: .contentProcessed { _ in
            connection.send(content: fileData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        })
    }
    
    // Helper to get WiFi IP address
    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == "en0" { // Usually WiFi
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
