//
//  PrikaziGazdinstvaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/15/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class PrikaziGazdinstvaVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
var kliknutiRedPGVC: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelaPrikaziGazdinstva.delegate = self
        tabelaPrikaziGazdinstva.dataSource = self
        self.view.backgroundColor = .cyan
        DodajDugmeZaNazad()
        PovuciPodatke()
    }
    
    @IBOutlet weak var tabelaPrikaziGazdinstva: UITableView!
    
    @IBOutlet weak var labelaNaziv: UITextField!
    @IBOutlet weak var labelaAdresa: UITextField!
    @IBOutlet weak var labelaTelefon: UITextField!
    @IBOutlet weak var labelaBroj: UITextField!
    
    @IBOutlet weak var lbMesto: UITextField!
    @IBOutlet weak var lbJmbg: UITextField!
    @IBOutlet weak var lbBrLK: UITextField!
    @IBOutlet weak var lbTr: UITextField!
    
    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaPGVC", sender: nil)
    }
    

    var nizNaziv: [String] = []
    var nizAdresa: [String] = []
    var nizBpg: [Int64] = []
    var nizTelefon: [Int64] = []
    
    var nizMesto: [String] = []
    var nizJmbg: [String] = []
    var nizBrLK: [Int32] = []
    var nizTR: [String] = []
    
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
                
                let mesto = podatak.value(forKey: "mesto")
                let jmbg = podatak.value(forKey: "jmbg")
                let brLk = podatak.value(forKey: "brojLicneKarte")
                let tr = podatak.value(forKey: "tekuciRacun")
                
                nizNaziv.append(naziv! as! String)
                nizAdresa.append(adresa! as! String)
                nizBpg.append(bpg! as! Int64)
                nizTelefon.append(telefon! as! Int64)
                
                nizMesto.append(mesto! as! String)
                nizJmbg.append(jmbg! as! String)
                nizBrLK.append(brLk! as! Int32)
                nizTR.append(tr! as! String)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizNaziv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaPGVC", for: indexPath)
        celija.textLabel?.text = nizNaziv[indexPath.row]
        return celija
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kliknutiRedPGVC = indexPath.row
        labelaNaziv.text = nizNaziv[kliknutiRedPGVC!]
        labelaAdresa.text = nizAdresa[kliknutiRedPGVC!]
        labelaTelefon.text = String(nizTelefon[kliknutiRedPGVC!])
        labelaBroj.text = String(nizBpg[kliknutiRedPGVC!])
        
        lbTr.text = nizTR[kliknutiRedPGVC!]
        lbBrLK.text = String(nizBrLK[kliknutiRedPGVC!])
        lbJmbg.text = String(nizJmbg[kliknutiRedPGVC!])
        lbMesto.text = nizMesto[kliknutiRedPGVC!]
    }


}

