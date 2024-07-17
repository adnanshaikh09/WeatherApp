import UIKit

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var weatherData: [WeatherResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let weather = weatherData[indexPath.row]
        
        cell.textLabel?.text = "\(weather.location.name): \(weather.current.temp_c)°C / \(weather.current.temp_f)°F"
        cell.imageView?.image = UIImage(systemName: "sun.min") // Placeholder image, will update based on condition
        
        return cell
    }
    
    @IBAction func onBackButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
