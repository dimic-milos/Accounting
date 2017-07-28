//
//  KursnaListaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/30/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class KursnaListaVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .cyan
        DodajDugmeZaNazad()
    }
    
    @IBOutlet weak var pikerDatum: UIDatePicker!
    @IBOutlet weak var tfGornji: UITextField!
    @IBOutlet weak var tfSrednji: UITextField!
    @IBOutlet weak var tfDonji: UITextField!
    
    var selektovanaValuta = "Evro"
    var gornji: Decimal?
    var srednji: Decimal?
    var donji: Decimal?
    
    @IBOutlet weak var segValuta: UISegmentedControl!
    
    @IBAction func SegValutaAction(_ sender: Any) {
        switch segValuta.selectedSegmentIndex
        {
        case 0 :
            selektovanaValuta = "Evro"
        case 1 :
            selektovanaValuta = "Dolar"
        default: break
        }
    }
    
    func PovuciKorisnikoveInpute() {
        if let double = NumberFormatter().number(from: tfGornji.value(forKey: "text") as! String) as? Double {
            gornji = Decimal(double)
        } else {
            gornji = nil
        }
        if let double = NumberFormatter().number(from: tfSrednji.value(forKey: "text") as! String) as? Double {
            srednji = Decimal(double)
        } else {
            srednji = nil
        }
        if let double = NumberFormatter().number(from: tfDonji.value(forKey: "text") as! String) as? Double {
            donji = Decimal(double)
        } else {
            donji = nil
        }
    }
    

    
    @IBAction func SacuvajListu(_ sender: Any) {
        
        if !VecPostojiKursnaListaNaTajDanZaTuValutu() {
            PovuciKorisnikoveInpute()
            
            
            do {
                let poljaSuIspravnoPopunjena = try ProveriValidnostUnosa(intGornji: gornji, intSrednji: srednji, intDonji: donji)
                if poljaSuIspravnoPopunjena {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        else {
                            return
                    }
                    
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let entitet = NSEntityDescription.entity(forEntityName: "KursnaLista", in: managedContext)
                    let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
                    
                    zapis.setValue(gornji, forKey: "gornji")
                    zapis.setValue(srednji, forKey: "srednji")
                    zapis.setValue(donji, forKey: "donji")
                    zapis.setValue(selektovanaValuta, forKey: "kursnaValuta")
                    zapis.setValue(pikerDatum.date, forKey: "datum")
                    
                    
                    do {
                        try managedContext.save()
                        print("U bazu podataka je upisana kursna lista  \(zapis)")
                        ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem kursnu listu: \(zapis)")
                        PrikaziUspesniPopUp()
                    } catch {
                        print("Ne mogu da upisem kursnu listu! \(error)")
                    }
                    
                }
            } catch {
                print("nisam usao u snimanje jer polja nisu dobro ispunjena \(error)")
            }
        }
        
    }
    
    
    enum Greske: Error {
        case NijeUnetGornjiKurs
        case NijeUnetSrednjiKurs
        case NijeUnetDonjiKurs
        case NemoguceDaJeTakavKurs
    }
    
    func ProveriValidnostUnosa(intGornji: Decimal?, intSrednji: Decimal?, intDonji: Decimal?) throws -> Bool {
        guard intGornji != nil else {
            PrikaziNeuspesniPopUp(poruka: "Nije unet gornji kurs")
            throw Greske.NijeUnetGornjiKurs
        }
        guard intSrednji != nil else {
            PrikaziNeuspesniPopUp(poruka: "Nije unet srednji kurs")
            throw Greske.NijeUnetSrednjiKurs
        }
        guard intDonji != nil else {
            PrikaziNeuspesniPopUp(poruka: "Nije unet donji kurs")
            throw Greske.NijeUnetDonjiKurs
        }
        guard (intGornji! > intSrednji!) && (intSrednji! > intDonji!) else {
            PrikaziNeuspesniPopUp(poruka: "Proveri te brojke za kurs")
            throw Greske.NemoguceDaJeTakavKurs
        }
        return true
    }
    
    
    func PrikaziUspesniPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili kurnu listu",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaKursnaLista", sender: nil)
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
   
    var nizDatumaKojiVecImajuKursnuListuZaTuValutu: [Date] = []
    func VecPostojiKursnaListaNaTajDanZaTuValutu() -> Bool {
        nizDatumaKojiVecImajuKursnuListuZaTuValutu = []
        PovuciPodatke()
        for clan in nizDatumaKojiVecImajuKursnuListuZaTuValutu {
            let kakavJeDatum = Calendar.current.compare(pikerDatum.date, to: clan, toGranularity: .day)
            
            switch kakavJeDatum {
            case .orderedDescending:
                print("Opadajuce")
            case .orderedAscending:
                print("Rastuce")
            case .orderedSame:
                print("Isto")
                PrikaziNeuspesniPopUp(poruka: "Vec postoji kursna lista za taj dan za tu valutu")
                return true
            }
        }
        return false
    }
    
    func PovuciPodatke() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "KursnaLista")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                if podatak.value(forKey: "kursnaValuta") as! String == selektovanaValuta {
                    let datum = podatak.value(forKey: "datum")
                    nizDatumaKojiVecImajuKursnuListuZaTuValutu.append(datum! as! Date)
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem kursne liste za proveru da li ima duplih kursnih lista! \(error)")
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
        performSegue(withIdentifier: "sgGlavniSaKursnaLista", sender: nil)
    }
}

