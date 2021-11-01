import UIKit

class CommonFunctions: NSObject {
    
  
    let durationOfAnimationInSecond = 1.0

    public class func showMessage(Title : String , message : String) {
            
                let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
                let Alert = UIAlertController(title: Title, message: (message), preferredStyle: UIAlertController.Style.alert)
                Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                }))
                rootViewController.present(Alert, animated: true, completion: nil)
            }

    public class func curveAnimation(view: UIView, animationOptions: UIView.AnimationOptions, isReset: Bool) {
      let defaultXMovement: CGFloat = 240
        UIView.animate(withDuration: 1.0, delay: 0, options: animationOptions, animations: {
        view.transform = isReset ? .identity : CGAffineTransform.identity.translatedBy(x: defaultXMovement, y: 0)
      }, completion: nil)
    }
    
    public class func transitionAnimation(view: UIView,r animationOptions: UIView.AnimationOptions, isReset: Bool) {
        UIView.transition(with: view, duration: 1.0, options: animationOptions, animations: {
         view.backgroundColor = UIColor.white
      }, completion: nil)
    }
    
    public class func getDifferenceTotalTimeInMinutes(from StartTime : Date, EndTime : Date) -> String {
        let distanceBetweenDates: TimeInterval? = EndTime.timeIntervalSince(StartTime)
        let totalTime = String().stringFromTimeInterval(interval: distanceBetweenDates!)
        
        return totalTime
    }
}
