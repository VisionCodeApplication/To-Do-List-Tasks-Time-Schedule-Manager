import UIKit

extension UITextField {

    func addInputViewDatePicker(target: Any, selector: Selector, mode : UIDatePicker.Mode , isFromPDFView : Bool) {

    let screenWidth = UIScreen.main.bounds.width

    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
    datePicker.datePickerMode = mode
    self.inputView = datePicker
     if(!isFromPDFView)
     {
        if(mode == .date)
        {
           datePicker.minimumDate = Date()
        }
     }
  
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
    let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
    toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: false)

    self.inputAccessoryView = toolBar
 }

   @objc func cancelPressed() {
     self.resignFirstResponder()
   }
    
    func AnimationShakeTextField(textField:UITextField){
           let animation = CABasicAnimation(keyPath: "position")
           animation.duration = 0.07
           animation.repeatCount = 4
           animation.autoreverses = true
           animation.fromValue = NSValue(cgPoint: CGPoint.init(x: textField.center.x - 5 , y: textField.center.y))
           animation.toValue = NSValue(cgPoint: CGPoint.init(x: textField.center.x + 5 , y: textField.center.y))
           textField.layer.animation(forKey: "position")
       }
}

extension Date{

    func dateStringWith(strFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = strFormat
        return dateFormatter.string(from: self)
    }
    func getStringTimeFromDate(date : Date) -> String
    {
        let strTime = date.dateStringWith(strFormat: DFullTimeFormat)
        print(strTime)
        
        return strTime
        
    }
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

extension UIDatePicker {

   func setDate(from string: String, format: String, animated: Bool = true) {

      let formater = DateFormatter()

      formater.dateFormat = format

      let date = formater.date(from: string) ?? Date()

      setDate(date, animated: animated)
   }
}

extension NSAttributedString {
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}

extension String {
    
    func getDateFromString (dateFormat format  : String, dateStr : String ) -> String
       {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = format
           let date = dateFormatter.date(from: dateStr)
            let str = dateFormatter.string(from: date!)

            return str
       }
    func strDatetoFormat( dateFormat format  : String ) -> String
    {
         let inFormatter = DateFormatter()
        inFormatter.dateFormat = DDBSmallDateFormat

        let outFormatter = DateFormatter()
        outFormatter.dateFormat = format
       let date = inFormatter.date(from: self)!
       let outStr = outFormatter.string(from: date)
       print(outStr)
       
       return outStr
    }
    
    func getTimeFromString (timeFormat format  : String, timeStr : String ) -> String
    {
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = DFullTimeFormat

        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = format
        let date = inFormatter.date(from: timeStr)!
        let outStr = outFormatter.string(from: date)
        print(outStr)
        
        return outStr
    }

    func convertTimeFormat (inputFormat: String, outFormat: String, time: String) -> String
    {
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = inputFormat

        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = outFormat
        let date = inFormatter.date(from: time)!
        let outStr = outFormatter.string(from: date)
        print(outStr)

        return outStr
    }
    
    func convertDateFormatter(dateStr: String ,timeFormat : String) -> Date
     {

        let dateString = dateStr

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timeFormat

        let date = dateFormatter.date(from: dateString)!
        return date
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let timeInterval : NSInteger = NSInteger(interval)
        let minutes = (timeInterval / 60) % 60;
        let hours = (timeInterval / 3600);
        
        print(String(format: "%0.2d:%0.2d",hours,minutes))
        
        return String(format: "%0.2d:%0.2d",hours,minutes)
    }
    
    func attributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf8,
            allowLossyConversion: false) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey.characterEncoding : String.Encoding.utf8.rawValue,
            NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html
        ]
        let htmlString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
        htmlString?.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.clear, range: NSMakeRange(0, 1))

        return htmlString
    }
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)

        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pdfFilename = documents.appending("/file.pdf")
        
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
}

extension UIColor
{
    struct MyTheme {
    static var progressDoneColor = UIColor(red: 102.0/255.0, green: 184.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    static var progressInProgressColor = UIColor(red: 243.0/255.0, green: 183.0/255.0, blue: 83.0/255.0, alpha: 1.0)
    static var progressPendingColor = UIColor(red: 240.0/255.0, green: 134.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    static var progressTrackColor = UIColor(red: 183.0/255.0, green: 183.0/255.0, blue: 183.0/255.0, alpha: 0.6)
    }

    static var TaskType = [UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0), UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0), UIColor(red: 233.0/255.0, green: 105.0/255.0, blue: 71.0/255.0, alpha: 1.0)]

    static var TaskTypeBackground = [UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 0.2), UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 0.2), UIColor(red: 233.0/255.0, green: 105.0/255.0, blue: 71.0/255.0, alpha: 0.2)]

    struct TaskTypeStatus {

    static var progressDoneColor = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 0.2)
    static var progressInProgressColor = UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 0.2)
    static var progressPendingColor = UIColor(red: 233.0/255.0, green: 105.0/255.0, blue: 71.0/255.0, alpha: 0.2)
    }
}

extension FileManager
{
    class func documentsDirHTMLFilePath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(DHTMLFileName)
        return path
    }
    
    class func documentsDirPDFHTMLFilePath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(DPDFHTMLFileName)
        return path
    }
}
