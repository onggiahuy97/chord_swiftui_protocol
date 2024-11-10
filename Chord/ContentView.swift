//
//  ContentView.swift
//  Chord
//
//  Created by Huy Ong on 11/10/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ChordRingView()
            Spacer()
            HStack {
                ScrollView {
                    Text(viewModel.nodeInfo ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity)
                Spacer()
                ScrollView {
                    HStack {
                        Button("Fetch Nodes") {
                            viewModel.fetchNodes()
                        }
                        
                        Button("New Node") {
                            viewModel.newNode()
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
