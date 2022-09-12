
import UIKit
import MapKit
import Parse

class DetailsViewController: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var detailsImageView: UIImageView!
    @IBOutlet weak var detailsNameLabel: UILabel!
    @IBOutlet weak var detailsTypeLabel: UILabel!
    @IBOutlet weak var detailsAtmosphereLabel: UILabel!
    @IBOutlet weak var detailsMapveiw: MKMapView!
    
    var chosenPlaceId = ""
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsMapveiw.delegate = self
        getData()
    }
    
    func getData() {
        let query = PFQuery(className: "Places")
        query.whereKey("objectId", equalTo: chosenPlaceId)
        
        query.findObjectsInBackground{ [self](objects , error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "ERROR")
            }
            else{
                if objects != nil {
                    if objects!.count > 0 {
                        let chosenPlaceObject = objects![0]
                        
                        if let placeName = chosenPlaceObject.object(forKey: "name") as? String {
                            self.detailsNameLabel.text = placeName
                        }
                        if let placeType = chosenPlaceObject.object(forKey: "type") as? String {
                            self.detailsTypeLabel.text = placeType
                        }
                        if let placeAtmosphere = chosenPlaceObject.object(forKey: "atmosphere") as? String {
                            self.detailsAtmosphereLabel.text = placeAtmosphere
                        }
                        if let placeLatitude = chosenPlaceObject.object(forKey: "latitude") as? String {
                            
                            if let placeLatitude = Double(placeLatitude) {
                                self.chosenLatitude = placeLatitude
                            }
                        }
                        
                        if let placeLongitude = chosenPlaceObject.object(forKey: "longitude") as? String {
                            if let placeLongitude = Double(placeLongitude) {
                                self.chosenLongitude = placeLongitude
                            }
                        }
                        
                        if let imageData = chosenPlaceObject.object(forKey: "image") as? PFFileObject {
                            
                            imageData.getDataInBackground{(data, error) in
                                if error == nil {
                                    if data != nil {
                                        self.detailsImageView.image = UIImage(data: data!)
                                    }
                                }else{
                                    let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
                                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert.addAction(ok)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    let location  = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.035 , longitudeDelta: 0.035)
                    let region = MKCoordinateRegion(center: location, span: span)
                    
                    self.detailsMapveiw.setRegion(region, animated: true)
                    
                    let annonation = MKPointAnnotation()
                    annonation.coordinate = location
                    annonation.title = detailsNameLabel.text
                    annonation.subtitle = detailsTypeLabel.text
                    self.detailsMapveiw.addAnnotation(annonation)
                }
            }
        }
    }
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"

            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if self.chosenLatitude != 0 && self.chosenLongitude != 0 {
            
            let requestLocation = CLLocation(latitude: chosenLatitude, longitude: chosenLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placeMark ,error) in
                
                if let placeMarks = placeMark {
                    
                    if placeMark!.count > 0 {
                        
                        let mkPlaceMark = MKPlacemark(placemark: placeMark![0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.detailsNameLabel.text
                        
                        let launchOptions = [ MKLaunchOptionsDirectionsModeKey :  MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
}
