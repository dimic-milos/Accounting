//
//  PoljoprivrednaGazdinstvaGlavniMeni.swift
//  accounting
//
//  Created by Dimic Milos on 5/14/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData



class PoljoprivrednaGazdinstvaGlavniMeni: UIViewController, UITableViewDelegate, UITableViewDataSource {
var kliknutiRedPGGMVC: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelaPG.delegate = self
        tabelaPG.dataSource = self
        self.view.backgroundColor = .red
        DodajDugmeZaNazad()
    }
    
    @IBOutlet weak var tabelaPG: UITableView!
    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaPg", sender: nil)
    }
    
    // MARK: Helpers
    func sectionHeaderName(forSection section: Int) -> String {
        return opcijePGSekcije[section]
    }
    
    let opcijePG = ["Baza Gazdinstva" : ["Unesi novo gazdinstvo", "Izmeni podatke vec postojeceg gazdinstva", "Izbrisi gazdinstvo"],
                    "Izvestaji" : ["Prikazi gazdinstva", "Pregled gazdinstava po kriterijumima", "Finansijska Kartica gazdinstva"],
                    "Otkup Robe" : ["Unos sa listica odvage", "Prikaz listica odvage", "Sacini Otkupni List", "Prikazi otkupne listove"],
                    "Prodaja Robe" : ["Sacini UGOVOR"],
                    "Preuzimanje Robe" : ["Gazdinstvo fizicki preuzelo robu po nekom UGOVORU"],
                    "TEST" : ["Izlistaj log", "Obrisi sve IZ NECEGA", "BRISE  SVE IZ CORE DATA!!!"]]
    
    let detaljnijeOpcijePG = ["Baza Gazdinstva" : ["dodaj", "izmeni", "izbrisi"],
                              "Izvestaji" : ["sa svim pripadajucim podacima", "rezultati po razlicitim filterima", "detaljni pregled istorije finansija"],
                              "Otkup Robe" : ["unos bruto i tara sa naloga magacinu da primi", "prikazuje vec unete odvage", "generise otkupni list", "prikazuje sve otkupne listove po izabranom gazdinstvu"],
                              "Prodaja Robe" : ["Stvaranje novog ugovora kooperacija"],
                              "Preuzimanje Robe" : ["dodeljivanje preuzimanja robe nekom UGOVORU"],
                              "TEST" : ["log svih desavanja", "brise sve iz dole-navedenog entiteta", "brise iz NIZA entiteta!"]]
    
    let opcijePGSekcije = ["Baza Gazdinstva",
                           "Izvestaji",
                           "Otkup Robe",
                           "Prodaja Robe",
                           "Preuzimanje Robe",
                           "TEST"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return opcijePGSekcije.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return opcijePGSekcije[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionHeaderName(forSection: section)
        return opcijePG[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "pgPrototipCelija")
        let key = sectionHeaderName(forSection: (indexPath as NSIndexPath).section)
        celija?.textLabel?.text = opcijePG[key]![(indexPath as NSIndexPath).row]
        celija?.detailTextLabel?.text = detaljnijeOpcijePG[key]![(indexPath as NSIndexPath).row]
        return celija!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0,0] {
            performSegue(withIdentifier: "sgUnosNovogPG", sender: nil)
        } else if indexPath == [1,0] {
            performSegue(withIdentifier: "sgPrikaziGazdinstva", sender: nil)
        } else if indexPath == [0, 2] {
            performSegue(withIdentifier: "sgIzbrisiGazdinstvo", sender: nil)
        } else if indexPath == [0,1] {
            performSegue(withIdentifier: "sgIzmeniPodatkeGazdinstva", sender: nil)
        } else if indexPath == [1,1] {
            dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = nil
            performSegue(withIdentifier: "sgFiltriranaGazdinstva", sender: nil)
        } else if indexPath == [2,0] {
            performSegue(withIdentifier: "sgUnosOdvagaOdGazdinstava", sender: nil)
        } else if indexPath == [2,1] {
            performSegue(withIdentifier: "sgPrikazUnetihListicaOdvage", sender: nil)
        } else if indexPath == [2,2] {
            dummyAppDelegate?.pzvImeGazdinstva = nil
             dummyAppDelegate?.pzvBPG = nil
             dummyAppDelegate?.pzvAdresa = nil
            dummyAppDelegate?.pzvPovratniTekuciRacunGazdinstva = nil
            
             dummyAppDelegate?.pzvBruto = nil
             dummyAppDelegate?.pzvTara = nil
             dummyAppDelegate?.pzvNeto = nil
             dummyAppDelegate?.pzvBrNalogaMagDP = nil
             dummyAppDelegate?.pzvKojaRoba = nil
             dummyAppDelegate?.pzvOdbitak = nil
             dummyAppDelegate?.pzvJUS = nil
            
             dummyAppDelegate?.pzvUkupnaVrednostOtvorenihAvansa = nil
             dummyAppDelegate?.pzvUkupnaVrednostOtvorenihUgovora = nil
             dummyAppDelegate?.pzvUkupniSaldoBezObziraNaValutu = nil
            
             dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost = nil
             dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost = nil
            
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje = nil
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule = nil
            
            performSegue(withIdentifier: "sgGenerisiOtkupniList", sender: nil)
        } else if indexPath == [1,2] {
            dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFinansijskaKarticaGazdinstva = nil
            performSegue(withIdentifier: "sgFinansijskaKarticaGazdinstva", sender: nil)
        } else if indexPath == [3,0] {
            performSegue(withIdentifier: "sgGenerisiUgovorSaGazdinstvom", sender: nil)
        } else if indexPath == [4,0] {
            performSegue(withIdentifier: "sgGazdinstvoPreuzimaRobuPoUgovoru", sender: nil)
        } else if indexPath == [2,3] {
            performSegue(withIdentifier: "sgPrikazOtkupnihListova", sender: nil)
        }



        
        
        
        
        
        if indexPath == [5,0] { // prikazuje log
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Log")
            do {
                let response = try managedContext.fetch(fetchRequest)
                for podatak in response {
                    print(podatak.value(forKey: "jeb") as Any, podatak.value(forKey: "staSeDesilo") as Any)
                }
                
            } catch let error as NSError {
                print("Ne mogu da preuzmem podatak za citanje \(error)")
            }
           
        } else if indexPath == [5,1] { // brise sve iz dolenavedenog entiteta
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "KursnaLista")
            
            do {
                let response = try managedContext.fetch(fetchRequest)
                for podatak in response {
                    managedContext.delete(podatak)
                    do {
                        try managedContext.save()
                        print("Iz baze podataka je obrisan zapis \(podatak)")
                        
                    } catch let error as NSError {
                        print("Ne mogu da obrisem podatak! \(error)")
                    }
                }
            } catch let error as NSError {
                print("Ne mogu da preuzmem podatak! \(error)")
            }
            
        } else if indexPath == [5,2] {   // brise sve iz dolenavedenog niza entiteta
            
            let spisakEntitetaZaBrisanje = ["AvansiGazdinstvima", "KursnaLista", "ListaDjubriva", "Log", "NalogMagacinuDaIzdaRobuPoUgovoru", "OtkupniList", "PrijemRobeSaVageOdPG", "SviDOO", "SviPG", "UgovorSaGazdinstvomKooperacija"]
            
            for entitet in spisakEntitetaZaBrisanje {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    else {
                        return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entitet)
                
                do {
                    let response = try managedContext.fetch(fetchRequest)
                    for podatak in response {
                        managedContext.delete(podatak)
                        do {
                            try managedContext.save()
                            print("Iz baze podataka je obrisan zapis \(podatak)")
                            
                        } catch let error as NSError {
                            print("Ne mogu da obrisem podatak! \(error)")
                        }
                    }
                } catch let error as NSError {
                    print("Ne mogu da preuzmem podatak! \(error)")
                }
            }
          
        }
    }
}





