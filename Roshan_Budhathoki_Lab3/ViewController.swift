//
//  ViewController.swift
//  Roshan_Budhathoki_Lab3
//
//  Created by zoro on 2024-11-01.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var enterLocation: UITextField!
    @IBOutlet weak var showWeather: UIImageView!
    @IBOutlet weak var toggleTemperature: UISwitch!
    @IBOutlet weak var showLocation: UILabel!
    @IBOutlet weak var showTemperature: UILabel!
    
    var wholeWeatherData: weatherApiData?;
    var locationController = CLLocationManager();
    var weatherDetails: [Int: weatherDetailsData] = [:];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterLocation.delegate = self
        setIcons()
        addWeatherImage(colorName: "sun.horizon")
        locationController.delegate = self
        locationController.requestWhenInUseAuthorization()
        locationController.startUpdatingLocation()
    }
    
    @IBAction func searchLocationTap(_ sender: UIButton) {
        makeWeatherCall(locationDetails: enterLocation.text)
    }
    
    @IBAction func ownLocationTap(_ sender: UIButton) {
        locationController.requestWhenInUseAuthorization()
        locationController.startUpdatingLocation()
    }
    
    @IBAction func switchTemperature(_ sender: Any) {
        let isOn = toggleTemperature.isOn
        if let weatherData = wholeWeatherData {
            let temperatureFahrenheit = String(weatherData.current.temp_f)
            let temperatureCelsius = String(weatherData.current.temp_c)
            
            showTemperature.text = isOn ? "\(temperatureCelsius)°C" : "\(temperatureFahrenheit)°F"
        } else {
            print("Weather data not available")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true);
        makeWeatherCall(locationDetails: textField.text);
        return true
    }
    
    private func makeWeatherCall(locationDetails: String?) {
        guard let location = locationDetails, !location.isEmpty else {
            return
        }
        
        guard let authenticateUrl = authenticateWeather(query: location) else {
            return
        }
        
        let session = URLSession.shared
        var showCelcius = toggleTemperature.isOn;
        
        let apiTask = session.dataTask(with: authenticateUrl) { data, response, error in
            print("Making an API call")
            
            guard error == nil else {
                print("Received Error")
                return
            }
            
            guard let data = data else {
                print("Data not found")
                return
            }
            
            if let responseWeatherData = self.parseWeatherData(data: data) {
               
                let weatherCode = responseWeatherData.current.condition.code;
                let symbol = self.getIcons(code: weatherCode);
                let weatherCondition = responseWeatherData.current.condition.text;
                

                let locationName = responseWeatherData.location.name;
                let temperatureCelcius = responseWeatherData.current.temp_c;
                let fareheitTemperature = responseWeatherData.current.temp_f;
                
                self.wholeWeatherData = responseWeatherData;

                DispatchQueue.main.async {
                    self.weatherCondition.text = weatherCondition;
                    self.addWeatherImage(colorName: symbol ?? "");
                    self.showTemperature.text = showCelcius ? "\(temperatureCelcius)°C" : "\(fareheitTemperature)°F";
                    self.showLocation.text = locationName
                }
            }
        }
        apiTask.resume()
    }
    
    private func parseWeatherData(data: Data) -> weatherApiData? {
        let newDecoder = JSONDecoder()
        var weatherData: weatherApiData?

        do {
            weatherData = try newDecoder.decode(weatherApiData.self, from: data);
        } catch let decodingError {
            print("Error parsing weather data: \(decodingError)")
            return nil
        }
        return weatherData
    }
    
    private func authenticateWeather(query: String) -> URL? {
        guard let wholeURL = "https://api.weatherapi.com/v1/current.json?key=36af6cf8980a4e2b89350235220106&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else{
            return nil
        }
        return URL(string: wholeURL)
    }
    
    private func addWeatherImage(colorName: String) {
        let configuration = UIImage.SymbolConfiguration(paletteColors: [.systemOrange, .systemBrown, .systemRed])
        showWeather.preferredSymbolConfiguration = configuration
        showWeather.image = UIImage(systemName: colorName);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let currentLocation = locations.first {
                let latitude = currentLocation.coordinate.latitude
                let longitude = currentLocation.coordinate.longitude

                makeWeatherCall(locationDetails: "\(latitude),\(longitude)")
                
                locationController.stopUpdatingLocation()
            }
        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Failed to get user location: \(error)")
       }
    
    func setIcons(){
            let weatherData: [weatherDetailsData] = [
                weatherDetailsData(code: 1000, symbol: "sun.min.fill", day: "Sunny"),
                weatherDetailsData(code: 1003, symbol: "cloud.sun", day: "Partly cloudy"),
                weatherDetailsData(code: 1006, symbol: "cloud.fill", day: "Cloudy"),
                weatherDetailsData(code: 1009, symbol: "cloud.circle", day: "Overcast"),
                weatherDetailsData(code: 1030, symbol: "moon.dust.circle", day: "Mist"),
                weatherDetailsData(code: 1063, symbol: "cloud.drizzle", day: "Patchy rain possible"),
                weatherDetailsData(code: 1066, symbol: "cloud.snow", day: "Patchy snow possible"),
                weatherDetailsData(code: 1069, symbol: "cloud.sleet", day: "Patchy sleet possible"),
                weatherDetailsData(code: 1072, symbol: "thermometer.snowflake", day: "Patchy freezing drizzle possible"),
                weatherDetailsData(code: 1087, symbol: "cloud.bolt", day: "Thundery outbreaks possible"),
                weatherDetailsData(code: 1114, symbol: "wind.snow", day: "Blowing snow"),
                weatherDetailsData(code: 1117, symbol: "cloud.snow.fill", day: "Blizzard"),
                weatherDetailsData(code: 1135, symbol: "cloud.fog.fill", day: "Fog"),
                weatherDetailsData(code: 1147, symbol: "cloud.snow", day: "Freezing fog"),
                weatherDetailsData(code: 1150, symbol: "cloud.drizzle", day: "Patchy light drizzle"),
                weatherDetailsData(code: 1153, symbol: "cloud.drizzle.fill", day: "Light drizzle"),
                weatherDetailsData(code: 1168, symbol: "thermometer.snowflake", day: "Freezing drizzle"),
                weatherDetailsData(code: 1171, symbol: "thermometer.snowflake", day: "Heavy freezing drizzle"),
                weatherDetailsData(code: 1180, symbol: "cloud.drizzle", day: "Patchy light rain"),
                weatherDetailsData(code: 1183, symbol: "cloud.rain", day: "Light rain"),
                weatherDetailsData(code: 1186, symbol: "cloud.rain.fill", day: "Moderate rain at times"),
                weatherDetailsData(code: 1189, symbol: "cloud.rain.fill", day: "Moderate rain"),
                weatherDetailsData(code: 1192, symbol: "cloud.heavyrain", day: "Heavy rain at times"),
                weatherDetailsData(code: 1195, symbol: "cloud.heavyrain.fill", day: "Heavy rain"),
                weatherDetailsData(code: 1198, symbol: "thermometer.snowflake", day: "Light freezing rain"),
                weatherDetailsData(code: 1201, symbol: "cloud.sleet.fill", day: "Moderate or heavy freezing rain"),
                weatherDetailsData(code: 1204, symbol: "cloud.sleet", day: "Light sleet"),
                weatherDetailsData(code: 1207, symbol: "cloud.sleet.fill", day: "Moderate or heavy sleet"),
                weatherDetailsData(code: 1210, symbol: "cloud.snow", day: "Patchy light snow"),
                weatherDetailsData(code: 1213, symbol: "cloud.snow.fill", day: "Light snow"),
                weatherDetailsData(code: 1216, symbol: "cloud.snow", day: "Patchy moderate snow"),
                weatherDetailsData(code: 1219, symbol: "cloud.snow.fill", day: "Moderate snow"),
                weatherDetailsData(code: 1222, symbol: "snowflake.circle", day: "Patchy heavy snow"),
                weatherDetailsData(code: 1225, symbol: "snowflake.circle.fill", day: "Heavy snow"),
                weatherDetailsData(code: 1237, symbol: "cloud.hail", day: "Ice pellets"),
                weatherDetailsData(code: 1240, symbol: "cloud.rain", day: "Light rain shower"),
                weatherDetailsData(code: 1243, symbol: "cloud.heavyrain", day: "Moderate or heavy rain shower"),
                weatherDetailsData(code: 1246, symbol: "cloud.bolt.rain.fill", day: "Torrential rain shower"),
                weatherDetailsData(code: 1249, symbol: "cloud.sleet", day: "Light sleet showers"),
                weatherDetailsData(code: 1252, symbol: "cloud.sleet.fill", day: "Moderate or heavy sleet showers"),
                weatherDetailsData(code: 1255, symbol: "cloud.snow", day: "Light snow showers"),
                weatherDetailsData(code: 1258, symbol: "cloud.snow.fill", day: "Moderate or heavy snow showers"),
                weatherDetailsData(code: 1261, symbol: "cloud.hail", day: "Light showers of ice pellets"),
                weatherDetailsData(code: 1264, symbol: "cloud.hail.fill", day: "Moderate or heavy showers of ice pellets")
            ]
        let weatherDataDictionary: [Int: weatherDetailsData] = Dictionary(uniqueKeysWithValues: weatherData.map { ($0.code, $0) })
        
        self.weatherDetails = weatherDataDictionary;
    }
    
    func getIcons(code: Int) -> String? {
        let weatherData = self.weatherDetails;
        if let weatherInfo = weatherData[code] {
            return weatherInfo.symbol;
        }
        return nil
    }
}

struct weatherCondition: Decodable {
    let text: String
    let code: Int
}

struct currentData: Decodable {
    let temp_c: Double
    let temp_f: Double
    let condition: weatherCondition
}

struct location: Decodable {
    let name: String
    let country: String
    let region: String
}

struct weatherApiData: Decodable {
    let location: location
    let current: currentData
}

struct weatherDetailsData: Decodable {
    let code: Int
    let symbol: String
    let day: String
}
