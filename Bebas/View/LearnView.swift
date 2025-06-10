//
//  LearnView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI

struct LearnView: View {
    @StateObject var learnViewModel = LearnViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack {
                    HStack {
                        Text("Alfabet Bahasa Isyarat")
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<5) { _ in
                                VStack {
                                    
                                }
                                .frame(width: 50, height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                ScrollView {
                    HStack {
                        Text("Bahasa Isyarat Lainnya")
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(.top, 0.2)
            .padding(.horizontal)
            .navigationTitle("Belajar")
            .searchable(text: $learnViewModel.searchText)
        }
    }
}

#Preview {
    LearnView()
}
