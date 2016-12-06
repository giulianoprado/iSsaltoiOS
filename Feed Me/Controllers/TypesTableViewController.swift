/*
  iSsalto - v1.0
  Giuliano Barbosa Prado
  Henrique de Almeida Machado da Silveira
  Marcelo de Paula Ferreira Costa
*/

import UIKit

protocol TypesTableViewControllerDelegate: class {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String])
}
protocol InsertDelegate: class {
  func getTypes(controller: TypesTableViewController, didSelectTypes types: [String])
}


class TypesTableViewController: UITableViewController {
  
  let possibleTypesDictionary = ["issalto_assalto":"Assalto", "issalto_roubo":"Roubo", "issalto_carro":"Roubo de carro", "issalto_estupro":"Estupro", "issalto_suspeito":"Suspeito"]
  var selectedTypes: [String]!
  weak var delegate: TypesTableViewControllerDelegate!
  weak var delegateInsert: InsertDelegate!
  var sortedKeys: [String] {
    return possibleTypesDictionary.keys.sort()
  }
  
  // MARK: - Actions
  @IBAction func donePressed(sender: AnyObject) {
    delegate?.typesController(self, didSelectTypes: selectedTypes)
    delegateInsert?.getTypes(self, didSelectTypes: selectedTypes)
  }
  
  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return possibleTypesDictionary.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) 
    let key = sortedKeys[indexPath.row]
    let type = possibleTypesDictionary[key]!
    cell.textLabel?.text = type
    cell.imageView?.image = UIImage(named: key)
    cell.accessoryType = (selectedTypes!).contains(key) ? .Checkmark : .None
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let key = sortedKeys[indexPath.row]
    if (selectedTypes!).contains(key) {
      selectedTypes = selectedTypes.filter({$0 != key})
    } else {
      selectedTypes.append(key)
    }
    
    tableView.reloadData()
  }
}
