//
//  LearnView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 12/06/25.
//

import SwiftUI

struct Learn2View: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Cara mempraktikkan kata")
                Text("Halooo")
                    .font(.title2)
                    .fontWeight(.bold)
                VStack {
                    Image("belajar_halo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Spacer()
                
                NavigationLink(destination: DictionaryView()) {
                    VStack {
                        Text("Berikutnya")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            .padding(24)
            .navigationTitle("Belajar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LearnView()
}
