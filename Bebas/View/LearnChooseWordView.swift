//
//  LearnChooseWordView.swift.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 13/06/25.
//

import SwiftUI

struct LearnChooseWordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State var data: [String] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(WordData.options) { word in
                        WordOptionView(word: word.word, description: word.description, image: word.image)
                    }

                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .searchable(
                text: $searchText,
                placement: sizeClass == .regular
                    ? .toolbar
                    : .navigationBarDrawer(displayMode: .always),
                prompt: "Search local note board"
            )
            .navigationTitle("Belajar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Dashboard")
                        }
                    }
                }
            }
        }
    }
    
    func WordOptionView(word: String, description: String, image: String) -> some View {
        NavigationLink(destination: LearnChoosenWordView(word: word, image: image)) {
            HStack(spacing: 16) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                VStack(alignment: .leading) {
                    Text(word)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray),
                alignment: .bottom
            )
        }
    }
}

#Preview {
    LearnChooseWordView()
}
