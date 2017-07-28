//
//  IzmeniPodatkeGazdinstvaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/16/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class IzmeniPodatkeGazdinstvaVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelaPrikaziGazdinstva.delegate = self
        tabelaPrikaziGazdinstva.dataSource = self
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.purple
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

    var nizNaziv: [String] = []
    var nizAdresa: [String] = []
    var nizBpg: [Int64] = []
    var nizTelefon: [Int64] = []
    
    var nizMesto: [String] = []
    var nizJmbg: [String] = []
    var nizBrLK: [Int32] = []
    var nizTR: [String] = []
    
    var kliknutiRedIPGVC: Int?
    var novaVrednost: UITextField?
    var numeruckaTastatura = true
    var identifikatorIzmenjenogPodatka: Int64?
    
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

    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaIzmeniPodatkeGazdinstva", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizNaziv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaIPGVC", for: indexPath)
        celija.textLabel?.text = nizNaziv[indexPath.row]
        return celija
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        OmoguciAktivnostPoljaRadiIzmene()
        kliknutiRedIPGVC = indexPath.row
     
        labelaNaziv.text = nizNaziv[kliknutiRedIPGVC!]
        labelaAdresa.text = nizAdresa[kliknutiRedIPGVC!]
        labelaTelefon.text = String(nizTelefon[kliknutiRedIPGVC!])
        labelaBroj.text = String(nizBpg[kliknutiRedIPGVC!])
        
        lbTr.text = nizTR[kliknutiRedIPGVC!]
        lbBrLK.text = String(nizBrLK[kliknutiRedIPGVC!])
        lbJmbg.text = String(nizJmbg[kliknutiRedIPGVC!])
        lbMesto.text = nizMesto[kliknutiRedIPGVC!]
        
        identifikatorIzmenjenogPodatka = nizBpg[kliknutiRedIPGVC!]
    }
    
    func OmoguciAktivnostPoljaRadiIzmene() {
        //labelaBroj.isUserInteractionEnabled = true
        //labelaNaziv.isUserInteractionEnabled = true
        labelaAdresa.isUserInteractionEnabled = true
        labelaTelefon.isUserInteractionEnabled = true
        lbMesto.isUserInteractionEnabled = true
        lbJmbg.isUserInteractionEnabled = true
        lbTr.isUserInteractionEnabled = true
        lbBrLK.isUserInteractionEnabled = true
        
        //labelaNaziv.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        labelaAdresa.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        //labelaBroj.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        labelaTelefon.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        
        lbMesto.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        lbJmbg.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        lbBrLK.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)
        lbTr.addTarget(self, action: #selector(PrikaziPopUp), for: .touchDown)

    }
    
    enum Greske: Error {
        case NisuUnetiSviParametri
        case SlovniUnosJePrekratak
        case BPGNijeValidan
        case TelefonNijeValidan
        case JMBGNijeValidan
    }
    
    func ProveriValidnostUnosa(x: String?, y: String?, a: Int64?, b: Int64?, c: String?) throws -> Bool {
        guard a! > 700_000_000_000 else {
            throw Greske.BPGNijeValidan
        }
        guard (x?.characters.count)! > 3 && (y?.characters.count)! > 3 else {
            throw Greske.SlovniUnosJePrekratak
        }
        guard b! >= 100_000 else {
            throw Greske.TelefonNijeValidan
        }
        guard String(c!).characters.count == 13 else {
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
    
    @IBAction func Sacuvaj(_ sender: Any) {
        do {
            let svaPoljaSuIspunjena =  try ProveriDaLiSuSvaPoljaPopunjena(naziv: labelaNaziv.text, adresa: labelaAdresa.text, telefon: labelaTelefon.text, bpg: labelaBroj.text, mestoIn: lbMesto.text, jmbgIn: lbJmbg.text, brLicneIn: lbBrLK.text, tekuciRacunIn: lbTr.text)
            if svaPoljaSuIspunjena && identifikatorIzmenjenogPodatka != nil {
                
                let strNazivPG = labelaNaziv.text!
                let strAdresaPG = labelaAdresa.text!
                let intBrojPG = Int64(labelaBroj.text!)!
                let intTelefonPG = Int64(labelaTelefon.text!)!
                
                let mesto = lbMesto.text!
                let jmbg = lbJmbg.text!
                let brLicne = Int64(lbBrLK.text!)
                let tekuciRacun = lbTr.text!
                
                do {
                    let unosJeValidan = try ProveriValidnostUnosa(x: strNazivPG, y: strAdresaPG, a: intBrojPG, b: intTelefonPG, c: jmbg)
                    
                    if unosJeValidan {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            else {
                                return
                        }
                        
                        let managedContext = appDelegate.persistentContainer.viewContext
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviPG")
                        // najpre pronalazimo gazdinstvo i zatim ga brisemo komplet iz baze
                        do {
                            let response = try managedContext.fetch(fetchRequest)
                            for podatak in response {
                                if podatak.value(forKey: "bpg") as! Int64 == identifikatorIzmenjenogPodatka! {
                                    managedContext.delete(podatak)
                                    do {
                                        ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "Brisem gazdinstvo radi upisa izmene: \(podatak)")
                                        try managedContext.save()
                                        
                                        // zatim vrsimo novi upis gazdinstva sve sa podacima koje je korisnik naumio da izmeni
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
                                            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem izmenu podatka gazdinstva kao potpuno novo gazdinstvo: \(zapis)")
                                            labelaNaziv.text = ""
                                            labelaAdresa.text = ""
                                            labelaTelefon.text = ""
                                            labelaBroj.text = ""
                                            
                                            lbTr.text = ""
                                            lbBrLK.text = ""
                                            lbJmbg.text = ""
                                            lbMesto.text = ""
                                            
                                            nizNaziv = []
                                            nizAdresa = []
                                            nizTelefon = []
                                            nizBpg = []
                                            
                                            nizJmbg = []
                                            nizTR = []
                                            nizBrLK = []
                                            nizMesto = []
                                            
                                            PovuciPodatke()
                                            tabelaPrikaziGazdinstva.reloadData()
                                        } catch let error as NSError {
                                            print("Ne mogu da upisem izmenu podatka za gazdinstvo! \(error)")
                                        }
                                    } catch let error as NSError {
                                        print("Ne mogu da obrisem podatak radi upisa izmene! \(error)")
                                    }
                                }
                            }
                        } catch let error as NSError {
                            print("Ne mogu da preuzmem podatak radi upisa izmene! \(error)")
                        }
                    }
                } catch {
                    print("Dogodila se greska pri izmeni podatka gazdinstva", error)
                }
            }
        } catch {
            print("nisu sva polja ispunjena \(error)")
        }
        kliknutiRedIPGVC = nil
        identifikatorIzmenjenogPodatka = nil
    }
   
    func PrikaziPopUp(sender: UITextField) {
        let popUp = UIAlertController(title: "Unesite izmenu podataka za polje: \(sender.placeholder!) ",
                                      message: "Klikom na predPotvrdi a zatim na SACUVAJ vrsite izmenu",
                                      preferredStyle: UIAlertControllerStyle.alert)

        let predPotvrdiAction = UIAlertAction(title: "PredPotvrdi",
                                              style: UIAlertActionStyle.default,
                                              handler: {(alert: UIAlertAction!) in
                                                self.PrenosimIzmenuKaOdgovarajucemTf(sender: sender)
                                                        })
        let otkaziAction = UIAlertAction(title: "OTKAZI",
                                         style: UIAlertActionStyle.cancel)
        
        numeruckaTastatura = KojiTipTastature(sender: sender)
        popUp.addAction(predPotvrdiAction)
        popUp.addAction(otkaziAction)
        popUp.addTextField(configurationHandler: DodajTfSaSledecimParametrima)
        present(popUp, animated: true, completion: nil)
    }

    func PrenosimIzmenuKaOdgovarajucemTf(sender: UITextField) {
        sender.text = novaVrednost?.text! ?? "korisnik je ostavio prazno polje"
    }
    
    func DodajTfSaSledecimParametrima(sender: UITextField!){
        sender.placeholder = "Unesi zeljeni podatak"
        if numeruckaTastatura {
            sender.keyboardType = .numberPad
        } else {
            sender.keyboardType = .default
            sender.autocapitalizationType = .allCharacters
        }
        novaVrednost = sender
    }
  
    func KojiTipTastature(sender: UITextField) -> Bool {
        for karakter in (sender.text?.characters)! {
            if karakter >= "A" && karakter <= "Z" || karakter >= "a" && karakter <= "z" {
                return false
            }
        }
        return true
    }   
}
