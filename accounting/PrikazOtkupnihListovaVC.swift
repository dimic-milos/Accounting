//
//  PrikazOtkupnihListovaVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/16/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class PrikazOtkupnihListovaVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        DodajDugmeZaNazad()
        PreuzmiImeSaDrugogVC()
        tabela.dataSource = self
        tabela.delegate = self
    }
    
    @IBOutlet weak var tfUnesiIme: UITextField!
    @IBOutlet weak var labelaBroj: UILabel!

    @IBOutlet weak var tabela: UITableView!
    
    var povratnoIme: String?
    var povratniBroj: Int64?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sg-PrikazOtkupnihListovaVC->FiltrGazd" {
            if let filtriranaGazdinstva = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstva.unosImenaGazdinstvaSaDrugogVC = potencijalnoIme
            }
        } else if segue.identifier == "sg-PrikazOtkupnihListova->DodajPromeneSaIzvoda" {
            if let dodajPromeneSaIzvoda = segue.destination as? DodajPromeneSaIzvoda{
                dodajPromeneSaIzvoda.povratnoIme = povratnoIme
                dodajPromeneSaIzvoda.povratniBroj = povratniBroj
               
                dodajPromeneSaIzvoda.povratniBrojOtkupnogLista = izabraniBrojOtkupnogLista
                dodajPromeneSaIzvoda.povratniPdvJeUplacen = izabraniPdvJeUplacen
                dodajPromeneSaIzvoda.povratniZaUplatuPGuJeUplaceno = izabraniZaUplatuPGuJeUplaceno
                dodajPromeneSaIzvoda.povratniVrednostPDV = izabraniVrednostPDV
                dodajPromeneSaIzvoda.povratniZaUplatuPGu = izabraniZaUplatuPGu
                dodajPromeneSaIzvoda.povratniKnjizenoUplateNaOvajOtkupniList = izabraniKnjizenoUplateNaOvajOtkupniList
            }
        }
    }
    
    var potencijalnoIme: String?
    @IBAction func IzaberiKomintenta(_ sender: Any) {
        potencijalnoIme = tfUnesiIme.text
        dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-PrikazOtkupnihListovaVC->FiltrGazd"
        performSegue(withIdentifier: "sg-PrikazOtkupnihListovaVC->FiltrGazd", sender: nil)
    }
    
    func PreuzmiImeSaDrugogVC() {
        if povratnoIme != nil {
            tfUnesiIme.text = povratnoIme!
            labelaBroj.text = String(povratniBroj!)
            
            PovuciEventualneOtkupneListoveNapuniTabelu()
            tabela.reloadData()
        }
    }

    var nizBrojOtkupnogLista: [Int32] = []
    var nizRobaKojaJeOtkupljena: [String] = []
    var nizJus: [Int32] = []
    var nizZaUplatuPGu: [Decimal?] = []
    var nizVrednostPDV: [Double] = []
    var nizUkupnoSkinutoSaUgovora: [Decimal?] = []
    var nizPdvJeUplacen: [Bool] = []
    var nizZaUplatuPGuJeUplaceno: [Bool] = []
    var nizDatumIzradeOtkupnogLista: [Date] = []
    var nizKnjizenoUplateNaOvajOtkupniList: [Decimal] = []
    func PovuciEventualneOtkupneListoveNapuniTabelu() {
        guard let filter = povratnoIme else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OtkupniList")
        
        print("postavljam predikat za \(filter)")
        let predicate = NSPredicate(format: "nazivPG = %@", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let brojOtkupnogLista = podatak.value(forKey: "brojOtkupnogLista")
                let robaKojaJeOtkupljena = podatak.value(forKey: "robaKojaJeOtkupljena")
                let jus = podatak.value(forKey: "jus")
                let zaUplatuPGu = podatak.value(forKey: "zaUplatuPGu")
                let vrednostPDV = podatak.value(forKey: "vrednostPDV")
                let ukupnoSkinutoSaUgovora = podatak.value(forKey: "ukupnoSkinutoSaUgovora")
                let pdvJeUplacen = podatak.value(forKey: "pdvJeUplacen")
                let zaUplatuPGuJeUplaceno = podatak.value(forKey: "zaUplatuPGuJeUplaceno")
                let datumIzradeOtkupnogLista = podatak.value(forKey: "datumIzradeOtkupnogLista")
                let knjizenoUplateNaOvajOtkupniList = podatak.value(forKey: "knjizenoUplateNaOvajOtkupniList")
                
                nizBrojOtkupnogLista.append(brojOtkupnogLista! as! Int32)
                nizRobaKojaJeOtkupljena.append(robaKojaJeOtkupljena! as! String)
                nizJus.append(jus! as! Int32)
                nizZaUplatuPGu.append(zaUplatuPGu as? Decimal)
                nizVrednostPDV.append(vrednostPDV as! Double)
                nizUkupnoSkinutoSaUgovora.append(ukupnoSkinutoSaUgovora as? Decimal)
                nizPdvJeUplacen.append(pdvJeUplacen! as! Bool)
                nizZaUplatuPGuJeUplaceno.append(zaUplatuPGuJeUplaceno! as! Bool)
                nizDatumIzradeOtkupnogLista.append(datumIzradeOtkupnogLista! as! Date)
                nizKnjizenoUplateNaOvajOtkupniList.append(knjizenoUplateNaOvajOtkupniList! as! Decimal)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih ugovora u tabeli! \(error)")
        }
    }

   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizBrojOtkupnogLista.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelija", for: indexPath) as? PrikazOtkupnihListovaTableVC
        celija?.labelaBrojOtkupnogLista.text = "Broj Otkupnog Lista " + String(nizBrojOtkupnogLista[indexPath.row])
        
        // uredjuje datum u citljiviju formu
        let uredjujemDatum = DateFormatter()
        uredjujemDatum.dateFormat = "dd MMM yyyy"
        let selektovaniDatum = uredjujemDatum.string(from: nizDatumIzradeOtkupnogLista[indexPath.row])
        celija?.labelaDatumIzradeOtkupnogLista.text = selektovaniDatum
        celija?.labelaRobaKojaJeOtkupljena.text = nizRobaKojaJeOtkupljena[indexPath.row]
        celija?.labelaJus.text = String(nizJus[indexPath.row]) + " JUS Kg"
        celija?.labelaZaUplatuPGu.text = "Za uplatu: " + String(format: "%.2f", locale: Locale.current, (nizZaUplatuPGu[indexPath.row] ?? 0).doubleValue.roundTo(places: 2)) + " Din"
        celija?.labelaVrednostPDV.text = "Vrednost PDV-a: " + String(format: "%.2f", locale: Locale.current, nizVrednostPDV[indexPath.row].roundTo(places: 2)) + " Din"
        celija?.labelaUkupnoSkinutoSaUgovora.text = "Sa ugovora: " + String(format: "%.2f", locale: Locale.current, (nizUkupnoSkinutoSaUgovora[indexPath.row] ?? 0).doubleValue.roundTo(places: 2)) + " Din"
        celija?.labelaKnjizenoUplateNaOvajOtkupniList.text = "Uplaceno: " + String(format: "%.2f", locale: Locale.current, nizKnjizenoUplateNaOvajOtkupniList[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
            if nizPdvJeUplacen[indexPath.row] && nizZaUplatuPGuJeUplaceno[indexPath.row] {
            celija?.roProgres.setProgress(1, animated: true)
        } else if !nizPdvJeUplacen[indexPath.row] && !nizZaUplatuPGuJeUplaceno[indexPath.row] {
            celija?.roProgres.setProgress(0, animated: true)
        } else if (!nizPdvJeUplacen[indexPath.row] && nizZaUplatuPGuJeUplaceno[indexPath.row]) || (nizPdvJeUplacen[indexPath.row] && !nizZaUplatuPGuJeUplaceno[indexPath.row]) {
            celija?.roProgres.setProgress(0.5, animated: true)
        }
        
        
        if nizPdvJeUplacen[indexPath.row] {
            celija?.labelaPdvJeUplacen.text = "PDV Placen"
            celija?.labelaPdvJeUplacen.backgroundColor = .green
        } else {
            celija?.labelaPdvJeUplacen.text = "PDV NE!!!"
            celija?.labelaPdvJeUplacen.backgroundColor = .red
        }
        
        if nizZaUplatuPGuJeUplaceno[indexPath.row] {
            celija?.labelaZaUplatuPGuJeUplaceno.text = "Ostatak Placen"
            celija?.labelaZaUplatuPGuJeUplaceno.backgroundColor = .green
        } else {
            celija?.labelaZaUplatuPGuJeUplaceno.text = "Ostatak NE!!!"
            celija?.labelaZaUplatuPGuJeUplaceno.backgroundColor = .red
        }
        
        
        return celija!
    }
    
    var selektovaniRed: Int?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selektovaniRed = indexPath.row
    }
    

    var izabraniBrojOtkupnogLista: Int32?
    var izabraniPdvJeUplacen: Bool?
    var izabraniZaUplatuPGuJeUplaceno: Bool?
    var izabraniVrednostPDV: Double?
    var izabraniZaUplatuPGu: Decimal?
    var izabraniKnjizenoUplateNaOvajOtkupniList: Decimal?
    @IBAction func IzaberiOtkupniListZaDodeluUplate(_ sender: Any) {
        if selektovaniRed != nil && povratnoIme != nil && povratnoIme != "" {
             izabraniBrojOtkupnogLista = nizBrojOtkupnogLista[selektovaniRed!]
             izabraniPdvJeUplacen = nizPdvJeUplacen[selektovaniRed!]
             izabraniZaUplatuPGuJeUplaceno = nizZaUplatuPGuJeUplaceno[selektovaniRed!]
             izabraniVrednostPDV = nizVrednostPDV[selektovaniRed!]
             izabraniZaUplatuPGu = (nizZaUplatuPGu[selektovaniRed!] ?? 0.0)
             izabraniKnjizenoUplateNaOvajOtkupniList = nizKnjizenoUplateNaOvajOtkupniList[selektovaniRed!]
  
            performSegue(withIdentifier: "sg-PrikazOtkupnihListova->DodajPromeneSaIzvoda", sender: nil)
        } else {
            PrikaziNeuspesniPopUp(poruka: "Nema Svih Podatak (nije odabran otkupni list ili nije odabrano gazdinstvo)")
        }
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
        performSegue(withIdentifier: "sgGlavniSaPrikazOtkupnihListova", sender: nil)
    }
}
