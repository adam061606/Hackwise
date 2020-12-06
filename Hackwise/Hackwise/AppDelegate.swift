//
//  AppDelegate.swift
//  Hackwise
//
//  Created by Granwyn Tan on 5/12/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged(notification:)), name: UIApplication.significantTimeChangeNotification, object: nil)
        return true
    }
    
    @objc func dayChanged(notification: NSNotification){
        print("Next Day")
        if defaults.object(forKey: "stepsToday") != nil {
            defaults.setValue(defaults.integer(forKey: "stepsToday"), forKey: "totalSteps")
            defaults.removeObject(forKey: "stepsToday")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

