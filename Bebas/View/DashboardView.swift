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
//            VStack {
//                ZStack {
//                    CameraView()
//                        .frame(width: 400, height: 1000)
//                        .cornerRadius(12)
//                        .shadow(radius: 5)
//                        .padding([.bottom], 500)
//                    
//                }
//            }
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
                TabView {
                    DashboardImage(title: "beranda_iklan1")
                    DashboardImage(title: "beranda_iklan2")
                    DashboardImage(title: "beranda_iklan3")
                    DashboardImage(title: "beranda_iklan4")
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
                        NavigationLink(destination: Learn1View()) {
                            DashboardButton(title: "Belajar", image: "beranda_belajar", color: .green)
                        }
                        DashboardButton(title: "Praktik", image: "beranda_praktik", color: .blue)
                    }
                    HStack(spacing: 16) {
                        NavigationLink(destination: DictionaryView()) {
                            DashboardButton(title: "Kamus", image: "beranda_kamus", color: .orange)
                        }
                        DashboardButton(title: "Eja Kata", image: "beranda_ejakata", color: .red)
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
    
    func DashboardButton(title: String, image: String, color: Color) -> some View {
        VStack {
            Image(image)
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
