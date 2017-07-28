//
//  ViewController.swift
//  accounting
//
//  Created by Dimic Milos on 5/14/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//  
/* TO DO
 

 
 */

import UIKit
import CoreData

var dummy: ViewController?
var setJebBrojeva = Set<Int64>()



func NapuniSetJebBrojevima() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Log")
    
    do {
        let response = try managedContext.fetch(fetchRequest)
        for podatak in response {
            let jeb = podatak.value(forKey: "jeb") as! Int64
            setJebBrojeva.insert(jeb)
        }
    } catch let error as NSError {
        print("Ne mogu da preuzmem set jeb brojeva! \(error)")
    }
}

func ProveriJebBrojInsertujEvent(jebBroj: Int64, event: String) {
    var JebBrojZaUnos = jebBroj
    
    repeat {
        JebBrojZaUnos += 1
    } while setJebBrojeva.contains(JebBrojZaUnos)
    
    setJebBrojeva.insert(JebBrojZaUnos)
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let entitet = NSEntityDescription.entity(forEntityName: "Log", in: managedContext)
    let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
    
    let date = NSDate()
    let calendar = NSCalendar.current
    let datumVreme = String(describing: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date))
    
    zapis.setValue(JebBrojZaUnos, forKey: "jeb")
    zapis.setValue(datumVreme + event, forKey: "staSeDesilo")

    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Ne mogu da upisem u bazu logova! \(error)")
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
var kliknutRedBroj: Int?
let pdvStopaZaPoljoprivrednaGazdinstva = 8.0
let pdvStopaZaRobuManjegPDVa = 10.0
let pdvStopaZaRobuVecegPDVa = 20.0
let pdvStopaZaRobuBezPDVa = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dummy = self
        tabelaGlavnogPrikaza.dataSource = self
        tabelaGlavnogPrikaza.delegate = self
        NapuniSetJebBrojevima()
    }
    
    @IBOutlet weak var tabelaGlavnogPrikaza: UITableView!
    
    let opcijeGlavnogPrikaza = ["Gazdinstva", "DOO", "IZVOD", "Kursna lista", "Artikl"]
    let detaljnijiOpisGlavnogPrikaza = ["rad sa poljoprivrednicima", "rad sa preduzecima", "rad sa izvodima", "unos i pregled kursne liste", "rad sa artiklima baze"]
    let spisakSegveja = [0 : "sgGazdinstva", 1 : "sgDOO", 2 : "sgIzvodi", 3 : "sgKursnaLista", 4 : "sgArtikl"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return opcijeGlavnogPrikaza.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija =  tableView.dequeueReusableCell(withIdentifier: "prototipCelija", for: indexPath)
        celija.textLabel?.text = opcijeGlavnogPrikaza[indexPath.row]
        celija.detailTextLabel?.text = detaljnijiOpisGlavnogPrikaza[indexPath.row]
        
        return celija
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kliknutRedBroj = indexPath.row
        performSegue(withIdentifier: spisakSegveja[kliknutRedBroj!]!, sender: nil)
    }
    
    
}
