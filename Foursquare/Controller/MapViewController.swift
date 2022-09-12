
import UIKit
import MapKit
import Parse

class MapViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var mapView : MKMapView!
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonClicked))
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backButtonItem))
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer : UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touches = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            
            let annonation = MKPointAnnotation()
            annonation.coordinate = coordinates
            annonation.title = PlaceModel.sharedInstance.placeName
            annonation.subtitle = PlaceModel.sharedInstance.placeType
            self.mapView.addAnnotation(annonation)
            
            PlaceModel.sharedInstance.placeLatitude = String(coordinates.latitude)
            PlaceModel.sharedInstance.placeLongitude = String(coordinates.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func backButtonItem() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonClicked() {
        
        let model = PlaceModel.sharedInstance
        
        let object = PFObject(className: "Places")
        object["name"] = model.placeName
        object["type"] = model.placeType
        object["atmosphere"] = model.placeAtmosphere
        object["latitude"] = model.placeLatitude
        object["longitude"] =  model.placeLongitude
        
        if let imageData = PlaceModel.sharedInstance.placeImage.jpegData(compressionQuality: 0.5) {
            
            object["image"] = PFFileObject(name: "image.jpeg", data: imageData )
        }
        
        object.saveInBackground{(success , error ) in
            
            if error != nil {
                
                let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                self.performSegue(withIdentifier: "fromMapVCtoPlacesVC", sender: nil)
            }
        }
            
    }



}
