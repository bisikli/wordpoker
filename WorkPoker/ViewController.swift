//
//  ViewController.swift
//  WorkPoker
//
//  Created by Bilgehan IŞIKLI on 09/02/2017.
//  Copyright © 2017 BY. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import ActionSheetPicker_3_0

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var list: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    var wordArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list.dataSource = self
        list.delegate   = self
        searchBar.delegate = self
        
        let searchField = searchBar.value(forKey: "_searchField") as! UITextField
        searchField.clearButtonMode = .never

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
        
        let multiplePicker = ActionSheetMultipleStringPicker(title: "WORD POKER", rows: [["Date","Word","Meaning"],["ASC","DESC"]], initialSelection: [0,0], doneBlock: { (picker, values, selected) in
            
            
            let selectedValues = selected as! NSArray
            
            let type = selectedValues.firstObject as! String
            let order = selectedValues.lastObject as! String
            
            switch(type){
                case "Date":
                    self.sortByDate(order: order)
                    break
                case "Word":
                    self.sortByAlpa(order: order, sortByMeaning: false)
                    break
                default:
                    self.sortByAlpa(order: order, sortByMeaning: true)
                    break
            }
            
            
        }, cancel: { (picker) in
            
        }, origin: sortButton)
        
        multiplePicker?.show()
        
    }
    

    
    func sortByDate(order: String){
        
        var isASC = true
        
        if(order == "DESC"){
            isASC = false
        }
        
        wordArray.sort { (object1, object2) -> Bool in
            let date1 = object1.value(forKey: "date") as! Date
            let date2 = object2.value(forKey: "date") as! Date
            if(isASC){
                return (date1<date2)
            }
            else{
                return (date1>date2)
            }
            
            
        }
        list.reloadData()
    }
    
    func sortByAlpa(order: String, sortByMeaning: Bool){
        
        var key = "itself"
        if(sortByMeaning){
            key = "meaning"
        }
        
        var isASC = true
        
        if(order == "DESC"){
            isASC = false
        }
        
        wordArray.sort { (object1, object2) -> Bool in
            let word1 = object1.value(forKey: key) as! String
            let word2 = object2.value(forKey: key) as! String
            
            if(isASC){
                return (word1<word2)
            }
            else{
                return (word1>word2)
                
            }
        }
        list.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        fetchAll()
    }
    
    func fetchAll(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        
        do {
            let fetchedWords = try moc().fetch(fetchRequest)
            wordArray = fetchedWords as! [NSManagedObject]
//            var isChanged = false
//            for words in wordArray {
//                if let date1 = words.value(forKey: "date"){
//                    //do nothing
//                }
//                else{
//                    NSLog("Date interpolated")
//                    isChanged = true
//                    words.setValue(Date(), forKey: "date")
//                }
//            }
//            if(isChanged) {
//                do {
//                    try moc().save()
//                } catch let error as NSError {
//                    showAlert(message:"Error saving data!")
//                }
//            }
            
            sortByDate(order: "DESC")
            
            list.reloadData()
            
            if(wordArray.count > 0){
                checkNotification()
            }
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    //MARK: SearchBar Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.isEmpty){
            fetchAll()
        }
        else{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
            let firstCondition  = NSPredicate(format: "itself CONTAINS[cd] %@", searchText)
            let secondCondition = NSPredicate(format: "meaning CONTAINS[cd] %@", searchText)
            
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstCondition,secondCondition])
            
            do {
                
                let fetchedWords = try moc().fetch(fetchRequest)
                wordArray = fetchedWords as! [NSManagedObject]
                list.reloadData()
                
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchAll()
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
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
        
        let word = wordObject.value(forKey: "itself") as? String
        let meaning = wordObject.value(forKey: "meaning") as? String
        
        if let word = word, let meaning = meaning {
            wordCell?.textLabel?.text = "'\(word)' : \(meaning)"
        }
        
        
        
        return wordCell!
    }
    
    //MARK: Other Methods
    
    func showAlert(message: String){
        
        let alertView = UIAlertController(title: "WORD POKER", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alertView.addAction(cancel)
        
        present(alertView, animated: true, completion: nil)
        
    }
    
    var blurView: UIVisualEffectView?
    var container: UIView?
    
    func createCustomInputView(){
          
        var frame = self.view.frame
        
        frame.size.width = self.view.frame.size.width * 2/3
        frame.size.height = self.view.frame.size.height * 1/4
        
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2
        frame.origin.y = (self.view.frame.size.height - frame.size.height)/2

        let myInput = InputView(parent: self.view, frame: frame, actionHandler: { (inputView) in
            
            if var input = inputView.word.text {
                input = input.trimmingCharacters(in: [" "])
                if(input.characters.count>0){
                    
                    if var meaning = inputView.meaning.text {
                        meaning = meaning.trimmingCharacters(in: [" "] )
                        if(meaning.characters.count>0){
                            self.saveData(word: input, meaning: meaning)
                            self.list.reloadData()
                        }
                    }
                    
                }
            }

            
        }) { (inputView) in
           
        }
        
        myInput.layer.cornerRadius = 10
        
//        let blur = UIBlurEffect(style: .extraLight)
//        blurView = UIVisualEffectView(effect: blur)
//        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurView?.frame = self.view.frame
//        blurView?.backgroundColor = UIColor.clear
//        self.view.addSubview(blurView!)
        
        
        
    }
    
    var existingWords: [String] = []
    
    func checkNotification(){
        
        
        let center = UNUserNotificationCenter.current()
        var notifCount = 0
        var nextTriggerDates : [TimeInterval] = []
        
        center.getPendingNotificationRequests { (requests) in
            
            for request in requests {
                if(request.identifier.contains("WordPoker")){
                    notifCount = notifCount+1
                    let timeIntervalTrigger = request.trigger as! UNTimeIntervalNotificationTrigger
                    if let date = timeIntervalTrigger.nextTriggerDate() {
                        nextTriggerDates.append(date.timeIntervalSinceNow)
                    }
                    self.existingWords.append(request.content.body)
                    
                }
            }
            
            var lastNotificationDate : TimeInterval = 0
            
            if(nextTriggerDates.count > 0){
                lastNotificationDate = nextTriggerDates.max()!
                
            }
            
            
            var limit = self.wordArray.count
            if(limit>64){
                limit = 64
            }
            
            if(notifCount < limit){
                let scheduleCount = limit - notifCount
                for i in 1...scheduleCount {
                    let triggerTime : TimeInterval = TimeInterval(Int(lastNotificationDate) + i*60*60*6)
                    self.setLocalNotification(timeInterval: triggerTime)
                }
            }
        }
        
        
    }
    
    func getRandomWord()->String{
        let count = UInt32(wordArray.count)
        let r = Int(arc4random_uniform(count))
        let wordObject = wordArray[r]
        let word = wordObject.value(forKey: "itself") as? String
        let meaning = wordObject.value(forKey: "meaning") as? String
        var body = "BOS"
        if let word = word, let meaning = meaning {
            body = "'\(word)' : \(meaning)"
        }
        return body
    }
    
    func setLocalNotification(timeInterval: TimeInterval){
    
    
        let content = UNMutableNotificationContent()
        content.title = "POKE YOU!"
        
        var body = getRandomWord()
        
        while(existingWords.contains(body)){
            body = getRandomWord()
        }
        
        content.body  = body
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "WordPoker: \(body)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            } else {
                // Request was added successfully
            }
        }
    }
    
    //MARK: CoreData Methods
    
    func moc() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveData(word: String, meaning: String){
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "itself == %@", word)
        
        do {
            let fetchedWords = try moc().fetch(fetchRequest)
            
            if(fetchedWords.count > 0){
                
                let existingRecord = fetchedWords.first as! NSManagedObject
                var count = existingRecord.value(forKey: "count") as! Int
                count = count + 1
                existingRecord.setValue(count, forKey: "count")
                existingRecord.setValue(Date(), forKey: "date")
                
                showAlert(message: "This is word is entered \(count) times.")
                
                do {
                    try moc().save()
                } catch let error as NSError {
                    showAlert(message:"Error saving data!")
                }
            }
            else {
                let entity = NSEntityDescription.entity(forEntityName: "Word", in: moc())
                
                let wordObject = NSManagedObject(entity: entity!, insertInto: moc())
                
                wordObject.setValue(word, forKey: "itself")
                wordObject.setValue(meaning, forKey: "meaning")
                wordObject.setValue(Date(), forKey: "date")
                
                do {
                    try moc().save()
                    
                    wordArray.append(wordObject)
                    
                } catch let error as NSError {
                    showAlert(message:"Error saving data!")
                }
            }
            
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        
        
        
        
    }

}

