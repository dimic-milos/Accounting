//
//  GazdinstvoPreuzimaRobuPoUgovoruVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/1/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class GazdinstvoPreuzimaRobuPoUgovoruVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate , UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .green
        DodajDugmeZaNazad()
        PreuzmiImeSaDrugogVC()
        PovuciPodatkeZaPikerArtikli()
        let pikerArtikla = UIPickerView()
        pikerArtikla.delegate = self
        tfRobaKojaJePredmetUgovora.inputView = pikerArtikla
        
        //////////////////////////////////////////
        let currentDate = Date()
        datumPiker.maximumDate = currentDate
        
        tabela.dataSource = self
        tabela.delegate = self
    }
    
    @IBOutlet weak var tfUnesiIme: UITextField!
    @IBOutlet weak var labelaBroj: UILabel!
    @IBOutlet weak var tfRobaKojaJePredmetUgovora: UITextField!
    
    var povratnoIme: String?
    var povratniBroj: Int64?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nekoIme = potencijalnoIme
        if segue.identifier == "sg-GazdinstvoPreuzimaRobuPoUgovoruVC->FiltrGazd" {
            if let filtriranaGazdinstva = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstva.unosImenaGazdinstvaSaDrugogVC = nekoIme
            }
        }
    }
    
    var potencijalnoIme: String?
    @IBAction func IzaberiKomintenta(_ sender: Any) {
        potencijalnoIme = tfUnesiIme.text
        dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-GazdinstvoPreuzimaRobuPoUgovoruVC->FiltrGazd"
        performSegue(withIdentifier: "sg-GazdinstvoPreuzimaRobuPoUgovoruVC->FiltrGazd", sender: nil)
    }
    
    func PreuzmiImeSaDrugogVC() {
        if povratnoIme != nil {
            tfUnesiIme.text = povratnoIme!
            labelaBroj.text = String(povratniBroj!)
            
            PovuciEventualneOtvoreneUgovoreZaIzabranuRobuNapuniTabelu()
            tabela.reloadData()
        }
    }
    
    var nativnaJedinicaMereArtiklaIzBaze: String?
    var kolicinaUPojedinacnomPakovanju: Decimal?
    var izabraniArtikl: String?
    
    var nizArtikli: [String] = []
    var nizjedinicaMereArtiklaIzBaze: [String] = []
    var nizkolicinaUPojedinacnomPakovanju: [Decimal] = []
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nizArtikli.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        izabraniArtikl = nizArtikli[0]
        nativnaJedinicaMereArtiklaIzBaze = nizjedinicaMereArtiklaIzBaze[0]
        kolicinaUPojedinacnomPakovanju = nizkolicinaUPojedinacnomPakovanju[0]
        
        tfRobaKojaJePredmetUgovora.text = izabraniArtikl
        return nizArtikli[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        izabraniArtikl = nizArtikli[row]
        nativnaJedinicaMereArtiklaIzBaze = nizjedinicaMereArtiklaIzBaze[row]
        kolicinaUPojedinacnomPakovanju = nizkolicinaUPojedinacnomPakovanju[row]
        
        tfRobaKojaJePredmetUgovora.text = izabraniArtikl
    }
    func PovuciPodatkeZaPikerArtikli() {
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
                let jedinicaMereArtiklaIzBaze = podatak.value(forKey: "jedinicaMere")
                let kolicinaUPojedinacnomPakovanju = podatak.value(forKey: "kolicinaUPojedinacnomPakovanju")
                
                nizjedinicaMereArtiklaIzBaze.append(jedinicaMereArtiklaIzBaze! as! String)
                nizArtikli.append(artikl! as! String)
                nizkolicinaUPojedinacnomPakovanju.append(kolicinaUPojedinacnomPakovanju as! Decimal)
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
        performSegue(withIdentifier: "sgGlavniSaGazdinstvoPreuzimaRobuPoUgovoru", sender: nil)
    }
    
    
    ///////////////////
    
    
    @IBOutlet var tfBrojNalogaMagacinuDaIzda: UITextField!
    var brojNalogaMagacinuDaIzda: Int64?
    
    @IBOutlet weak var tabela: UITableView!
    
    var datumIzdavanjaRobe: Date?
    @IBOutlet weak var datumPiker: UIDatePicker!
    
    
    var repromaterijalFinansiranUgovorom: String?
    @IBOutlet weak var roSegCtrlRepromaterijalFinansiranUgovorom: UISegmentedControl!
    @IBAction func SegCtrlRepromaterijalFinansiranUgovorom(_ sender: Any) {
        switch roSegCtrlRepromaterijalFinansiranUgovorom.selectedSegmentIndex {
        case 0:
            repromaterijalFinansiranUgovorom = roSegCtrlRepromaterijalFinansiranUgovorom.titleForSegment(at: 0)!
        case 1:
            repromaterijalFinansiranUgovorom = roSegCtrlRepromaterijalFinansiranUgovorom.titleForSegment(at: 1)!
        case 2:
            repromaterijalFinansiranUgovorom = roSegCtrlRepromaterijalFinansiranUgovorom.titleForSegment(at: 2)!
        default:
            repromaterijalFinansiranUgovorom = "nije izabrano sta se finansira ovim ugovorom!!!!"
        }
    }
    @IBOutlet weak var tfKolicinaRobe: UITextField!
    var preuzetaKolicinaRobe: Decimal?
    
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
    
    var nizRobaKojaJePredmetUgovora: [String] = []
    var nizNacelnaVrednostUgovora: [Decimal] = []
    var nizRealizovanaVrednostUgovora: [Decimal] = []
    var nizNacinRazduzenja: [String] = []
    var nizKolicinaRobe: [Decimal] = []
    var nizBrojUgovora: [Int64] = []
    var nizPreuzetaKolicinaDoSada: [Decimal] = []
    var nizRepromaterijalFinansiranUgovoromTabela: [String] = []
    func PovuciEventualneOtvoreneUgovoreZaIzabranuRobuNapuniTabelu() {
        guard let filter = povratnoIme else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")

        print("postavljam predikat za \(filter)")
        let predicate = NSPredicate(format: "povratnoIme = %@", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)

            for podatak in response {
                let robaKojaJePredmetUgovora = podatak.value(forKey: "robaKojaJePredmetUgovora")
                let nacelnaVrednostUgovora = podatak.value(forKey: "nacelnaVrednostUgovora")
                let realizovanaVrednostUgovora = podatak.value(forKey: "realizovanaVrednostUgovora")
                let nacinRazduzenja = podatak.value(forKey: "nacinRazduzenja")
                let kolicinaRobe = podatak.value(forKey: "kolicinaRobe")
                let brojUgovora = podatak.value(forKey: "brojUgovora")
                let preuzetaKolicinaDoSada = podatak.value(forKey: "preuzetaKolicina")
                let repromaterijalFinansiranUgovoromTabela = podatak.value(forKey: "repromaterijalFinansiranUgovorom")
                
                nizRobaKojaJePredmetUgovora.append(robaKojaJePredmetUgovora! as! String)
                nizNacelnaVrednostUgovora.append(nacelnaVrednostUgovora! as! Decimal)
                nizRealizovanaVrednostUgovora.append(realizovanaVrednostUgovora! as! Decimal)
                nizNacinRazduzenja.append(nacinRazduzenja! as! String)
                nizKolicinaRobe.append(kolicinaRobe! as! Decimal)
                nizBrojUgovora.append(brojUgovora! as! Int64)
                nizPreuzetaKolicinaDoSada.append(preuzetaKolicinaDoSada! as! Decimal)
                nizRepromaterijalFinansiranUgovoromTabela.append(repromaterijalFinansiranUgovoromTabela! as! String)
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih ugovora u tabeli! \(error)")
        }
    }
    
    var selektovaniUgovor: Int64?
    var preuzetaKolicinaDoSada: Decimal?
    var dogovorenaKolicinaPoUgovoru: Decimal?
    var repromaterijalIzUgovora: String?
    var repromaterijalFinansiranUgovoromTabela: String?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizRobaKojaJePredmetUgovora.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelija", for: indexPath) as? GazdinstvoPreuzimaRobuPoUgovoruTableVC
        celija?.labelaNacinRazduzenja.text = "Rezduzuje u: " + nizNacinRazduzenja[indexPath.row]
        celija?.labelaRobaKojaSeDajeNaKooperaciju.text = nizRobaKojaJePredmetUgovora[indexPath.row]
        celija?.labelaDogovorenaKolicina.text = "Ugovor obuhvata kolicinu: " + String(nizKolicinaRobe[indexPath.row].doubleValue.roundTo(places: 4))
        celija?.labelaNacelnaVrednostUgovora.text = "Nacelna vrednost ug: " + String(nizNacelnaVrednostUgovora[indexPath.row].doubleValue.roundTo(places: 4))
        celija?.labelaRealizovanaVrednostUgovora.text = "Vrednost povucne robe: " + String(nizRealizovanaVrednostUgovora[indexPath.row].doubleValue.roundTo(places: 4))
        celija?.labelaBrojUgovora.text = "Br.Ug: " + String(nizBrojUgovora[indexPath.row])
        celija?.labelaPreuzeoDoSada.text = "Preuzeto do sada: " + String(nizPreuzetaKolicinaDoSada[indexPath.row].doubleValue.roundTo(places: 2))
        celija?.labelaPreostajeDaPreuzme.text = "Preostaje jos da uzme: " + String((nizKolicinaRobe[indexPath.row] - nizPreuzetaKolicinaDoSada[indexPath.row]).doubleValue.roundTo(places: 2))
        
        return celija!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selektovaniUgovor = nizBrojUgovora[indexPath.row]
        preuzetaKolicinaDoSada = nizPreuzetaKolicinaDoSada[indexPath.row]
        dogovorenaKolicinaPoUgovoru = nizKolicinaRobe[indexPath.row]
        repromaterijalIzUgovora = nizRobaKojaJePredmetUgovora[indexPath.row]
        repromaterijalFinansiranUgovoromTabela = nizRepromaterijalFinansiranUgovoromTabela[indexPath.row]
    }
    
    func PrikaziPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili dodeljivanje izlaza robe pojedinacnom Ugovoru na osnovu naloga magacinu da izda",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaGazdinstvoPreuzimaRobuPoUgovoru", sender: nil)
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

    
    var snimanjNalogaMagacinuDaIzdaRobuGazdinstvuPoUgovoru = false
    var povlacenjePostojecihFinansijskihPodatakaUgovora = false
    var dodeljivanjePreuzeteKolicineRobeOdgovarajaucemUgovoru = false
    @IBAction func DodeliIzabranomUgovoru(_ sender: Any) {
        //print(repromaterijalIzUgovora, repromaterijalFinansiranUgovorom, repromaterijalFinansiranUgovoromTabela, izabraniArtikl)
        datumIzdavanjaRobe = datumPiker.date
        do {
        let osnovnaProvera = try OsnovnaProvera(intIme: tfUnesiIme.text, intKolicinaRobe: tfKolicinaRobe.text, intSelektovaniUgovor: selektovaniUgovor, intJedinicaZaMeru: jedinicaZaMeru, intRobaZaIzdavanje: tfRobaKojaJePredmetUgovora.text)
        
        if osnovnaProvera {
            if let double = NumberFormatter().number(from: tfKolicinaRobe.value(forKey: "text") as! String) as? Double {
                preuzetaKolicinaRobe = Decimal(double)
            }
            if jedinicaZaMeru != nativnaJedinicaMereArtiklaIzBaze {
                preuzetaKolicinaRobe = preuzetaKolicinaRobe! * kolicinaUPojedinacnomPakovanju!
            }
            
            do {
                let korisnickiUnosJeIspravan = try ProveriKorisnickiUnos(intBrojNalogaMagacinuDaIzda: tfBrojNalogaMagacinuDaIzda.text, intKolicinaRobe: tfKolicinaRobe.text, intSelektovaniUgovor: selektovaniUgovor, intPreuzetaKolicinaDoSada: preuzetaKolicinaDoSada, intPreuzetaKolicina: preuzetaKolicinaRobe, intDogovorenaKolicinaPoUgovoru: dogovorenaKolicinaPoUgovoru, intIzabraniArtikl: izabraniArtikl, intRepromaterijalIzUgovora: repromaterijalIzUgovora, intRepromaterijalFinansiranUgovorom: repromaterijalFinansiranUgovorom, intRepromaterijalFinansiranUgovoromTabela: repromaterijalFinansiranUgovoromTabela)
                if korisnickiUnosJeIspravan {
                    brojNalogaMagacinuDaIzda = Int64(tfBrojNalogaMagacinuDaIzda.text!)
                    
                    //print(nativnaJedinicaMereArtiklaIzBaze, kolicinaUPojedinacnomPakovanju, repromaterijalIzUgovora, repromaterijalFinansiranUgovorom, repromaterijalFinansiranUgovoromTabela, izabraniArtikl)
                    
                   // print(povratnoIme, povratniBroj, izabraniArtikl, brojNalogaMagacinuDaIzda, datumIzdavanjaRobe, preuzetaKolicinaRobe, selektovaniUgovor, preuzetaKolicinaDoSada)
                    
                    //unesi da se tf za unos opcije koja je roba preuzeta da ne izlazi keyboard
                    
                    SacuvajNalogMagacinuDaIzdaRobuGazdinstvuPoUgovoru()
                    PovuciFinansijskePodatkeUgovoraNaKomeSeVrsiIzmena()
                    DodeliPreuzetuKolicinuRobeOdgovarajaucemUgovoru()
                }
            } catch {
                print("nisam usao u snimanje jer polja nisu dobro ispunjena \(error)")
            }

        }
        
        } catch {
            print("ne prolazi ni osnovnu proveru \(error)")
        }

    }
    
    func SacuvajNalogMagacinuDaIzdaRobuGazdinstvuPoUgovoru() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "NalogMagacinuDaIzdaRobuPoUgovoru", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue(datumIzdavanjaRobe, forKey: "datumIzdavanjaRobe")
        zapis.setValue(izabraniArtikl, forKey: "artiklKojiPreuzima")
        zapis.setValue(povratnoIme, forKey: "nazivKupca")
        zapis.setValue(brojNalogaMagacinuDaIzda, forKey: "brojNalogaMagacinuDaIzda")
        zapis.setValue(selektovaniUgovor, forKey: "poKomUgovoru")
        zapis.setValue(nativnaJedinicaMereArtiklaIzBaze, forKey: "jedinicaZaMeru")
        zapis.setValue(povratniBroj, forKey: "brojGazdinstva")
        
        zapis.setValue(preuzetaKolicinaRobe, forKey: "preuzetaKolicina")
        
        do {
            try managedContext.save()
            snimanjNalogaMagacinuDaIzdaRobuGazdinstvuPoUgovoru = true
            print("U bazu podataka je upisan nalog magacinu da izda robu gazdinstvu po ugovoru \(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem nalog magacinu da izda robu gazdinstvu po ugovoru: \(zapis)")
            //PrikaziPopUp()
        } catch {
            print("Ne mogu da upisem nalog magacinu da izda robu gazdinstvu po ugovoru! \(error)")
        }
    }
    

    var postojecaCenaPoJediniciMere: Decimal?
    var postojeciMinimalniKursZaObracunRazduzenja: Decimal?
    var postojecaNeotplacenaVrednostUgovora: Decimal?
    var postojecaPreuzetaKolicina: Decimal?
    var postojeceOtplaceno: Decimal?
    var postojecaRealizovanaVrednostUgovora: Decimal?
    var postojecaVrednostPDVaOvogUgovora: Decimal?
    func PovuciFinansijskePodatkeUgovoraNaKomeSeVrsiIzmena() {
        guard let filter = selektovaniUgovor else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")
        
        let predicate = NSPredicate(format: "brojUgovora = %i", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                postojecaCenaPoJediniciMere = podatak.value(forKey: "cenaPoJediniciMere") as? Decimal
                postojeciMinimalniKursZaObracunRazduzenja = podatak.value(forKey: "minimalniKursZaObracunRazduzenja") as? Decimal
                postojecaNeotplacenaVrednostUgovora = podatak.value(forKey: "neotplacenaVrednostUgovora") as? Decimal
                postojecaPreuzetaKolicina = podatak.value(forKey: "preuzetaKolicina") as? Decimal
                postojeceOtplaceno = podatak.value(forKey: "otplaceno") as? Decimal
                postojecaRealizovanaVrednostUgovora = podatak.value(forKey: "realizovanaVrednostUgovora") as? Decimal
                postojecaVrednostPDVaOvogUgovora = podatak.value(forKey: "vrednostPDVaOvogUgovora") as? Decimal
                povlacenjePostojecihFinansijskihPodatakaUgovora = true
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za postojece finansijske podatke ugovora! \(error)")
        }

    }
    
    func DodeliPreuzetuKolicinuRobeOdgovarajaucemUgovoru() {
        // cenaPoJediniciMere 0.25
        // minimalniKursZaObracunRazduzenja 130.8734
        // ***neotplacenaVrednostUgovora 0
        // **preuzetaKolicina 0
        // otplaceno 0
        // **realizovanaVrednostUgovora 0
        // ***vrednostPDVaOvogUgovora 0
        
        guard let filter = selektovaniUgovor else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")
        let predicate = NSPredicate(format: "brojUgovora = %i", filter)
        fetchRequest.predicate = predicate
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                let ukupnaPreuzetaKolicina = postojecaPreuzetaKolicina! + preuzetaKolicinaRobe!
                podatak.setValue(ukupnaPreuzetaKolicina, forKey: "preuzetaKolicina")
                podatak.setValue(ukupnaPreuzetaKolicina * postojecaCenaPoJediniciMere!, forKey: "realizovanaVrednostUgovora")
                podatak.setValue(ukupnaPreuzetaKolicina * postojecaCenaPoJediniciMere! - postojeceOtplaceno!, forKey: "neotplacenaVrednostUgovora")
                
                var vrednostPDVzaSetovanje: Decimal?
                if postojeciMinimalniKursZaObracunRazduzenja != nil {
                    vrednostPDVzaSetovanje = (((ukupnaPreuzetaKolicina * postojecaCenaPoJediniciMere!) / 100 * Decimal((dummy?.pdvStopaZaRobuManjegPDVa)!)) * postojeciMinimalniKursZaObracunRazduzenja!)
                    podatak.setValue(vrednostPDVzaSetovanje , forKey: "vrednostPDVaOvogUgovora")
                } else {
                    vrednostPDVzaSetovanje = (((ukupnaPreuzetaKolicina * postojecaCenaPoJediniciMere!) / 100 * Decimal((dummy?.pdvStopaZaRobuManjegPDVa)!)))
                    podatak.setValue(vrednostPDVzaSetovanje, forKey: "vrednostPDVaOvogUgovora")
                }
                
                
                dodeljivanjePreuzeteKolicineRobeOdgovarajaucemUgovoru = true
                print("U bazu podataka je upisana izmenu vrednost UGOVORA prema nalogu magacinu da izda robu gazdinstvu direktno NA ugovor UKUPNA PREUZETA KOLICINA je sada: \(podatak.value(forKey: "preuzetaKolicina")!) a REALIZOVANA VREDNOST UGOVORA je sada: \(podatak.value(forKey: "realizovanaVrednostUgovora")!), POSTOJECA NEOTPLACENA VREDNOST je sada \(podatak.value(forKey: "neotplacenaVrednostUgovora")!), VREDNOST PDV-a OVOG UGOVORA je sada \(podatak.value(forKey: "vrednostPDVaOvogUgovora")!)")
                ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu podataka je upisana izmenu vrednost UGOVORA prema nalogu magacinu da izda robu gazdinstvu direktno NA ugovor UKUPNA PREUZETA KOLICINA je sada: \(podatak.value(forKey: "preuzetaKolicina")!) a REALIZOVANA VREDNOST UGOVORA je sada: \(podatak.value(forKey: "realizovanaVrednostUgovora")!), POSTOJECA NEOTPLACENA VREDNOST je sada \(podatak.value(forKey: "neotplacenaVrednostUgovora")!), VREDNOST PDV-a OVOG UGOVORA je sada \(podatak.value(forKey: "vrednostPDVaOvogUgovora")!)")
                
                if snimanjNalogaMagacinuDaIzdaRobuGazdinstvuPoUgovoru && povlacenjePostojecihFinansijskihPodatakaUgovora && dodeljivanjePreuzeteKolicineRobeOdgovarajaucemUgovoru {
                    PrikaziPopUp()
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za postojece finansijske podatke ugovora koje bih u sledecem koraku menjao! \(error)")
        }

        
    }
    
    enum Greske: Error {
        case NijeUnetBrojNalogaMagacinuDaIzda
        case NijeUnetaKolicinaRobe
        case NijeSelektovanNijedanUgovor
        case PreuzetaKolicinaPrevazilaziUgovorenuKolicinu
        case NeMozeSeZaduzitiUgovorSaRobomRazlicitomOdUgovorene
        case NeMozeSeZaduzitiUgovorKlasomRobeDrugacijomOdUgovoreneKlaseRobe
        
        case NemaImena
        case NemaKolicine
        case NijeOdabranaJedinicaZaMeru
        case NijeOdabranaRobaZaIzdavanje
    }
    
    func ProveriKorisnickiUnos(intBrojNalogaMagacinuDaIzda: String?, intKolicinaRobe: String?, intSelektovaniUgovor: Int64?, intPreuzetaKolicinaDoSada: Decimal?, intPreuzetaKolicina: Decimal?, intDogovorenaKolicinaPoUgovoru: Decimal?, intIzabraniArtikl: String?, intRepromaterijalIzUgovora: String?, intRepromaterijalFinansiranUgovorom: String?, intRepromaterijalFinansiranUgovoromTabela: String?) throws -> Bool {
        guard intBrojNalogaMagacinuDaIzda != nil && intBrojNalogaMagacinuDaIzda != "" else {
            PrikaziNeuspesniPopUp(poruka: "nijeUnetBrojNalogaMagacinuDaIzda")
            throw Greske.NijeUnetBrojNalogaMagacinuDaIzda
        }
        
        guard intKolicinaRobe != nil && intKolicinaRobe != "" else {
            PrikaziNeuspesniPopUp(poruka: "nijeUnetaKolicinaRobe")
            throw Greske.NijeUnetaKolicinaRobe
        }
        
        guard intSelektovaniUgovor != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeSelektovanNijedanUgovor")
            throw Greske.NijeSelektovanNijedanUgovor
        }
        
        guard intPreuzetaKolicinaDoSada! + intPreuzetaKolicina! <= intDogovorenaKolicinaPoUgovoru! else {
            PrikaziNeuspesniPopUp(poruka: "PreuzetaKolicinaPrevazilaziUgovorenuKolicinu")
            throw Greske.PreuzetaKolicinaPrevazilaziUgovorenuKolicinu
        }
        
        guard intRepromaterijalIzUgovora == intIzabraniArtikl else {
            PrikaziNeuspesniPopUp(poruka: "NeMozeSeZaduzitiUgovorSaRobomRazlicitomOdUgovorene")
            throw Greske.NeMozeSeZaduzitiUgovorSaRobomRazlicitomOdUgovorene
        }
        
        guard intRepromaterijalFinansiranUgovorom == intRepromaterijalFinansiranUgovoromTabela else {
            PrikaziNeuspesniPopUp(poruka: "NeMozeSeZaduzitiUgovorKlasomRobeDrugacijomOdUgovoreneKlaseRobe")
            throw Greske.NeMozeSeZaduzitiUgovorKlasomRobeDrugacijomOdUgovoreneKlaseRobe
        }
        return true
    }
    
    func OsnovnaProvera(intIme: String?, intKolicinaRobe: String?, intSelektovaniUgovor: Int64?, intJedinicaZaMeru: String?, intRobaZaIzdavanje: String?) throws -> Bool {
        guard intIme != nil && intIme != "" else {
            PrikaziNeuspesniPopUp(poruka: "Nema Imena")
            throw Greske.NemaImena
        }
        guard intKolicinaRobe != nil && intKolicinaRobe != "" else {
            PrikaziNeuspesniPopUp(poruka: "Nema Kolicine")
            throw Greske.NemaKolicine
        }
        
        guard intJedinicaZaMeru != nil else {
            PrikaziNeuspesniPopUp(poruka: "Nema jedinice za meru")
            throw Greske.NijeOdabranaJedinicaZaMeru
        }
        
        guard intSelektovaniUgovor != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeSelektovanNijedanUgovor")
            throw Greske.NijeSelektovanNijedanUgovor
        }
        
        guard intRobaZaIzdavanje != nil && intRobaZaIzdavanje != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeOdabranaRobaZaIzdavanje")
            throw Greske.NijeOdabranaRobaZaIzdavanje
        }
        return true
    }
}

