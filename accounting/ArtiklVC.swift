//
//  ArtiklVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/31/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//sgArtikl

import UIKit
import CoreData

class ArtiklVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .brown
        DodajDugmeZaNazad()
        PovuciPodatke()
        pikerArtikli.delegate = self
        pikerArtikli.dataSource = self
    }
    
    @IBOutlet weak var pikerArtikli: UIPickerView!
    @IBOutlet weak var tfNazivArtikla: UITextField!
    @IBOutlet weak var tfPorekloArtikla: UITextField!


    
    @IBOutlet weak var tfKolicinaUPojedinacnomPakovanju: UITextField!
    
    var jedinicaZaMeru: String?
    @IBOutlet weak var roSegCtrlJedinicaMere: UISegmentedControl!
    @IBAction func SegCtrlJedinicaMere(_ sender: Any) {
        switch roSegCtrlJedinicaMere.selectedSegmentIndex {
        case 0:
            jedinicaZaMeru = roSegCtrlJedinicaMere.titleForSegment(at: 0)!
        case 1:
            jedinicaZaMeru = roSegCtrlJedinicaMere.titleForSegment(at: 1)!
        case 2:
            jedinicaZaMeru = roSegCtrlJedinicaMere.titleForSegment(at: 2)!
        default:
            jedinicaZaMeru = "nije izabrana jedinica za meru!!!!"
        }
        
    }
    
    
    @IBAction func Izbrisi(_ sender: Any) {
    }
    @IBAction func Izmeni(_ sender: Any) {
    } // urea rusija  kg 50
    @IBAction func Dodaj(_ sender: Any) {
        
        let nazivArtiklaZaDodavanje = tfNazivArtikla.text
        let porekloArtiklaZaDodavanje = tfPorekloArtikla.text


        
        
        if nazivArtiklaZaDodavanje != nil && nazivArtiklaZaDodavanje != "" &&
            porekloArtiklaZaDodavanje != nil && porekloArtiklaZaDodavanje != "" &&
            jedinicaZaMeru != nil &&
            tfKolicinaUPojedinacnomPakovanju.text != nil && tfKolicinaUPojedinacnomPakovanju.text != "" {
            
            let kolicinaUPojedinacnomPakovanju = Decimal(Double(tfKolicinaUPojedinacnomPakovanju.text!)!)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            
            let kompletanArtiklZaDodavanjeUBazu = nazivArtiklaZaDodavanje! + " / " + porekloArtiklaZaDodavanje!  + " / " + jedinicaZaMeru! + " / " + tfKolicinaUPojedinacnomPakovanju.text!
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entitet = NSEntityDescription.entity(forEntityName: "ListaDjubriva", in: managedContext)
            let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
            
            zapis.setValue(kompletanArtiklZaDodavanjeUBazu, forKey: "naziv") // urea rusija kg 50
            zapis.setValue(nazivArtiklaZaDodavanje, forKey: "basNazivSamogArtikla") // urea
            zapis.setValue(kolicinaUPojedinacnomPakovanju, forKey: "kolicinaUPojedinacnomPakovanju") // 50.0
            zapis.setValue(jedinicaZaMeru, forKey: "jedinicaMere") // kg
            zapis.setValue(porekloArtiklaZaDodavanje, forKey: "porekloArtiklaZaDodavanje") // rusija
            
            do {
                try managedContext.save()
                
                print("U bazu podataka je upisan novi artikl \(zapis)")
                ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem novi artikl: \(zapis)")
                PrikaziUspesniPopUp()
            } catch {
                print("Ne mogu da upisem novo artikl! \(error)")
            }
        } else {
            PrikaziNeuspesniPopUp(poruka: "Nesto fali. Mora imati NAZIV, POREKLO, KOLICINU U POJEDINACNOM PAKOVANJU, JEDINICU MERE")
        }
        
    }
    
    var nizArtikli: [String] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nizArtikli.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nizArtikli[row]
    }
    
    func PrikaziUspesniPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili novi artikl",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaArtikl", sender: nil)
        })
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }
    
    func PrikaziNeuspesniPopUp(poruka: String?) {
        let popUp = UIAlertController(title: "NEUSPESNO",
                                      message: poruka,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        let okAction = UIAlertAction(title: "Pokusacu ponovo sve opet",
                                     style: UIAlertActionStyle.default)
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }

    
    func PovuciPodatke() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListaDjubriva")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let artikl = podatak.value(forKey: "naziv")
                nizArtikli.append(artikl! as! String)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
    }

    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaArtikl", sender: nil)
    }
}
