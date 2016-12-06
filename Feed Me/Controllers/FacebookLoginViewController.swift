/*
  iSsalto - v1.0
  Giuliano Barbosa Prado
  Henrique de Almeida Machado da Silveira
  Marcelo de Paula Ferreira Costa
*/

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class FacebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {

  
  @IBOutlet weak var infoLabel: UILabel!
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // Do any additional setup after loading the view, typically from a nib.
    
    // Logar e obter dados
    if (FBSDKAccessToken.currentAccessToken() != nil)
    {
      
      let loginView : FBSDKLoginButton = FBSDKLoginButton()
      self.view.addSubview(loginView)
      loginView.center = self.view.center
      loginView.readPermissions = ["public_profile", "email", "user_friends"]
      loginView.delegate = self
      self.returnUserData()
    }
    else
    {
      let loginView : FBSDKLoginButton = FBSDKLoginButton()
      self.view.addSubview(loginView)
      loginView.center = self.view.center
      loginView.readPermissions = ["public_profile", "email", "user_friends"]
      loginView.delegate = self
    }
    
  }
  
  // Facebook Delegate Methods
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    print("User Logged In")
    
    if ((error) != nil)
    {
      // Process error
    }
    else if result.isCancelled {
      // Handle cancellations
    }
    else {
      // If you ask for multiple permissions at once, you
      // should check if specific permissions missing
      if result.grantedPermissions.contains("email")
      {
        // Do work
      }
      
      self.returnUserData()
    }
    
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    print("User Logged Out")
  }
  
  func returnUserData()
  {
    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"])
    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
      
      if ((error) != nil)
      {
        // Process error
        print("Error: \(error)")
      }
      else
      {
        
        print("fetched user: \(result)")
        let facebookId : NSString = result.valueForKey("id") as! NSString
        let userName : NSString = result.valueForKey("name") as! NSString
        print("User Name is: \(userName)")
        let userEmail : NSString = result.valueForKey("email") as! NSString
        print("User Email is: \(userEmail)")
        self.infoLabel.text = "Usuario conectado via Facebook! \n\t Nome do usuario: \(userName)\n\tID: \(facebookId)\n\tEmail: \(userEmail)"
      }
    })
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
