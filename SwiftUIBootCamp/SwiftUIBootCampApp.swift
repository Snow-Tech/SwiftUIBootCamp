//
//  SwiftUIBootCampApp.swift
//  SwiftUIBootCamp
//
//  Created by Brian Michael on 24/07/2022.
//

import SwiftUI

@main
struct SwiftUIBootCampApp: App {
    
    @State private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            //ContentView()
            LocationView()
                .environmentObject(vm)
            
        }
    }
}
