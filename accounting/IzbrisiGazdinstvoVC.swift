//
//  IzbrisiGazdinstvoVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/15/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class IzbrisiGazdinstvoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        roIzbrisiGazdinstvo.isUserInteractionEnabled = false
        tabelaPrikaziGazdinstva.delegate = self
        tabelaPrikaziGazdinstva.dataSource = self
        self.view.backgroundColor = .brown
        self.hideKeyboardWhenTappedAround()
        DodajDugmeZaNazad()
        PovuciPodatke()
    }
    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaIzbrisiGazdinstvo", sender: nil)
    }
    
    var nizNaziv: [String] = []
    var nizAdresa: [String] = []
    var nizBpg: [Int64] = []
    var nizTelefon: [Int64] = []
    
    func PovuciPodatke() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviPG")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let naziv = podatak.value(forKey: "naziv")
                let adresa = podatak.value(forKey: "adresa")
                let bpg = podatak.value(forKey: "bpg")
                let telefon = podatak.value(forKey: "telefon")
                
                nizNaziv.append(naziv! as! String)
                nizAdresa.append(adresa! as! String)
                nizBpg.append(bpg! as! Int64)
                nizTelefon.append(telefon! as! Int64)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
    }
    
    @IBOutlet weak var roIzbrisiGazdinstvo: UIButton!
    @IBOutlet weak var tabelaPrikaziGazdinstva: UITableView!
    @IBOutlet weak var tfBpg: UITextField!
    var kliknutiRedIGVC: Int?
    
    @IBAction func IzbrisiGazdinstvo(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviPG")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            for podatak in response {
                
                if podatak.value(forKey: "bpg") as! Int64 == nizBpg[kliknutiRedIGVC!] {
                    managedContext.delete(podatak)
                    do {
                        ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "Brisem gazdinstvo: \(podatak)")
                        try managedContext.save()
                        print("Iz baze podataka je obrisano gazdinstvo \(podatak)")
                    } catch let error as NSError {
                        print("Ne mogu da obrisem podatak! \(error)")
                    }
                }
            }
            roIzbrisiGazdinstvo.isUserInteractionEnabled = false
            kliknutiRedIGVC = nil
            tfBpg.text = ""
            nizNaziv = []
            nizAdresa = []
            nizBpg = []
            nizTelefon = []
            PovuciPodatke()
            tabelaPrikaziGazdinstva.reloadData()
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak! \(error)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizNaziv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaIGVC", for: indexPath)
        celija.textLabel?.text = nizNaziv[indexPath.row]
        celija.detailTextLabel?.text = String(nizTelefon[indexPath.row])
        return celija
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        roIzbrisiGazdinstvo.isUserInteractionEnabled = true
        kliknutiRedIGVC = indexPath.row
        tfBpg.text = String(nizBpg[kliknutiRedIGVC!])
    }
}
