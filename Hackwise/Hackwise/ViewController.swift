//
//  ViewController.swift
//  Hackwise
//
//  Created by Adam Tan on 5/12/20.
//

import UIKit
import HealthKit

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
    }
}
//extension UIColor {
//    const pink = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
//}
let healthStore = HKHealthStore()

let defaults = UserDefaults.standard

class ViewController: UIViewController {

    @IBOutlet weak var welcomeBG: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    var goalSteps: Int = 10000
//    @IBOutlet weak var CircularProgress: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateText.text = "\(Calendar.current.component(.day, from: Date())) \(Date().monthAsString()), \(Calendar.current.component(.year, from: Date()))"
        let cp = CircularProgressView(frame: CGRect(x: 80.0, y: 80.0, width: 300.0, height: 300.0))
        cp.trackColor = UIColor.systemGray4
        cp.progressColor = UIColor.systemBlue
        cp.tag = 1
        self.view.addSubview(cp)
        cp.center.x = self.view.center.x
        cp.center.y = self.view.center.y+40
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
        welcomeBG.layer.cornerRadius = 30
        welcomeBG.layer.masksToBounds = true
        //        CircularProgress.trackColor = UIColor.white
//        CircularProgress.progressColor = UIColor.purple
//        CircularProgress.setProgressWithAnimation(duration: 1.0, value: 0.3)
        if let stepTarget = defaults.integer(forKey: "stepTarget") {
            goalSteps = stepTarget
        } else {
            goalSteps = 10000
        }
        // Access Step Count
        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]
        // Check for Authorization
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            if (bool) {
                // Authorization Successful
                self.getTodaysSteps { (result) in
                    DispatchQueue.main.async {
                        let stepCount = String(Int(result))
                        print(stepCount)
                        self.stepsLabel.text = String(stepCount)
                    }
                }
            } // end if
        }
    }
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }
    
    @objc func animateProgress() {
        let cP = self.view.viewWithTag(1) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 1.0, value: 0.7)
    }


}


