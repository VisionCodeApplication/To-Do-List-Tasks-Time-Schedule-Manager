
import UIKit

@IBDesignable class CustomHeaderView: UIView {

    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var btnBack : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

       fileprivate func setupView() {
           let view = viewFromNibForClass()
           view.frame = bounds
           view.autoresizingMask = [
               UIView.AutoresizingMask.flexibleWidth,
               UIView.AutoresizingMask.flexibleHeight
           ]
           addSubview(view)
       }
  
       fileprivate func viewFromNibForClass() -> UIView {
           let bundle = Bundle(for: type(of: self))
           let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
           let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
           return view
       }
    func setTitle()
    {
        self.btnBack.isHidden = true
        self.lblTitle.textAlignment = .center
   
    }

       @IBAction func btnBackClicked()
       {
            AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
       }
        

}
