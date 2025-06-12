//
//  DashboardView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI
import AVKit
import WebKit

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Selamat datang di")
                        .font(.title2)
                    Text("BEBAS")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                Text("Apa yang ingin kamu pelajari hari ini?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(.systemGray))
                    .font(.subheadline)
//                Spacer()
//                    .frame(height: 8)

                TabView {
                    DashboardImage(title: "HomeImage1")
                    DashboardImage(title: "HomeImage1")
                    DashboardImage(title: "HomeImage1")
                    DashboardImage(title: "HomeImage1")
                }
                .frame(height: 180)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle())
                .cornerRadius(10)
                
                Spacer()
                    .frame(height: 24)
                VStack(spacing: 16) {
                    HStack {
                        Text("Aktivitas di Bebas")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack(spacing: 16) {
                        DashboardButton(title: "Belajar", color: .green)
                        DashboardButton(title: "Praktik", color: .blue)
                    }
                    HStack(spacing: 16) {
                        NavigationLink(destination: DictionaryView()) {
                            DashboardButton(title: "Kamus", color: .orange)
                        }
                        DashboardButton(title: "Eja Kata", color: .red)
                    }
                }

                
                


                
            }
            .padding(24)
        }
    }
    
    func DashboardImage(title: String) -> some View {
        HStack {
            Image(title)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
    }
    
    func DashboardButton(title: String, color: Color) -> some View {
        VStack {
            Image(title)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 130)
            Spacer()
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 2)
        )
    }
}

#Preview {
    ContentView()
}
