//
//  GenerisiOtkupniListVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/21/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData
import MessageUI


extension Double {
    var skiniPoljoprivrednickiIznosPDVa : Double {
        return self / ((dummy!.pdvStopaZaPoljoprivrednaGazdinstva / 100) + 1)
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


class GenerisiOtkupniListVC: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
var potecijalnoImeGazdinstva: String?

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nekoImeGazdinstva = potecijalnoImeGazdinstva
        if segue.identifier == "sg-GenOtkList->FiltrGazd" {
            if let filtriranaGazdinstvaVC = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstvaVC.unosImenaGazdinstvaSaDrugogVC = nekoImeGazdinstva
            }
        } else if segue.identifier == "sg-GenOtkList->FinKarGaz" {
            if let finansijskaKarticaGazdinstvaVC = segue.destination as? FinansijskaKarticaGazdinstvaVC {
                finansijskaKarticaGazdinstvaVC.povratnoIme = povratnoImeGazdinstva!
                finansijskaKarticaGazdinstvaVC.povratniBroj = povratniBPG!
                if vrednostBezPDV != nil {
                    finansijskaKarticaGazdinstvaVC.povratniSaldoPodobanZaKompenzaciju = vrednostBezPDV
                }
            }
        }
    }


var povratnoImeGazdinstva: String?
var povratnaAdresaGazdinstva: String?
var povratniBPG: Int64?
var povratniTekuciRacunGazdinstva: String?
    
var povratnaUkupnaVrednostOtvorenihAvansa: Decimal?
var povratnaUkupnaVrednostOtvorenihUgovora: Decimal?
var povratniUkupniSaldoBezObziraNaValutu: Decimal?
var povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost: Dictionary? = [Int : Decimal]()
var povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost: Dictionary? = [Int : Decimal]()
var povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje: Dictionary = [Int : Decimal]()
var povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule: Dictionary = [Int : Decimal]()

    @IBOutlet weak var labelaUkupnaVrednostOtvorenihAvansa: UILabel!
    @IBOutlet weak var labelaUkupnaVrednostOtvorenihUgovora: UILabel!
    @IBOutlet weak var labelaUkupniSaldoBezObziraNaValutu: UILabel!


    @IBOutlet weak var labelaBrojAvansaVrednost: UILabel!
    @IBOutlet weak var labelaBrojUgovoraVrednost: UILabel!
    @IBOutlet weak var labelaBrojUgovoraVrednostDocnjeIliValutneNivelacije: UILabel!
    
    
    @IBOutlet weak var labelaKompenzujemNaDnu: UILabel!
    @IBOutlet weak var labelaObavenizPDVnaDnu: UILabel!
    @IBOutlet weak var labelaZaUplatuNaDnu: UILabel!
    @IBOutlet weak var labelaUkupnoSaAvansaNaDnu: UILabel!
    
    
    override func awakeFromNib() {
        PreuzmiDanasnjiKursZaObracun()
        super.awakeFromNib()
        self.view.backgroundColor = UIColor.lightGray
        swTelKel.isUserInteractionEnabled = false
        self.hideKeyboardWhenTappedAround()
        DodajDugmeZaNazad()
        tfUnesiImePG.addTarget(self, action: #selector(PreuzmiPotencijalnoImeGazdinstva), for: .editingChanged)
        tfManuelniUnosCene.addTarget(self, action: #selector(RacunamVrednostiVezaneZaCenu), for: .editingChanged)
        swTelKel.addTarget(self, action: #selector(PrikaziTelKelObjasnjenje), for: UIControlEvents.valueChanged)
    }
  
    override func viewDidAppear(_ animated: Bool) {
        if danasnjiKursZaObracunRazduzenjaEUR == nil || danasnjiKursZaObracunRazduzenjaDOL == nil {
            PrikaziNeuspesniPopUp(poruka: "Nema upisanog kursa EUR ili DOL - najpre unesi kurseve u kursnu listu pa se vrati ovde")
        } else {
            ProveriKojiJeBrojOtkupnogListaNaRedu()
            labelaBrojOtkupnogLista.text = "Otkupni list br: " + String(brojPoslednjegOtkupnogLista + 1)
            
            NapuniPoljaVecPrikupljenimInformacijama()
            PreuzmiKojeGazdinstvoSaDrugogVC()
            PreuzmiOdvageSaDrugogVC()
            PreuzmiCenuZaObracunSaDrugogVC()
            PreuzmiFinansijskoStanjeSaDrugogVC()
        }
    }
    
    func PreuzmiKojeGazdinstvoSaDrugogVC() {        
        if povratnoImeGazdinstva != nil {
            //print("punim IME iz PreuzmiKojeGazdinstvoSaDrugogVC ")
            tfUnesiImePG.text = povratnoImeGazdinstva!
            labelaBPG.text = String(povratniBPG!)
            labelaAdresa.text = povratnaAdresaGazdinstva!
            labelaTekuciRacunGazdinstva.text = povratniTekuciRacunGazdinstva!
            PrivermenoZadrzavanjeVrednostPreuzetihSaDrugihVC(sender: "KOJEGAZDINSTVO")
            
            dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFinansijskaKarticaGazdinstva = "sg-GenOtkList->FinKarGaz"
            performSegue(withIdentifier: "sg-GenOtkList->FinKarGaz", sender: nil)
        }
    }
    
    func PreuzmiOdvageSaDrugogVC() {
        if potencijalnaKojaRoba != nil {
            //print("punim BRUTO iz PreuzmiOdvageSaDrugogVC")
            lbBruto.text = String(potencijalniBruto!)
            lbTara.text = String(potencijalnaTara!)
            lbNeto.text = String(potencijalniNeto!)
            lbBrNalogaMagDP.text = String(describing: potencijalniBrojNalogaMagacinuDaPrimi!)
            labelaKojaRoba.text = String(potencijalnaKojaRoba!)
            labelaUkupnoJUS.text = String(potencijalniJUS!)
            labelaOdbitak.text = String(potencijalniOdbitak!)
            PrivermenoZadrzavanjeVrednostPreuzetihSaDrugihVC(sender: "KOJEODAVGE")
        }
    }
    
    func PreuzmiCenuZaObracunSaDrugogVC() {
        // ovde ako budes nekada vukao cenu sa drugog vc-a
        PrivermenoZadrzavanjeVrednostPreuzetihSaDrugihVC(sender: "CENAZAOBRACUN")
        
    }
   
    var ukupnoZaKompenzovanje: Decimal?
    var ukupnoSaAvansa: Decimal?
    var preostajeZaUplatu: Decimal?
    var brojeviAvansaiKompencacioniIznosi = ""
    var brojeviUgovoraIKompencacioniIznosi = ""
    var brojeviUgovoraIIznosiDocnjeIValutneNivelacije = ""
    func PreuzmiFinansijskoStanjeSaDrugogVC() {
        if povratnaUkupnaVrednostOtvorenihAvansa != nil || povratnaUkupnaVrednostOtvorenihUgovora != nil {
            tfManuelniUnosCene.isUserInteractionEnabled = false
            
            labelaUkupnaVrednostOtvorenihAvansa.text = String(format: "%.2f", locale: Locale.current, povratnaUkupnaVrednostOtvorenihAvansa!.doubleValue.roundTo(places: 2))
            labelaUkupnaVrednostOtvorenihUgovora.text = String(format: "%.2f", locale: Locale.current, povratnaUkupnaVrednostOtvorenihUgovora!.doubleValue.roundTo(places: 2))
            labelaUkupniSaldoBezObziraNaValutu.text = String(format: "%.2f", locale: Locale.current, povratniUkupniSaldoBezObziraNaValutu!.doubleValue.roundTo(places: 2))
            
            brojeviAvansaiKompencacioniIznosi = ""
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost!.keys {
                brojeviAvansaiKompencacioniIznosi += "Avans broj: " + String(clan) + " Iznos: " + String(povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            brojeviUgovoraIKompencacioniIznosi = ""
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost!.keys {
                brojeviUgovoraIKompencacioniIznosi += "Ugovor broj: " + String(clan) + " Iznos: " + String(povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            brojeviUgovoraIIznosiDocnjeIValutneNivelacije = ""
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje.keys {
                brojeviUgovoraIIznosiDocnjeIValutneNivelacije += "Ugovor broj: " + String(clan) + " Iznos docnje: " + String(povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje[clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule.keys {
                brojeviUgovoraIIznosiDocnjeIValutneNivelacije += "Ugovor broj: " + String(clan) + " Iznos valutne nivelacije: " + String(povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule[clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            labelaBrojAvansaVrednost.text = brojeviAvansaiKompencacioniIznosi
            labelaBrojUgovoraVrednost.text = brojeviUgovoraIKompencacioniIznosi
            labelaBrojUgovoraVrednostDocnjeIliValutneNivelacije.text = brojeviUgovoraIIznosiDocnjeIValutneNivelacije
            
            ukupnoZaKompenzovanje = nil
            ukupnoSaAvansa = nil
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost!.keys {
                ukupnoSaAvansa = (ukupnoSaAvansa ?? 0) + povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost![clan]!
            }
             
            for clan in povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost!.keys {
                ukupnoZaKompenzovanje = (ukupnoZaKompenzovanje ?? 0) + povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![clan]!
            }
            
            if ukupnoSaAvansa != nil {
                labelaUkupnoSaAvansaNaDnu.text = String(ukupnoSaAvansa!.doubleValue.roundTo(places: 2)) + " Din"
            }
            
            if ukupnoZaKompenzovanje != nil {
                labelaKompenzujemNaDnu.text = String(ukupnoZaKompenzovanje!.doubleValue.roundTo(places: 2)) + " Din"
            }
            
            preostajeZaUplatu = Decimal(vrednostBezPDV!) - (ukupnoZaKompenzovanje ?? 0) - (ukupnoSaAvansa ?? 0)
            
            labelaObavenizPDVnaDnu.text = String(vrednostPDV!.roundTo(places: 2)) + " Din"
            labelaZaUplatuNaDnu.text = String(preostajeZaUplatu!.doubleValue.roundTo(places: 2)) + " Din"
            
            PrivermenoZadrzavanjeVrednostPreuzetihSaDrugihVC(sender: "KOJEFINANSIJSKOSTANJE")
        }
    }
    
    func NapuniPoljaVecPrikupljenimInformacijama() {
        if dummyAppDelegate?.pzvImeGazdinstva != nil {
            //print("punim IME iz NapuniPoljaVecPrikupljenimInformacijama ")
            tfUnesiImePG.text = dummyAppDelegate?.pzvImeGazdinstva
            labelaBPG.text = String((dummyAppDelegate?.pzvBPG)!)
            labelaAdresa.text = dummyAppDelegate?.pzvAdresa
            labelaTekuciRacunGazdinstva.text = dummyAppDelegate?.pzvPovratniTekuciRacunGazdinstva
        }
        //print("analiziram zasto ne prolazi uslov da je ovo razlicito od nil \(dummyAppDelegate?.pzvKojaRoba)")
        if dummyAppDelegate?.pzvKojaRoba != nil {
            //print("punim BRUTO iz NapuniPoljaVecPrikupljenimInformacijama")
            lbBrNalogaMagDP.text = String(describing: (dummyAppDelegate?.pzvBrNalogaMagDP!)!)
            lbBruto.text = String((dummyAppDelegate?.pzvBruto)!)
            lbTara.text = String((dummyAppDelegate?.pzvTara)!)
            lbNeto.text = String((dummyAppDelegate?.pzvNeto)!)
            labelaKojaRoba.text = dummyAppDelegate?.pzvKojaRoba
            labelaOdbitak.text = String((dummyAppDelegate?.pzvOdbitak)!)
            labelaUkupnoJUS.text = String((dummyAppDelegate?.pzvJUS)!)
        }
        
        if dummyAppDelegate?.pzvCenaZaKgSaPDV != nil {
            cenaZaKgSaPDV = dummyAppDelegate?.pzvCenaZaKgSaPDV
            swTelKel.isOn = (dummyAppDelegate?.pzvSwTelKel)!
            RacunamVrednostiVezaneZaCenu()
        }
        
        if dummyAppDelegate?.pzvUkupnaVrednostOtvorenihAvansa != nil {
            labelaUkupnaVrednostOtvorenihAvansa.text = String(format: "%.2f", locale: Locale.current, (dummyAppDelegate?.pzvUkupnaVrednostOtvorenihAvansa!.doubleValue.roundTo(places: 2))!)
            labelaUkupnaVrednostOtvorenihUgovora.text = String(format: "%.2f", locale: Locale.current, (dummyAppDelegate?.pzvUkupnaVrednostOtvorenihUgovora!.doubleValue.roundTo(places: 2))!)
            labelaUkupniSaldoBezObziraNaValutu.text = String(format: "%.2f", locale: Locale.current, (dummyAppDelegate?.pzvUkupniSaldoBezObziraNaValutu!.doubleValue.roundTo(places: 2))!)
            
            brojeviAvansaiKompencacioniIznosi = ""
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost!.keys {
                brojeviAvansaiKompencacioniIznosi += "Avans broj: " + String(clan) + " Iznos: " + String(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            brojeviUgovoraIKompencacioniIznosi = ""
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost!.keys {
                brojeviUgovoraIKompencacioniIznosi += "Ugovor broj: " + String(clan) + " Iznos: " + String(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            brojeviUgovoraIIznosiDocnjeIValutneNivelacije = ""
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje!.keys {
                brojeviUgovoraIIznosiDocnjeIValutneNivelacije += "Ugovor broj: " + String(clan) + " Iznos docnje: " + String(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule!.keys {
                brojeviUgovoraIIznosiDocnjeIValutneNivelacije += "Ugovor broj: " + String(clan) + " Iznos valutne nivelacije: " + String(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule![clan]!.doubleValue.roundTo(places: 2)) + " // "
            }
            
            ukupnoZaKompenzovanje = nil
            ukupnoSaAvansa = nil
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost!.keys {
                ukupnoSaAvansa = (ukupnoSaAvansa ?? 0) + dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost![clan]!
            }
            
            for clan in dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost!.keys {
                ukupnoZaKompenzovanje = (ukupnoZaKompenzovanje ?? 0) + dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![clan]!
            }
            
            if ukupnoSaAvansa != nil {
                labelaUkupnoSaAvansaNaDnu.text = String(ukupnoSaAvansa!.doubleValue.roundTo(places: 2)) + " Din"
            }
            
            if ukupnoZaKompenzovanje != nil {
                labelaKompenzujemNaDnu.text = String(ukupnoZaKompenzovanje!.doubleValue.roundTo(places: 2)) + " Din"
            }
            
            
            
            labelaBrojAvansaVrednost.text = brojeviAvansaiKompencacioniIznosi
            labelaBrojUgovoraVrednost.text = brojeviUgovoraIKompencacioniIznosi
            labelaBrojUgovoraVrednostDocnjeIliValutneNivelacije.text = brojeviUgovoraIIznosiDocnjeIValutneNivelacije
        }
    }
    
    func PrivermenoZadrzavanjeVrednostPreuzetihSaDrugihVC(sender: String) {
        if sender == "KOJEGAZDINSTVO" {
            dummyAppDelegate?.pzvImeGazdinstva = povratnoImeGazdinstva
            dummyAppDelegate?.pzvBPG = povratniBPG
            dummyAppDelegate?.pzvAdresa = povratnaAdresaGazdinstva
            dummyAppDelegate?.pzvPovratniTekuciRacunGazdinstva = povratniTekuciRacunGazdinstva
        }
        if sender == "KOJEODAVGE" {
             dummyAppDelegate?.pzvBruto = potencijalniBruto
             dummyAppDelegate?.pzvTara = potencijalnaTara
             dummyAppDelegate?.pzvNeto = potencijalniNeto
             dummyAppDelegate?.pzvBrNalogaMagDP = potencijalniBrojNalogaMagacinuDaPrimi
             dummyAppDelegate?.pzvKojaRoba = potencijalnaKojaRoba
             dummyAppDelegate?.pzvJUS = potencijalniJUS
             dummyAppDelegate?.pzvOdbitak = potencijalniOdbitak
             dummyAppDelegate?.pzvPotencijalniDatumPrijema = potencijalniDatumPrijema
            
        }
        if sender == "CENAZAOBRACUN" {
            // ovde ako budes nekada vukao cenu sa drugog vc-a
        }
        if sender == "KOJEFINANSIJSKOSTANJE" {
            dummyAppDelegate?.pzvUkupnaVrednostOtvorenihAvansa = povratnaUkupnaVrednostOtvorenihAvansa
            dummyAppDelegate?.pzvUkupnaVrednostOtvorenihUgovora = povratnaUkupnaVrednostOtvorenihUgovora
            dummyAppDelegate?.pzvUkupniSaldoBezObziraNaValutu = povratniUkupniSaldoBezObziraNaValutu
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost = povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost = povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje = povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje
            dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule = povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule
        }
        

    }
    
    @IBOutlet weak var tfUnesiImePG: UITextField!
    @IBOutlet weak var labelaBPG: UILabel!
    @IBOutlet weak var labelaAdresa: UILabel!
    @IBOutlet weak var labelaTekuciRacunGazdinstva: UILabel!
    
    
    func PreuzmiPotencijalnoImeGazdinstva(sender: UITextField) {
        potecijalnoImeGazdinstva = tfUnesiImePG.text
    }
    
    @IBAction func IzaberiGazdinstvo(_ sender: Any) {
        dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-GenOtkList->FiltrGazd"
        performSegue(withIdentifier: "sg-GenOtkList->FiltrGazd", sender: nil)
    }
    
    @IBOutlet weak var lbBrNalogaMagDP: UILabel!
    @IBOutlet weak var lbBruto: UILabel!
    @IBOutlet weak var lbTara: UILabel!
    @IBOutlet weak var lbNeto: UILabel!
    @IBOutlet weak var labelaKojaRoba: UILabel!
    @IBOutlet weak var labelaUkupnoJUS: UILabel!
    @IBOutlet weak var labelaOdbitak: UILabel!
    
    @IBOutlet weak var labelaCenaPoKgSaPDV: UILabel!
    @IBOutlet weak var labelaCenaPoKgBezPDV: UILabel!
    @IBOutlet weak var labelaVrednostBezPDV: UILabel!
    @IBOutlet weak var labelaVrednostPDV: UILabel!
    @IBOutlet weak var labelaUkupno: UILabel!
    

    
    var cenaZaKgSaPDV: Double?
    var cenaZaKgBezPDV: Double?
    var vrednostBezPDV: Double?
    var vrednostPDV: Double?
    var ukupno: Double?
    
    @IBOutlet weak var tfManuelniUnosCene: UITextField!
    
    func RacunamVrednostiVezaneZaCenu() {

        if tfManuelniUnosCene.text! != "" && tfManuelniUnosCene.text != nil {
            print("preuzimam vrednost iz text fielda")
            cenaZaKgSaPDV = Double(tfManuelniUnosCene.text!)
            dummyAppDelegate?.pzvCenaZaKgSaPDV = cenaZaKgSaPDV
        }

        
        if cenaZaKgSaPDV != nil && dummyAppDelegate?.pzvJUS != nil {
            swTelKel.isUserInteractionEnabled = true
            cenaZaKgBezPDV = cenaZaKgSaPDV!.skiniPoljoprivrednickiIznosPDVa
            vrednostBezPDV = (cenaZaKgBezPDV! * Double((dummyAppDelegate?.pzvJUS)!)).roundTo(places: 2)
            vrednostPDV = (cenaZaKgSaPDV! * Double((dummyAppDelegate?.pzvJUS)!) - vrednostBezPDV!).roundTo(places: 2)
            ukupno = (vrednostBezPDV! + vrednostPDV!).roundTo(places: 2)
           
            IzracunajVrednostiVezaneZaCenuAkoJeTelKelSwON()
            PrikazujemVrednostiVezaneZaCenu()
        } else {
            swTelKel.isOn = false
            swTelKel.isUserInteractionEnabled = false
            labelaCenaPoKgSaPDV.text = ""
            labelaCenaPoKgBezPDV.text = ""
            labelaVrednostBezPDV.text = ""
            labelaVrednostPDV.text = ""
            labelaUkupno.text = ""
            labelaObavestenjaNetoAkoJeTelKelSwON.text = ""
            labelaCenaPoKgSaPdvAkoJeTelKelSwON.text = ""
            labelaCenaPoKgBezPdvAkoJeTelKelSwON.text = ""
            
        }
    }
    
    func PrikazujemVrednostiVezaneZaCenu() {
        
        labelaCenaPoKgSaPDV.text = String(format: "%.2f", locale: Locale.current, cenaZaKgSaPDV!.roundTo(places: 4))
        labelaCenaPoKgBezPDV.text = String(format: "%.2f", locale: Locale.current, cenaZaKgBezPDV!.roundTo(places: 4))
        labelaVrednostBezPDV.text = String(format: "%.2f", locale: Locale.current, vrednostBezPDV!.roundTo(places: 4))
        labelaVrednostPDV.text = String(format: "%.2f", locale: Locale.current, vrednostPDV!.roundTo(places: 4))
        labelaUkupno.text = String(format: "%.2f", locale: Locale.current, ukupno!.roundTo(places: 4))
    }
    
    var netoAkoJeTelKelSwON: Double?
    var cenaZaKgSaPDVakoJeTelKelSwON: Double?
    var cenaZaKgBezPDVakoJeTelKelSwON: Double?
    var vrednostBezPDVakoJeTelKelSwON: Double?
    var vrednostPDVakoJeTelKelSwON: Double?
    var ukupnoAkoJeTelKelSwON: Double?

    @IBOutlet weak var swTelKel: UISwitch!
    @IBOutlet weak var labelaCenaPoKgSaPdvAkoJeTelKelSwON: UILabel!
    @IBOutlet weak var labelaCenaPoKgBezPdvAkoJeTelKelSwON: UILabel!
    @IBOutlet weak var labelaObavestenjaNetoAkoJeTelKelSwON: UILabel!

   
    func IzracunajVrednostiVezaneZaCenuAkoJeTelKelSwON() {
        netoAkoJeTelKelSwON = Double((dummyAppDelegate?.pzvNeto)!)
        
        vrednostBezPDVakoJeTelKelSwON = vrednostBezPDV
        vrednostPDVakoJeTelKelSwON = vrednostPDV
        ukupnoAkoJeTelKelSwON = ukupno
        
        cenaZaKgSaPDVakoJeTelKelSwON = ukupnoAkoJeTelKelSwON! / netoAkoJeTelKelSwON!
        cenaZaKgBezPDVakoJeTelKelSwON = cenaZaKgSaPDVakoJeTelKelSwON?.skiniPoljoprivrednickiIznosPDVa
        PrikaziTelKelObjasnjenje()
    }
    
    func PrikaziTelKelObjasnjenje() {
        dummyAppDelegate?.pzvSwTelKel = swTelKel.isOn
        if swTelKel.isOn && dummyAppDelegate?.pzvOdbitak! != 0 {
            labelaObavestenjaNetoAkoJeTelKelSwON.text = "Ulaz u magacin ce biti \(Int(netoAkoJeTelKelSwON!)) KG"
            labelaCenaPoKgSaPdvAkoJeTelKelSwON.text = String(format: "%.2f", locale: Locale.current, cenaZaKgSaPDVakoJeTelKelSwON!.roundTo(places: 4))
            labelaCenaPoKgBezPdvAkoJeTelKelSwON.text = String(format: "%.2f", locale: Locale.current, cenaZaKgBezPDVakoJeTelKelSwON!.roundTo(places: 4))
        } else {
            labelaObavestenjaNetoAkoJeTelKelSwON.text = ""
            labelaCenaPoKgSaPdvAkoJeTelKelSwON.text = ""
            labelaCenaPoKgBezPdvAkoJeTelKelSwON.text = ""
        }
    }
    
    
    @IBAction func IzaberiOdvage(_ sender: Any) {
        performSegue(withIdentifier: "sg-GenOtkList->PrikazUnetihListicaOdvage", sender: nil)
    }
    
    @IBAction func IzaberiAvanseUgovoreZaUkrstanjeSaOtkupnimListom(_ sender: Any) {
        
    }
    
    
    @IBAction func Dugme(_ sender: Any) {
        
        if KorisnickiUnosJeDobar() {
            // snimi celokupni otkupni list u core data
            SnimiOtkupniList()
            
            // posalji otkupni list na mail
            // iskazi nivelaciju docnje i njen iznos kao i broj ugovora na koji se odnosi
            // iskazi valutnu nivelaciju i njen iznos kao i broj ugovora na koji se odnosi
            PosaljiOtkupniListMail()
            
            // posalji automatski na stampu nalog za placanje koji se sadrzi od dva dela (obavezna uplata PDV-a + ostatak za uplatu)
            PosaljiNalogZaUplatu()
            
            // snimi u core data celokupnu kompenzaciju i posalji automatski na stampu tu kompenzaciju
            // zabelezi u odgovarajuce ugovore da je jedan njihov deo, ili u celosti naplacen a ako je naplacen u celosti onda ga zatvori (otplaceno, neotplacenaVrednostUgovora, ugovorJeZatvoren)

            if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?.count != 0 {
                print("count recnika pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost je \(String(describing: dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?.count))")
                ProveriKojiJeBrojKompenzacijeNaRedu()
                SnimiKompenzaciju()
                PosaljiKompenzacijuMail()
                OsveziUgovoreNovimPodacima()
            }

            if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost?.count != 0 {
                print("count recnika pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost je \(String(describing: dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost?.count))")
                // zabelezi u odgovarajuce avanse da je jedan njihov deo, ili mozda i celina naplacena a ako je naplacen u celosti onda ga zatvori (kompenzovano, avansJeZatvoren)
                OsveziAvanseNovimPodacima()
            }
            
            // zabelezi u core data da su odgovarajuce odvage iskoriscene za obracun i disable da moze sw na njima da se pomeri na ON ILI IZBACI UPOZERENJE UKOLIKO SE OPET IZABERU ZBOG DOPLATE
            OsveziOdvage()
            // Prikazi popup i dugme da odvede na vezivanje svih mailova i slanje ga u jednom
            PrikaziPopUp()
            
            
        }
        
        
        
        
        
        // zabelezi u odgovarajuce ugovore da je na njih, i u kom iznosu, primenjena nivelacija docnje i valutna nivelacija

        
    }
    
    var potencijalniBruto: Int32?
    var potencijalnaTara: Int32?
    var potencijalniNeto: Int32?
    var potencijalniBrojNalogaMagacinuDaPrimi: [Int32]?
    var potencijalnaKojaRoba: String?
    var potencijalniJUS: Int32?
    var potencijalniOdbitak: Int32?
    var potencijalniDatumPrijema: Date?
    
    
    @IBOutlet weak var labelaBrojOtkupnogLista: UILabel!
    
    
    var brojPoslednjegOtkupnogLista: Int32 = 0
    func ProveriKojiJeBrojOtkupnogListaNaRedu() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OtkupniList")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            print(fetchRequest)
            for podatak in response {
                //print("vrtim response")
                if podatak.value(forKey: "brojPoslednjegOtkupnogLista") == nil {
                    brojPoslednjegOtkupnogLista = 0
                    //print(brojPoslednjegOtkupnogLista)
                } else {
                    brojPoslednjegOtkupnogLista = (podatak.value(forKey: "brojPoslednjegOtkupnogLista") as? Int32)!
                    //print(brojPoslednjegOtkupnogLista)
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak poslednji broj otkupnog lista! \(error)")
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
        
        performSegue(withIdentifier: "sgGlavniSaGenerisiOtkupniList", sender: nil)
    }
    
    @IBOutlet weak var roSnimi: UIButton!
    func PrikaziPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno ste snimili OTKUPNI LIST",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.roSnimi.isHidden = true
                                        self.PosaljiMailSaSvimRelevenatnimPodacima()
                                        //self.performSegue(withIdentifier: "sgGlavniSaGenerisiOtkupniList", sender: nil)
                                        
        })
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }
    
    func PrikaziNeuspesniPopUp(poruka: String?) {
        let popUp = UIAlertController(title: "NEUSPESNO",
                                      message: poruka,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        var okAction = UIAlertAction(title: "Pokusacu PONOVO sve opet",
                                     style: UIAlertActionStyle.default)
        
        if poruka == "Nema upisanog kursa EUR ili DOL - najpre unesi kurseve u kursnu listu pa se vrati ovde" {
            okAction = UIAlertAction(title: "Pokusacu ponovo sve opet",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaGenerisiOtkupniList", sender: nil)
            })
        }
        
        popUp.addAction(okAction)
        present(popUp, animated: true, completion: nil)
    }
    
    var danasnjiKursZaObracunRazduzenjaEUR: Decimal?
    var danasnjiKursZaObracunRazduzenjaDOL: Decimal?
    func PreuzmiDanasnjiKursZaObracun() {
        let currentDate = Date()
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
                    let kakavJeDatum = Calendar.current.compare(currentDate, to: podatak.value(forKey: "datum") as! Date, toGranularity: .day)
                    switch kakavJeDatum {
                    case .orderedSame:
                        danasnjiKursZaObracunRazduzenjaEUR = podatak.value(forKey: "gornji") as? Decimal
                    default:
                        print("default")
                    }
                }
                if podatak.value(forKey: "kursnaValuta") as? String == "Dolar" {
                    let kakavJeDatum = Calendar.current.compare(currentDate, to: podatak.value(forKey: "datum") as! Date, toGranularity: .day)
                    switch kakavJeDatum {
                    case .orderedSame:
                        danasnjiKursZaObracunRazduzenjaDOL = podatak.value(forKey: "gornji") as? Decimal
                    default:
                        print("default")
                    }
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za kurs! \(error)")
        }
    }


    
    enum Greske: Error {
        case NemaBrojaOtkupnogLista
        case NemaOdabranihBrojevaNalogaMagacinuDaPrimi
        case NemaNETO
        case NemaNazivaRobeZaObracun
        case NemaCene
        case NemaNazivaPG
        case NemaIznosaObaveznogPDVa
        case NemaIznosaZaUplatu
        case NemaDatumaNajranijegOtkupa
    }
    
    func ProveravamKorisnickiUnos(intBrojOtkLista: Int32?, intBrojeviNMDP: [Int32?]?, intNeto: Int32?, intRoba: String?, intCenaZaKgSaPDV: Double?, intNazivGazdinstva: String?, intObavezniPDV: Double?, intZaUplatu: Decimal?, intDatumNajranijegOtkupa: Date?) throws -> Bool {
        
        guard intBrojOtkLista != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaBrojaOtkupnogLista")
            throw Greske.NemaBrojaOtkupnogLista
        }
        
        guard intBrojeviNMDP != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaOdabranihBrojevaNalogaMagacinuDaPrimi")
            throw Greske.NemaOdabranihBrojevaNalogaMagacinuDaPrimi
        }
        
        guard intNeto != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaNETO")
            throw Greske.NemaNETO
        }
        
        guard intRoba != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaNazivaRobeZaObracun")
            throw Greske.NemaNazivaRobeZaObracun
        }
        
        guard intCenaZaKgSaPDV != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaCene")
            throw Greske.NemaCene
        }
        
        guard intNazivGazdinstva != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaNazivaPG")
            throw Greske.NemaNazivaPG
        }
        
        guard intObavezniPDV != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaIznosaObaveznogPDVa")
            throw Greske.NemaIznosaObaveznogPDVa
        }
        
        guard intZaUplatu != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaIznosaZaUplatu")
            throw Greske.NemaIznosaZaUplatu
        }
        
        guard intDatumNajranijegOtkupa != nil else {
            PrikaziNeuspesniPopUp(poruka: "NemaDatumaNajranijegOtkupa")
            throw Greske.NemaDatumaNajranijegOtkupa
        }
        return true
    }
    
    func KorisnickiUnosJeDobar() -> Bool {
        do {
            let unosJeValidan = try ProveravamKorisnickiUnos(intBrojOtkLista: brojPoslednjegOtkupnogLista, intBrojeviNMDP: dummyAppDelegate?.pzvBrNalogaMagDP, intNeto: dummyAppDelegate?.pzvNeto, intRoba: dummyAppDelegate?.pzvKojaRoba, intCenaZaKgSaPDV: dummyAppDelegate?.pzvCenaZaKgSaPDV, intNazivGazdinstva: dummyAppDelegate?.pzvImeGazdinstva, intObavezniPDV: vrednostPDV, intZaUplatu: preostajeZaUplatu, intDatumNajranijegOtkupa: dummyAppDelegate?.pzvPotencijalniDatumPrijema)
            
            if unosJeValidan {
                print("super je korisnicki unos")
                return true
            }
        } catch {
            print("Dogodila se greska jer korisnicki unos nije kompletan ", error)
        }
        return false
    }
    
    var zbirniIznosVrednostiDocnje: Decimal?
    var zbirniIznosVrednostiValutneNivelacije: Decimal?
    var brojeviAvansaKojiSuKorisceniZaOtkupniList = ""
    var brojeviUgovoraKoriscenihZaOtkupniList = ""
    func SnimiOtkupniList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "OtkupniList", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue(false, forKey: "zaUplatuPGuJeUplaceno")
        zapis.setValue(false, forKey: "pdvJeUplacen")
        zapis.setValue(Decimal(0), forKey: "knjizenoUplateNaOvajOtkupniList")
        
        zapis.setValue(dummyAppDelegate?.pzvImeGazdinstva, forKey: "nazivPG")
        zapis.setValue(dummyAppDelegate?.pzvPovratniTekuciRacunGazdinstva, forKey: "tekuciRacunPG")
        zapis.setValue(dummyAppDelegate?.pzvAdresa, forKey: "adresaPG")
        zapis.setValue(dummyAppDelegate?.pzvBPG, forKey: "bPG")
        
        
        if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost != nil {
            
            for clan in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost?.keys)! {
                brojeviAvansaKojiSuKorisceniZaOtkupniList += String(clan) + " / "
            }
            zapis.setValue(brojeviAvansaKojiSuKorisceniZaOtkupniList, forKey: "brojeviAvansaKojiSuKorisceniZaOtkupniList")
        }

        if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost != nil {
            
            for clan in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?.keys)! {
                brojeviUgovoraKoriscenihZaOtkupniList += String(clan) + " / "
            }
            zapis.setValue(brojeviUgovoraKoriscenihZaOtkupniList, forKey: "brojeviUgovoraKoriscenihZaOtkupniList")
        }
        
        var brojeviNMDPzaOtkupniList = ""
        for clan in (dummyAppDelegate?.pzvBrNalogaMagDP)! {
            brojeviNMDPzaOtkupniList += String(clan) + " / "
        }
        zapis.setValue(brojeviNMDPzaOtkupniList, forKey: "brojeviNMDPzaOtkupniList")
        
        
        zapis.setValue(brojPoslednjegOtkupnogLista + 1, forKey: "brojOtkupnogLista")
        zapis.setValue(brojPoslednjegOtkupnogLista + 1, forKey: "brojPoslednjegOtkupnogLista")
        zapis.setValue(dummyAppDelegate?.pzvBruto, forKey: "bruto")
        zapis.setValue(dummyAppDelegate?.pzvTara, forKey: "tara")
        zapis.setValue(dummyAppDelegate?.pzvNeto, forKey: "neto")
        
        if swTelKel.isOn {
            zapis.setValue(cenaZaKgBezPDVakoJeTelKelSwON, forKey: "cenaZaKgBezPDV")
            zapis.setValue(cenaZaKgSaPDVakoJeTelKelSwON, forKey: "cenaZaKgSaPDV")
            zapis.setValue(dummyAppDelegate?.pzvNeto, forKey: "jus")
        } else if !swTelKel.isOn {
            zapis.setValue(cenaZaKgBezPDV, forKey: "cenaZaKgBezPDV")
            zapis.setValue(dummyAppDelegate?.pzvCenaZaKgSaPDV, forKey: "cenaZaKgSaPDV")
            zapis.setValue(dummyAppDelegate?.pzvOdbitak, forKey: "odbitak")
            zapis.setValue(dummyAppDelegate?.pzvJUS, forKey: "jus")
        }

        
        let date = NSDate()
        zapis.setValue(date as Date, forKey: "datumIzradeOtkupnogLista")
        zapis.setValue(dummyAppDelegate?.pzvPotencijalniDatumPrijema, forKey: "datumPrijemaSaNajranijeOdvageNaOtkupnomListu")
        zapis.setValue(dummyAppDelegate?.pzvKojaRoba, forKey: "robaKojaJeOtkupljena")
        zapis.setValue(ukupnoSaAvansa, forKey: "ukupnoSkinutoSaAvansa")
        zapis.setValue(ukupnoZaKompenzovanje, forKey: "ukupnoSkinutoSaUgovora")
        
        
        if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje != nil {
            for clan in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje!.keys)! {
                zbirniIznosVrednostiDocnje = (zbirniIznosVrednostiDocnje ?? 0) + (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje![clan])!
            }
            zapis.setValue(zbirniIznosVrednostiDocnje, forKey: "ukupnoNivelacijeDocnje")
        }
        
        if dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule != nil {
            for clan in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule!.keys)! {
                zbirniIznosVrednostiValutneNivelacije = (zbirniIznosVrednostiValutneNivelacije ?? 0) + (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule![clan])!
            }
            zapis.setValue(zbirniIznosVrednostiValutneNivelacije, forKey: "ukupnoValutneNivelacije")
        }
        
        zapis.setValue(ukupno, forKey: "ukupnoZaObracun")
        zapis.setValue(vrednostBezPDV, forKey: "vrednostBezPDV")
        zapis.setValue(vrednostPDV, forKey: "vrednostPDV")
        zapis.setValue(preostajeZaUplatu, forKey: "zaUplatuPGu")
    
        
        do {
            try managedContext.save()
            print("U bazu podataka je upisan otkupni list \(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem otkupni list: \(zapis)")
        } catch {
            print("Ne mogu da upisem nov otkupni list! \(error)")
        }
    }
    
    var contentOtkupniList = ""
    func PosaljiOtkupniListMail() {
        var stampa_cenaZaKgBezPDV: Double = 0
        var stampa_cenaZaKgSaPDV: Double = 0
        var stampa_odbitak: Int32 = 0
        var stampa_jus: Int32 = 0
        
        if swTelKel.isOn {
             stampa_cenaZaKgBezPDV = cenaZaKgBezPDVakoJeTelKelSwON!
             stampa_cenaZaKgSaPDV = cenaZaKgSaPDVakoJeTelKelSwON!
             stampa_odbitak = 0
             stampa_jus = (dummyAppDelegate?.pzvNeto)!
        } else if !swTelKel.isOn {
             stampa_cenaZaKgBezPDV = cenaZaKgBezPDV!
             stampa_cenaZaKgSaPDV = (dummyAppDelegate?.pzvCenaZaKgSaPDV)!
             stampa_odbitak = (dummyAppDelegate?.pzvOdbitak ?? 0)
             stampa_jus = (dummyAppDelegate?.pzvJUS)!
        }
        
        // uredjuje datum u citljiviju formu
        let uredjujemDatum = DateFormatter()
        uredjujemDatum.dateFormat = "dd MMM yyyy"
        let selektovaniDatum = uredjujemDatum.string(from: dummyAppDelegate!.pzvPotencijalniDatumPrijema!)

        
        
        contentOtkupniList = "<p><strong>Osnovno: AgroPan, mesto: Pancevo, adresa: Vojvode Radomira Putnika 3, maticniBroj: 08185085, tekuciRacun: 160-69764-13, pib: 101049140</strong></p><p><strong>OTKUPNI LIST BROJ \(brojPoslednjegOtkupnogLista + 1)</strong></p><p>Datum otkupa \(selektovaniDatum)</p><p>Naziv gazdinstva: \(dummyAppDelegate!.pzvImeGazdinstva!)</p><p>Broj poljoprivrednog gazdinstva: \(dummyAppDelegate!.pzvBPG!)</p><p>Adresa: \((dummyAppDelegate!.pzvAdresa!))</p><p>Tekuci Racun gazdinstva: \(dummyAppDelegate!.pzvPovratniTekuciRacunGazdinstva!)</p><p>Brojevi naloga po kojima je sacinjen otkupni list: \(dummyAppDelegate!.pzvBrNalogaMagDP!)</p><p>Bruto : \(dummyAppDelegate!.pzvBruto!)<p>Tara: \(dummyAppDelegate!.pzvTara!)<p>Neto: \(dummyAppDelegate!.pzvNeto!)</p></p></p><p>Odbitak u KG: \(stampa_odbitak)</p><p>Ukupno JUS kilograma: \(stampa_jus)</p><p>Roba: \(dummyAppDelegate!.pzvKojaRoba!)</p><p><p><p>Cena za kilogram sa uracunatim PDV-om: \(stampa_cenaZaKgSaPDV.roundTo(places: 4))</p></p></p><p>Cena za kilogram bez uracunatog PDV-a: \(stampa_cenaZaKgBezPDV.roundTo(places: 4))</p><p>Vrednost otkupnog lista bez PDV-a: \(vrednostBezPDV!.roundTo(places: 2))</p><p>Vrednost PDV-a: \(vrednostPDV!.roundTo(places: 2))</p><p>Vrednost otkupnog lista sve ukupno: \(ukupno!.roundTo(places: 2))</p><p>Preostaje za uplatu \(preostajeZaUplatu!.doubleValue.roundTo(places: 2))</p><p>Ukupno skinutu sa Avansa \((ukupnoSaAvansa ?? 0).doubleValue.roundTo(places: 2))</p><p>Brojevi avansa koji su korisceni za ovaj otkupni list:: \(brojeviAvansaiKompencacioniIznosi)</p><p>Ukupno Kompenzovano \((ukupnoZaKompenzovanje ?? 0).doubleValue.roundTo(places: 2))</p><p>Brojevi ugovora koji su korisceni u ovom otkupnom listu \(brojeviUgovoraIKompencacioniIznosi)</p><p>Ukupno nivelacije zbog docnje u otplati \((zbirniIznosVrednostiDocnje ?? 0).doubleValue.roundTo(places: 2))</p><p>Ukupno nivelacije zaduzenja zbog valutnih razlika \((zbirniIznosVrednostiValutneNivelacije ?? 0).doubleValue.roundTo(places: 2))</p><p>Ugovori i iznosi kompenzovani po osnovu docnje i valutnih razlika \(brojeviUgovoraIIznosiDocnjeIValutneNivelacije)</p>"
        
        //sendEmail(subject: "Otkupni List", textToSend: contentOtkupniList)
    }
    
    var contentNalogZaUplatu = ""
    func PosaljiNalogZaUplatu() {
        
        
        contentNalogZaUplatu = "<p><strong>NALOG ZA UPLATU</strong></p><p>UPLATITI sledecem gazdinstvu: \(dummyAppDelegate!.pzvImeGazdinstva!)</p><p>Adresa: \((dummyAppDelegate!.pzvAdresa!))</p><p>Tekuci Racun gazdinstva: \(dummyAppDelegate!.pzvPovratniTekuciRacunGazdinstva!)</p><p>UPLATA OBAVEZNOG DELA PDV-A ZA OTKUPNI LIST \(brojPoslednjegOtkupnogLista + 1)<p><strong>Iznos obaveznog PDV dela: \(vrednostPDV!.roundTo(places: 2))</strong></p><p><strong>UPLATA OSTATKA IZNOSA OTKUPNOG LISTA \(preostajeZaUplatu!.doubleValue.roundTo(places: 2))</strong></p>"
        
        //sendEmail(subject: "Nalog Za Uplati Prema Otkunom Listu", textToSend: content)
    }
    
    var brojPoslednjeKompenzacije: Int32 = 0
    func ProveriKojiJeBrojKompenzacijeNaRedu() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Kompenzacija")
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            print(fetchRequest)
            for podatak in response {
                
                if podatak.value(forKey: "brojPoslednjeKompenzacije") == nil {
                    brojPoslednjeKompenzacije = 0
                    
                } else {
                    brojPoslednjeKompenzacije = (podatak.value(forKey: "brojPoslednjeKompenzacije") as? Int32)!
                    
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak poslednji broj kompenzacije! \(error)")
        }
        
    }
    
    func SnimiKompenzaciju() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "Kompenzacija", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue(dummyAppDelegate!.pzvBPG!, forKey: "bPG")
        zapis.setValue(brojPoslednjeKompenzacije + 1, forKey: "brojKompenzacije")
        zapis.setValue(brojPoslednjegOtkupnogLista + 1, forKey: "brojOtkupnogListaNaOsnovuKojegSeSprovodiKompenzacija")
        zapis.setValue(brojPoslednjeKompenzacije + 1, forKey: "brojPoslednjeKompenzacije")
        zapis.setValue(dummyAppDelegate!.pzvImeGazdinstva!, forKey: "nazivPG")
        zapis.setValue(dummyAppDelegate!.pzvPotencijalniDatumPrijema!, forKey: "datumKompenzacije")
        
        var snimioSamPrviUgovor = false
        var snimioSamDrugiUgovor = false
        var snimioSamTreciUgovor = false
        for clan in (dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?.keys)! {
            if !snimioSamPrviUgovor {
                zapis.setValue(Int32(clan), forKey: "brojUgovoraZaKompenzacijuJedan")
                zapis.setValue(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?[clan], forKey: "iznosUgovoraZaKompenzacijuJedan")
                snimioSamPrviUgovor = true
            } else if !snimioSamDrugiUgovor {
                zapis.setValue(Int32(clan), forKey: "brojUgovoraZaKompenzacijuDva")
                zapis.setValue(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?[clan], forKey: "iznosUgovoraZaKompenzacijuDva")
                snimioSamDrugiUgovor = true
            } else if !snimioSamTreciUgovor {
                zapis.setValue(Int32(clan), forKey: "brojUgovoraZaKompenzacijuTri")
                zapis.setValue(dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?[clan], forKey: "iznosUgovoraZaKompenzacijuTri")
                snimioSamTreciUgovor = true
            }
        }
        
        do {
            try managedContext.save()
            print("U bazu podataka je upisana kompenzacija \(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem kompenzaciju: \(zapis)")
        } catch {
            print("Ne mogu da upisem novu kompenzaciju! \(error)")
        }
        
    }
    
    var contentKompenzacija = ""
    func PosaljiKompenzacijuMail() {
        // uredjuje datum u citljiviju formu
        let uredjujemDatum = DateFormatter()
        uredjujemDatum.dateFormat = "dd MMM yyyy"
        let selektovaniDatum = uredjujemDatum.string(from: dummyAppDelegate!.pzvPotencijalniDatumPrijema!)
        
        
        
        contentKompenzacija = "<p><strong>KOMPENZACIJA broj \(brojPoslednjeKompenzacije + 1)</strong></p><p>Datum kompenzacije \(selektovaniDatum)</p><p>Gazdinstvo sa kojim kompenzujem \(dummyAppDelegate!.pzvImeGazdinstva!)</p><p>Broj poljoprivrednog gazdinstva sa kojim kompenzujem \(dummyAppDelegate!.pzvBPG!)</p><p>Kompenzujem sledece IZNOSE sa sledecih UGOVORA Poljoprivrednog Gazdinstva: \(brojeviUgovoraIKompencacioniIznosi)</p><p>Kompenzujem sa oktupnog lista broj \(brojPoslednjegOtkupnogLista + 1) iznos od \((ukupnoZaKompenzovanje ?? 0).doubleValue.roundTo(places: 2))</p>"
        
        //sendEmail(subject: "Kompenzacija", textToSend: content)
    }
    
    func OsveziUgovoreNovimPodacima() {
        // zabelezi u odgovarajuce ugovore da je jedan njihov deo, ili u celosti naplacen a ako je naplacen u celosti onda ga zatvori (otplaceno, neotplacenaVrednostUgovora, ugovorJeZatvoren)
        // prvo skidas sa ugovora docnju a zatim valutnu razliku pa tek onda glavnicu
        
        
        // KURSNE RAZLIKE SE RACUNAJU TAKO DA SE ZA OBRACUN DINARSKOG DELA DUGA ZAPRAVO UZIMA NAJVECI KURS KOJI JE PG IMALO U CELOJ ISTORIJI SVOG RAZDUZIVANJA. TAKO DA NPR AKO SE PG KAD JE PRAVILO UGOVOR ZADUZILO PO NEKOM KURSU OD 100 DINARA A PRILIKOM JEDNOG OD RAZDUZIVANJA JE KURS BIO 97 PA SLEDECEG RAZDUZIVANJA JE KURS BIO 103 PA ZA NEKO FINALNO RAZDUZIVANJE JE KURS BIO 108 RACUNACE SE KURS KOJI JE BIO NAJVECI OD TA CETIRI KURSA, S'TIM DA SE VALUTNA RAZLIKA KOJA MOZDA U NEKOM TRENUTKU PADNE ISPOD VEC OBRACUNATE NE PRIKAZUJE I NE RACUNA VEC SE VODI KAO NULA. JEDNOM OBRACUNATA KURSNA RAZLIKA NA KORIST PREDUZECA SE VODI BUKVALNO KAO NOVI MINIMUM ZA RAZDUZENJE CELOG UGOVORA STO ZNACI DA PG TREBA DA GLEDA DA UHVATI KURS KOJI JE ILI NA NIVOU ILI ISPOD UGOVORENOG MINIMALNOG KURSA I DA NE DONOSI ROBU KAD JE KURS U PEAK MOMENTU JER JE MOMENTOM OBRACUNA VALUTNE RAZLIKE KOJA SE RADI NA CELU VREDNOST UGOVORA DO LIKVIDIRANJA UGOVORA IZRACUNATA VALUTNA RAZLIKA KOJA NIKADA OD TOG TRENUTKA NE MOZE BITI MANJA VEC SAMO ISTA ILI VECA PA MAKAR KAKAV BIO KURS
        
        // TREBA OBRATITI PAZNJU NA TO DA SE UGOVOR ZATVARA U MOMENTU KAD VISE NEMA NICEGA DA SE NAPLATI ALI DA TO AUTOMATSKI ZNACI DA AKO KORISNIK UGOVORA NIJE POVUKAO SVU NACELNO UGOVORENO ROBU ON U MOMENTU KOJI NASTAJE NEDUGOVANJEM PO TOM OSNOVU I ZATVARA UGOVOR. MOZDA BI TREBALO EVENTUALNO UVESTI NEKI CHECK 
        
        for brojUgovora in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost?.keys)! {
            let filter = brojUgovora
             
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")
            let predicate = NSPredicate(format: "brojUgovora = %i", Int64(filter))
            fetchRequest.predicate = predicate
            
            do {
                let response = try managedContext.fetch(fetchRequest)
                
                var minimalniKursZaObracunRazduzenja: Decimal?
                for podatak in response {
                    let valutnaKlauzula = podatak.value(forKey: "valutnaKlauzula") as! Bool
                    let docnja = podatak.value(forKey: "docnja") as! Bool
                    
                    if valutnaKlauzula {
                        minimalniKursZaObracunRazduzenja = podatak.value(forKey: "minimalniKursZaObracunRazduzenja") as? Decimal
                        //let valutaUgovora = podatak.value(forKey: "valutaUgovora") as! String
                        
                        /*
                        if valutaUgovora == "Evro" {
                            if minimalniKursZaObracunRazduzenja! < danasnjiKursZaObracunRazduzenjaEUR! {
                                minimalniKursZaObracunRazduzenja = danasnjiKursZaObracunRazduzenjaEUR!
                            }
                        } else if valutaUgovora == "Dolar" {
                            if minimalniKursZaObracunRazduzenja! < danasnjiKursZaObracunRazduzenjaDOL! {
                                minimalniKursZaObracunRazduzenja = danasnjiKursZaObracunRazduzenjaDOL!
                            }
                        }
                        */
                    }
                    
                    var iznosKojiUpisujemZaNivelacijuDocnje: Decimal = 0
                    var postojeciIznosDocnje: Decimal = 0
                    if docnja {
                        if podatak.value(forKey: "iznosNivelacijeDocnje") != nil {
                            postojeciIznosDocnje = podatak.value(forKey: "iznosNivelacijeDocnje") as! Decimal
                        }
                        
                        iznosKojiUpisujemZaNivelacijuDocnje = (postojeciIznosDocnje ) + (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje?[brojUgovora] ?? 0)
                        podatak.setValue(iznosKojiUpisujemZaNivelacijuDocnje, forKey: "iznosNivelacijeDocnje")
                    }
                    
                    var iznosKojiUpisujemZaValutnuNivelaciju: Decimal = 0
                    var postojeciIznosValutneNivelacije: Decimal = 0
                    if valutnaKlauzula {
                        if podatak.value(forKey: "iznosValutneNivelacije") != nil {
                            postojeciIznosValutneNivelacije = podatak.value(forKey: "iznosValutneNivelacije") as! Decimal
                        }
                        
                        iznosKojiUpisujemZaValutnuNivelaciju = (postojeciIznosValutneNivelacije ) + (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule?[brojUgovora] ?? 0)
                        print("setuje vrednost iz otkupnog lista za valutnu nivelaciju u iznosu od \(iznosKojiUpisujemZaValutnuNivelaciju)")
                        podatak.setValue(iznosKojiUpisujemZaValutnuNivelaciju, forKey: "iznosValutneNivelacije")
                    }
                    
                    
                    var ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta: Decimal = 0
                    if valutnaKlauzula {
                        ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta = dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![brojUgovora]! / minimalniKursZaObracunRazduzenja!
                    } else {
                        ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta = dummyAppDelegate!.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost![brojUgovora]!
                    }
                    
                    let ovajUgovorZbogValutneKlauzuleSeUvecaoZa = (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule?[brojUgovora] ?? 0)
                    let ovajUgovorZbogDocnjeSeUvecaoZa = (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje?[brojUgovora] ?? 0)
                    
                    let ukupnoZaUpisZaOTPLACENO = (ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta ) - (ovajUgovorZbogValutneKlauzuleSeUvecaoZa / minimalniKursZaObracunRazduzenja!) - ( ovajUgovorZbogDocnjeSeUvecaoZa / minimalniKursZaObracunRazduzenja!)
                    
                    let prethodnoOtplaceno = podatak.value(forKey: "otplaceno") as? Decimal
                    podatak.setValue((prethodnoOtplaceno ?? 0) + ukupnoZaUpisZaOTPLACENO, forKey: "otplaceno")
                    
                    
                    let prethodnaNeotplacenaVrednostUgovora = podatak.value(forKey: "neotplacenaVrednostUgovora") as? Decimal
                    podatak.setValue(prethodnaNeotplacenaVrednostUgovora! - ukupnoZaUpisZaOTPLACENO, forKey: "neotplacenaVrednostUgovora")
                    
                    var zatvaramUgovor = false
                    if prethodnaNeotplacenaVrednostUgovora! - ukupnoZaUpisZaOTPLACENO >= 0 && prethodnaNeotplacenaVrednostUgovora! - ukupnoZaUpisZaOTPLACENO <= 5 {
                        zatvaramUgovor = true
                        podatak.setValue(zatvaramUgovor, forKey: "ugovorJeZatvoren")
                    }
                    

                    print("U bazu podataka je upisana izmenu vrednost u UGOVOR broj \(filter) sledece:  za iznosNivelacijeDocnje se upisuje: \(iznosKojiUpisujemZaNivelacijuDocnje) jer smo prethodno imali postojeci iznos docnje \((postojeciIznosDocnje )) koji sabiramo sa iznosom docnje sada upravo izracunatim \((dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje?[brojUgovora] ?? 0)), za iznosValutneNivelacije se upisuje \(iznosKojiUpisujemZaValutnuNivelaciju) jer smo imali postojeci iznos valutne nivelacije \((postojeciIznosValutneNivelacije)) i na to dodajemo iznos valutne nivelacije upravo sada izracunat \((dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule?[brojUgovora] ?? 0)) Za OTPLACENO se upisuje \((prethodnoOtplaceno ?? 0) + ukupnoZaUpisZaOTPLACENO), jer je prethodno otplaceno \((prethodnoOtplaceno ?? 0)) a u ovom prolazu je otplaceno \(ukupnoZaUpisZaOTPLACENO) JER je OTPLACENO u ovom prolazu sacinjeno od ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta sve primenjeno na ovaj ugovor: \(ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta) minus valutna klauzula ovog ugovora \((ovajUgovorZbogValutneKlauzuleSeUvecaoZa / minimalniKursZaObracunRazduzenja!)) minus iznos docnje ovog ugovora \(( ovajUgovorZbogDocnjeSeUvecaoZa / minimalniKursZaObracunRazduzenja!))  pa je to to kad se zbere i oduzme. Prethodna neotplacena vrednost ugovora je bila \(prethodnaNeotplacenaVrednostUgovora!) sada oduzimam od ove cifre ono sto je u ovom prolazu otplaceno: \(ukupnoZaUpisZaOTPLACENO) pa za neotplacenaVrednostUgovora se ne kraju upisuje \(prethodnaNeotplacenaVrednostUgovora! - ukupnoZaUpisZaOTPLACENO), i zatvaram ugovor \(zatvaramUgovor)")
                    ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu podataka je upisana izmenu vrednost u UGOVOR broj \(filter) sledece:  za iznosNivelacijeDocnje se upisuje: \(iznosKojiUpisujemZaNivelacijuDocnje) jer smo prethodno imali postojeci iznos docnje \((postojeciIznosDocnje )) koji sabiramo sa iznosom docnje sada upravo izracunatim \((dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje?[brojUgovora] ?? 0)), za iznosValutneNivelacije se upisuje \(iznosKojiUpisujemZaValutnuNivelaciju) jer smo imali postojeci iznos valutne nivelacije \((postojeciIznosValutneNivelacije)) i na to dodajemo iznos valutne nivelacije upravo sada izracunat \((dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule?[brojUgovora] ?? 0)) Za OTPLACENO se upisuje \((prethodnoOtplaceno ?? 0) + ukupnoZaUpisZaOTPLACENO), jer je prethodno otplaceno \((prethodnoOtplaceno ?? 0)) a u ovom prolazu je otplaceno \(ukupnoZaUpisZaOTPLACENO) JER je OTPLACENO u ovom prolazu sacinjeno od ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta sve primenjeno na ovaj ugovor: \(ukupnoZaKompnezovanjeUSkladuSaTimDaLiPostojiValuta) minus valutna klauzula ovog ugovora \((ovajUgovorZbogValutneKlauzuleSeUvecaoZa / minimalniKursZaObracunRazduzenja!)) minus iznos docnje ovog ugovora \(( ovajUgovorZbogDocnjeSeUvecaoZa / minimalniKursZaObracunRazduzenja!))  pa je to to kad se zbere i oduzme. Prethodna neotplacena vrednost ugovora je bila \(prethodnaNeotplacenaVrednostUgovora!) sada oduzimam od ove cifre ono sto je u ovom prolazu otplaceno: \(ukupnoZaUpisZaOTPLACENO) pa za neotplacenaVrednostUgovora se ne kraju upisuje \(prethodnaNeotplacenaVrednostUgovora! - ukupnoZaUpisZaOTPLACENO), i zatvaram ugovor \(zatvaramUgovor)")
                    
                
                }
            } catch let error as NSError {
                print("Ne mogu da preuzmem podatak za postojece finansijske podatke ugovora  \(error)")
            }

        }
    }
    
    func OsveziAvanseNovimPodacima() {
        // zabelezi u odgovarajuce avanse da je jedan njihov deo, ili mozda i celina naplacena a ako je naplacen u celosti onda ga zatvori (kompenzovano, odliv, avansJeZatvoren)
        for brojAvansa in (dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost?.keys)! {
            let filter = brojAvansa
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AvansiGazdinstvima")
            let predicate = NSPredicate(format: "brojAvansa = %i", Int64(filter))
            fetchRequest.predicate = predicate
            
            do {
                let response = try managedContext.fetch(fetchRequest)
                
                let kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza = dummyAppDelegate?.pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost![brojAvansa]
                
                for podatak in response {
                    let odliv = podatak.value(forKey: "odliv") as! Decimal
                    let prethodnoKompenzovano = podatak.value(forKey: "kompenzovano") as? Decimal
                    podatak.setValue((prethodnoKompenzovano ?? 0) + kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza!, forKey: "kompenzovano")

                    var zatvaramAvans = false
                    if abs(kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza! + (prethodnoKompenzovano ?? 0) - odliv) <= 5 {
                        zatvaramAvans = true
                        podatak.setValue(zatvaramAvans, forKey: "avansJeZatvoren")
                    }
                    
                    
                    print("U bazu podataka je upisana izmenu vrednost u AVANS broj \(filter) sledece:  za kompenzovano se upisuje: \((prethodnoKompenzovano ?? 0) + kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza!) jer je prethodno kompenzovano na tom avansu bilo \(prethodnoKompenzovano ?? 0) pa smo dodali u ovom prolazu \(kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza!) i zatvram avans \(zatvaramAvans)")
                    ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu podataka je upisana izmenu vrednost u AVANS broj \(filter) sledece:  za kompenzovano se upisuje: \((prethodnoKompenzovano ?? 0) + kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza!) jer je prethodno kompenzovano na tom avansu bilo \(prethodnoKompenzovano ?? 0) pa smo dodali u ovom prolazu \(kompenzovanaVrednostOdgovarajucegAvansaIzOvogProlaza!) i zatvram avans \(zatvaramAvans)")
                    
                    
                }
            } catch let error as NSError {
                print("Ne mogu da preuzmem podatak za postojece finansijske podatke avansa! \(error)")
            }
            
        }
        
    }
    
    func OsveziOdvage() {
        for brojNMDP in (dummyAppDelegate?.pzvBrNalogaMagDP)! {
            let filter = brojNMDP
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PrijemRobeSaVageOdPG")
            let predicate = NSPredicate(format: "brojNalogaMagacinuDaPrimi = %i", Int32(filter))
            fetchRequest.predicate = predicate
            
            do {
                let response = try managedContext.fetch(fetchRequest)
                
                
                
                for podatak in response {
                    podatak.setValue(true, forKey: "nalogMagacniuDaPrimiUpotrebljen")
                    
                    
                    
                    print("U bazu podataka je upisana izmenu vrednost u za BROJ NALOGA MAGACINU DA PRIMI broj \(filter) sledece:  za TAJ BROJ NALOGA MAGACINU DA PRIMI se upisuje: DA JE ZATVOREN")
                    ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu podataka je upisana izmenu vrednost u za BROJ NALOGA MAGACINU DA PRIMI broj \(filter) sledece:  za TAJ BROJ NALOGA MAGACINU DA PRIMI se upisuje: DA JE ZATVOREN")
                    
                    
                }
            } catch let error as NSError {
                print("Ne mogu da preuzmem podatak za postojece finansijske podatke avansa! \(error)")
            }
        }
    }
    
    func PosaljiMailSaSvimRelevenatnimPodacima() {
        var content = ""
        content = contentOtkupniList + "<p></p>" + contentKompenzacija + "<p></p>" + contentNalogZaUplatu
        sendEmail(subject: "Otkupni List, Nalog Za Uplatu i Eventualna Kompenzacija", textToSend: content)
    }
    
    
    

}
