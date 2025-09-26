import Foundation
import UIKit


import SwiftUI
import OneSignalFramework


@main

class AppDelegate: UIResponder, UIApplicationDelegate {
  
    
   static var orientationLock =
   UIInterfaceOrientationMask.all

   func application(_ application: UIApplication,
   supportedInterfaceOrientationsFor window:
   UIWindow?) -> UIInterfaceOrientationMask {
   return AppDelegate.orientationLock
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       OneSignal.initialize("2271b7ea-2458-46c6-bae2-a5acf05c5f6a", withLaunchOptions: launchOptions)
       OneSignal.Notifications.requestPermission({ accepted in
           print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)

       return true
   }

   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
       return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }

   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
 
       
   }

    

   
   

}

