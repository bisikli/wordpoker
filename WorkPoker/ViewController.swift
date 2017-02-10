//
//  ViewController.swift
//  WorkPoker
//
//  Created by Bilgehan IŞIKLI on 09/02/2017.
//  Copyright © 2017 BY. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var list: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var wordArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list.dataSource = self
        list.delegate   = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addAction(_ sender: Any) {
        //createAlertController(title: "WordPoker", message: "Add New Word")
        createCustomInputView()
    }

    @IBAction func sortAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        
        do {
            let fetchedWords = try moc().fetch(fetchRequest)
            wordArray = fetchedWords as! [NSManagedObject]
            list.reloadData()
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    //MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let wordCell = tableView.dequeueReusableCell(withIdentifier: "wordCell")
        
        let wordObject = wordArray[indexPath.row]
        
        wordCell?.textLabel?.text = wordObject.value(forKey: "itself") as? String
        
        return wordCell!
    }
    
    //MARK: Other Methods
    
    func createAlertController(title: String, message: String ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let textField = alert.textFields?.first {
                if var input = textField.text {
                    input = input.replacingOccurrences(of: " ", with: "")
                    if(input.characters.count > 0){
                        self.saveData(word: input)
                        self.list.reloadData()
                    }
                }
                
            }
            
        }
        
//        let an = UIAlertAction(title: <#T##String?#>, style: <#T##UIAlertActionStyle#>, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField(configurationHandler: { (textField) in
            //nothing
        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func createCustomInputView(){
          
        var frame = self.view.frame
        
        frame.size.width = self.view.frame.size.width * 2/3
        frame.size.height = self.view.frame.size.height * 1/3
        
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2
        frame.origin.y = (self.view.frame.size.height - frame.size.height)/2

        let myInput = InputView(frame: frame, actionHandler: { (inputView) in
            
            if var input = inputView.word.text {
                input = input.replacingOccurrences(of: " ", with: "")
                if(input.characters.count>0){
                    self.saveData(word: input)
                    self.list.reloadData()
                }
            }

            
        }) { (inputView) in
           
        }
        
        myInput.backgroundColor = UIColor.blue
        //myInput.layer.cornerRadius = 10
        myInput.layer.shadowColor = UIColor.black.cgColor
        myInput.layer.shadowOpacity = 1
        
        
        self.view.addSubview(myInput)
        self.view.bringSubview(toFront: myInput)
        
    }
    
    //MARK: CoreData Methods
    
    func moc() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveData(word: String){
        
        let entity = NSEntityDescription.entity(forEntityName: "Word", in: moc())
        
        let wordObject = NSManagedObject(entity: entity!, insertInto: moc())
        
        wordObject.setValue(word, forKey: "itself")
        
        do {
            try moc().save()
            
            wordArray.append(wordObject)
            
        } catch let error as NSError {
            print("Error saving data!")
        }
        
        
    }

}

