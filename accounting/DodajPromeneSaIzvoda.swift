//
//  DodajPromeneSaIzvoda.swift
//  accounting
//
//  Created by Dimic Milos on 5/25/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData
class DodajPromeneSaIzvoda: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var povratniBrojOtkupnogLista: Int32?
    var povratniPdvJeUplacen: Bool?
    var povratniZaUplatuPGuJeUplaceno: Bool?
    var povratniVrednostPDV: Double?
    var povratniZaUplatuPGu: Decimal?
    var povratniKnjizenoUplateNaOvajOtkupniList: Decimal?
    
    var preostajeZaNammirenjeOtkupnogLista: Decimal?
    
    var povratnoIme: String?
    var povratniBroj: Int64?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nekoIme = potencijalnoIme
        if segue.identifier == "sg-DodajPromeneSaIzvoda->FiltrGazd" {
            if let filtriranaGazdinstva = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstva.unosImenaGazdinstvaSaDrugogVC = nekoIme
            }
        }
    }
    
    @IBOutlet weak var labelapovratniPdvJeUplacen: UILabel!
    @IBOutlet weak var labelapovratniVrednostPDV: UILabel!
    @IBOutlet weak var labelapovratniZaUplatuPGuJeUplaceno: UILabel!
    @IBOutlet weak var labelapovratniZaUplatuPGu: UILabel!
    @IBOutlet weak var labelapovratniBrojOtkupnogLista: UILabel!
    @IBOutlet weak var labelapovratniKnjizenoUplateNaOvajOtkupniList: UILabel!
    
    @IBOutlet weak var labelaPreostajeZaNammirenjeOtkupnogLista: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .yellow
        DodajDugmeZaNazad()
        
        tfOdliv.delegate = self
        tfPriliv.delegate = self
        
        piker.dataSource = self
        piker.delegate = self
        
        pikerBankaBrojIzvoda.dataSource = self
        pikerBankaBrojIzvoda.delegate = self
        
        
        tfOdliv.addTarget(self, action: #selector(OdabranJeOdlivIliPriliv(sender:)), for: .editingDidBegin)
        tfPriliv.addTarget(self, action: #selector(OdabranJeOdlivIliPriliv(sender:)), for: .editingDidBegin)
        
        tfOdliv.addTarget(self, action: #selector(PovuciIznos(sender:)), for: .editingDidEnd)
        tfPriliv.addTarget(self, action: #selector(PovuciIznos(sender:)), for: .editingDidEnd)
        
        PreuzmiImeSaDrugogVC()
        
        for _ in 0...360 {
            brojeviIzvoda.append(brojeviIzvoda.last! + 1)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if povratnoIme == nil {
            tfPriliv.isUserInteractionEnabled = false
            tfOdliv.isUserInteractionEnabled = false
        }
        
        if povratniBrojOtkupnogLista != nil {
            if povratniPdvJeUplacen! {
                labelapovratniPdvJeUplacen.text = "PDV Namiren"
                labelapovratniPdvJeUplacen.backgroundColor = .green
            } else {
                labelapovratniPdvJeUplacen.text = "PDV NE namiren"
                labelapovratniPdvJeUplacen.backgroundColor = .red
            }
            
            if povratniZaUplatuPGuJeUplaceno! {
                labelapovratniZaUplatuPGuJeUplaceno.text = "Namiren je i iznos koji je preostao"
                labelapovratniPdvJeUplacen.backgroundColor = .green
            } else {
                labelapovratniZaUplatuPGuJeUplaceno.text = "Ima jos da se plati"
                labelapovratniZaUplatuPGuJeUplaceno.backgroundColor = .red
            }
            
            labelapovratniVrednostPDV.text = "Vrednost PDV-a: " + String(format: "%.2f", locale: Locale.current, povratniVrednostPDV!.roundTo(places: 2)) + " Din"
            labelapovratniKnjizenoUplateNaOvajOtkupniList.text = "Placeno: " + String(format: "%.2f", locale: Locale.current, povratniKnjizenoUplateNaOvajOtkupniList!.doubleValue.roundTo(places: 2)) + " Din"
            labelapovratniZaUplatuPGu.text = "Ukupno: " + String(format: "%.2f", locale: Locale.current, (povratniZaUplatuPGu ?? 0).doubleValue.roundTo(places: 2)) + " Din"
                
            labelapovratniBrojOtkupnogLista.text = "Broj otkupnog lista: " + String(povratniBrojOtkupnogLista!)
            
            preostajeZaNammirenjeOtkupnogLista = (povratniZaUplatuPGu ?? 0) - povratniKnjizenoUplateNaOvajOtkupniList! + Decimal(povratniVrednostPDV!)
            labelaPreostajeZaNammirenjeOtkupnogLista.text = "Za uplatu: " + String(format: "%.2f", locale: Locale.current, preostajeZaNammirenjeOtkupnogLista!.doubleValue.roundTo(places: 2)) + " Din"
        }
    }
    

    
    @IBOutlet weak var tfPriliv: UITextField!
    @IBOutlet weak var tfOdliv: UITextField!
    
    @IBOutlet weak var piker: UIPickerView!
    @IBOutlet weak var pikerBankaBrojIzvoda: UIPickerView!

    var izabranaGlavnaOpcija = 0
    var izabranaPodopcija = 0
    
    var izabranaBanka: String?
    var izabranBrojIzvoda: Int32?
    
    @IBOutlet weak var pikerDatum: UIDatePicker!
    @IBOutlet weak var tfUnesiIme: UITextField!
    @IBOutlet weak var labelaBroj: UILabel!
    
    var potencijalnoIme: String?
    @IBAction func IzaberiKomintenta(_ sender: Any) {
        if izabranaGlavnaOpcija == 0 {
            potencijalnoIme = tfUnesiIme.text
            dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-DodajPromeneSaIzvoda->FiltrGazd"
            performSegue(withIdentifier: "sg-DodajPromeneSaIzvoda->FiltrGazd", sender: nil)
        }
    }
    
    func PreuzmiImeSaDrugogVC() {
        if povratnoIme != nil {
            tfUnesiIme.text = povratnoIme!
            labelaBroj.text = String(povratniBroj!)
            
            if povratniBrojOtkupnogLista == nil {
                print("setuje glavnu opciju na 0 i podopciju na 1")
                izabranaGlavnaOpcija = 0
                izabranaPodopcija = 1
                
                
                piker.selectRow(1, inComponent: 1, animated: true)
            }
        }
    }

    
    let model = [["GAZDINSTVO", "Uplata za Robu", "Avans"], ["DOO"], ["Fizicko Lice"]]
    
    let banke = ["Intesa", "Vojvodjanska", "Pireus", "ProCredit", "Adiko", "Marfin"]
    var brojeviIzvoda = [1, 2, 3, 4, 5, 6]
    
    var odliv: Decimal?
    var priliv: Decimal?
    
    func OdabranJeOdlivIliPriliv(sender: UITextField) {
        if sender == tfOdliv {
            tfPriliv.isUserInteractionEnabled = false
        } else if sender == tfPriliv {
            tfOdliv.isUserInteractionEnabled = false
        }
    }
    
    func PovuciIznos(sender: UITextField) {
       
        var vrednostIzTfbezZareza: String = ""
        for clan in (sender.value(forKey: "text") as! String).characters {
            if clan != "," {
                vrednostIzTfbezZareza = vrednostIzTfbezZareza + String(clan)
            }
        }

        if sender == tfOdliv {
            if let double = NumberFormatter().number(from: vrednostIzTfbezZareza) as? Double {
                odliv = Decimal(double)
            }
        } else if sender == tfPriliv {
            if let double = NumberFormatter().number(from: vrednostIzTfbezZareza) as? Double {
                priliv = Decimal(double)
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rezultat = 0
        if pickerView == piker {
            if component == 0 {
                rezultat = model.count
            } else if component == 1 {
                rezultat = model[izabranaGlavnaOpcija].count - 1
            }
        }
        if pickerView == pikerBankaBrojIzvoda {
            if component == 0 {
                rezultat = banke.count
            } else if component == 1 {
                rezultat = brojeviIzvoda.count
            }
        }
        return rezultat
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var rezultat = ""
        if pickerView == piker {
            if component == 0 {
                rezultat = model[row][0]
            } else if component == 1 {
                rezultat = model[izabranaGlavnaOpcija][row + 1]
            }
        }
        if pickerView == pikerBankaBrojIzvoda {
            if component == 0 {
                rezultat = banke[row]
            } else if component == 1 {
                rezultat = String(brojeviIzvoda[row])
            }
        }
        
        return rezultat
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == piker {
            if component == 0 {
                izabranaGlavnaOpcija = row
            } else if component == 1 {
                izabranaPodopcija = row
            }
            
            if izabranaGlavnaOpcija == 0 && izabranaPodopcija == 0 {
                print("odvedi me da izaberem otkupne listove")
                performSegue(withIdentifier: "sg-DodajPromeneSaIzvoda->PrikazOtkupnihListova", sender: nil)
            }
            
            piker.reloadAllComponents()
        }
        if pickerView == pikerBankaBrojIzvoda {
            if component == 0 {
                izabranaBanka = banke[row]
            } else if component == 1 {
                izabranBrojIzvoda = Int32(brojeviIzvoda[row])
            }
        }
        
        
    }
    
    
    
    @IBAction func Snimi(_ sender: Any) {
        print(izabranaGlavnaOpcija, izabranaPodopcija)
        pikerDatum.datePickerMode = UIDatePickerMode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let selektovanDatum = dateFormatter.string(from: pikerDatum.date)
        
        let date = NSDate()
        let trenutniDatum = dateFormatter.string(from: date as Date)
        
        // OVO SVE SAMO ZA OPCIJU KADA SE DAJE AVANS GAZDINSTVU
        if izabranaGlavnaOpcija == 0 && izabranaPodopcija == 1 {
            
            var brojPoslednjegAvansa: Int32 = 0
            func ProveriKojiJeBrojAvansaNaRedu() {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    else {
                        return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AvansiGazdinstvima")
                
                do {
                    let response = try managedContext.fetch(fetchRequest)
                    print(fetchRequest)
                    for podatak in response {
                        if podatak.value(forKey: "brojPoslednjegAvansa") == nil {
                            brojPoslednjegAvansa = 0
                        } else {
                            brojPoslednjegAvansa = (podatak.value(forKey: "brojPoslednjegAvansa") as? Int32)!
                        }
                    }
                } catch let error as NSError {
                    print("Ne mogu da preuzmem podatak poslednji broj avansa! \(error)")
                }
                
            }
            
            ProveriKojiJeBrojAvansaNaRedu()
            let brojAvansa = brojPoslednjegAvansa + 1

            do {
                let poljaSuIspravnoPopunjena = try ProveriValidnostUnosa(intTrenutniDatum: trenutniDatum, intSelektovaniDatum: selektovanDatum, intIme: povratnoIme, intBroj: povratniBroj, intPriliv: priliv, intOdliv: odliv, intBanka: izabranaBanka, intIzvod: izabranBrojIzvoda, intGlavnaOpcija: model[izabranaGlavnaOpcija][0], intPodopcija: model[izabranaGlavnaOpcija][izabranaPodopcija + 1], datumIzvoda: pikerDatum.date, danasnjiDatum: date as Date)
                if poljaSuIspravnoPopunjena {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        else {
                            return
                    }
                    
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let entitet = NSEntityDescription.entity(forEntityName: "AvansiGazdinstvima", in: managedContext)
                    let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
                    
                    zapis.setValue(povratniBroj, forKey: "bpg")
                    zapis.setValue(izabranBrojIzvoda, forKey: "brojIzvoda")
                    zapis.setValue(odliv, forKey: "odliv")
                    zapis.setValue(izabranaBanka, forKey: "banka")
                    zapis.setValue(povratnoIme, forKey: "naziv")
                    zapis.setValue(pikerDatum.date, forKey: "datum")
                    zapis.setValue(false, forKey: "avansJeZatvoren")
                    zapis.setValue(0.0, forKey: "kompenzovano")
                    
                    zapis.setValue(brojAvansa, forKey: "brojPoslednjegAvansa")
                    zapis.setValue(brojAvansa, forKey: "brojAvansa")

                    
                    do {
                        try managedContext.save()
                        print("U bazu podataka je upisana avansna uplata PG-u \(zapis)")
                        ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem avansnu uplatu gazdinstvu: \(zapis)")
                        PrikaziPopUp()
                    } catch {
                        print("Ne mogu da upisem avansnu uplatu gazdinstvu! \(error)")
                    }
                    
                }
            } catch {
                print("nisam usao u snimanje jer polja nisu dobro ispunjena \(error)")
            }  // OVO JE SAD ZA OPCIJU UPLATA ZA ROBU
        } else if izabranaGlavnaOpcija == 0 && izabranaPodopcija == 0 {
            print("udjoh u deo koji se bavi uplatom za robu")
            do {
                let poljaSuIspravnoPopunjena = try ProveriValidnostUnosa(intTrenutniDatum: trenutniDatum, intSelektovaniDatum: selektovanDatum, intIme: povratnoIme, intBroj: povratniBroj, intPriliv: priliv, intOdliv: odliv, intBanka: izabranaBanka, intIzvod: izabranBrojIzvoda, intGlavnaOpcija: model[izabranaGlavnaOpcija][0], intPodopcija: model[izabranaGlavnaOpcija][izabranaPodopcija + 1], datumIzvoda: pikerDatum.date, danasnjiDatum: date as Date)
                
                let iznosiMoguDaSeUkrste = try ProveriIspravnostUnosaZaUplatuZaRobuNaOsnovuOtkupnogLista(intIznosKojiSeDodeljujeOtkupnomListu: odliv!, intPreostajeZaNammirenjeOtkupnogLista: preostajeZaNammirenjeOtkupnogLista!)
                print(poljaSuIspravnoPopunjena, iznosiMoguDaSeUkrste)
                if poljaSuIspravnoPopunjena && iznosiMoguDaSeUkrste {
                    print("udjoh do filtera za broj otkupnog lista")
                    let filter = povratniBrojOtkupnogLista!
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        else {
                            return
                    }
                    let managedContext = appDelegate.persistentContainer.viewContext
                    
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OtkupniList")
                    let predicate = NSPredicate(format: "brojOtkupnogLista = %i", filter)
                    fetchRequest.predicate = predicate
                    
                    do { 
                        let response = try managedContext.fetch(fetchRequest)
                        
                        for podatak in response {
                            //zaUplatuPGuJeUplaceno BOOL
                            //pdvJeUplacen BOOL
                            
                            let postojeceKnjizenoUplateNaOvajOtkupniList = podatak.value(forKey: "knjizenoUplateNaOvajOtkupniList") as! Decimal
                            
                            var PDVdeoPlacen = false
                            if postojeceKnjizenoUplateNaOvajOtkupniList + odliv! >= Decimal(povratniVrednostPDV!) - 1 {
                                PDVdeoPlacen = true
                                podatak.setValue(PDVdeoPlacen, forKey: "pdvJeUplacen")
                            }
                            
                            var ostatakOtkupnogListaPlacen = false
                            if postojeceKnjizenoUplateNaOvajOtkupniList + odliv! >= povratniZaUplatuPGu! - 1 {
                                ostatakOtkupnogListaPlacen = true
                                podatak.setValue(ostatakOtkupnogListaPlacen, forKey: "zaUplatuPGuJeUplaceno")
                            }
                            
                            podatak.setValue(postojeceKnjizenoUplateNaOvajOtkupniList + odliv!, forKey: "knjizenoUplateNaOvajOtkupniList")
                            
                            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "Stanje Otkupnog lista broj \(String(describing: povratniBrojOtkupnogLista)) je da je on vec primio sledece uplate: \(postojeceKnjizenoUplateNaOvajOtkupniList) i da na to sad nadodajemo ovu novu uplatu u iznosu od \(odliv!). Ukupno treba da se plati za ovaj otkupni list \(String(describing: povratniZaUplatuPGu)). Setujemo da je PDVdeoPlacen na \(PDVdeoPlacen) i da je ostatak otkupnog lista placen na \(ostatakOtkupnogListaPlacen)")
                            print("Stanje Otkupnog lista broj \(String(describing: povratniBrojOtkupnogLista)) je da je on vec primio sledece uplate: \(postojeceKnjizenoUplateNaOvajOtkupniList) i da na to sad nadodajemo ovu novu uplatu u iznosu od \(odliv!). Ukupno treba da se plati za ovaj otkupni list \(String(describing: povratniZaUplatuPGu)). Setujemo da je PDVdeoPlacen na \(PDVdeoPlacen) i da je ostatak otkupnog lista placen na \(ostatakOtkupnogListaPlacen)")
                            PrikaziPopUp()
                            
                        }
                    } catch let error as NSError {
                        print("Ne mogu da preuzmem podatak za postojece finansijske podatke ugovora  \(error)")
                    }
                }
            } catch {
                print("nisam usao u snimanje jer polja nisu dobro ispunjena \(error)")
            }
        }
    }
    
    enum Greske: Error {
        case DatumIzvodaJeIzBuducnosti
        case DatumJeDanasnji
        case NijeIzabranoIme
        case NemaBrojaKomintenta
        case NemaUneteSume
        case NijeIzabranaBanka
        case NijeIzabranIzvod
        case NeMozeAvansGazdinstvuPrekoPriliva
        
        case IznosKojiSePokusavaDodelitiOtkupnomListuPrevazilaziNjegovuOtvorenuVrednost
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
    
    func ProveriIspravnostUnosaZaUplatuZaRobuNaOsnovuOtkupnogLista(intIznosKojiSeDodeljujeOtkupnomListu: Decimal, intPreostajeZaNammirenjeOtkupnogLista: Decimal) throws -> Bool {
        guard intIznosKojiSeDodeljujeOtkupnomListu <= intPreostajeZaNammirenjeOtkupnogLista + 1 else {
            PrikaziNeuspesniPopUp(poruka: "IznosKojiSePokusavaDodelitiOtkupnomListuPrevazilaziNjegovuOtvorenuVrednost")
            throw Greske.IznosKojiSePokusavaDodelitiOtkupnomListuPrevazilaziNjegovuOtvorenuVrednost
        }
        return true
    }
    
    func ProveriValidnostUnosa(intTrenutniDatum: String?, intSelektovaniDatum: String?, intIme: String?, intBroj: Int64?, intPriliv: Decimal?, intOdliv: Decimal?, intBanka: String?, intIzvod: Int32?, intGlavnaOpcija: String?, intPodopcija: String?, datumIzvoda: Date, danasnjiDatum: Date) throws -> Bool {
        
        guard intTrenutniDatum != intSelektovaniDatum else {
            PrikaziNeuspesniPopUp(poruka: "DatumJeDanasnji")
            throw Greske.DatumJeDanasnji
        }
        
        guard ProveriDaLiJeLeviDatumRanijiOdDesnogDatuma(leviDatum: datumIzvoda, desniDatum: danasnjiDatum) else {
            PrikaziNeuspesniPopUp(poruka: "DatumIzvodaJeIzBuducnosti")
            throw Greske.DatumIzvodaJeIzBuducnosti
        }
        
        guard intIme != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeIzabranoIme")
            throw Greske.NijeIzabranoIme
        }
        guard intBroj != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaBrojaKomintenta")
            throw Greske.NemaBrojaKomintenta
        }
        guard (intPriliv != nil || intOdliv != nil) else {
            PrikaziNeuspesniPopUp(poruka: "NemaUneteSume")
            throw Greske.NemaUneteSume
        }
        guard intBanka != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeIzabranaBanka")
            throw Greske.NijeIzabranaBanka
        }
        guard intIzvod != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeIzabranIzvod")
            throw Greske.NijeIzabranIzvod
        }
        
        if intPodopcija == "Avans" {
            guard intGlavnaOpcija == "GAZDINSTVO" && intOdliv != nil else {
                //print(intGlavnaOpcija, intPodopcija, intOdliv)
                PrikaziNeuspesniPopUp(poruka: "NeMozeAvansGazdinstvuPrekoPriliva")
                throw Greske.NeMozeAvansGazdinstvuPrekoPriliva
            }
        }
        
        if intPodopcija == "Uplata za Robu" {
            guard intGlavnaOpcija == "GAZDINSTVO" && intOdliv != nil else {
                //print(intGlavnaOpcija, intPodopcija, intOdliv)
                PrikaziNeuspesniPopUp(poruka: "NeMozeUplatazaRobuGazdinstvuPrekoPriliva")
                throw Greske.NeMozeAvansGazdinstvuPrekoPriliva
            }
        }
        
      
        
        return true
    }
    
    
    func PrikaziPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili promenu sa IZVODA",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaDodajPromeneSaIzvoda", sender: nil)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("gledam nesto po ovoj tf funkciji")
        //PovuciIznos(sender: textField)
        if ((string == "0" || string == "") && (textField.text! as NSString).range(of: ".").location < range.location) {
            return true
        }
        
        // First check whether the replacement string's numeric...
        let cs = NSCharacterSet(charactersIn: "0123456789.").inverted
        let filtered = string.components(separatedBy: cs)
        let component = filtered.joined(separator: "")
        let isNumeric = string == component
        
        // Then if the replacement string's numeric, or if it's
        // a backspace, or if it's a decimal point and the text
        // field doesn't already contain a decimal point,
        // reformat the new complete number using
        if isNumeric {
            //print("prosao numeric part")
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 8
            // Combine the new text with the old; then remove any
            // commas from the textField before formatting
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let numberWithOutCommas = newString.replacingOccurrences(of: ",", with: "")
            let number = formatter.number(from: numberWithOutCommas)
            if number != nil {
                var formattedString = formatter.string(from: number!)
                // If the last entry was a decimal or a zero after a decimal,
                // re-add it here because the formatter will naturally remove
                // it.
                if string == "." && range.location == textField.text?.characters.count {
                    formattedString = formattedString?.appending(".")
                }
                textField.text = formattedString
            } else {
                textField.text = nil
            }
        }
        return false
        
    }
 
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaDodajPromeneSaIzvoda", sender: nil)
    }

}
