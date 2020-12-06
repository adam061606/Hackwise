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

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 25 }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize)}

    func boldGreen(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor : UIColor.systemGreen
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func boldRed(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor : UIColor.systemRed
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func boldBlue(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor : UIColor.systemBlue
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func blackHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func underlined(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
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
    @IBOutlet weak var stepsTotalLabel: UILabel!
    @IBOutlet weak var goals: UIButton!
    
    var goalSteps: Int = 10000
    var steps = Int()
    var totalStepsAllTime = Int()
//    @IBOutlet weak var CircularProgress: CircularProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        goals.layer.cornerRadius = 10
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        let userCalendar = Calendar.current
        let currentDateString: String = dateFormatter.string(from: date/*userCalendar.date(from: dateComponents)!*/)
        dateText.text = currentDateString
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
        stepsLabel.center.x = self.view.center.x
        stepsLabel.center.y = self.view.center.y+40
        //        CircularProgress.trackColor = UIColor.white
//        CircularProgress.progressColor = UIColor.purple
//        CircularProgress.setProgressWithAnimation(duration: 1.0, value: 0.3)
        if defaults.object(forKey: "stepsTarget") != nil {
            goalSteps = defaults.integer(forKey: "stepsTarget")
        } else {
            goalSteps = 10000
            defaults.setValue(goalSteps, forKey: "stepsTarget")
        }
        // Access Step Count
        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]
        // Check for Authorization
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            if (bool) {
                // Authorization Successful
                self.getTodaysSteps { (result) in
                    DispatchQueue.main.async {
//                        let stepCount = String(Int(result))
//                        print(stepCount)
                        self.steps = Int(result)
                        self.stepsLabel.attributedText =
                            self.steps >= self.goalSteps ? NSMutableAttributedString().boldGreen("\(self.steps)").normal("/").boldBlue("\(self.goalSteps)").normal("\nsteps") : NSMutableAttributedString().boldRed("\(self.steps)").normal("/").boldBlue("\(self.goalSteps)").normal("\nsteps")
                        defaults.setValue(self.steps, forKey: "stepsToday")
                        defaults.setValue(self.steps, forKey: "totalSteps")
                        self.totalStepsAllTime = defaults.integer(forKey: "totalSteps")
                        self.stepsTotalLabel.text = self.totalStepsAllTime > 1 ? "You have walked \(self.totalStepsAllTime) steps so far" : "You have walked \(self.totalStepsAllTime) step so far"
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
        Int() < self.goalSteps ?
            cP.setProgressWithAnimation(duration: 1.0, value: Float(Double(self.steps)/Double(self.goalSteps))) : cP.setProgressWithAnimation(duration: 1.0, value: 1.0)
    }


}


