//
//  InsertViewController.swift
//  iSsalto
//
//  Created by Giuliano Barbosa Prado on 20/10/16.
//  Copyright © 2016 Ron Kliffer. All rights reserved.
//

import UIKit

protocol InsertViewControllerDelegate: class {
  func novaOcorrencia(controller: InsertViewController, type: String, title: String, description: String)
}

class InsertViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var descricao: UITextView!
  
  weak var delegateCreateNewOcurrence: InsertViewControllerDelegate!
  
  @IBOutlet weak var pickerViewTipos: UIPickerView!
  var tipoSelecionado = "isaslto_assalto"
  
  var tipos = ["issalto_assalto", "issalto_carro", "issalto_estupro", "issalto_roubo", "issalto_suspeito"]
  var tiposNome = ["Assalto", "Roubo", "Estupro", "Roubo de carro", "Suspeito"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerViewTipos.delegate = self
    pickerViewTipos.dataSource = self
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    tipoSelecionado = tipos[row]
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return tiposNome[row]
  }
  
  @IBAction func salvarClick(sender: AnyObject) {
    delegateCreateNewOcurrence?.novaOcorrencia(self, type: tipoSelecionado, title: "(20/10) Teste", description: descricao.text)
  }
  
  @IBAction func backClick(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return tipos.count
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  
  
}


// MARK: - TypesTableViewControllerDelegate
extension InsertViewController: InsertDelegate {
  func getTypes(controller: TypesTableViewController, didSelectTypes types: [String]) {
    tipos = controller.selectedTypes.sort()
  }
}
