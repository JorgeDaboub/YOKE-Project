//
//  ContentView.swift
//  YOKE PROJECT
//
//  Created by Jorge Daboub on 7/28/20.
//  Copyright © 2020 Jorge Daboub. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weather = weatherData()
    
    func refresh() {
        weather.fetch()
    }
    
    var body: some View {
        VStack(spacing: 50) {
            Button(action:refresh) {
                Text("Refresh")
            }
            
            Text("""
                Simple Weather App
                Lat: \(String(format: "%.5f", weather.data.latitude))
                Long: \(String(format: "%.5f", weather.data.longitude))
                Timezone: \(weather.data.timezone)
                """)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(weather.data.hourly.data, id: \.time) { result in
                        Text("""
                            Date: \(result.dateReadable ?? "NA")
                            Time: \(result.timeReadable ?? "NA")
                            Temp: \(String(format: "%.2f", result.temperature)) °F
                            """)
                            .foregroundColor(.white)
                            .frame(width: 160, height: 160)
                            .background(Color.blue)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        ContentView()
    }
}
