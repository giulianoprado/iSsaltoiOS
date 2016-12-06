/*
  iSsalto - v1.0
  Giuliano Barbosa Prado
  Henrique de Almeida Machado da Silveira
  Marcelo de Paula Ferreira Costa
*/

import UIKit

protocol InsertViewControllerDelegate: class {
  func novaOcorrencia(controller: InsertViewController, type: String, description: String)
}

class InsertViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  let possibleTypesDictionary = ["issalto_assalto":"Assalto", "issalto_roubo":"Roubo", "issalto_carro":"Roubo de carro", "issalto_estupro":"Estupro", "issalto_suspeito":"Suspeito"]
  
  
  @IBOutlet weak var descricao: UITextField!
  
  weak var delegateCreateNewOcurrence: InsertViewControllerDelegate!
  
  @IBOutlet weak var pickerViewTipos: UIPickerView!
  var tipoSelecionado = "isaslto_assalto"
  
  var tipos = ["issalto_assalto", "issalto_carro", "issalto_estupro", "issalto_roubo", "issalto_suspeito"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerViewTipos.delegate = self
    pickerViewTipos.dataSource = self
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    tipoSelecionado = tipos[row]
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return possibleTypesDictionary["\(tipos[row])"];
  }
  
  @IBAction func salvarClick(sender: AnyObject) {
    delegateCreateNewOcurrence?.novaOcorrencia(self, type: tipoSelecionado, description: descricao.text!)
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
