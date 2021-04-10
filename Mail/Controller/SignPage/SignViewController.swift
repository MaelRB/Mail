//
//  SignViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 08/04/2021.
//

import UIKit

class SignViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        silentAuthentication()
    }
    
    @IBAction func signButtonTapped(_ sender: Any) {
        interactiveAuthentication()
    }
    
    private func silentAuthentication() {
        AuthenticationManager.instance.getTokenSilently {
            (token: String?, error: Error?) in
            
            DispatchQueue.main.async {
                
                guard let _ = token, error == nil else {
                    // If there is no token or if there's an error,
                    // no user is signed in, so stay here
                    return
                }
                
                // Since we got a token, a user is signed in
                // Go to welcome page
//                self.performSegue(withIdentifier: "userSignedIn", sender: nil)
            }
        }
    }
    
    private func interactiveAuthentication() {
        // Do an interactive sign in
        AuthenticationManager.instance.getTokenInteractively(parentView: self) {
            (token: String?, error: Error?) in
            
            DispatchQueue.main.async {
                
                guard let _ = token, error == nil else {
                    // Show the error and stay on the sign-in page
                    let alert = UIAlertController(title: "Error signing in",
                                                  message: error.debugDescription,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                // Signed in successfully
                // Go to welcome page
                self.performSegue(withIdentifier: "userSignedIn", sender: nil)
            }
        }
    }
    

}
