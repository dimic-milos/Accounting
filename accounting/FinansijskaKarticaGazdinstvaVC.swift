//
//  FinansijskaKarticaGazdinstvaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/29/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

enum VrstaTransakcije {
    case AvansPoljoprivrednomGazdinstvu
    case UgovorOKooperaciji
    case OtkupniList
}

struct PoslovanjeSaGazdinstvom {
    var vrsta: VrstaTransakcije
    var naziv: String
    var bpg: Int64
    var datumPromene: Date
    
    var odliv: Decimal?
    var banka: String?
    var brojIzvoda: Int32?
    var valuta: Date?
    var kompenzovano: Decimal?
    var avansJeZatvoren: Bool?
    var brojAvansa: Int32?
    
    var cenaPoJediniciMere: Decimal?
    var preuzetaKolicina: Decimal?
    var minimalniKursZaObracunRazduzenja: Decimal?
    var otplaceno: Decimal? // sve ono sto je placeno
    var neotplacenaVrednostUgovora: Decimal? // realizovanaVrednostUgovora - otplaceno
    var realizovanaVrednostUgovora: Decimal? // povucena kolicina robe * cena po jedinici mere i sve to u nativnoj valuti
    var vrednostPDVaOvogUgovora: Decimal? // deste posto od realizovanevrednosti ugovora
    var datumskaValutaUgovora: Date?
    var valutnaKlauzula: Bool?
    var valutaUgovora: String?
    var docnja: Bool?
    var ugovorJeZatvoren: Bool?
    var iznosNivelacijeDocnje: Decimal?
    var iznosValutneNivelacije: Decimal?
    var brojUgovora: Int64?
    var robaKojaJeDataNaodlozeno: String?
    
    var brojOtkupnogLista: Int32?
    var robaKojaJeOtkupljena: String?
    var datumIzradeOtkupnogLista: Date?
    var pdvJeUplacen: Bool?
    var zaUplatuPGuJeUplaceno: Bool?
    var vrednostPDV: Double?
    var zaUplatuPGu: Decimal?
    var knjizenoUplateNaOvajOtkupniList: Decimal?

}

extension PoslovanjeSaGazdinstvom {
    init(AVANS vrsta: VrstaTransakcije, naziv: String, bpg: Int64, datumPromene: Date, odliv: Decimal, banka: String, brojIzvoda: Int32, valuta: Date, kompenzovano: Decimal, avansJeZatvoren: Bool, brojAvansa: Int32) {
        self.vrsta = vrsta
        self.naziv = naziv
        self.bpg = bpg
        self.datumPromene = datumPromene
        
        self.odliv = odliv
        self.banka = banka
        self.brojIzvoda = brojIzvoda
        self.valuta = valuta
        self.kompenzovano = kompenzovano
        self.avansJeZatvoren = avansJeZatvoren
        self.brojAvansa = brojAvansa
    }
    
    init(UGOVOR vrsta: VrstaTransakcije, naziv: String, bpg: Int64, datumPromene: Date, cenaPoJediniciMere: Decimal, preuzetaKolicina: Decimal, minimalniKursZaObracunRazduzenja: Decimal?, otplaceno: Decimal, neotplacenaVrednostUgovora: Decimal, realizovanaVrednostUgovora: Decimal, vrednostPDVaOvogUgovora: Decimal, datumskaValutaUgovora: Date, valutnaKlauzula: Bool, valutaUgovora: String, docnja: Bool, ugovorJeZatvoren: Bool, iznosNivelacijeDocnje: Decimal?, iznosValutneNivelacije: Decimal?, brojUgovora: Int64, robaKojaJeDataNaodlozeno: String) {
        self.vrsta = vrsta
        self.naziv = naziv
        self.bpg = bpg
        self.datumPromene = datumPromene
        
        self.cenaPoJediniciMere = cenaPoJediniciMere
        self.preuzetaKolicina = preuzetaKolicina
        self.minimalniKursZaObracunRazduzenja = minimalniKursZaObracunRazduzenja
        self.otplaceno = otplaceno
        self.neotplacenaVrednostUgovora = neotplacenaVrednostUgovora
        self.realizovanaVrednostUgovora = realizovanaVrednostUgovora
        self.vrednostPDVaOvogUgovora = vrednostPDVaOvogUgovora
        self.datumskaValutaUgovora = datumskaValutaUgovora
        self.valutnaKlauzula = valutnaKlauzula
        self.valutaUgovora = valutaUgovora
        self.docnja = docnja
        self.ugovorJeZatvoren = ugovorJeZatvoren
        self.iznosNivelacijeDocnje = iznosNivelacijeDocnje
        self.iznosValutneNivelacije = iznosValutneNivelacije
        self.brojUgovora = brojUgovora
        self.robaKojaJeDataNaodlozeno = robaKojaJeDataNaodlozeno
    }
    
    init(OTKUPNI_LIST vrsta: VrstaTransakcije, naziv: String, bpg: Int64, datumPromene: Date, brojOtkupnogLista: Int32, robaKojaJeOtkupljena: String, datumIzradeOtkupnogLista: Date, pdvJeUplacen: Bool, zaUplatuPGuJeUplaceno: Bool, vrednostPDV: Double, zaUplatuPGu: Decimal?, knjizenoUplateNaOvajOtkupniList: Decimal) {
        self.vrsta = vrsta
        self.naziv = naziv
        self.bpg = bpg
        self.datumPromene = datumPromene

        self.brojOtkupnogLista = brojOtkupnogLista
        self.robaKojaJeOtkupljena = robaKojaJeOtkupljena
        self.datumIzradeOtkupnogLista = datumIzradeOtkupnogLista
        self.pdvJeUplacen = pdvJeUplacen
        self.zaUplatuPGuJeUplaceno = zaUplatuPGuJeUplaceno
        self.vrednostPDV = vrednostPDV
        self.zaUplatuPGu = zaUplatuPGu
        self.knjizenoUplateNaOvajOtkupniList = knjizenoUplateNaOvajOtkupniList
    }
    
}



class FinansijskaKarticaGazdinstvaVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        PreuzmiDanasnjiKursZaObracun()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .green
        DodajDugmeZaNazad()
        //print("preuzimam ime sa drugog vc iz viewdiload")
        //PreuzmiImeSaDrugogVC()
        roIdiNaOtkupniListBezZaduzivanjaUgovoraIliAvansa.isHidden = true
        let nizSlajdera = [slajderOdabranDokumentZaKompenzacijuJedan, slajderOdabranDokumentZaKompenzacijuDva, slajderOdabranDokumentZaKompenzacijuTri]
        
        roSnimiSelektovaneDokumentePodobneZaKompenzaciju.isHidden = true
        for clan in nizSlajdera {
            clan?.isHidden = true
            clan?.addTarget(self, action: #selector(PodesiSlajer(sender:)), for: UIControlEvents.valueChanged)
            clan?.addTarget(self, action: #selector(OsveziLimite), for: UIControlEvents.touchUpInside )
            clan?.isContinuous = true
        }
        
        tabela.delegate = self
        tabela.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tabela.reloadData()
        if danasnjiKursZaObracunRazduzenjaEUR == nil || danasnjiKursZaObracunRazduzenjaDOL == nil {
            PrikaziNeuspesniPopUp(poruka: "Nema upisanog kursa EUR ili DOL - najpre unesi kurseve u kursnu listu pa se vrati ovde")
        } else {
            //print("preuzimam ime sa drugog vc iz viewdidAPPEAR")
            PreuzmiImeSaDrugogVC()
            if povratniSaldoPodobanZaKompenzaciju != nil {
                labelaPovratniSaldoPodobanZaKompenzaciju.text = "Za kompenzaciju: " + String(format: "%.2f", locale: Locale.current, povratniSaldoPodobanZaKompenzaciju!) + " Din"
                roIdiNaOtkupniListBezZaduzivanjaUgovoraIliAvansa.isHidden = false
                /*String(format: "%.2f", locale: Locale.current, nizUkupniSaldoBezObziraNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"*/
            }
            tabela.reloadData()
        }
    }
    
    @IBOutlet weak var tfUnesiIme: UITextField!
    @IBOutlet weak var labelaBroj: UILabel!
    
    var povratnoIme: String?
    var povratniBroj: Int64?
    
    @IBOutlet weak var labelaPovratniSaldoPodobanZaKompenzaciju: UILabel!
    var povratniSaldoPodobanZaKompenzaciju: Double?
    
    @IBOutlet weak var labelaOdabranDokumentZaKompenzacijuJedan: UILabel!
    @IBOutlet weak var labelaOdabranDokumentZaKompenzacijuDva: UILabel!
    @IBOutlet weak var labelaOdabranDokumentZaKompenzacijuTri: UILabel!
    
    @IBOutlet weak var lablaZbirOdabranihDokumenataZaKompenzaciju: UILabel!
    
    @IBOutlet weak var slajderOdabranDokumentZaKompenzacijuJedan: UISlider!
    @IBOutlet weak var slajderOdabranDokumentZaKompenzacijuDva: UISlider!
    @IBOutlet weak var slajderOdabranDokumentZaKompenzacijuTri: UISlider!
    
    @IBOutlet weak var labelaPrikazVrednostSaSlajderaJedan: UILabel!
    @IBOutlet weak var labelaPrikazVrednostSaSlajderaDva: UILabel!
    @IBOutlet weak var labelaPrikazVrednostSaSlajderaTri: UILabel!
    
    
    @IBOutlet weak var roSnimiSelektovaneDokumentePodobneZaKompenzaciju: UIButton!
    
    var recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost: Dictionary = [Int : Decimal]()
    var recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost: Dictionary = [Int : Decimal]()
    
    var recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje: Dictionary = [Int : Decimal]()
    var recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule: Dictionary = [Int : Decimal]()
    
    @IBAction func SnimiSelektovaneDokumentePodobneZaKompenzaciju(_ sender: Any) {
        /*
         
         var zbirOdabranihDokumenataZaKompenzaciju: Decimal = 0.0
         var recnikKojaLabelaKojaVrednost: Dictionary = [Int : Decimal]()
         var recnikKojiRedKojaLabela: Dictionary = [Int : Int]()
         var selektovaniRovovi = Set<Int>()
         
         var vrednostLabeleJedan: Decimal?
         var vrednostLabeleDva: Decimal?
         var vrednostLabeleTri: Decimal?
         
         var recnikKojaLabelaKojaVrednostSaSlajdera: Dictionary = [Int : Decimal]()
         var zbirOdabranihDokumenataZaKompenzacijuSaSlajdera: Decimal?
         
         */
        

        var vrednostKojaSePokusavaKompenzovatiJeVecaOdMoguce = false
        if zbirOdabranihDokumenataZaKompenzacijuSaSlajdera == nil {  // slucaj kad se ne pojavljuju slajderi
            if povratniSaldoPodobanZaKompenzaciju! < (zbirOdabranihDokumenataZaKompenzaciju.doubleValue - 0.1) {
                vrednostKojaSePokusavaKompenzovatiJeVecaOdMoguce = true
                PrikaziNeuspesniPopUp(poruka: "Odabrana je veca masa za kompenzovanje nego sto je moguce kompnezovati")
            } else {
                for clan in selektovaniRovovi {
                    if nizPoslovanjaSaGazdinstvom[clan].vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
                        let brojAvansa = Int(nizPoslovanjaSaGazdinstvom[clan].brojAvansa!)
                        let iznosAvansaKojiSeKompenzuje = recnikKojaLabelaKojaVrednost[recnikKojiRedKojaLabela[clan]!]
                        recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost[brojAvansa] = iznosAvansaKojiSeKompenzuje
                    } else if nizPoslovanjaSaGazdinstvom[clan].vrsta == VrstaTransakcije.UgovorOKooperaciji {
                        let brojUgovora = Int(nizPoslovanjaSaGazdinstvom[clan].brojUgovora!)
                        let iznosUgovoraKojiSeKompenzuje = recnikKojaLabelaKojaVrednost[recnikKojiRedKojaLabela[clan]!]
                        
                        // proveravamo da li ima docnju, i ako je ima onda vidimo da li moze cela da se knjizi, ili bar jedan njen deo
                        var iznosNivelacijeDocnjeKojiSeMozeKompenzovati: Decimal?
                        if nizPoslovanjaSaGazdinstvom[clan].docnja! {
                            if nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje != nil {
                                if nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje!.doubleValue <= iznosUgovoraKojiSeKompenzuje!.doubleValue {
                                    iznosNivelacijeDocnjeKojiSeMozeKompenzovati = nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje
                                } else {
                                    iznosNivelacijeDocnjeKojiSeMozeKompenzovati = iznosUgovoraKojiSeKompenzuje
                                }
                                recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje[brojUgovora] = iznosNivelacijeDocnjeKojiSeMozeKompenzovati
                            }
                        }
                        // sad proverimo i da li ima valutnu nivelaciju, i ako je ima onda vidimo da li moze cela da se knjizi, ili bar jedan njen deo
                        var iznosValutneNivelacijeKojiSeMozeKompenzovati: Decimal?
                        if nizPoslovanjaSaGazdinstvom[clan].valutnaKlauzula! {
                            if nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije != nil {
                                if nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije!.doubleValue <= (iznosUgovoraKojiSeKompenzuje!.doubleValue - (iznosNivelacijeDocnjeKojiSeMozeKompenzovati ?? 0.0).doubleValue) {
                                    iznosValutneNivelacijeKojiSeMozeKompenzovati = nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije
                                } else {
                                    iznosValutneNivelacijeKojiSeMozeKompenzovati = iznosUgovoraKojiSeKompenzuje! - Decimal(((iznosNivelacijeDocnjeKojiSeMozeKompenzovati ?? 0.0).doubleValue))
                                }
                            }
                        }
                        recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost[brojUgovora] = iznosUgovoraKojiSeKompenzuje
                        if iznosNivelacijeDocnjeKojiSeMozeKompenzovati != nil {
                            recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje[brojUgovora] = iznosNivelacijeDocnjeKojiSeMozeKompenzovati
                        }
                        if iznosValutneNivelacijeKojiSeMozeKompenzovati != nil {
                            recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule[brojUgovora] = iznosValutneNivelacijeKojiSeMozeKompenzovati
                        }
                    }
                }
                print(recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule)
            }
        } else { // slucaj kad se pojavljuje podesavanje vrednosti pojedinicanih ugovora sa slajderima
            if povratniSaldoPodobanZaKompenzaciju! < ((zbirOdabranihDokumenataZaKompenzacijuSaSlajdera?.doubleValue)! - 0.1) {
                vrednostKojaSePokusavaKompenzovatiJeVecaOdMoguce = true
                PrikaziNeuspesniPopUp(poruka: "Odabrana je veca masa za kompenzovanje nego sto je moguce kompnezovati")
            } else {
                for clan in selektovaniRovovi {
                    if nizPoslovanjaSaGazdinstvom[clan].vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
                        let brojAvansa = Int(nizPoslovanjaSaGazdinstvom[clan].brojAvansa!)
                        let iznosAvansaKojiSeKompenzuje = recnikKojaLabelaKojaVrednostSaSlajdera[recnikKojiRedKojaLabela[clan]!]
                        recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost[brojAvansa] = iznosAvansaKojiSeKompenzuje
                    } else if nizPoslovanjaSaGazdinstvom[clan].vrsta == VrstaTransakcije.UgovorOKooperaciji {
                        let brojUgovora = Int(nizPoslovanjaSaGazdinstvom[clan].brojUgovora!)
                        let iznosUgovoraKojiSeKompenzuje = recnikKojaLabelaKojaVrednostSaSlajdera[recnikKojiRedKojaLabela[clan]!]
                        
                        // proveravamo da li ima docnju, i ako je ima onda vidimo da li moze cela da se knjizi, ili bar jedan njen deo
                        var iznosNivelacijeDocnjeKojiSeMozeKompenzovati: Decimal?
                        if nizPoslovanjaSaGazdinstvom[clan].docnja! {
                            if nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje != nil {
                                if nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje!.doubleValue <= iznosUgovoraKojiSeKompenzuje!.doubleValue {
                                    iznosNivelacijeDocnjeKojiSeMozeKompenzovati = nizPoslovanjaSaGazdinstvom[clan].iznosNivelacijeDocnje
                                } else {
                                    iznosNivelacijeDocnjeKojiSeMozeKompenzovati = iznosUgovoraKojiSeKompenzuje
                                }
                                recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje[brojUgovora] = iznosNivelacijeDocnjeKojiSeMozeKompenzovati
                            }
                        }
                        // sad proverimo i da li ima valutnu nivelaciju, i ako je ima onda vidimo da li moze cela da se knjizi, ili bar jedan njen deo
                        var iznosValutneNivelacijeKojiSeMozeKompenzovati: Decimal?
                        if nizPoslovanjaSaGazdinstvom[clan].valutnaKlauzula! {
                            if nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije != nil {
                                if nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije!.doubleValue <= (iznosUgovoraKojiSeKompenzuje!.doubleValue - (iznosNivelacijeDocnjeKojiSeMozeKompenzovati ?? 0.0).doubleValue) {
                                    iznosValutneNivelacijeKojiSeMozeKompenzovati = nizPoslovanjaSaGazdinstvom[clan].iznosValutneNivelacije
                                } else {
                                    iznosValutneNivelacijeKojiSeMozeKompenzovati = iznosUgovoraKojiSeKompenzuje! - Decimal(((iznosNivelacijeDocnjeKojiSeMozeKompenzovati ?? 0.0).doubleValue))
                                }
                            }
                        }
                        recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost[brojUgovora] = iznosUgovoraKojiSeKompenzuje
                        if iznosNivelacijeDocnjeKojiSeMozeKompenzovati != nil {
                            recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje[brojUgovora] = iznosNivelacijeDocnjeKojiSeMozeKompenzovati
                        }
                        if iznosValutneNivelacijeKojiSeMozeKompenzovati != nil {
                            recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule[brojUgovora] = iznosValutneNivelacijeKojiSeMozeKompenzovati
                        }
                        
                        
                        recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost[brojUgovora] = iznosUgovoraKojiSeKompenzuje
                    }
                }
                print(recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje)
                print(recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule)

            }
        }
        if !vrednostKojaSePokusavaKompenzovatiJeVecaOdMoguce {
            performSegue(withIdentifier: "sg-FinKarGaz->GenOtkList", sender: nil)
        }
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nekoIme = potencijalnoIme
        if segue.identifier == "sg-FinansijskaKarticaGazdinstva->FiltrGazd" {
            if let filtriranaGazdinstva = segue.destination as? FiltriranaGazdinstvaVC {
                filtriranaGazdinstva.unosImenaGazdinstvaSaDrugogVC = nekoIme
            }
        } else if segue.identifier == "sg-FinKarGaz->GenOtkList" {
            if let generisiOtkupniList = segue.destination as? GenerisiOtkupniListVC {
                generisiOtkupniList.povratnaUkupnaVrednostOtvorenihAvansa = ukupnaVrednostOtvorenihAvansa
                generisiOtkupniList.povratnaUkupnaVrednostOtvorenihUgovora = ukupnaVrednostOtvorenihUgovora
                generisiOtkupniList.povratniUkupniSaldoBezObziraNaValutu = ukupniSaldoBezObziraNaValutu
                generisiOtkupniList.povratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost = recnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost
                generisiOtkupniList.povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost = recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost
                generisiOtkupniList.povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje = recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje
                generisiOtkupniList.povratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule = recnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule
            }
        }
    }
    
    var potencijalnoIme: String?
    @IBAction func IzaberiKomintenta(_ sender: Any) {
        potencijalnoIme = tfUnesiIme.text
        dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva = "sg-FinansijskaKarticaGazdinstva->FiltrGazd"
        performSegue(withIdentifier: "sg-FinansijskaKarticaGazdinstva->FiltrGazd", sender: nil)
    }
    
    func PreuzmiImeSaDrugogVC() {
        if dummyAppDelegate?.poslednjiSegvejKojiJePozvaoFinansijskaKarticaGazdinstva == "sg-GenOtkList->FinKarGaz" {
            if povratnoIme != nil {
                tfUnesiIme.text = povratnoIme!
                labelaBroj.text = String(povratniBroj!)
                PovuciPodatke()
                //print("samo sto nisam vratio sa finkargaz na gen otk lis")
                //performSegue(withIdentifier: "sg-FinKarGaz->GenOtkList", sender: nil)
            }
        } else if povratnoIme != nil {
            //print("udjoh u nedefinisani preuzmi ime sa drugog vc")
            tfUnesiIme.text = povratnoIme!
            labelaBroj.text = String(povratniBroj!)
            PovuciPodatke()
        }
    }
    
    @IBOutlet weak var tabela: UITableView!
    
    func PovuciPodatke() {
        
        PovuciSveAvanseGazdinstvima()
        PovuciSveUgovoreSaGazdinstvom()
        PovuciSveOtkupneListove()
        SorirajTabelu()
    }
    
    var nizPoslovanjaSaGazdinstvom = [PoslovanjeSaGazdinstvom]()
    func PovuciSveAvanseGazdinstvima() {
        guard let filter = povratnoIme else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AvansiGazdinstvima")
        
        let predicate = NSPredicate(format: "naziv = %@", filter)
        fetchRequest.predicate = predicate
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
               
                    let naziv = podatak.value(forKey: "naziv") as! String
                    let banka = podatak.value(forKey: "banka") as! String
                    let bpg = podatak.value(forKey: "bpg") as! Int64
                    let datumPromene = podatak.value(forKey: "datum") as! Date
                    let brojIzvoda = podatak.value(forKey: "brojIzvoda") as! Int32
                    let odliv = podatak.value(forKey: "odliv") as! Decimal
                    let kompenzovano = podatak.value(forKey: "kompenzovano") as! Decimal
                    let avansJeZatvoren = podatak.value(forKey: "avansJeZatvoren") as! Bool
                    let brojAvansa = podatak.value(forKey: "brojAvansa") as! Int32
                    
                nizPoslovanjaSaGazdinstvom.append(PoslovanjeSaGazdinstvom(AVANS: VrstaTransakcije.AvansPoljoprivrednomGazdinstvu, naziv: naziv, bpg: bpg, datumPromene: datumPromene, odliv: odliv, banka: banka, brojIzvoda: brojIzvoda, valuta: datumPromene, kompenzovano: kompenzovano, avansJeZatvoren: avansJeZatvoren, brojAvansa: brojAvansa))
                
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih avansa gazdinstavima u tabeli! \(error)")
        }
    }
    func PovuciSveUgovoreSaGazdinstvom() {
        // cenaPoJediniciMere 0.25
        // preuzetaKolicina 0
        // minimalniKursZaObracunRazduzenja 130.8734
        // otplaceno 0
        // neotplacenaVrednostUgovora 0
        
        // realizovanaVrednostUgovora 0
        // vrednostPDVaOvogUgovora 0
        
        // datumSklapanjaUgovora
        // datumskaValutaUgovora
        // valutnaKlauzula
        // valutaUgovora EUR DOL DIN
        // docnja
        // ugovorJeZatvoren
        
        // iznosNivelacijeDocnje (ovo racunas kad se radi prikaz kao da u tom trenutku zeli da razduzi sve)
        // iznosValutneNivelacije (ovo racunas kad se radi prikaz kao da u tom trenutku zeli da razduzi sve)

        guard let filter = povratnoIme else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UgovorSaGazdinstvomKooperacija")
        
        let predicate = NSPredicate(format: "povratnoIme = %@", filter)
        fetchRequest.predicate = predicate
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                
                let naziv = podatak.value(forKey: "povratnoIme") as! String
                let bpg = podatak.value(forKey: "povratniBroj") as! Int64
                
                let cenaPoJediniciMere = podatak.value(forKey: "cenaPoJediniciMere") as! Decimal
                let preuzetaKolicina = podatak.value(forKey: "preuzetaKolicina") as! Decimal
                let minimalniKursZaObracunRazduzenja = podatak.value(forKey: "minimalniKursZaObracunRazduzenja") as! Decimal?
                let otplaceno = podatak.value(forKey: "otplaceno") as! Decimal
                let neotplacenaVrednostUgovora = podatak.value(forKey: "neotplacenaVrednostUgovora") as! Decimal
                
                let realizovanaVrednostUgovora = podatak.value(forKey: "realizovanaVrednostUgovora") as! Decimal
                let vrednostPDVaOvogUgovora = podatak.value(forKey: "vrednostPDVaOvogUgovora") as! Decimal
                
                let datumSklapanjaUgovora = podatak.value(forKey: "datumSklapanjaUgovora") as! Date
                let datumskaValutaUgovora = podatak.value(forKey: "datumskaValutaUgovora") as! Date
                let valutnaKlauzula = podatak.value(forKey: "valutnaKlauzula") as! Bool
                let valutaUgovora = podatak.value(forKey: "valutaUgovora") as! String
                let docnja = podatak.value(forKey: "docnja") as! Bool
                let ugovorJeZatvoren = podatak.value(forKey: "ugovorJeZatvoren") as! Bool
                
                let brojUgovora = podatak.value(forKey: "brojUgovora") as! Int64
                let robaKojaJeDataNaodlozeno = podatak.value(forKey: "robaKojaJePredmetUgovora") as! String
                
                let postojecaNaplacenaVrednostNivelacijeDocnje = podatak.value(forKey: "iznosNivelacijeDocnje") as? Decimal
                let postojecaNaplacenaVrednostValutneNivelacije = podatak.value(forKey: "iznosValutneNivelacije") as? Decimal
                
                var iznosNivelacijeDocnje: Decimal?
                if docnja {
                    print(brojUgovora)
                    let currentDate = Date()
                    let kakavJeDatum = Calendar.current.compare(currentDate, to: datumskaValutaUgovora, toGranularity: .day)
                    
                    switch kakavJeDatum {
                    case .orderedDescending:
                        let ukupnoKasnjenjeUDanima = IzracunavamKolikoDanaJeUKasnjenju(start: datumskaValutaUgovora, end: currentDate)
                        //print(ukupnoKasnjenjeUDanima, datumskaValutaUgovora, currentDate)
                        // nivelaciju docnje takodje nuliramo jer je tako najsigurnije
                        if ukupnoKasnjenjeUDanima > 0 {
                            iznosNivelacijeDocnje = Decimal(ukupnoKasnjenjeUDanima) * ((realizovanaVrednostUgovora * minimalniKursZaObracunRazduzenja!) / 1000) - (postojecaNaplacenaVrednostNivelacijeDocnje ?? 0)
                            if iznosNivelacijeDocnje! < 0 {
                                iznosNivelacijeDocnje = 0
                            }
                        }
                        
                    default:
                        print("default")
                    }
                }
                
                var iznosValutneNivelacije: Decimal?
                if valutnaKlauzula {
                    if valutaUgovora == "Evro" {
                        // ovde se ulazi samo i samo u slucaju da je kurs manji od onog setovanog u ugovoru koji je definisan jos pri pravljenju ugovora, medjutim nastaje problem kada se parciajlno razduzuje i uima robu jer je pg u mogucnosti da napravi ugovor na 2000e po kursu 100 i da povuce 1000e robe u prvom koraku a zatim da se razduzi u narednom koraku preko otkupnog lista u momentu kad je kurs 150 gde ce evidentno satati valutna razlika od 50.000 koja ce biti iskazana na otkupnom listu. Nakon razduzenja gazdinstvo povlaci jos 1000e sa ugovora i pojavljuje se da razduzi robu kad je kurs 120. Prilikom tog drugog obracuna gazdinstvu se obracunava kursna razlika od 40.000. U tom slucaju ce kursna ralika biti negativna jer sada dolazimo u situaciju da od ovih 40.000 koje smo obracunali kao valutnu razliku u ovom drugom razduzenju moramo oduzeti vec naplacenih 50.000 kursnih razlika te ZBOG toga kursne razlike koje se izracunavaju preko finansijske kartice nuliramo u slucaju da su negativne.
                        if danasnjiKursZaObracunRazduzenjaEUR! > minimalniKursZaObracunRazduzenja! {
                            iznosValutneNivelacije = (realizovanaVrednostUgovora * danasnjiKursZaObracunRazduzenjaEUR!) - (realizovanaVrednostUgovora * minimalniKursZaObracunRazduzenja!) -  (postojecaNaplacenaVrednostValutneNivelacije ?? 0)
                            
                            if iznosValutneNivelacije! < 0 {
                                print("nuliram iznos valutne nivelacije jer je negativan")
                                iznosValutneNivelacije = 0
                            }
                            
                            print("postojeca valutna nivelacije je \((postojecaNaplacenaVrednostValutneNivelacije ?? 0))")
                        }
                    } else if valutaUgovora == "Dolar" {
                        if danasnjiKursZaObracunRazduzenjaDOL! > minimalniKursZaObracunRazduzenja! {
                            iznosValutneNivelacije = (realizovanaVrednostUgovora * danasnjiKursZaObracunRazduzenjaDOL!) - (realizovanaVrednostUgovora * minimalniKursZaObracunRazduzenja!) - (postojecaNaplacenaVrednostValutneNivelacije ?? 0)
                            if iznosValutneNivelacije! < 0 {
                                print("nuliram iznos valutne nivelacije jer je negativan")
                                iznosValutneNivelacije = 0
                            }
                        }
                    }
                }
                
                nizPoslovanjaSaGazdinstvom.append(PoslovanjeSaGazdinstvom(UGOVOR: VrstaTransakcije.UgovorOKooperaciji, naziv: naziv, bpg: bpg, datumPromene: datumSklapanjaUgovora, cenaPoJediniciMere: cenaPoJediniciMere, preuzetaKolicina: preuzetaKolicina, minimalniKursZaObracunRazduzenja: minimalniKursZaObracunRazduzenja, otplaceno: otplaceno, neotplacenaVrednostUgovora: neotplacenaVrednostUgovora, realizovanaVrednostUgovora: realizovanaVrednostUgovora, vrednostPDVaOvogUgovora: vrednostPDVaOvogUgovora, datumskaValutaUgovora: datumskaValutaUgovora, valutnaKlauzula: valutnaKlauzula, valutaUgovora: valutaUgovora, docnja: docnja, ugovorJeZatvoren: ugovorJeZatvoren, iznosNivelacijeDocnje: iznosNivelacijeDocnje, iznosValutneNivelacije: iznosValutneNivelacije, brojUgovora: brojUgovora, robaKojaJeDataNaodlozeno: robaKojaJeDataNaodlozeno))
                
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih avansa gazdinstavima u tabeli! \(error)")
        }
    }
    
    func IzracunavamKolikoDanaJeUKasnjenju(start: Date, end: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func PovuciSveOtkupneListove() {
        guard let filter = povratnoIme else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OtkupniList")
        
        let predicate = NSPredicate(format: "nazivPG = %@", filter)
        fetchRequest.predicate = predicate
        
        do {
            let response = try managedContext.fetch(fetchRequest)
            
            for podatak in response {
                
                let naziv = podatak.value(forKey: "nazivPG") as! String
                let bpg = podatak.value(forKey: "bPG") as! Int64
                let datumPromene = podatak.value(forKey: "datumPrijemaSaNajranijeOdvageNaOtkupnomListu") as! Date
                let brojOtkupnogLista = podatak.value(forKey: "brojOtkupnogLista") as! Int32
                
                let robaKojaJeOtkupljena = podatak.value(forKey: "robaKojaJeOtkupljena") as! String
                let datumIzradeOtkupnogLista = podatak.value(forKey: "datumIzradeOtkupnogLista") as! Date
                let pdvJeUplacen = podatak.value(forKey: "pdvJeUplacen") as! Bool
                let zaUplatuPGuJeUplaceno = podatak.value(forKey: "zaUplatuPGuJeUplaceno") as! Bool
                let vrednostPDV = podatak.value(forKey: "vrednostPDV") as! Double
                let zaUplatuPGu = podatak.value(forKey: "zaUplatuPGu") as? Decimal
                let knjizenoUplateNaOvajOtkupniList = podatak.value(forKey: "knjizenoUplateNaOvajOtkupniList") as! Decimal
                
                nizPoslovanjaSaGazdinstvom.append(PoslovanjeSaGazdinstvom(OTKUPNI_LIST: VrstaTransakcije.OtkupniList, naziv: naziv, bpg: bpg, datumPromene: datumPromene, brojOtkupnogLista: brojOtkupnogLista, robaKojaJeOtkupljena: robaKojaJeOtkupljena, datumIzradeOtkupnogLista: datumIzradeOtkupnogLista, pdvJeUplacen: pdvJeUplacen, zaUplatuPGuJeUplaceno: zaUplatuPGuJeUplaceno, vrednostPDV: vrednostPDV, zaUplatuPGu: zaUplatuPGu, knjizenoUplateNaOvajOtkupniList: knjizenoUplateNaOvajOtkupniList))
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih otkupnih listova sa gazdinstavima u tabeli! \(error)")
        }
    }

    // vidi da li po datumu ili po valuti kako ti odgovara
    func SortiramPoDatumuNajpreBuducnostPaProslost(ulaz1: PoslovanjeSaGazdinstvom, ulaz2: PoslovanjeSaGazdinstvom) -> Bool {
        return ulaz1.datumPromene > ulaz2.datumPromene
    }
    
    func SortiramPoDatumuNajpreProslostPaBducnost(ulaz1: PoslovanjeSaGazdinstvom, ulaz2: PoslovanjeSaGazdinstvom) -> Bool {
        return ulaz1.datumPromene < ulaz2.datumPromene
    }
    
    var ukupnaVrednostOtvorenihAvansa: Decimal = 0.0
    var ukupnaVrednostOtvorenihUgovora: Decimal = 0.0
    
    var ukupniSaldoBezObziraNaValutu: Decimal = 0.0
    var ukupniSaldoSaObziromNaValutu: Decimal = 0.0
    
    var nizUkupniSaldoBezObziraNaValutu: [Decimal] = []
    var nizUkupniSaldoSaObziromNaValutu: [Decimal] = []
    func SorirajTabelu() {
        nizPoslovanjaSaGazdinstvom = nizPoslovanjaSaGazdinstvom.sorted(by: SortiramPoDatumuNajpreBuducnostPaProslost)
    
        for clan in nizPoslovanjaSaGazdinstvom.sorted(by: SortiramPoDatumuNajpreProslostPaBducnost) {
            if clan.vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
                let ostaloOtvorenoAvansa = clan.odliv! - clan.kompenzovano!
                ukupniSaldoBezObziraNaValutu += ostaloOtvorenoAvansa
                nizUkupniSaldoBezObziraNaValutu.append(ukupniSaldoBezObziraNaValutu)
                
                let danasnjiDatum = NSDate()
                if LeviDatumJeKasnijiIliIstiPoredeciSaDesnimDatumom(leviDatum: danasnjiDatum as Date, desniDatum: clan.valuta!) {
                    
                    ukupniSaldoSaObziromNaValutu += ostaloOtvorenoAvansa
                    nizUkupniSaldoSaObziromNaValutu.append(ukupniSaldoSaObziromNaValutu)
                    
                    ukupnaVrednostOtvorenihAvansa += ostaloOtvorenoAvansa
                } else {
                    nizUkupniSaldoSaObziromNaValutu.append(ukupniSaldoSaObziromNaValutu)
                }
            } else if clan.vrsta == VrstaTransakcije.UgovorOKooperaciji {
                var ukupanDugPoUgovoru = clan.neotplacenaVrednostUgovora!
                
                if clan.minimalniKursZaObracunRazduzenja != nil {
                    ukupanDugPoUgovoru = ukupanDugPoUgovoru * clan.minimalniKursZaObracunRazduzenja!
                }
              
                ukupanDugPoUgovoru += (clan.iznosNivelacijeDocnje ?? 0.0) + (clan.iznosValutneNivelacije ?? 0.0)
                
                
                ukupniSaldoBezObziraNaValutu += ukupanDugPoUgovoru
                nizUkupniSaldoBezObziraNaValutu.append(ukupniSaldoBezObziraNaValutu)
                
                
                let danasnjiDatum = NSDate()
                if LeviDatumJeKasnijiIliIstiPoredeciSaDesnimDatumom(leviDatum: danasnjiDatum as Date, desniDatum: clan.datumskaValutaUgovora!) {
                    ukupniSaldoSaObziromNaValutu += ukupanDugPoUgovoru
                    nizUkupniSaldoSaObziromNaValutu.append(ukupniSaldoSaObziromNaValutu)
                    
                    ukupnaVrednostOtvorenihUgovora += ukupanDugPoUgovoru
                } else {
                    nizUkupniSaldoSaObziromNaValutu.append(ukupniSaldoSaObziromNaValutu)
                }

            } else if clan.vrsta == VrstaTransakcije.OtkupniList {
                let ostaloJosDaSePlatiPGuPoOtkupnomListu = (clan.zaUplatuPGu ?? 0) + Decimal(clan.vrednostPDV!) - clan.knjizenoUplateNaOvajOtkupniList!
                
                ukupniSaldoBezObziraNaValutu -= ostaloJosDaSePlatiPGuPoOtkupnomListu
                nizUkupniSaldoBezObziraNaValutu.append(ukupniSaldoBezObziraNaValutu)
                
                ukupniSaldoSaObziromNaValutu -= ostaloJosDaSePlatiPGuPoOtkupnomListu
                nizUkupniSaldoSaObziromNaValutu.append(ukupniSaldoSaObziromNaValutu)
                
            }
        }
        nizUkupniSaldoBezObziraNaValutu.reverse()
        nizUkupniSaldoSaObziromNaValutu.reverse()
        
        //print(ukupnaVrednostOtvorenihAvansa, ukupnaVrednostOtvorenihUgovora)
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
    
    func PrikaziUspesniPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
                                      message: "Uspesno nesto....",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                     style: UIAlertActionStyle.default,
                                     handler: {(alert: UIAlertAction!) in
                                        self.performSegue(withIdentifier: "sgGlavniSaFinansijskaKarticaGazdinstva", sender: nil)
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
                                        self.performSegue(withIdentifier: "sgGlavniSaFinansijskaKarticaGazdinstva", sender: nil)
            })
        }
        
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
        performSegue(withIdentifier: "sgGlavniSaFinansijskaKarticaGazdinstva", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nizPoslovanjaSaGazdinstvom.count
    }
    

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
            print("celija vrsta avans")
            let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaAvans", for: indexPath) as? FinansijskaKarticaGazdinstvaAvansTableVC
            celija?.labelaOpisPromeneAvans.text = "Avans gazdinstvu br: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojAvansa!)
            celija?.labelaBanka.text = "Placeno sa: " + nizPoslovanjaSaGazdinstvom[indexPath.row].banka!
            celija?.labelaIzvod.text = "Izvod br: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojIzvoda!)
            celija?.labelaOdlivIznos.text = "Iznos avansa: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].odliv!.doubleValue.roundTo(places: 2)) + " Din"
            
            // uredjujem datum u citljiviju formu
            let uredjujemDatum = DateFormatter()
            uredjujemDatum.dateFormat = "dd MMM yyyy"
            let selektovaniDatum = uredjujemDatum.string(from: nizPoslovanjaSaGazdinstvom[indexPath.row].valuta!)
            celija?.labelaValuta.text = "Valuta: " + selektovaniDatum
            
            let datumPromene = uredjujemDatum.string(from: nizPoslovanjaSaGazdinstvom[indexPath.row].datumPromene)
            celija?.labelaDatumPromene.text = datumPromene
            
            celija?.labelaKompenzovano.text = "Kompenzovano: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].kompenzovano!.doubleValue.roundTo(places: 2)) + " Din"
            
            let ostaloOtvorenoAvansa = nizPoslovanjaSaGazdinstvom[indexPath.row].odliv! - nizPoslovanjaSaGazdinstvom[indexPath.row].kompenzovano!
            celija?.labelaOstajeOtvoreno.text = "Otvoren avans: " + String(format: "%.2f", locale: Locale.current, ostaloOtvorenoAvansa.doubleValue.roundTo(places: 2)) + " Din"
            
            celija?.progresAvansa.setProgress(Float((nizPoslovanjaSaGazdinstvom[indexPath.row].kompenzovano! / nizPoslovanjaSaGazdinstvom[indexPath.row].odliv!).doubleValue), animated: true)
            

            celija?.ukupniSaldoBezObziraNaValutu.text = "Dug crno/belo: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoBezObziraNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"

            celija?.ukupniSaldoKojiJeDospeoPoValuti.text = "Dospeo dug: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoSaObziromNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
            /*
            if selektovaniRovovi.contains(indexPath.row) {
                celija?.backgroundColor = UIColor.gray
            } */
            return celija!
        } /*else if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.OtkupniList {
            print("celija vrsta otkupni list")
           /* let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaOtkupniList", for: indexPath) as? FinansijskaKarticaGazdinstvaOtkupniListTableVC
            
            celija?.labelabrojOtkupnogLista.text = "Broj otkupnog lista" + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojOtkupnogLista!)
            
            */
            
/*
            celija?.ukupniSaldoBezObziraNaValutu.text = "Dug crno/belo: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoBezObziraNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
            
            celija?.ukupniSaldoKojiJeDospeoPoValuti.text = "Dospeo dug: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoSaObziromNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
 */
            //return celija!
        } */else if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.UgovorOKooperaciji {
            print("celija vrsta ugovor o kooperaciji")
            let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaUgovor", for: indexPath) as? FinansijskaKarticaGazdinstvaUgovorTableVC
            celija?.labelaOpisPromenUgovor.text = "Ugovor o kooperaciji"
            celija?.labelaBrojUgovora.text = "Broj ugovora: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojUgovora!)
            
            // uredjujem datum u citljiviju formu
            let uredjujemDatum = DateFormatter()
            uredjujemDatum.dateFormat = "dd MMM yyyy"
            let selektovaniDatum = uredjujemDatum.string(from: nizPoslovanjaSaGazdinstvom[indexPath.row].datumskaValutaUgovora!)
            celija?.labelaValutaUgovora.text = "Valuta: " + selektovaniDatum
            
            let datumPromene = uredjujemDatum.string(from: nizPoslovanjaSaGazdinstvom[indexPath.row].datumPromene)
            celija?.labelaDatumPromene.text = datumPromene
            
            if nizPoslovanjaSaGazdinstvom[indexPath.row].iznosNivelacijeDocnje != nil {
                celija?.labelaIznosNivelacijeDocnje.text = "Docnja: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].iznosNivelacijeDocnje!.doubleValue.roundTo(places: 2)) + " Din"
            } else {
                celija?.labelaIznosNivelacijeDocnje.text = "Nema docnje"
            }
            
            if nizPoslovanjaSaGazdinstvom[indexPath.row].iznosValutneNivelacije != nil {
                celija?.labelaIznosValutneNivelacije.text = "Valutna razlika: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].iznosValutneNivelacije!.doubleValue.roundTo(places: 2)) + " Din"
            } else {
                celija?.labelaIznosValutneNivelacije.text = "Nema valutne razlike"
            }
            print("neotplacena vrednost ugovora je \(nizPoslovanjaSaGazdinstvom[indexPath.row].neotplacenaVrednostUgovora!)")
            celija?.labelaNeotplacenaVrednostUgovora.text = "Neotplaceno: " + String(format: "%.2f", locale: Locale.current, (nizPoslovanjaSaGazdinstvom[indexPath.row].neotplacenaVrednostUgovora!.doubleValue.roundTo(places: 2))) + " " + nizPoslovanjaSaGazdinstvom[indexPath.row].valutaUgovora!
            
            // ukupan dug predtavlja ((povucena kolicina robe * cena po jedinici mere i sve to u nativnoj valuti) - otplaceno) * kurs minimalni i na to nadodas docnju i valutnu razliku
            var ukupanDugPoUgovoru = nizPoslovanjaSaGazdinstvom[indexPath.row].neotplacenaVrednostUgovora!
            // ovo ispod ukoliko je bilo u dinarima valuta pa da ne mnozi sa kursom
            if nizPoslovanjaSaGazdinstvom[indexPath.row].minimalniKursZaObracunRazduzenja != nil {
                ukupanDugPoUgovoru = ukupanDugPoUgovoru * nizPoslovanjaSaGazdinstvom[indexPath.row].minimalniKursZaObracunRazduzenja!
            }
            // na ovo nadodajemo dinarsk iznos docnje i valutne nivelacije
            print("ukupan dug po ugovoru mi je pre dodavanja docnje i valutne klauzule \(ukupanDugPoUgovoru)")
            ukupanDugPoUgovoru += (nizPoslovanjaSaGazdinstvom[indexPath.row].iznosNivelacijeDocnje ?? 0.0) + (nizPoslovanjaSaGazdinstvom[indexPath.row].iznosValutneNivelacije ?? 0.0)
            print("nakon dodavanja ukupan dug po ugovoru mi je \(ukupanDugPoUgovoru) jer sam dodao docnju \((nizPoslovanjaSaGazdinstvom[indexPath.row].iznosNivelacijeDocnje ?? 0.0)) i valutnu nivelaciju \((nizPoslovanjaSaGazdinstvom[indexPath.row].iznosValutneNivelacije ?? 0.0))")
            
            celija?.labelaUkupnoDugujePoUgovoru.text = "Ukupno dug: " + String(format: "%.2f", locale: Locale.current, ukupanDugPoUgovoru.doubleValue.roundTo(places: 2)) + " Din"
            
            celija?.labelaRobaKojaJeDataNaOdlozeno.text = nizPoslovanjaSaGazdinstvom[indexPath.row].robaKojaJeDataNaodlozeno
            
            celija?.ukupniSaldoBezObziraNaValutu.text = "Dug crno/belo: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoBezObziraNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"

            celija?.ukupniSaldoKojiJeDospeoPoValuti.text = "Dospeo dug: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoSaObziromNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
           /*
            if selektovaniRovovi.contains(indexPath.row) {
                celija?.backgroundColor = UIColor.gray
            } */
            return celija!
        } else {
            print("celija vrsta otkupni list")
            let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelijaOtkupniList", for: indexPath) as? FinansijskaKarticaGazdinstvaOtkupniListTableVC
            
            celija?.labelabrojOtkupnogLista.text = "Broj Otkupnog Lista: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojOtkupnogLista!)
            celija?.labelarobaKojaJeOtkupljena.text = nizPoslovanjaSaGazdinstvom[indexPath.row].robaKojaJeOtkupljena!
            
            // uredjujem datum u citljiviju formu
            let uredjujemDatum = DateFormatter()
            uredjujemDatum.dateFormat = "dd MMM yyyy"
            let selektovaniDatum = uredjujemDatum.string(from: nizPoslovanjaSaGazdinstvom[indexPath.row].datumPromene)
            
            celija?.labeladatumIzradeOtkupnogLista.text = selektovaniDatum
            
            if nizPoslovanjaSaGazdinstvom[indexPath.row].pdvJeUplacen! {
                celija?.labelapdvJeUplacen.text = "PDV Ok"
                celija?.labelapdvJeUplacen.backgroundColor = .green
            } else {
                celija?.labelapdvJeUplacen.text = "PDV NE"
                celija?.labelapdvJeUplacen.backgroundColor = .red
            }
            
            if nizPoslovanjaSaGazdinstvom[indexPath.row].zaUplatuPGuJeUplaceno! {
                celija?.labelazaUplatuPGuJeUplaceno.text = "Uplata Ok"
                celija?.labelazaUplatuPGuJeUplaceno.backgroundColor = .green
            } else {
                celija?.labelazaUplatuPGuJeUplaceno.text = "Uplata NE"
                celija?.labelazaUplatuPGuJeUplaceno.backgroundColor = .red
            }
            
            celija?.labelavrednostPDV.text = "Vrednost PDV: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].vrednostPDV!.roundTo(places: 2)) + " Din"
            celija?.labelazaUplatuPGu.text = "Za Uplatu: " + String(format: "%.2f", locale: Locale.current, nizPoslovanjaSaGazdinstvom[indexPath.row].zaUplatuPGu!.doubleValue.roundTo(places: 2)) + " Din"
            
            let preostajeJosDaSeUplati = Decimal(nizPoslovanjaSaGazdinstvom[indexPath.row].vrednostPDV!) + (nizPoslovanjaSaGazdinstvom[indexPath.row].zaUplatuPGu ?? 0) - nizPoslovanjaSaGazdinstvom[indexPath.row].knjizenoUplateNaOvajOtkupniList!
            celija?.labelaostaloJosDaSePlatiPGuPoOtkupnomListu.text = "Preostaje: " + String(format: "%.2f", locale: Locale.current, preostajeJosDaSeUplati.doubleValue.roundTo(places: 2)) + " Din"
            
            celija?.labelaukupniSaldoBezObziraNaValutu.text = "Dug crno/belo: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoBezObziraNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
            
            celija?.labelaukupniSaldoKojiJeDospeoPoValuti.text = "Dospeo dug: " + String(format: "%.2f", locale: Locale.current, nizUkupniSaldoSaObziromNaValutu[indexPath.row].doubleValue.roundTo(places: 2)) + " Din"
            
            return celija!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
            return 145
        } else if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.OtkupniList {
            return 125
        } else {
            return 155
        }
    }
    /*
     @IBOutlet weak var labelabrojOtkupnogLista: UILabel!
     @IBOutlet weak var labelarobaKojaJeOtkupljena: UILabel!
     @IBOutlet weak var labelapdvJeUplacen: UILabel!
     @IBOutlet weak var labelazaUplatuPGuJeUplaceno: UILabel!
     @IBOutlet weak var labeladatumIzradeOtkupnogLista: UILabel!
     @IBOutlet weak var labelavrednostPDV: UILabel!
     @IBOutlet weak var labelazaUplatuPGu: UILabel!
     @IBOutlet weak var labelaostaloJosDaSePlatiPGuPoOtkupnomListu: UILabel!
     
     @IBOutlet weak var ukupniSaldoKojiJeDospeoPoValuti: UILabel!
     @IBOutlet weak var ukupniSaldoBezObziraNaValutu: UILabel!
     */
    /*
    var odabranDokumentZaKompenzacijuJedan: Int?
    var odabranDokumentZaKompenzacijuDva: Int?
    var odabranDokumentZaKompenzacijuTri: Int?
    */
    
    var zbirOdabranihDokumenataZaKompenzaciju: Decimal = 0.0
    var recnikKojaLabelaKojaVrednost: Dictionary = [Int : Decimal]()
    var recnikKojiRedKojaLabela: Dictionary = [Int : Int]()
    var selektovaniRovovi = Set<Int>()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if povratniSaldoPodobanZaKompenzaciju != nil {
            roSnimiSelektovaneDokumentePodobneZaKompenzaciju.isHidden = false
        }
        
        if !selektovaniRovovi.contains(indexPath.row) && povratniSaldoPodobanZaKompenzaciju != nil {
            if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.AvansPoljoprivrednomGazdinstvu {
                let ostaloOtvorenoAvansa = nizPoslovanjaSaGazdinstvom[indexPath.row].odliv! - nizPoslovanjaSaGazdinstvom[indexPath.row].kompenzovano!
                
                if labelaOdabranDokumentZaKompenzacijuJedan.text == "" {
                    slajderOdabranDokumentZaKompenzacijuJedan.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 1
                    recnikKojaLabelaKojaVrednost[1] = ostaloOtvorenoAvansa
                    labelaOdabranDokumentZaKompenzacijuJedan.text = "Avans: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojAvansa!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ostaloOtvorenoAvansa.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ostaloOtvorenoAvansa
                } else if labelaOdabranDokumentZaKompenzacijuDva.text == "" {
                    slajderOdabranDokumentZaKompenzacijuDva.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 2
                    recnikKojaLabelaKojaVrednost[2] = ostaloOtvorenoAvansa
                    labelaOdabranDokumentZaKompenzacijuDva.text = "Avans: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojAvansa!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ostaloOtvorenoAvansa.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ostaloOtvorenoAvansa
                } else if labelaOdabranDokumentZaKompenzacijuTri.text == "" {
                    slajderOdabranDokumentZaKompenzacijuTri.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 3
                    recnikKojaLabelaKojaVrednost[3] = ostaloOtvorenoAvansa
                    labelaOdabranDokumentZaKompenzacijuTri.text = "Avans: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojAvansa!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ostaloOtvorenoAvansa.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ostaloOtvorenoAvansa
                } else {
                    PrikaziNeuspesniPopUp(poruka: "Vec si odabrao TRI dokumenta, deselektuj jedan da oslobodis prostor pa se vrati na ovaj koji sad pokusavas da odaberes")
                }
            } else if nizPoslovanjaSaGazdinstvom[indexPath.row].vrsta == VrstaTransakcije.UgovorOKooperaciji {
                var ukupanDugPoUgovoru = nizPoslovanjaSaGazdinstvom[indexPath.row].neotplacenaVrednostUgovora!
                if nizPoslovanjaSaGazdinstvom[indexPath.row].minimalniKursZaObracunRazduzenja != nil {
                    ukupanDugPoUgovoru = ukupanDugPoUgovoru * nizPoslovanjaSaGazdinstvom[indexPath.row].minimalniKursZaObracunRazduzenja!
                }
                ukupanDugPoUgovoru += (nizPoslovanjaSaGazdinstvom[indexPath.row].iznosNivelacijeDocnje ?? 0.0) + (nizPoslovanjaSaGazdinstvom[indexPath.row].iznosValutneNivelacije ?? 0.0)
                
                if labelaOdabranDokumentZaKompenzacijuJedan.text == "" {
                    slajderOdabranDokumentZaKompenzacijuJedan.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 1
                    recnikKojaLabelaKojaVrednost[1] = ukupanDugPoUgovoru
                    labelaOdabranDokumentZaKompenzacijuJedan.text = "Ugovor: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojUgovora!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ukupanDugPoUgovoru.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ukupanDugPoUgovoru
                } else if labelaOdabranDokumentZaKompenzacijuDva.text == "" {
                    slajderOdabranDokumentZaKompenzacijuDva.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 2
                    recnikKojaLabelaKojaVrednost[2] = ukupanDugPoUgovoru
                    labelaOdabranDokumentZaKompenzacijuDva.text = "Ugovor: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojUgovora!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ukupanDugPoUgovoru.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ukupanDugPoUgovoru
                } else if labelaOdabranDokumentZaKompenzacijuTri.text == "" {
                    slajderOdabranDokumentZaKompenzacijuTri.isHidden = false
                    selektovaniRovovi.insert(indexPath.row)
                    recnikKojiRedKojaLabela[indexPath.row] = 3
                    recnikKojaLabelaKojaVrednost[3] = ukupanDugPoUgovoru
                    labelaOdabranDokumentZaKompenzacijuTri.text = "Ugovor: " + String(nizPoslovanjaSaGazdinstvom[indexPath.row].brojUgovora!) + " iznos: " + String(format: "%.2f", locale: Locale.current, ukupanDugPoUgovoru.doubleValue.roundTo(places: 2)) + " Din"
                    zbirOdabranihDokumenataZaKompenzaciju += ukupanDugPoUgovoru
                } else {
                    PrikaziNeuspesniPopUp(poruka: "Vec si odabrao TRI dokumenta, deselektuj jedan da oslobodis prostor pa se vrati na ovaj koji sad pokusavas da odaberes")
                }
            }
        }
        lablaZbirOdabranihDokumenataZaKompenzaciju.text = "Odabrano: " +  String(format: "%.2f", locale: Locale.current, zbirOdabranihDokumenataZaKompenzaciju.doubleValue.roundTo(places: 2)) + " Din"
        //tabela.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let ocistiLabeluBroj = recnikKojiRedKojaLabela[indexPath.row]
        
        if ocistiLabeluBroj == 1 {
            slajderOdabranDokumentZaKompenzacijuJedan.isHidden = true
            zbirOdabranihDokumenataZaKompenzaciju -= recnikKojaLabelaKojaVrednost[1]!
            labelaOdabranDokumentZaKompenzacijuJedan.text = ""
        } else if ocistiLabeluBroj == 2 {
            slajderOdabranDokumentZaKompenzacijuDva.isHidden = true
            zbirOdabranihDokumenataZaKompenzaciju -= recnikKojaLabelaKojaVrednost[2]!
            labelaOdabranDokumentZaKompenzacijuDva.text = ""
        } else if ocistiLabeluBroj == 3 {
            slajderOdabranDokumentZaKompenzacijuTri.isHidden = true
            zbirOdabranihDokumenataZaKompenzaciju -= recnikKojaLabelaKojaVrednost[3]!
            labelaOdabranDokumentZaKompenzacijuTri.text = ""
        }
        
        selektovaniRovovi.remove(indexPath.row)
        if selektovaniRovovi.count == 0 {
            roSnimiSelektovaneDokumentePodobneZaKompenzaciju.isHidden = true
        }
        recnikKojiRedKojaLabela[indexPath.row] = nil
        lablaZbirOdabranihDokumenataZaKompenzaciju.text = "Odabrano: " + String(format: "%.2f", locale: Locale.current, zbirOdabranihDokumenataZaKompenzaciju.doubleValue.roundTo(places: 2)) + " Din"
        
    }
    
    var vrednostLabeleJedan: Decimal?
    var vrednostLabeleDva: Decimal?
    var vrednostLabeleTri: Decimal?
    
    var recnikKojaLabelaKojaVrednostSaSlajdera: Dictionary = [Int : Decimal]()
    var zbirOdabranihDokumenataZaKompenzacijuSaSlajdera: Decimal?
    func PodesiSlajer(sender: UISlider) {
        tabela.isUserInteractionEnabled = false
        
        zbirOdabranihDokumenataZaKompenzacijuSaSlajdera = (recnikKojaLabelaKojaVrednostSaSlajdera[1] ?? 0) + (recnikKojaLabelaKojaVrednostSaSlajdera[2] ?? 0) + (recnikKojaLabelaKojaVrednostSaSlajdera[3] ?? 0)
        
        
        
        if sender.tag == 1 {
            
            vrednostLabeleJedan = recnikKojaLabelaKojaVrednost[1]
            
            var makisimalnaVrednostSlajdera = (Float((povratniSaldoPodobanZaKompenzaciju! / vrednostLabeleJedan!.doubleValue)))
            
            
            if limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera != nil {
                //print("preuzimam limit iz drugog segmenta")
                makisimalnaVrednostSlajdera = (Float(((povratniSaldoPodobanZaKompenzaciju! - limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera!.doubleValue ) / vrednostLabeleJedan!.doubleValue)))
            }
            
            if makisimalnaVrednostSlajdera > 1 {
                makisimalnaVrednostSlajdera = 1
            }
            
            //print("Maks vred slajdera \(makisimalnaVrednostSlajdera)")
            sender.maximumValue = makisimalnaVrednostSlajdera
            
            recnikKojaLabelaKojaVrednostSaSlajdera[1] = Decimal(Double(sender.value)) * vrednostLabeleJedan!
            labelaPrikazVrednostSaSlajderaJedan.text = String(format: "%.2f", locale: Locale.current, recnikKojaLabelaKojaVrednostSaSlajdera[1]!.doubleValue.roundTo(places: 2)) + " Din"
            
        } else if sender.tag == 2 {
            vrednostLabeleDva = recnikKojaLabelaKojaVrednost[2]
            
            var makisimalnaVrednostSlajdera = (Float((povratniSaldoPodobanZaKompenzaciju! / vrednostLabeleDva!.doubleValue)))
            
            
            if limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera != nil {
                //print("preuzimam limit iz drugog segmenta")
                makisimalnaVrednostSlajdera = (Float(((povratniSaldoPodobanZaKompenzaciju! - limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera!.doubleValue ) / vrednostLabeleDva!.doubleValue)))
            }
            
            if makisimalnaVrednostSlajdera > 1 {
                makisimalnaVrednostSlajdera = 1
            }
            
            //print("Maks vred slajdera \(makisimalnaVrednostSlajdera)")
            sender.maximumValue = makisimalnaVrednostSlajdera
            
            recnikKojaLabelaKojaVrednostSaSlajdera[2] = Decimal(Double(sender.value)) * vrednostLabeleDva!
            labelaPrikazVrednostSaSlajderaDva.text = String(format: "%.2f", locale: Locale.current, recnikKojaLabelaKojaVrednostSaSlajdera[2]!.doubleValue.roundTo(places: 2)) + " Din"
            
        } else if sender.tag == 3 {
            vrednostLabeleTri = recnikKojaLabelaKojaVrednost[3]
            
            var makisimalnaVrednostSlajdera = (Float((povratniSaldoPodobanZaKompenzaciju! / vrednostLabeleTri!.doubleValue)))
            
            
            if limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera != nil {
                //print("preuzimam limit iz drugog segmenta")
                makisimalnaVrednostSlajdera = (Float(((povratniSaldoPodobanZaKompenzaciju! - limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera!.doubleValue ) / vrednostLabeleTri!.doubleValue)))
            }
            
            if makisimalnaVrednostSlajdera > 1 {
                makisimalnaVrednostSlajdera = 1
            }
            
            //print("Maks vred slajdera \(makisimalnaVrednostSlajdera)")
            sender.maximumValue = makisimalnaVrednostSlajdera
            
            recnikKojaLabelaKojaVrednostSaSlajdera[3] = Decimal(Double(sender.value)) * vrednostLabeleTri!
            labelaPrikazVrednostSaSlajderaTri.text = String(format: "%.2f", locale: Locale.current, recnikKojaLabelaKojaVrednostSaSlajdera[3]!.doubleValue.roundTo(places: 2)) + " Din"
            
        }
        
        // opet racunas zbir nakon setovanja slajdera
        zbirOdabranihDokumenataZaKompenzacijuSaSlajdera = (recnikKojaLabelaKojaVrednostSaSlajdera[1] ?? 0) + (recnikKojaLabelaKojaVrednostSaSlajdera[2] ?? 0) + (recnikKojaLabelaKojaVrednostSaSlajdera[3] ?? 0)
        
        
        
        lablaZbirOdabranihDokumenataZaKompenzaciju.text = "Odabrano: " + String(format: "%.2f", locale: Locale.current, zbirOdabranihDokumenataZaKompenzacijuSaSlajdera!.doubleValue.roundTo(places: 2)) + " Din"
        
    }
    
    var limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera: Decimal?
  
    func OsveziLimite() {
        //print("osvezi limit")
        limitZbirOdabranihDokumenataZaKompenzacijuSaSlajdera = zbirOdabranihDokumenataZaKompenzacijuSaSlajdera
    }
    
    func LeviDatumJeKasnijiIliIstiPoredeciSaDesnimDatumom(leviDatum: Date, desniDatum: Date) -> Bool {
        let kakavJeDatum = Calendar.current.compare(leviDatum, to: desniDatum, toGranularity: .day)
        switch kakavJeDatum {
        case .orderedSame:
            return true
        case .orderedDescending:
            return true
        default:
            print("default")
        }
        return false
    }
    
    @IBOutlet weak var roIdiNaOtkupniListBezZaduzivanjaUgovoraIliAvansa: UIButton!
    @IBAction func IdiNaOtkupniListBezZaduzivanjaUgovoraIliAvansa(_ sender: Any) {
        performSegue(withIdentifier: "sg-FinKarGaz->GenOtkList", sender: nil)
    }
    
}


