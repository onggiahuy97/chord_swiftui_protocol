//
//  Model.swift
//  Chord
//
//  Created by Huy Ong on 11/10/24.
//

import SwiftUI

// Node data structure
struct ChordNode: Identifiable {
    let id: Int
    var color: Color = .gray
    var position: CGPoint = .zero
}

// Define the Node model based on the JSON structure
struct Node: Decodable {
    let id: Int
    let successor: Int
}

struct NodesResponse: Decodable {
    let nodes: [Node]
}

class ViewModel: ObservableObject {
    @Published var nodes: [ChordNode] = []
    @Published var currentNode: ChordNode?
    @Published var nodeInfo: String?

    let nodeRadius: CGFloat = 18
    let ringDiameter: CGFloat = 300
    
    init() {
        self.fetchNodes()
    }
    
    func updateNodes() {
        let ids = nodes.map(\.id).sorted()
        var tempNodes: [ChordNode] = []
        let angleIncrement = 2 * .pi / Double(ids.count)
        let radius = ringDiameter / 2
        // Initialize each node's position and color based on its index
        for (index, id) in ids.enumerated() {
            let angle = angleIncrement * Double(index)
            let x = radius + cos(angle) * radius
            let y = radius + sin(angle) * radius
            let position = CGPoint(x: x, y: y)
            let color = Color.gray
            tempNodes.append(ChordNode(id: id, color: color, position: position))
        }
        
        DispatchQueue.main.async {
            self.nodes = tempNodes
        }
        
    }
    
    func fetchNodeInfo(for id: Int) {
        guard let url = URL(string: "http://127.0.0.1:5000/info/\(id)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching node info: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Convert data to string to see raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.nodeInfo = jsonString
                    self.currentNode = self.nodes.first(where: { $0.id == id })
                }
            } else {
                print("Could not convert data to string")
            }
        }.resume()
    }
    
    func newNode() {
        guard let url = URL(string: "http://127.0.0.1:5000/join") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating new node: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("New node created:", jsonString)
                }
            } else {
                print("Could not convert data to string")
            }
            
            self.fetchNodes()
        }.resume()
    }
    
    func fetchNodes() {
        guard let url = URL(string: "http://127.0.0.1:5000/nodes") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching nodes: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(NodesResponse.self, from: data)
                
                // Update the nodes on the main thread
                DispatchQueue.main.async {
                    self.nodes = decodedResponse.nodes.map(\.id).map { ChordNode(id: $0) }
                    self.updateNodes()
                }
            } catch {
                print("Error decoding nodes: \(error)")
            }
        }.resume()
    }

}
