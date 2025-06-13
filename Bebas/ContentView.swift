//
//  ContentView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("firstTimeOpenBebasApp") var firstTimeOpenBebasApp: Bool = false
    
    var body: some View {
        NavigationStack {
            if !firstTimeOpenBebasApp {
                DashboardView()
            } else {
                DashboardView()
            }
        }
    }
    
}

#Preview {
    ContentView()
}
