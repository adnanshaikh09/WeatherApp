//
//  ViewController.swift
//  Lab4
//
//  Created by Adnan Shaikh on 2024-07-16.
//

import UIKit

import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var citiesButton: UIButton!
    
    @IBOutlet weak var temperatureToggle: UISegmentedControl!
    
    var weatherData: [WeatherResponse] = []
    var isCelsius: Bool = true
    var locationManager: CLLocationManager!

    let weatherSymbols: [Int: String] = [
        1000: "sun.max",         // Clear/Sunny
        1003: "cloud.sun",       // Partly Cloudy
        1006: "cloud",           // Cloudy
        1009: "smoke",           // Overcast
        1030: "cloud.fog",       // Mist
        1063: "cloud.drizzle",   // Patchy rain possible
        1066: "cloud.snow",      // Patchy snow possible
        1069: "cloud.sleet",     // Patchy sleet possible
        1072: "cloud.hail",      // Patchy freezing drizzle possible
        1087: "cloud.bolt",      // Thundery outbreaks possible
        1114: "wind.snow",       // Blowing snow
        1117: "snow",            // Blizzard
        1135: "cloud.fog",       // Fog
        1147: "cloud.fog.fill",  // Freezing fog
        1150: "cloud.drizzle",   // Patchy light drizzle
        1153: "cloud.drizzle",   // Light drizzle
        1168: "cloud.hail",      // Freezing drizzle
        1171: "cloud.hail.fill", // Heavy freezing drizzle
        1180: "cloud.rain",      // Patchy light rain
        1183: "cloud.rain",      // Light rain
        1186: "cloud.heavyrain", // Moderate rain at times
        1189: "cloud.heavyrain", // Moderate rain
        1192: "cloud.heavyrain.fill", // Heavy rain at times
        1195: "cloud.heavyrain.fill", // Heavy rain
        1198: "cloud.hail",      // Light freezing rain
        1201: "cloud.hail.fill", // Moderate or heavy freezing rain
        1204: "cloud.sleet",     // Light sleet
        1207: "cloud.sleet.fill",// Moderate or heavy sleet
        1210: "snowflake",       // Patchy light snow
        1213: "snowflake.circle.fill", // Light snow
        1216: "snowflake",       // Patchy moderate snow
        1219: "snowflake.circle.fill", // Moderate snow
        1222: "snowflake",       // Patchy heavy snow
        1225: "snowflake.circle.fill", // Heavy snow
        1237: "cloud.hail.fill", // Ice pellets
        1240: "cloud.rain",      // Light rain showers
        1243: "cloud.heavyrain.fill", // Moderate or heavy rain showers
        1246: "cloud.heavyrain.fill", // Torrential rain shower
        1249: "cloud.sleet",     // Light sleet showers
        1252: "cloud.sleet.fill",// Moderate or heavy sleet showers
        1255: "snowflake",       // Light snow showers
        1258: "snowflake.circle.fill", // Moderate or heavy snow showers
        1261: "cloud.hail.fill", // Light showers of ice pellets
        1264: "cloud.hail.fill", // Moderate or heavy showers of ice pellets
        1273: "cloud.bolt.rain.fill", // Patchy light rain with thunder
        1276: "cloud.bolt.rain.fill", // Moderate or heavy rain with thunder
        1279: "cloud.bolt.rain", // Patchy light snow with thunder
        1282: "cloud.bolt.rain.fill"  // Moderate or heavy snow with thunder
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting background image
        let backgroundImage = UIImage(named: "background")
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        // Adding constraints
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        weatherConditionImage.image = UIImage(systemName: "sun.min")
        searchTextField.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Set up temperature toggle
        temperatureToggle.addTarget(self, action: #selector(toggleTemperature), for: .valueChanged)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        onSearchTapped(UIButton())
        return true
    }
    
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location = locations.first {
             let lat = location.coordinate.latitude
             let lon = location.coordinate.longitude
             loadWeather(lat: lat, lon: lon)
         }
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("Failed to get user location: \(error.localizedDescription)")
     }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    @IBAction func onCitiesTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showCities", sender: self)
    }
    
    @objc func toggleTemperature() {
        isCelsius.toggle()
        updateTemperatureDisplay()
    }
    
    private func updateTemperatureDisplay() {
         if let weather = weatherData.last {
             let temperature = isCelsius ? weather.current.temp_c : weather.current.temp_f
             let unit = isCelsius ? "C" : "F"
             temperatureLabel.text = "\(temperature)°\(unit)"
         }
     }
     
     private func loadWeather(search: String? = nil, lat: Double? = nil, lon: Double? = nil) {
         var urlString: String?
         if let search = search {
             urlString = getURL(query: search)
         } else if let lat = lat, let lon = lon {
             let baseUrl = "https://api.weatherapi.com/v1/"
             let currentEndpoint = "current.json"
             let apiKey = "47687f1ae282442481941826241707"
             urlString = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(lat),\(lon)"
         }
         
         guard let url = URL(string: urlString ?? "") else {
             print("could not get url")
             return
         }
         
         // Step 2: create URLSession
         let session = URLSession.shared
         
         // Step 3: Create a task for session
         let dataTask = session.dataTask(with: url) { data, response, error in
             // Network call finished
             print("Network call complete")
             
             guard error == nil else {
                 print("Received error")
                 return
             }
             
             guard let data = data else {
                 print("No data found")
                 return
             }
             
             if let weatherResponse = self.parseJson(data: data) {
                 print(weatherResponse.location.name)
                 print(weatherResponse.current.temp_c)
                 
                 DispatchQueue.main.async {
                     self.locationLabel.text = weatherResponse.location.name
                     self.weatherData.append(weatherResponse)
                     self.updateTemperatureDisplay()
                     
                     // Update weather condition image
                     if let symbolName = self.weatherSymbols[weatherResponse.current.condition.code] {
                         self.weatherConditionImage.image = UIImage(systemName: symbolName)
                     }
                 }
             }
         }
         
         // Step 4: start the task
         dataTask.resume()
     }
     
     private func getURL(query: String) -> String {
         let baseUrl = "https://api.weatherapi.com/v1/"
         let currentEndpoint = "current.json"
         let apiKey = "47687f1ae282442481941826241707"
         return "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
     }
     
     private func parseJson(data: Data) -> WeatherResponse? {
         let decoder = JSONDecoder()
         
         var weather: WeatherResponse?
         do {
             weather = try decoder.decode(WeatherResponse.self, from: data)
         } catch {
             print("Error decoding")
         }
         return weather
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showCities" {
             let destinationVC = segue.destination as! CitiesViewController
             destinationVC.weatherData = self.weatherData
         }
     }
 }

 struct WeatherResponse: Decodable {
     let location: Location
     let current: Weather
 }

 struct Location: Decodable {
     let name: String
 }

 struct Weather: Decodable {
     let temp_c: Float
     let temp_f: Float
     let condition: WeatherCondition
 }

 struct WeatherCondition: Decodable {
     let text: String
     let code: Int
 }
