//
//  ViewController.swift
//  Assingment8
//
//  Created by user236597 on 4/1/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

        @IBOutlet weak var locationLabel: UILabel!
        @IBOutlet weak var weatherLabel: UILabel!
        @IBOutlet weak var uiImageView: UIImageView!
        @IBOutlet weak var temperatureLabel: UILabel!
        @IBOutlet weak var temperatureHumidityLabel: UILabel!
        @IBOutlet weak var temperatureWindSpeedLabel: UILabel!
        
        
        let GPSManager = CLLocationManager()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            GPSManager.delegate = self
            GPSManager.requestWhenInUseAuthorization()
        }
        
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            GPSManager.requestLocation()
        default:
            break
        }
       }
     
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                getDataFromAPI(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] result in
                    switch result {
                    case .success(let success):
                        DispatchQueue.main.async {
                            self?.updateUI(data: success)
                        }
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
        
        func updateUI(data: WeatherData) {
            locationLabel.text = data.name ?? ""
            weatherLabel.text = data.weather?.first?.description ?? ""
            if let weatherurl = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
                uiImageView.load(url: weatherurl)
            }
            temperatureHumidityLabel.text = "Humidity: \(data.main?.humidity ?? 0)%"
            temperatureWindSpeedLabel.text = "Wind: \(data.wind?.speed ?? 0)Km/h"
            temperatureLabel.text = "\(Int(data.main?.temp ?? 0))°C"
        }
        
        func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> ()) {
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=e37319c9d12742b2a2e894082672ea55&units=metric") else { return }
            URLSession.shared.dataTask(with: URLRequest(url: url)) { jsonData, _, error in
                guard let jsonData = jsonData else { return }
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }


    extension UIImageView {
     func load(url: URL) {
         DispatchQueue.global().async { [weak self] in
             if let data = try? Data(contentsOf: url) {
                 if let image = UIImage(data: data) {
                     DispatchQueue.main.async {
                         self?.image = image
                     }
                 }
             }
         }
     }
    }
