//
//  MapViewController.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit

class MapViewController: UIViewController, GMSMapViewDelegate {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var accountButton: UIBarButtonItem!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  
  let numberToNameDictionary = [0:"issalto_assalto", 1:"issalto_roubo", 2:"issalto_carro", 3:"issalto_estupro", 4:"issalto_suspeito"]
  let nameToNumberDictionary = ["issalto_assalto":0, "issalto_roubo":1, "issalto_carro":2, "issalto_estupro":3, "issalto_suspeito":4]
  let possibleTypesDictionary = ["issalto_assalto":"Assalto", "issalto_roubo":"Roubo", "issalto_carro":"Roubo de carro", "issalto_estupro":"Estupro", "issalto_suspeito":"Suspeito"]
  var searchedTypes = ["issalto_assalto", "issalto_carro", "issalto_estupro", "issalto_roubo", "issalto_suspeito"]
  
  var markers = [GMSMarker]()
  var circ = GMSCircle(position:  CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 500)

  var lastSelectedPos = CLLocationCoordinate2D()
  var insertController = InsertViewController()
  var opened = false
  
  override func viewDidAppear(animated: Bool) {
    loadDataOnline()
    for marker in markers {
      var filtered = true
      for element in searchedTypes {
        if marker.icon == UIImage(named: element) {
          filtered = false
        }
      }
      if (filtered) {
        marker.map = nil
      } else {
        marker.map = mapView
      }
    }
    
    
    // FACEBOOK:
    if (FBSDKAccessToken.currentAccessToken() != nil)
    {
      // User is already logged in, do work such as go to next view controller.
      
      // Or Show Logout Button
      self.setUserDataOnScreen()
    }
    else
    {
      self.accountButton.title = "Desconectado"
    }
    
  }
  
  
  func setUserDataOnScreen()
  {
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
      
      if ((error) != nil)
      {
        // Process error
        print("Error: \(error)")
      }
      else
      {
        let userName : NSString = result.valueForKey("name") as! NSString
        self.accountButton.title = "\(userName)"
        print(FBSDKAccessToken.currentAccessToken().tokenString)
      }
    })
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.myLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.delegate = self
    
    
    mapView.camera = GMSCameraPosition.cameraWithLatitude(-22.0058691141315,
      longitude: -47.895916365087, zoom: 16)
    
    
    
    circ.map = mapView
    //generateSamples()
    
    //let circleCenter = CLLocationCoordinate2D(latitude: 10, longitude: 10)
    //let circ = GMSCircle(position: circleCenter, radius: 1000)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
    if segue.identifier == "Insert" {
      let navigationController = segue.destinationViewController as! UINavigationController
      insertController = navigationController.topViewController as! InsertViewController
      insertController.delegateCreateNewOcurrence = self
      opened = true
    }
  }
  
  
  func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    if (FBSDKAccessToken.currentAccessToken() != nil) {
      lastSelectedPos = coordinate
      self.performSegueWithIdentifier("Insert", sender: self)
    } else {
      let alert = UIAlertController(title: "Usuário desconectado!", message: "Clique em conectar para fazer login com o Facebook e criar sua notificação!", preferredStyle: UIAlertControllerStyle.Alert)
      
      self.presentViewController(alert, animated: true, completion: nil)
      alert.addAction(UIAlertAction(title: "Fazer login", style: .Default, handler: { action in
        self.performSegueWithIdentifier("loginSegue", sender: self)
      }))
      alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
    }
  }
  
  func insertMarkOnline (type: String, coordinate: CLLocationCoordinate2D, title: String, description: String) {
    let request = NSMutableURLRequest(URL: NSURL(string: "http://issalto.herokuapp.com/inserirOcorrencia/")!)
    request.HTTPMethod = "POST"
    /* formata a data */
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = formatter.stringFromDate(NSDate())
    /* cria a string do post */
    let postString = "posx=\(coordinate.latitude)&posy=\(coordinate.longitude)&timestamp=\(timestamp)&description=\(description)&type=\(nameToNumberDictionary[type]!)&username=Cassio"
    print(postString)
    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      guard error == nil && data != nil else {                                                          // check for fundamental networking error
        print("error=\(error)")
        return
      }
      
      if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
        print("statusCode should be 200, but is \(httpStatus.statusCode)")
        print("response = \(response)")
      }
      
      let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
    }
    task.resume()
  }
  var arrRes = [[String:AnyObject]]()
  func loadDataOnline () {
    Alamofire.request(.GET, "http://issalto.herokuapp.com/ocorrencias/u=Cassio").responseJSON { (req, res, json) -> Void in
      if (json.value == nil) {
        NSLog("Erro ao ler os dados!")
        return
      }
      let swiftyJsonVar = JSON(json.value!)
      
      for (_,value):(String,JSON) in swiftyJsonVar {
        self.createMarker(self.numberToNameDictionary[Int(String(value["type"]))!]!, coordinate: CLLocationCoordinate2D(latitude: Double(String(value["posx"]))!, longitude: Double(String(value["posy"]))!), title: String(value["username"]), description: String(value["description"]))
      }
      if let resData = swiftyJsonVar["0"].arrayObject {
        self.arrRes = resData as! [[String:AnyObject]]
      }
      if self.arrRes.count > 0 {
        for elem in self.arrRes {
          print(">\(elem)<")
        }
      }
      else
      {
        print("VAZIO!!")
      }
    }
  
  
  }

  func createMarker (type: String, coordinate: CLLocationCoordinate2D, title: String, description: String) {
    let newMarker = GMSMarker(position: coordinate)
    newMarker.title = title
    newMarker.icon = UIImage(named: type)
    newMarker.map = mapView
    newMarker.snippet = description
    newMarker.appearAnimation = kGMSMarkerAnimationPop
    markers.append(newMarker)
  }
  
  func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    changeCircleRegion(coordinate)
  }
  
  func changeCircleRegion (coordinate: CLLocationCoordinate2D) {
    circ.position = coordinate
    circ.radius = 500
    //circ.fillColor = UIColor.blueColor()
    
  }
  
  
  func generateSamples() {
    createMarker("issalto_assalto", coordinate: CLLocationCoordinate2D(latitude: -22.0058691141315, longitude: -47.895916365087), title: "(12/10) Assalto a mão armada", description: "Descrição: estava saindo da faculdade, quando fui abordado por dois homens negros, de estatura baixa, armados, que levaram meu celular");
    createMarker("issalto_carro", coordinate: CLLocationCoordinate2D(latitude: -22.0036546032568, longitude: -47.8962184488773), title: "(11/10) Roubo de carro", description: "Descrição: deixei o carro parado na rua. Quando voltei, o som e o vidro não estavam mais lá");
    createMarker("issalto_roubo", coordinate: CLLocationCoordinate2D(latitude: -22.0025852594009, longitude: -47.8984289243817), title: "(11/10) Roubo de carro", description: "Descrição: enfiaram a mão no meu bolso e levaram meu celular! Não vi nem o ladrão!");
    createMarker("issalto_estupro", coordinate: CLLocationCoordinate2D(latitude: -22.0114509330969, longitude: -47.8973258659244), title: "(10/10) Estupro", description: "Descrição: estava saindo de uma festa, quando fui abordado por dois homens, que me puxaram para o canto e abusaram de mim");
    createMarker("issalto_suspeito", coordinate: CLLocationCoordinate2D(latitude: -22.0104689940198, longitude: -47.8982639685273), title: "(11/10) Suspeito", description: "Descrição: há um homem estranho parado na rua! Tomem cuidado!");
    createMarker("issalto_assalto", coordinate: CLLocationCoordinate2D(latitude: -22.011464609946, longitude: -47.895961292088), title: "Assalto a mão armada", description: "Descrição: fui assaltado por um homem com uma faca");
    
  }
  
  // FACEBOOK FUNCTIONS
  
  
  
  
  
//  func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//    marker.position = coordinate
//    print(coordinate);
//  }
}





extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension MapViewController: InsertViewControllerDelegate {
  func novaOcorrencia(controller: InsertViewController, type: String, title: String, description: String) {
    print("AAAA")
    insertMarkOnline(type, coordinate: lastSelectedPos, title: title, description: "Descrição: \(description)");
    createMarker(type, coordinate: lastSelectedPos, title: title, description: "Descrição: \(description)");
    print("Pimba")
    dismissViewControllerAnimated(true, completion: nil)
  }
}


