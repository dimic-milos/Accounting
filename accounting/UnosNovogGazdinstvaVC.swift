//
//  UnosNovogGazdinstvaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/14/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class UnosNovogGazdinstvaVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.hideKeyboardWhenTappedAround()
        DodajDugmeZaNazad()
    }
    
    @IBOutlet weak var nazivPG: UITextField!
    @IBOutlet weak var adresaPG: UITextField!
    @IBOutlet weak var telefonPG: UITextField!
    @IBOutlet weak var brojPG: UITextField!
    
    @IBOutlet weak var tfMesto: UITextField!
    @IBOutlet weak var tfJmbg: UITextField!
    @IBOutlet weak var tfBrojLicneKarte: UITextField!
    @IBOutlet weak var tfTekuciRacun: UITextField!
    
    
    
    enum Greske: Error {
        case NisuUnetiSviParametri
        case SlovniUnosJePrekratak
        case BPGNijeValidan
        case TelefonNijeValidan
        case JMBGNijeValidan
    }
    
    func ProveriValidnostUnosa(x: String?, y: String?, a: Int64?, b: Int64?, c: String?) throws -> Bool {
        guard a! > 700_000_000_000 else {
            PrikaziNeuspesniPopUp(poruka: "BPGNijeValidan jer mora biti veci od 700.000.000.000")
            throw Greske.BPGNijeValidan
        }
        guard (x?.characters.count)! > 3 && (y?.characters.count)! > 3 else {
            PrikaziNeuspesniPopUp(poruka: "SlovniUnosJePrekratak mora biti bar 4 slova")
            throw Greske.SlovniUnosJePrekratak
        }
        guard b! >= 100_000 else {
            PrikaziNeuspesniPopUp(poruka: "TelefonNijeValidan mora biti bar 6 cifara")
            throw Greske.TelefonNijeValidan
        }
        guard String(c!).characters.count == 13 else {
            PrikaziNeuspesniPopUp(poruka: "JMBGNijeValidan, manji je od 13 cifara")
            throw Greske.JMBGNijeValidan
        }
        return true
    }
    
    func ProveriDaLiSuSvaPoljaPopunjena(naziv: String?, adresa: String?, telefon: String?, bpg: String?, mestoIn: String?, jmbgIn: String?, brLicneIn: String?, tekuciRacunIn: String?) throws -> Bool {
        guard naziv != "" && adresa != "" && telefon != "" && bpg != "" && mestoIn != "" && jmbgIn != "" && brLicneIn != "" && tekuciRacunIn != "" else {
            throw Greske.NisuUnetiSviParametri
        }
        return true
    }
    
    
    @IBAction func Snimi(_ sender: Any) {
  
        do {
            let svaPoljaSuIspunjena =  try ProveriDaLiSuSvaPoljaPopunjena(naziv: nazivPG.text, adresa: adresaPG.text, telefon: telefonPG.text, bpg: brojPG.text, mestoIn: tfMesto.text, jmbgIn: tfJmbg.text, brLicneIn: tfBrojLicneKarte.text, tekuciRacunIn: tfTekuciRacun.text)
            if svaPoljaSuIspunjena {
                
                let strNazivPG = nazivPG.text!
                let strAdresaPG = adresaPG.text!
                let intBrojPG = Int64(brojPG.text!)!
                let intTelefonPG = Int64(telefonPG.text!)!
                
                let mesto = tfMesto.text!
                let jmbg = tfJmbg.text!
                let brLicne = Int64(tfBrojLicneKarte.text!)
                let tekuciRacun = tfTekuciRacun.text!
                
                do  {
                    let unosJeValidan = try ProveriValidnostUnosa(x: strNazivPG, y: strAdresaPG, a: intBrojPG, b: intTelefonPG, c: jmbg)
                    
                    if unosJeValidan {
                        
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            else {
                                return
                        }
                        
                        let managedContext = appDelegate.persistentContainer.viewContext
                        let entitet = NSEntityDescription.entity(forEntityName: "SviPG", in: managedContext)
                        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
                        
                        zapis.setValue(strAdresaPG, forKey: "adresa")
                        zapis.setValue(intBrojPG, forKey: "bpg")
                        zapis.setValue(strNazivPG, forKey: "naziv")
                        zapis.setValue(intTelefonPG, forKey: "telefon")
                        
                        zapis.setValue(mesto, forKey: "mesto")
                        zapis.setValue(jmbg, forKey: "jmbg")
                        zapis.setValue(brLicne, forKey: "brojLicneKarte")
                        zapis.setValue(tekuciRacun, forKey: "tekuciRacun")
                        
                        do {
                            try managedContext.save()
                            print("U bazu podataka je upisan zapis \(zapis)")
                            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem gazdinstvo: \(zapis)")
                        } catch {
                            print("Ne mogu da upisem novo gazdinstvo! \(error)")
                        }
                    }
                    PrikaziPopUp()
                    nazivPG.text = ""
                    adresaPG.text = ""
                    telefonPG.text = ""
                    brojPG.text = ""
                    
                    tfTekuciRacun.text = ""
                    tfBrojLicneKarte.text = ""
                    tfJmbg.text = ""
                    tfMesto.text = ""
                } catch {
                    print("Dogodila se greska pri upisu novog gazdinstva", error)
                }
            }
        } catch {
            print("nisu sva polja ispunjena \(error)")
        }  
    }
    

    func PrikaziPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili NOVO GAZDINSTVO",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaUnosNovogPG", sender: nil)
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

    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaUnosNovogPG", sender: nil)
    }
}
