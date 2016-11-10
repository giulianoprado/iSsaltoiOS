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

class MapViewController: UIViewController, GMSMapViewDelegate {
  
  @IBOutlet weak var mapView: GMSMapView!
  
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["issalto_assalto", "issalto_carro", "issalto_estupro", "issalto_roubo", "issalto_suspeito"]
  
  var markers = [GMSMarker]()
  var circ = GMSCircle(position:  CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 500)

  var lastSelectedPos = CLLocationCoordinate2D()
  var insertController = InsertViewController()
  var opened = false
  
  override func viewDidAppear(animated: Bool) {
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
    if (opened){
      createMarker(insertController.tipoSelecionado, coordinate: lastSelectedPos, title: "(21/10) Teste", description: insertController.descricao.text);
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    
    
    mapView.camera = GMSCameraPosition.cameraWithLatitude(-22.0058691141315,
      longitude: -47.895916365087, zoom: 16)
    
    
    circ.map = mapView
    generateSamples()
    
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
      opened = true
    }
  }
  
  
  func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    //createMarker("issalto_assalto", coordinate: coordinate, title: "(14/10) Assalto de teste", description: "Descrição: assalto de número \(markers.count)")
    self.performSegueWithIdentifier("Insert", sender: self)
    lastSelectedPos = coordinate
    print(coordinate);
    print(searchedTypes);
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
  
//  func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//    marker.position = coordinate
//    print(coordinate);
//  }
}

// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
  }
}


extension MapViewController: CreateNewOcurrence {
  func novaOcorrencia(controller: InsertViewController, type: String, title: String, description: String) {
    print("AAAA")
    createMarker(type, coordinate: lastSelectedPos, title: "(21/10) Teste", description: "Descrição: \(description)");
    print("Pimba")
  }
}