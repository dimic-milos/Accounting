//
//  FiltriranaGazdinstvaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/17/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//sg-FiltrGazd->GenOtkList

import UIKit
import CoreData

class FiltriranaGazdinstvaVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var unosImenaGazdinstvaSaDrugogVC: String?
    
    var selektovanoImePG: String?
    var selektovanaAdresaPG: String?
    var selektovaniBPG: Int64?
    
    var selektovanoMesto: String?
    var selektovanTekuciRacun: String?
    var selektovanTelefon: Int64?
    var selektovanJmbg: String?
    var selektovanBrojLicneKarte: Int64?
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sg-FiltrGazd->GenOtkList" {
            if let generisiOtkupniListVC = segue.destination as? GenerisiOtkupniListVC {
                generisiOtkupniListVC.povratnoImeGazdinstva = selektovanoImePG
                generisiOtkupniListVC.povratnaAdresaGazdinstva = selektovanaAdresaPG
                generisiOtkupniListVC.povratniBPG = selektovaniBPG
                generisiOtkupniListVC.povratniTekuciRacunGazdinstva = selektovanTekuciRacun
            }
        } else if segue.identifier == "sg-FiltrGazd->DodajPromeneSaIzvoda" {
            if let dodajPromeneSaIzvodaVC = segue.destination as? DodajPromeneSaIzvoda {
                dodajPromeneSaIzvodaVC.povratnoIme = selektovanoImePG
                dodajPromeneSaIzvodaVC.povratniBroj = selektovaniBPG
            }
        } else if segue.identifier == "sg-FiltrGazd->FinansijskaKarticaGazdinstva" {
            if let finansijskaKarticaGazdinstvaVC = segue.destination as? FinansijskaKarticaGazdinstvaVC {
                finansijskaKarticaGazdinstvaVC.povratnoIme = selektovanoImePG
                finansijskaKarticaGazdinstvaVC.povratniBroj = selektovaniBPG
            }
        } else if segue.identifier == "sg-FiltrGazd->GenerisiUgovorSaGazdinstvomVC" {
            if let generisiUgovorSaGazdinstvomVC = segue.destination as? GenerisiUgovorSaGazdinstvomVC {
                generisiUgovorSaGazdinstvomVC.povratnoIme = selektovanoImePG
                generisiUgovorSaGazdinstvomVC.povratniBroj = selektovaniBPG
                generisiUgovorSaGazdinstvomVC.povratnoMesto = selektovanoMesto
                generisiUgovorSaGazdinstvomVC.povratniTekuciRacun = selektovanTekuciRacun
                generisiUgovorSaGazdinstvomVC.povratniTelefon = selektovanTelefon
                generisiUgovorSaGazdinstvomVC.povratniJmbg = selektovanJmbg
                generisiUgovorSaGazdinstvomVC.povratniBrojLicneKarte = selektovanBrojLicneKarte
                generisiUgovorSaGazdinstvomVC.povratnaAdresaPG = selektovanaAdresaPG
            }
        } else if segue.identifier == "sg-FiltrGazd->GazdinstvoPreuzimaRobuPoUgovoruVC" {
            if let gazdinstvoPreuzimaRobuPoUgovoruVC = segue.destination as? GazdinstvoPreuzimaRobuPoUgovoruVC {
                gazdinstvoPreuzimaRobuPoUgovoruVC.povratnoIme = selektovanoImePG
                gazdinstvoPreuzimaRobuPoUgovoruVC.povratniBroj = selektovaniBPG
            }
        } else if segue.identifier == "sg-FiltrGazd->PrikazOtkupnihListovaVC" {
            if let prikazOtkupnihListovaVC = segue.destination as? PrikazOtkupnihListovaVC {
                prikazOtkupnihListovaVC.povratnoIme = selektovanoImePG
                prikazOtkupnihListovaVC.povratniBroj = selektovaniBPG
            }
        }

        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfPretragaPoBpg.delegate = self
        tabelaPrikaziGazdinstva.delegate = self
        tabelaPrikaziGazdinstva.dataSource = self
        
        swPoNazivu.isOn = false
        swPoBpg.isOn = false
        
        tfPretragaPoNazivu.tag = 100
        tfPretragaPoBpg.tag = 101
        tfPretragaPoBpg.addTarget(self, action: #selector(DrziSamoJedanSwOn), for: .touchDown)
        tfPretragaPoNazivu.addTarget(self, action: #selector(DrziSamoJedanSwOn), for: .touchDown)
        
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.orange
        
        PreuzmiPotencijalniUnosSaDrugogVC()
        DodajDugmeZaNazad()
    }
    
    func PreuzmiPotencijalniUnosSaDrugogVC() {
        if unosImenaGazdinstvaSaDrugogVC != nil {
            tfPretragaPoNazivu.text = unosImenaGazdinstvaSaDrugogVC!
            swPoNazivu.isOn = true
            Filtriraj(self)
        }
    }
    
    // moralo se limitirati na devet zbog nepreciznosti predikata
    let limitLength = 9
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaFiltriranaGazdinstva", sender: nil)
    }
    
    
    @IBOutlet weak var tabelaPrikaziGazdinstva: UITableView!
    @IBOutlet weak var tfPretragaPoNazivu: UITextField!
    @IBOutlet weak var tfPretragaPoBpg: UITextField!
    @IBOutlet weak var swPoNazivu: UISwitch!
    @IBOutlet weak var swPoBpg: UISwitch!
    
    
    var nizNaziv: [String] = []
    var nizAdresa: [String] = []
    var nizBpg: [Int64] = []
    var nizTelefon: [Int64] = []
    
    var nizBrojLicneKarte: [Int64] = []
    var nizMesto: [String] = []
    var nizJmbg: [String] = []
    var nizTekuciRacun: [String] = []
    
    @IBAction func Filtriraj(_ sender: Any) {
        nizNaziv = []
        nizAdresa = []
        nizBpg = []
        nizTelefon = []
        
        nizBrojLicneKarte = []
        nizMesto = []
        nizJmbg = []
        nizTekuciRacun = []
        
        if swPoNazivu.isOn && !swPoBpg.isOn {
            FiltrirajPoNazivu()
            tabelaPrikaziGazdinstva.reloadData()
        } else if !swPoNazivu.isOn && swPoBpg.isOn {
            FiltrirajPoBpg()
            tabelaPrikaziGazdinstva.reloadData()
        } else if swPoNazivu.isOn && swPoBpg.isOn {
            var setPoNazivu = Set<Int64>()
            var setPoBpg = Set<Int64>()
            
            FiltrirajPoNazivu()
            for clan in nizBpg {
                setPoNazivu.insert(clan)
            }
            nizNaziv = []
            nizAdresa = []
            nizBpg = []
            nizTelefon = []
            
            nizBrojLicneKarte = []
            nizMesto = []
            nizJmbg = []
            nizTekuciRacun = []
            
            FiltrirajPoBpg()
            for clan in nizBpg {
                setPoBpg.insert(clan)
            }
            nizNaziv = []
            nizAdresa = []
            nizBpg = []
            nizTelefon = []
            
            nizBrojLicneKarte = []
            nizMesto = []
            nizJmbg = []
            nizTekuciRacun = []
            
            var setPoNazivuPoBpg = setPoNazivu.intersection(setPoBpg)
            for clan in setPoNazivuPoBpg {
                print(clan)
                tfPretragaPoBpg.text = String(clan / 1000) // zbog nepreciznosti koje predicate %i svodi na devet cifara
                FiltrirajPoBpg()
            }
            print(nizBpg)
            tabelaPrikaziGazdinstva.reloadData()
            tfPretragaPoBpg.text = ""
            tfPretragaPoNazivu.text = ""
            setPoNazivuPoBpg = []
            setPoBpg = []
            setPoNazivuPoBpg = []
        }
        
    }
    
    func DrziSamoJedanSwOn(sender: UISwitch) {
        if sender.tag == 100 {
            swPoNazivu.isOn = true
            swPoBpg.isOn = false
        } else if sender.tag == 101 {
            swPoNazivu.isOn = false
            swPoBpg.isOn = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizNaziv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaFGVC", for: indexPath)
        celija.textLabel?.text = nizNaziv[indexPath.row]
        celija.detailTextLabel?.text = nizAdresa[indexPath.row]
        return celija
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selektovanoImePG = nizNaziv[indexPath.row]
        selektovanaAdresaPG = nizAdresa[indexPath.row]
        selektovaniBPG = nizBpg[indexPath.row]
        selektovanoMesto = nizMesto[indexPath.row]
        selektovanJmbg = nizJmbg[indexPath.row]
        selektovanTelefon = nizTelefon[indexPath.row]
        selektovanTekuciRacun = nizTekuciRacun[indexPath.row]
        selektovanBrojLicneKarte = nizBrojLicneKarte[indexPath.row]
        
        if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-GenOtkList->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->GenOtkList", sender: nil)
        } else if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-DodajPromeneSaIzvoda->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->DodajPromeneSaIzvoda", sender: nil)
        } else if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-FinansijskaKarticaGazdinstva->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->FinansijskaKarticaGazdinstva", sender: nil)
        } else if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-GenerisiUgovorSaGazdinstvomVC->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->GenerisiUgovorSaGazdinstvomVC", sender: nil)
        } else if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-GazdinstvoPreuzimaRobuPoUgovoruVC->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->GazdinstvoPreuzimaRobuPoUgovoruVC", sender: nil)
        } else if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva == "sg-PrikazOtkupnihListovaVC->FiltrGazd" {
            performSegue(withIdentifier: "sg-FiltrGazd->PrikazOtkupnihListovaVC", sender: nil)
        }


    }
    
    func FiltrirajPoNazivu() {
        let filter = tfPretragaPoNazivu.text!
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviPG")
        let predicate = NSPredicate(format: "naziv CONTAINS[cd] %@", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let naziv = podatak.value(forKey: "naziv")
                let adresa = podatak.value(forKey: "adresa")
                let bpg = podatak.value(forKey: "bpg")
                let telefon = podatak.value(forKey: "telefon")
                
                let brojLicneKarte = podatak.value(forKey: "brojLicneKarte")
                let mesto = podatak.value(forKey: "mesto")
                let jmbg = podatak.value(forKey: "jmbg")
                let tekuciRacun = podatak.value(forKey: "tekuciRacun")
                
                nizNaziv.append(naziv! as! String)
                nizAdresa.append(adresa! as! String)
                nizBpg.append(bpg! as! Int64)
                nizTelefon.append(telefon! as! Int64)
                
                nizBrojLicneKarte.append(brojLicneKarte! as! Int64)
                nizMesto.append(mesto! as! String)
                nizJmbg.append(jmbg! as! String)
                nizTekuciRacun.append(tekuciRacun! as! String)
                
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
    }
    
    func FiltrirajPoBpg() {
        // koristi predicate %i pa je zbog toga je preciznost svedena na devet cifara
        guard let filter = Int64(tfPretragaPoBpg!.text!) else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviPG")
        let vrednost: Int64 = Int64(filter)
        print("udjoh u filtriram pobpg za sledeci value \(vrednost)")
        let predicate = NSPredicate(format: "bpg CONTAINS[cd] %i", vrednost)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let naziv = podatak.value(forKey: "naziv")
                let adresa = podatak.value(forKey: "adresa")
                let bpg = podatak.value(forKey: "bpg")
                let telefon = podatak.value(forKey: "telefon")
                
                let brojLicneKarte = podatak.value(forKey: "brojLicneKarte")
                let mesto = podatak.value(forKey: "mesto")
                let jmbg = podatak.value(forKey: "jmbg")
                let tekuciRacun = podatak.value(forKey: "tekuciRacun")
                
                nizNaziv.append(naziv! as! String)
                nizAdresa.append(adresa! as! String)
                nizBpg.append(bpg! as! Int64)
                nizTelefon.append(telefon! as! Int64)
                
                nizBrojLicneKarte.append(brojLicneKarte! as! Int64)
                nizMesto.append(mesto! as! String)
                nizJmbg.append(jmbg! as! String)
                nizTekuciRacun.append(tekuciRacun! as! String)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }

    }
    
    
    
}
