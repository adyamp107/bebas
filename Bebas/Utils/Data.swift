//
//  Data.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 16/06/25.
//

import Foundation

struct WordOption: Identifiable {
    let id = UUID()
    let word: String
    let description: String
    let image: String
}

struct WordData {
    static let options: [WordOption] = [
        WordOption(word: "Saya", description: "Ini description", image: "belajar_saya"),
        WordOption(word: "Makan", description: "Ini description", image: "belajar_makan"),
        WordOption(word: "Minum", description: "Ini description", image: "belajar_minum"),
        WordOption(word: "Bersama", description: "Ini description", image: "belajar_bersama"),
        WordOption(word: "Teman", description: "Ini description", image: "belajar_teman"),
        WordOption(word: "Selamat", description: "Ini description", image: "belajar_selamat"),
        WordOption(word: "Malam", description: "Ini description", image: "belajar_malam"),
        WordOption(word: "Pagi", description: "Ini description", image: "belajar_pagi"),
        WordOption(word: "Tidur", description: "Ini description", image: "belajar_tidur")
    ]
}
