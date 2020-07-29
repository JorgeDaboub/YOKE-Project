//
//  API.swift
//  YOKE PROJECT
//
//  Created by Jorge Daboub on 7/28/20.
//  Copyright © 2020 Jorge Daboub. All rights reserved.
//

import Foundation

// MARK: - Main
public struct weatherResponse: Codable {
    let latitude, longitude: Double
    let timezone: String
    var hourly: Hourly
    let offset: Int
    
    init() {
        self.latitude = 0
        self.longitude = 0
        self.timezone = ""
        self.offset = 0
        self.hourly = Hourly()
    }
}

// MARK: - Hourly
struct Hourly: Codable {
    let summary: String
    let icon: Icon
    var data: [Datum]
    
    init() {
        self.summary = ""
        self.icon = Icon.clearDay
        self.data = [Datum()]
    }
}

// MARK: - Datum
struct Datum: Codable {
    let time: Double
    var timeReadable: String?
    var dateReadable: String?
    //    let summary: String
    //    let icon: Icon
    //    let precipIntensity, precipProbability: Double
    //    let precipType: Icon?
    let temperature: Double
    //    let apparentTemperature, dewPoint, humidity: Double
    //    let pressure, windSpeed, windGust: Double
    //    let windBearing: Int
    //    let cloudCover: Double
    //    let uvIndex: Int
    //    let visibility, ozone: Double
    
    init() {
        self.time = 0
        self.temperature = 0
        self.timeReadable = ""
        self.dateReadable = ""
    }
}

enum Icon: String, Codable {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case rain = "rain"
}

// Add queries to URL
extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self,
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map
            { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}

// MARK: - Class Declaration
class weatherData: ObservableObject {
    /* API Class to fetch data */
    @Published var data = weatherResponse()
    
    // URL to Call
    let baseURL = URL(string: "https://api.darksky.net/forecast/d3fba72e83fc64768952cbf06ee6e5d1/38.978291,-76.495682")!
    
    // Queries to be added
    let query: [String: String] = [
        "exclude": "currently,minutely,daily,alerts,flags",
    ]
    
    init() {
        self.fetch()
    }
    
    func fetch() {
        var request = URLRequest(url: self.baseURL)
        
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error:  \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("HTTP Status code: \(response.statusCode)")
            }
            
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let decodedData = try? jsonDecoder.decode(weatherResponse.self,
                                                          from: data) {
                DispatchQueue.main.async {
                    self.data = decodedData
                    
                    // Change time to human readable
                    let dateFormatter = DateFormatter()
                    
                    for indx in self.data.hourly.data.indices {
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        self.data.hourly.data[indx].dateReadable = dateFormatter.string(from: Date(timeIntervalSince1970: self.data.hourly.data[indx].time))
                        
                        dateFormatter.dateFormat = "HH:mm"
                        self.data.hourly.data[indx].timeReadable = dateFormatter.string(from: Date(timeIntervalSince1970: self.data.hourly.data[indx].time))
                    }
                }
            }
            
        }
        task.resume()
    }
}
