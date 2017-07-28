//
//  PrikazUnetihListicaOdvageVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/19/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class PrikazUnetihListicaOdvageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var potencijalniBruto: Int32?
    var potencijalnaTara: Int32?
    var potencijalniNeto: Int32?
    var potencijalniBrojNalogaMagacinuDaPrimi: [Int32]?
    var potencijalnaKojaRoba: String?
    var potencijalniOdbitak: Int32?
    var potencijalniJUS: Int32?
    var potencijalniDatumPrijema: Date?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if setSelektovanihOdvaga.count != 0 {
            if segue.identifier == "sg-PrikazUnetihListicaOdvage->GenOtkList" {
                if let generisiOtkupniList = segue.destination as? GenerisiOtkupniListVC {
                    if generisiOtkupniList.potencijalniBruto == nil { // videti iz kog razloga puca ukoliko se ovaj uslov ukloni. Pucalo je kad se unese prvo PG pa zatim odvaga. A nije pucalo ukoliko se prvo unosi odvaga
                        generisiOtkupniList.potencijalniBruto = potencijalniBruto
                        generisiOtkupniList.potencijalnaTara = potencijalnaTara
                        generisiOtkupniList.potencijalniNeto = potencijalniNeto
                        generisiOtkupniList.potencijalniBrojNalogaMagacinuDaPrimi = potencijalniBrojNalogaMagacinuDaPrimi
                        generisiOtkupniList.potencijalnaKojaRoba = potencijalnaKojaRoba
                        generisiOtkupniList.potencijalniOdbitak = potencijalniOdbitak
                        generisiOtkupniList.potencijalniJUS = potencijalniJUS
                        generisiOtkupniList.potencijalniDatumPrijema = potencijalniDatumPrijema
                    }

                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        DodajDugmeZaNazad()
        PovuciPodatke()
    }

    @IBOutlet weak var tabelaPrikaziOdvage: UITableView!
    
    var nizDatum: [Date] = []
    var nizBrNalogaMDP: [Int32] = []
    var nizBruto: [Int32] = []
    var nizTara: [Int32] = []
    var nizNeto: [Int32] = []
    var niziwOdvagaUpotrebljena: [Bool] = []
    var nizKojaRoba: [String] = []
    
    var nizOdbitakKgZbogPrimesa: [Int32] = []
    var nizOdbitakKgZbogVlage: [Int32] = []
    var nizProsecnaVlaga: [Double?] = []
    var nizProsecnaPrimesa: [Double?] = []
    
    var nizOdbitakKg: [Int32] = []
    var nizUkupnoJUSkg: [Int32] = []
    
    
    func PovuciPodatke() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PrijemRobeSaVageOdPG")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let brNalogaMDP = podatak.value(forKey: "brojNalogaMagacinuDaPrimi")
                let datum = podatak.value(forKey: "datumPrijema")
                let kojaJeRoba = podatak.value(forKey: "kojaRoba")
                let iwOdvagaUpotrebljena = podatak.value(forKey: "nalogMagacniuDaPrimiUpotrebljen")
                let odbitakKgVlaga = podatak.value(forKey: "odbitakKgZbogVlage")
                let odbitakKgPrimesa = podatak.value(forKey: "odbitakKgZbogPrimesa")
                let prosecnaVlagaNaloga = podatak.value(forKey: "prosecnaVlagaNalogaMDP")
                let prosecnaPrimesaNaloga = podatak.value(forKey: "prosecnePrimeseNalogaMDP")
                let tara = podatak.value(forKey: "ukupnaTara") as! Int32
                let bruto = podatak.value(forKey: "ukupniBruto") as! Int32
                
                let odbitakKg = podatak.value(forKey: "ukupniOdbitakKg")
                let jusKg = podatak.value(forKey: "ukupnoJUSkg")
                
                let neto = (podatak.value(forKey: "ukupniBruto") as! Int32) - (podatak.value(forKey: "ukupnaTara") as! Int32)
                
                
                

                
                nizDatum.append(datum! as! Date)
                nizBrNalogaMDP.append(brNalogaMDP! as! Int32)
                nizBruto.append(bruto)
                nizTara.append(tara)
                nizNeto.append(neto)
                niziwOdvagaUpotrebljena.append(iwOdvagaUpotrebljena! as! Bool)
                nizKojaRoba.append(kojaJeRoba as! String)
                
                nizOdbitakKgZbogPrimesa.append(odbitakKgVlaga as! Int32)
                nizOdbitakKgZbogVlage.append(odbitakKgPrimesa as! Int32)
                
                nizProsecnaVlaga.append(prosecnaVlagaNaloga as? Double) 
                nizProsecnaPrimesa.append(prosecnaPrimesaNaloga as? Double)
                
                nizOdbitakKg.append(odbitakKg as! Int32)
                nizUkupnoJUSkg.append(jusKg as! Int32)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizBrNalogaMDP.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaPrikaziOdvage", for: indexPath) as? OdvageTableVC
        
        if niziwOdvagaUpotrebljena[indexPath.row] {
            celija?.iwOdvagaUpotrebljena.backgroundColor = UIColor.green
        } else {
            celija?.iwOdvagaUpotrebljena.backgroundColor = UIColor.red
        }
        celija?.labelaBrNalogaMDP.text = "Br naloga " + String(nizBrNalogaMDP[indexPath.row])
       
        // uredjuje datum u citljiviju formu
        let uredjujemDatum = DateFormatter()
        uredjujemDatum.dateFormat = "dd MMM yyyy"
        let selektovaniDatum = uredjujemDatum.string(from: nizDatum[indexPath.row])
        
        celija?.labelaDatum.text = selektovaniDatum        
        celija?.labelaNeto.text = "NETO " + String(nizNeto[indexPath.row]) + " KG"
        celija?.labelaKojaRoba.text = nizKojaRoba[indexPath.row]
        
        celija?.roSW.tag = indexPath.row + 1000
        celija?.roSW.addTarget(self, action: #selector(FormiramSetSelektovanihOdvaga), for: .valueChanged)
        
        if nizProsecnaVlaga[indexPath.row] != nil {
            celija?.lbPrimese.text = String(Int(nizProsecnaVlaga[indexPath.row]!))
        }
        if nizProsecnaPrimesa[indexPath.row] != nil {
            celija?.lbVlaga.text = String(Int(nizProsecnaPrimesa[indexPath.row]!))
        }
     

        return celija!
    }
    
    var setSelektovanihOdvaga = Set<Int>()
    func FormiramSetSelektovanihOdvaga(sender: UISwitch) {
        if sender.isOn {
            setSelektovanihOdvaga.insert(sender.tag)
        } else if !sender.isOn {
            setSelektovanihOdvaga.remove(sender.tag)
        }
    }
    
    
    @IBAction func PrenesiOznaceneOdvageNaOtkupniList(_ sender: Any) {
        var ukupniBruto: Int32 = 0
        var ukupnaTara: Int32 = 0
        var ukupniNeto: Int32 = 0
        var ukupniBrojNalogaMagacinuDaPrimi = [Int32]()
        var ukupnoRoba = Set<String>()
        var ukupnoOdbitak: Int32 = 0
        var ukupnoJUS: Int32 = 0
        var najranijiDatumPrijema: Date?
        
        for clan in setSelektovanihOdvaga {
            let pogledajZaIndex = clan - 1000
            
            ukupniBruto += nizBruto[pogledajZaIndex]
            ukupnaTara += nizTara[pogledajZaIndex]
            ukupniNeto += nizNeto[pogledajZaIndex]
            ukupniBrojNalogaMagacinuDaPrimi.append(nizBrNalogaMDP[pogledajZaIndex])
            ukupnoRoba.insert(nizKojaRoba[pogledajZaIndex])
            ukupnoOdbitak += nizOdbitakKg[pogledajZaIndex]
            ukupnoJUS += nizUkupnoJUSkg[pogledajZaIndex]
            
            if najranijiDatumPrijema == nil {
                najranijiDatumPrijema = nizDatum[pogledajZaIndex]
            } else {
                if ProveriDaLiJeLeviDatumRanijiOdDesnogDatuma(leviDatum: nizDatum[pogledajZaIndex], desniDatum: najranijiDatumPrijema!) {
                    najranijiDatumPrijema = nizDatum[pogledajZaIndex]
                }
            }
            
        }
        
        if ukupnoRoba.count == 1 {
            potencijalniBruto = ukupniBruto
            potencijalnaTara = ukupnaTara
            potencijalniNeto = ukupniNeto
            potencijalniBrojNalogaMagacinuDaPrimi = ukupniBrojNalogaMagacinuDaPrimi
            potencijalnaKojaRoba = ukupnoRoba.first
            potencijalniOdbitak = ukupnoOdbitak
            potencijalniJUS = ukupnoJUS
            potencijalniDatumPrijema = najranijiDatumPrijema
            
            performSegue(withIdentifier: "sg-PrikazUnetihListicaOdvage->GenOtkList", sender: nil)
        } else {
            
            PrikaziNeuspesniPopUp(poruka: "mora biti selektovana samo JEDNA ROBA a ne njih vise razlicitih. Znaci ne moze suncokret i kukuruz na jedan otkupni list!")
        }

    }
    
    func ProveriDaLiJeLeviDatumRanijiOdDesnogDatuma(leviDatum: Date, desniDatum: Date) -> Bool {
        let kakavJeDatum = Calendar.current.compare(leviDatum, to: desniDatum, toGranularity: .day)
        switch kakavJeDatum {
        case .orderedAscending:
            return true
        default:
            print("default")
        }
        return false
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
        performSegue(withIdentifier: "sgGlavniSaPrikazUnetihListicaOdvage", sender: nil)
    }
}
