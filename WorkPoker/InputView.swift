//
//  InputView.swift
//  WorkPoker
//
//  Created by Bilgehan IŞIKLI on 10/02/2017.
//  Copyright © 2017 BY. All rights reserved.
//

import UIKit

class InputView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var view: UIView!
    let handler: ((InputView)-> Void)?
    let cancelHandler: ((InputView)-> Void)?
    
    init(frame: CGRect, actionHandler:((InputView)-> Void)?, cancelHandler:((InputView)-> Void)?){
        handler = actionHandler
        self.cancelHandler = cancelHandler
        
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        handler = nil
        cancelHandler = nil
        
        super.init(coder: aDecoder)!
        loadViewFromNib()
    }
    
    func loadViewFromNib()
    {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "InputView", bundle: bundle)
        self.view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 10
        
        addSubview(view)
    }
    
    
    @IBOutlet weak var word: UITextField!
    @IBOutlet weak var meaning: UITextField!
    
    
    @IBAction func saveAction(_ sender: Any) {
        
        if let handler = handler {
            handler(self)
            self.removeFromSuperview()
        }
        
        
    }
    @IBAction func cancelAction(_ sender: Any) {
        
        if let cancelAction = cancelHandler {
            cancelAction(self)
        }
        
        self.removeFromSuperview()
        
    }

    
    
}
