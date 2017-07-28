//
//  GenerisiUgovorSaGazdinstvomVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/29/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

class GenerisiUgovorSaGazdinstvomVC: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    func sendEmail(subject: String, textToSend: String) {
        //MFMailComposeViewControllerDelegate
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(subject)
            mail.setToRecipients(["dimic.milos@icloud.com"])
            mail.setMessageBody(textToSend, isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.white
        DodajDugmeZaNazad()
        PreuzmiImeSaDrugogVC()
        PovuciPodatkeMojeFirmeIzBaze()
        ProveriKojiJeBrojUgovoraNaRedu()
        brojUgovora = brojPoslednjegUgovora + 1
        labelaBrojUgovora.text = "Ugovor.br:" + String(brojUgovora!)
        datumSklapanjaUgovora = pikerDatum.date
        PovuciPodatkeZaPikerArtikli()
        let pikerArtikla = UIPickerView()
        pikerArtikla.delegate = self
        tfRobaKojaJePredmetUgovora.inputView = pikerArtikla
        PreuzmiMinimalniKursZaObracun()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if minimalniKursZaObracunRazduzenjaEUR == nil || minimalniKursZaObracunRazduzenjaDOL == nil {
            PrikaziNeuspesniPopUp(poruka: "Nema upisanog kursa EUR ili DOL - najpre unesi kurseve u kursnu listu pa se vrati ovde")
        }
    }
    
    @IBOutlet weak var tfUnesiIme: UITextField!
    @IBOutlet weak var labelaBroj: UILabel!
    
    @IBOutlet weak var tfMesto: UITextField!
    @IBOutlet weak var tfAdresa: UITextField!
    @IBOutlet weak var tfTelefon: UITextField!
    @IBOutlet weak var tfJmbg: UITextField!
    @IBOutlet weak var tfBrojLicneKarte: UITextField!
    @IBOutlet weak var tfTekuciRacun: UITextField!
    
    @IBOutlet weak var labelaPodaciMojeFirme: UILabel!
    
    @IBOutlet weak var tfRobaKojaJePredmetUgovora: UITextField!
    
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
    @IBOutlet weak var tfCenaPoJediniciMere: UITextField!
    
    @IBOutlet weak var rosegCtrlValutaUgovora: UISegmentedControl!
    @IBAction func segCtrlValutaUgovora(_ sender: Any) {
        rosegCtrlValutaUgovora.isUserInteractionEnabled = false
        switch rosegCtrlValutaUgovora.selectedSegmentIndex {
        case 0:
            minimalniKursZaObracunRazduzenja = minimalniKursZaObracunRazduzenjaEUR
            valutaUgovora = rosegCtrlValutaUgovora.titleForSegment(at: 0)!
            swValutnaKlauzula.isOn = true
            swValutnaKlauzula.isUserInteractionEnabled = false
        case 1:
            minimalniKursZaObracunRazduzenja = minimalniKursZaObracunRazduzenjaDOL
            valutaUgovora = rosegCtrlValutaUgovora.titleForSegment(at: 1)!
            swValutnaKlauzula.isOn = true
            swValutnaKlauzula.isUserInteractionEnabled = false
        case 2:
            valutaUgovora = rosegCtrlValutaUgovora.titleForSegment(at: 2)!
            swValutnaKlauzula.isOn = false
            swValutnaKlauzula.isUserInteractionEnabled = false
        default:
            valutaUgovora = "nije izabrana valuta ugovora EUR DOL DIN!!!!"
        }

    }
    @IBOutlet weak var swDocnja: UISwitch!
    @IBOutlet weak var swValutnaKlauzula: UISwitch!
    @IBOutlet weak var tfBrojMenice: UITextField!
    
    @IBOutlet weak var rosegCtrlNacinRazduzenja: UISegmentedControl!
    @IBAction func segCtrlNacinRazduzenja(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yyyy"
        
        let date = NSDate()
        let calendar = NSCalendar.current
        
        let godina = calendar.dateComponents([.year], from: date as Date)
        let trenutnaGodina = String(godina.year!)
        
        switch rosegCtrlNacinRazduzenja.selectedSegmentIndex {
        case 0:
            nacinRazduzenja = rosegCtrlNacinRazduzenja.titleForSegment(at: 0)!
            let zeljeniDatum = dateFormatter.date(from: "31/07/" + trenutnaGodina)
            pikerDatum.setDate(zeljeniDatum!, animated: true)
        case 1:
            nacinRazduzenja = rosegCtrlNacinRazduzenja.titleForSegment(at: 1)!
            let zeljeniDatum = dateFormatter.date(from: "30/08/" + trenutnaGodina)
            pikerDatum.setDate(zeljeniDatum!, animated: true)
        case 2:
            nacinRazduzenja = rosegCtrlNacinRazduzenja.titleForSegment(at: 2)!
            let zeljeniDatum = dateFormatter.date(from: "30/10/" + trenutnaGodina)
            pikerDatum.setDate(zeljeniDatum!, animated: true)
        case 3:
            nacinRazduzenja = rosegCtrlNacinRazduzenja.titleForSegment(at: 3)!
            let zeljeniDatum = dateFormatter.date(from: "15/11/" + trenutnaGodina)
            pikerDatum.setDate(zeljeniDatum!, animated: true)
        default:
            nacinRazduzenja = "nije izabran nacin razduzenja to jest kojom robom se razduzuje kooperant!!!"
        }
    }
    @IBOutlet weak var pikerDatum: UIDatePicker!
    
    @IBAction func SacuvajUgovor(_ sender: Any) {
        KompletirajPodatke()
        
        
        
        do {
            let poljaSuIspravnoPopunjena = try KorisnickiUnosJeIspravan(intDatumSklapanjaUgovora: datumSklapanjaUgovora, intDocnja: docnja, intUgovorJeZatvoren: ugovorJeZatvoren, intValutnaKlauzula: valutnaKlauzula, intAdresa: adresa, intBrojMenice: brojMenice, intJedinicaZaMeru: jedinicaZaMeru, intMaticniBroj: maticniBroj, intMesto: mesto, intNacinRazduzenja: nacinRazduzenja, intNaziv: naziv, intPib: pib, intPovratnaAdresaPG: povratnaAdresaPG, intPovratniJmbg: povratniJmbg, intPovratniTekuciRacun: povratniTekuciRacun, intPovratnoIme: povratnoIme, intReporomaterijalFinansiranUgovorom: repromaterijalFinansiranUgovorom, intRobaKojaJePredmetUgovora: robaKojaJePredmetUgovora, intTekuciRacun: tekuciRacun, intValutaUgovora: valutaUgovora, intCenaPoJediniciMere: cenaPoJediniciMere, intIznosNivelacijeDocnje: iznosNivelacijeDocnje, intIznosValutneNivelacije: iznosValutneNivelacije, intKolicinaRobe: kolicinaRobe, indMinimalniKursZaObracunRazduzenja: minimalniKursZaObracunRazduzenja, intBrojUgovora: brojUgovora, intPovratniBroj: povratniBroj, intPovratniBrojLicneKarte: povratniBrojLicneKarte, intPovratniTelefno: povratniTelefon, intDatumskaValutaUgovora: datumskaValutaUgovora)
            
            if poljaSuIspravnoPopunjena {
               
                nacelnaVrednostUgovora = kolicinaRobe! * cenaPoJediniciMere!
               
                if valutnaKlauzula! {
                    vrednostPDVaOvogUgovora = (realizovanaVrednostUgovora! * minimalniKursZaObracunRazduzenja!) / 100 * Decimal((dummy?.pdvStopaZaRobuManjegPDVa)!)
                } else {
                    vrednostPDVaOvogUgovora = (realizovanaVrednostUgovora!) / 100 * Decimal((dummy?.pdvStopaZaRobuManjegPDVa)!)
                }
                
                var vrednostUgovoraNavelaTokNaPopUpUpozorenje = false
                if nacelnaVrednostUgovora! >= Decimal(5000.00) && (valutaUgovora == "Evro" || valutaUgovora == "Dolar" ) {
                    vrednostUgovoraNavelaTokNaPopUpUpozorenje = true
                    PrikaziPopUpKojiUpozoravaNaVelikuVrednostUgovora()
                } else if nacelnaVrednostUgovora! >= Decimal(500_000.00) && (valutaUgovora == "Dinar" ) {
                    vrednostUgovoraNavelaTokNaPopUpUpozorenje = true
                    PrikaziPopUpKojiUpozoravaNaVelikuVrednostUgovora()
                }
                
                if !vrednostUgovoraNavelaTokNaPopUpUpozorenje {
                    KonacnoUsnimiUgovor()
                }
            }
        } catch {
            print("nisam usao u snimanje jer polja nisu dobro ispunjena \(error)")
        }
        
    }
    
    
    func KonacnoUsnimiUgovor() {
        if jedinicaZaMeru != nativnaJedinicaMereArtiklaIzBaze {
            cenaPoJediniciMere = cenaPoJediniciMere! / kolicinaUPojedinacnomPakovanju!
            jedinicaZaMeru = nativnaJedinicaMereArtiklaIzBaze
            kolicinaRobe = kolicinaRobe! * kolicinaUPojedinacnomPakovanju!
        }
        
        labelaNacelnaVrednostUgovora.text = "Nacelno: " + String(nacelnaVrednostUgovora!.doubleValue.roundTo(places: 4)) + valutaUgovora!
        labelaRealizovanaVrednostUgovora.text = "Realizovano: " + String(describing: realizovanaVrednostUgovora!) + valutaUgovora!
        labelaIznosValutneNivelacije.text = "Val. niv: " + String(describing: iznosValutneNivelacije!) + valutaUgovora!
        labelaIznosNivelacijeDocnje.text = "Docnja niv: " + String(describing: iznosNivelacijeDocnje!) + valutaUgovora!
        labelaOtplaceno.text = "Otplaceno: : " + String(describing: otplaceno!) + valutaUgovora!
        labelaNeotplacenaVrednostUgovora.text = "Neotplaceno: " + String(describing: neotplacenaVrednostUgovora!) + valutaUgovora!
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "UgovorSaGazdinstvomKooperacija", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue(datumskaValutaUgovora, forKey: "datumskaValutaUgovora")
        zapis.setValue(datumSklapanjaUgovora, forKey: "datumSklapanjaUgovora")
        zapis.setValue(docnja, forKey: "docnja")
        zapis.setValue(ugovorJeZatvoren, forKey: "ugovorJeZatvoren")
        zapis.setValue(valutnaKlauzula, forKey: "valutnaKlauzula")
        
        zapis.setValue(adresa, forKey: "adresa")
        zapis.setValue(brojMenice, forKey: "brojMenice")
        zapis.setValue(jedinicaZaMeru, forKey: "jedinicaZaMeru")
        zapis.setValue(maticniBroj, forKey: "maticniBroj")
        zapis.setValue(mesto, forKey: "mesto")
        
        
        zapis.setValue(nacinRazduzenja, forKey: "nacinRazduzenja")
        zapis.setValue(naziv, forKey: "naziv")
        zapis.setValue(pib, forKey: "pib")
        zapis.setValue(povratnaAdresaPG, forKey: "povratnaAdresaPG")
        zapis.setValue(povratniJmbg, forKey: "povratniJmbg")
        
        zapis.setValue(povratniTekuciRacun, forKey: "povratniTekuciRacun")
        zapis.setValue(povratnoIme, forKey: "povratnoIme")
        zapis.setValue(povratnoMesto, forKey: "povratnoMesto")
        zapis.setValue(repromaterijalFinansiranUgovorom, forKey: "repromaterijalFinansiranUgovorom")
        zapis.setValue(robaKojaJePredmetUgovora, forKey: "robaKojaJePredmetUgovora")
        
        
        
        zapis.setValue(tekuciRacun, forKey: "tekuciRacun")
        zapis.setValue(valutaUgovora, forKey: "valutaUgovora")
        zapis.setValue(cenaPoJediniciMere, forKey: "cenaPoJediniciMere")
        zapis.setValue(iznosNivelacijeDocnje, forKey: "iznosNivelacijeDocnje")
        zapis.setValue(iznosValutneNivelacije, forKey: "iznosValutneNivelacije")
        
        zapis.setValue(0.0, forKey: "preuzetaKolicina")
        
        let testKurs: Decimal = 100
        
        zapis.setValue(kolicinaRobe, forKey: "kolicinaRobe")
        zapis.setValue(/*minimalniKursZaObracunRazduzenja*/testKurs, forKey: "minimalniKursZaObracunRazduzenja")
        zapis.setValue(nacelnaVrednostUgovora, forKey: "nacelnaVrednostUgovora")
        zapis.setValue(neotplacenaVrednostUgovora, forKey: "neotplacenaVrednostUgovora")
        zapis.setValue(otplaceno, forKey: "otplaceno")
        
        zapis.setValue(realizovanaVrednostUgovora, forKey: "realizovanaVrednostUgovora")
        zapis.setValue(vrednostPDVaOvogUgovora, forKey: "vrednostPDVaOvogUgovora")
        zapis.setValue(brojUgovora, forKey: "brojUgovora")
        zapis.setValue(povratniBroj, forKey: "povratniBroj")
        zapis.setValue(povratniBrojLicneKarte, forKey: "povratniBrojLicneKarte")
        
        zapis.setValue(povratniTelefon, forKey: "povratniTelefon")
        zapis.setValue(brojUgovora, forKey: "brojPoslednjegUgovora")
        
        do {
            try managedContext.save()
            print("U bazu podataka je upisana ugovor sa gazdinstvom  \(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem ugovor sa gazdinstvom: \(zapis)")
            PrikaziUspesniPopUp()
        } catch {
            print("Ne mogu da upisem ugovor sa gazdinstvom! \(error)")
        }
        
    }
    
    enum Greske: Error {
        case NisuUnetiDatumiSklapanjaUgovoraIDatumskaValutaUgovora
        case DatumSklapanjaUgovoraJeKasnijiOdDatumskeValuteUgovora
        case NemaPotpunihPodatakaFirme
        case NemaPotpunihPodatakaGazdinstva
        case NijeUnetaMenica
        case NijeUnetaJedinicaZaMeru
        case NijeUnetNacinRazduzenja
        case NijeUnetReporomaterijalFinansiranUgovorom
        case NijeUnetaRobaKojaJePredmetUgovora
        case NijeUnetaValutaUgovora
        case NijeUnetaCenaPoJediniciMere
        case NijeUnetaKolicinaRobe
        case NemaBrojaUgovora
    }
    
    func KorisnickiUnosJeIspravan(intDatumSklapanjaUgovora: Date?, intDocnja: Bool?, intUgovorJeZatvoren: Bool?, intValutnaKlauzula: Bool?, intAdresa: String?, intBrojMenice: String?, intJedinicaZaMeru: String?, intMaticniBroj: String?, intMesto: String?, intNacinRazduzenja: String?, intNaziv: String?, intPib: String?, intPovratnaAdresaPG: String?, intPovratniJmbg: String?, intPovratniTekuciRacun: String?, intPovratnoIme: String?, intReporomaterijalFinansiranUgovorom: String?, intRobaKojaJePredmetUgovora: String?, intTekuciRacun: String?, intValutaUgovora: String?, intCenaPoJediniciMere: Decimal?, intIznosNivelacijeDocnje: Decimal?, intIznosValutneNivelacije: Decimal?, intKolicinaRobe: Decimal?, indMinimalniKursZaObracunRazduzenja: Decimal?, intBrojUgovora: Int64?, intPovratniBroj: Int64?, intPovratniBrojLicneKarte: Int64?, intPovratniTelefno: Int64?, intDatumskaValutaUgovora: Date?) throws -> Bool {
        
        guard intDatumskaValutaUgovora != nil && intDatumSklapanjaUgovora != nil else {
            print(intDatumskaValutaUgovora!, intDatumSklapanjaUgovora!)
            PrikaziNeuspesniPopUp(poruka: "NisuUnetiDatumiSklapanjaUgovoraIDatumskaValutaUgovora")
            throw Greske.NisuUnetiDatumiSklapanjaUgovoraIDatumskaValutaUgovora
        }
 /*
        guard ProveriDaLiJeLeviDatumRanijiOdDesnogDatuma(leviDatum: intDatumSklapanjaUgovora!, desniDatum: intDatumskaValutaUgovora!) else {
            PrikaziNeuspesniPopUp(poruka: "DatumSklapanjaUgovoraJeKasnijiOdDatumskeValuteUgovora")
            throw Greske.DatumSklapanjaUgovoraJeKasnijiOdDatumskeValuteUgovora
        }
 */
        guard intAdresa != nil && intMaticniBroj != nil && intMesto != nil && intNaziv != nil && intPib != nil && intTekuciRacun != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaPotpunihPodatakaFirme")
            throw Greske.NemaPotpunihPodatakaFirme
        }
        
        guard intPovratnoIme != nil && intPovratniBroj != nil && povratniTelefon != nil && povratniBrojLicneKarte != nil && povratniTekuciRacun != nil && povratniJmbg != nil && intPovratnaAdresaPG != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaPotpunihPodatakaGazdinstva")
            throw Greske.NemaPotpunihPodatakaGazdinstva
        }
        
        guard intBrojMenice != nil && intBrojMenice != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaMenica")
            throw Greske.NijeUnetaMenica
        }
        
        guard intJedinicaZaMeru != nil && intJedinicaZaMeru != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaJedinicaZaMeru")
            throw Greske.NijeUnetaJedinicaZaMeru
        }
        
        guard intNacinRazduzenja != nil && intNacinRazduzenja != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetNacinRazduzenja")
            throw Greske.NijeUnetNacinRazduzenja
        }
        
        guard intReporomaterijalFinansiranUgovorom != nil && intReporomaterijalFinansiranUgovorom != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetReporomaterijalFinansiranUgovorom")
            throw Greske.NijeUnetReporomaterijalFinansiranUgovorom
        }
        
        guard intRobaKojaJePredmetUgovora != nil && intRobaKojaJePredmetUgovora != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaRobaKojaJePredmetUgovora")
            throw Greske.NijeUnetaRobaKojaJePredmetUgovora
        }
        
        guard intValutaUgovora != nil && intValutaUgovora != "" else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaValutaUgovora")
            throw Greske.NijeUnetaValutaUgovora
        }

        guard intCenaPoJediniciMere != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaCenaPoJediniciMere")
            throw Greske.NijeUnetaCenaPoJediniciMere
        }
        
        guard intKolicinaRobe != nil else {
            PrikaziNeuspesniPopUp(poruka: "NijeUnetaKolicinaRobe")
            throw Greske.NijeUnetaKolicinaRobe
        }
        
        guard intBrojUgovora != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaBrojaUgovora")
            throw Greske.NemaBrojaUgovora
        }
        
        return true
    }
    
    func ProveriDaLiJeLeviDatumRanijiOdDesnogDatuma(leviDatum: Date, desniDatum: Date) -> Bool {
        let kakavJeDatum = Calendar.current.compare(leviDatum, to: desniDatum, toGranularity: .day)
        switch kakavJeDatum {
        case .orderedSame:
            return true
        case .orderedAscending:
            return true
        default:
            print("default")
        }
        return false
    }
    
    func KompletirajPodatke() {
        robaKojaJePredmetUgovora = tfRobaKojaJePredmetUgovora.text
        brojMenice = tfBrojMenice.text
        if let double = NumberFormatter().number(from: tfCenaPoJediniciMere.value(forKey: "text") as! String) as? Double {
            cenaPoJediniciMere = Decimal(double)
        } else {
            cenaPoJediniciMere = nil
        }
        if let double = NumberFormatter().number(from: tfKolicinaRobe.value(forKey: "text") as! String) as? Double {
            kolicinaRobe = Decimal(double)
        } else {
            kolicinaRobe = nil
        }
        datumskaValutaUgovora = pikerDatum.date
        valutnaKlauzula = swValutnaKlauzula.isOn
        docnja = swDocnja.isOn
        
        
        
        realizovanaVrednostUgovora = 0
        iznosValutneNivelacije = 0
        iznosNivelacijeDocnje = 0
        otplaceno = 0
        neotplacenaVrednostUgovora = 0
        
        
        
        ugovorJeZatvoren = false
        

    }
    @IBOutlet weak var labelaBrojUgovora: UILabel!
    @IBOutlet weak var labelaNacelnaVrednostUgovora: UILabel!
    @IBOutlet weak var labelaRealizovanaVrednostUgovora: UILabel!
    @IBOutlet weak var labelaIznosValutneNivelacije: UILabel!
    @IBOutlet weak var labelaIznosNivelacijeDocnje: UILabel!
    @IBOutlet weak var labelaOtplaceno: UILabel!
    @IBOutlet weak var labelaNeotplacenaVrednostUgovora: UILabel!
    
    var robaKojaJePredmetUgovora: String?
    var repromaterijalFinansiranUgovorom: String?
    var kolicinaRobe: Decimal?
    var jedinicaZaMeru: String?
    var cenaPoJediniciMere: Decimal?
    var valutaUgovora: String?
    var datumSklapanjaUgovora: Date?
    var docnja: Bool?
    var valutnaKlauzula: Bool?
    var brojMenice: String?
    var nacinRazduzenja: String?
    var datumskaValutaUgovora: Date?
    var brojUgovora: Int64?
    var minimalniKursZaObracunRazduzenjaEUR: Decimal?
    var minimalniKursZaObracunRazduzenjaDOL: Decimal?
    var minimalniKursZaObracunRazduzenja: Decimal?
    var nativnaJedinicaMereArtiklaIzBaze: String?
    var kolicinaUPojedinacnomPakovanju: Decimal?
    
    var nacelnaVrednostUgovora: Decimal?
    var realizovanaVrednostUgovora: Decimal?  // u kg se povlaci podatak koliko je neko gazdintvo povuklo robe na tom ugovoru
    var iznosValutneNivelacije: Decimal?
    var iznosNivelacijeDocnje: Decimal?
    var otplaceno: Decimal?
    var neotplacenaVrednostUgovora: Decimal?
    var ugovorJeZatvoren: Bool?
    var vrednostPDVaOvogUgovora: Decimal?
    
    var povratnoIme: String?
    var povratniBroj: Int64?

    var povratnaAdresaPG: String?
    var povratnoMesto: String?
    var povratniTekuciRacun: String?
    var povratniTelefon: Int64?
    var povratniJmbg: String?
    var povratniBrojLicneKarte: Int64?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nekoIme = potencijalnoIme
        if segue.identifier == "sg-GenerisiUgovorSaGazdinstvomVC->FiltrGazd" {
            if let filtriranaGazdinstva = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstva.unosImenaGazdinstvaSaDrugogVC = nekoIme
            }
        }
    }
    
    var potencijalnoIme: String?
    @IBAction func IzaberiKomintenta(_ sender: Any) {
        potencijalnoIme = tfUnesiIme.text
        dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-GenerisiUgovorSaGazdinstvomVC->FiltrGazd"
        performSegue(withIdentifier: "sg-GenerisiUgovorSaGazdinstvomVC->FiltrGazd", sender: nil)
    }
    
    func PreuzmiImeSaDrugogVC() {
        if povratnoIme != nil {
            tfUnesiIme.text = povratnoIme!
            labelaBroj.text = String(povratniBroj!)
            tfAdresa.text = povratnaAdresaPG!
            tfMesto.text = povratnoMesto!
            tfTekuciRacun.text = povratniTekuciRacun!
            tfTelefon.text = String(povratniTelefon!)
            tfJmbg.text = povratniJmbg!
            tfBrojLicneKarte.text = String(povratniBrojLicneKarte!)
        }
    }
    
    var naziv: String?
    var mesto: String?
    var adresa: String?
    var maticniBroj: String?
    var tekuciRacun: String?
    var pib: String?
    func PovuciPodatkeMojeFirmeIzBaze() {
        let filter = "08185085"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviDOO")
        let predicate = NSPredicate(format: "maticniBroj CONTAINS[cd] %@", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                 naziv = podatak.value(forKey: "naziv") as? String
                 mesto = podatak.value(forKey: "mesto") as? String
                 adresa = podatak.value(forKey: "adresa") as? String
                 maticniBroj = podatak.value(forKey: "maticniBroj") as? String
                 tekuciRacun = podatak.value(forKey: "tekuciRacun") as? String
                 pib = podatak.value(forKey: "pib") as? String
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za svoje firme iz baze! \(error)")
        }
        labelaPodaciMojeFirme.text = naziv! + " iz " + mesto! + " ulica " + adresa! + " maticni broj: " + maticniBroj! + " sa tekucim racunom: " + tekuciRacun! + " i sa PIB-om: " + pib!
    }

    
    var brojPoslednjegUgovora: Int64 = 0
    func ProveriKojiJeBrojUgovoraNaRedu() {
        //SnimiInicijalizator()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            for podatak in response {
                if podatak.value(forKey: "brojPoslednjegUgovora") == nil {
                    brojPoslednjegUgovora = 0
                } else {
                    brojPoslednjegUgovora = (podatak.value(forKey: "brojPoslednjegUgovora") as? Int64)!
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak poslednji broj ugovora o kooperaciji! \(error)")
        }
        
    }
    
    
    func SnimiInicijalizator() {
        // ova funkcija samo u prazan entitet snima jedan podataka koji nije bitan jer glupi core data nece da izvrti prazan entitet i da mu pristupi radi inicijalizacije dok u njemu nema bar jedan podatak.... e pa evo mu podatak
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "UgovorSaGazdinstvomKooperacija", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue("bilosta", forKey: "inicijalizator")
        
        do {
            try managedContext.save()
            print("U bazu podataka je upisan zapis inicijalizator za ugovor o kooperaciji sa gazdinstvom\(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem inicijalizator o kooperaciji sa gazdinstvom: \(zapis)")
        } catch {
            print("Ne mogu da upisem novi inicijalizator o kooepraciji sa gazdinstvom! \(error)")
        }
         
    }

    func PreuzmiMinimalniKursZaObracun() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "KursnaLista")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                if podatak.value(forKey: "kursnaValuta") as? String == "Evro" {
                    let kakavJeDatum = Calendar.current.compare(datumSklapanjaUgovora!, to: podatak.value(forKey: "datum") as! Date, toGranularity: .day)
                    switch kakavJeDatum {
                    case .orderedSame:
                        minimalniKursZaObracunRazduzenjaEUR = podatak.value(forKey: "gornji") as? Decimal
                    default:
                        print("default")
                    }
                }
                if podatak.value(forKey: "kursnaValuta") as? String == "Dolar" {
                    let kakavJeDatum = Calendar.current.compare(datumSklapanjaUgovora!, to: podatak.value(forKey: "datum") as! Date, toGranularity: .day)
                    switch kakavJeDatum {
                    case .orderedSame:
                        minimalniKursZaObracunRazduzenjaDOL = podatak.value(forKey: "gornji") as? Decimal
                    default:
                        print("default")
                    }
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak kursa ! \(error)")
        }
    }
    
    @IBOutlet weak var roSacuvajUgovor: UIButton!
    func PrikaziUspesniPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili ugovor sa gazdinstvom",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.roSacuvajUgovor.isHidden = true
                                        // ovde da umetnes mail
                                        self.sendEmail(subject: "UGOVOR", textToSend: "tekst ugovora: Poljoprivredno gazdinstvo je saglasno da ce se prilikom delimicnog ili celokupnog razduzenja svoje ugovorne obaveze, a u slucaju da vrednost valutnog kursa u momentu razduzenja prevazilazi prethodno utvrdjenu minimalnu vrednost valutnog kursa, utvrditi novi minimalni iznos vrednosti za valutni kurs a sve radi daljeg obracuna vrednosti ugovornog zaduzenja poljoprivrednog gazdinstva. Ova vrednost minimalnog iznosa vrednosti za valutni kurs se nadalje koristi kao najmanja vrednost prilikom obracuna razduzenja poljoprivrednog gazdinstva na celokupnu vrednost ugovora sve do zatvaranja ugovora ili sticanja novog minimalnog iznosa vrednosti valutnog kursa.")
                                        self.performSegue(withIdentifier: "sgGlavniSaGenerisiUgovorSaGazdinstvom", sender: nil)
        })
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }

    
    func PrikaziNeuspesniPopUp(poruka: String?) {
        let popUp = UIAlertController(title: "NEUSPESNO",
                                      message: poruka,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        var okAction = UIAlertAction(title: "Pokusacu ponovo sve opet",
                                     style: UIAlertActionStyle.default)
        
        if poruka == "Nema upisanog kursa - najpre unesi kurs u kursnu listu pa nastavi dalje" {
             okAction = UIAlertAction(title: "Pokusacu ponovo sve opet",
                                         style: UIAlertActionStyle.default,
                                         handler: {(alert: UIAlertAction!) in
                                            self.performSegue(withIdentifier: "sgGlavniSaGenerisiUgovorSaGazdinstvom", sender: nil)
            })
        }
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }
    
    func PrikaziPopUpKojiUpozoravaNaVelikuVrednostUgovora() {
        print("UPOZORENJE")
        let popUp = UIAlertController(title: "Upozorenje! Vrednost ugovora je podosta velika, mozda nije bas sve popunjeno kako valja",
            message: "Klikom na Cepam Dalje nastavljas dalje iako je vrednost ugovora preko 500.000 din, a na ODUSTAJEM izlazis iz svega ovoga",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cepamDaljeAction = UIAlertAction(title: "Cepam Dalje",
                                              style: UIAlertActionStyle.default,
                                              handler: {(alert: UIAlertAction!) in
                                                self.KonacnoUsnimiUgovor()
        })

        let odustajemAction = UIAlertAction(title: "ODUSTAJEM",
                                            style: UIAlertActionStyle.cancel,
                                            handler: {(alert: UIAlertAction!) in
                                                self.performSegue(withIdentifier: "sgGlavniSaGenerisiUgovorSaGazdinstvom", sender: nil)
        })
        
        popUp.addAction(cepamDaljeAction)
        popUp.addAction(odustajemAction)
        present(popUp, animated: true, completion: nil)
    }
    
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
        tfRobaKojaJePredmetUgovora.text = nizArtikli[0]
        nativnaJedinicaMereArtiklaIzBaze = nizjedinicaMereArtiklaIzBaze[0]
        kolicinaUPojedinacnomPakovanju = nizkolicinaUPojedinacnomPakovanju[0]
        return nizArtikli[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfRobaKojaJePredmetUgovora.text = nizArtikli[row]
        nativnaJedinicaMereArtiklaIzBaze = nizjedinicaMereArtiklaIzBaze[row]
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
        performSegue(withIdentifier: "sgGlavniSaGenerisiUgovorSaGazdinstvom", sender: nil)
    }
}
