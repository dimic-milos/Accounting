//
//  UnosOdvagaOdGazdinstavaVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/19/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//



import UIKit
import CoreData

class UnosOdvagaOdGazdinstavaVC: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProveriKojiJeBrojNalogaMagacinuDaPrimiNaRedu()
        tfBrojNalogaMagDaPrimi.isUserInteractionEnabled = false
        tfBrojNalogaMagDaPrimi.placeholder = "Broj naloga magacinu da primi: " + String(brojPoslednjegNalogaMagacinuDaPrimi + 1)
        pikerRobe.delegate = self
        pikerRobe.dataSource = self
        tfBrojNalogaMagDaPrimi.delegate = self
        roSacuvaj.isUserInteractionEnabled = true
        
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.lightGray
        DodajDugmeZaNazad()
       
        let nizBrutoTf = [tfBruto1, tfBruto2, tfBruto3, tfBruto4, tfBruto5, tfBruto6]
        let nizTaraTf = [tfTara1, tfTara2, tfTara3, tfTara4, tfTara5, tfTara6]
        for clan in nizBrutoTf {
            clan!.addTarget(self, action: #selector(TrenutniPrikazLabelaUkupnoBruto), for: .editingChanged)
            clan!.addTarget(self, action: #selector(OmoguciTaraUnosOnemuguciBrutoUnos), for: .editingDidEnd)
        }
        for clan in nizTaraTf {
            clan!.addTarget(self, action: #selector(TrenutniPrikazLabelaUkupnoTara), for: .editingChanged)
            clan!.addTarget(self, action: #selector(OmoguciUnosVlagePrimesaIOnemoguciIzmenuBrutoTara), for: .editingDidEnd)
            clan!.addTarget(self, action: #selector(TrenutniPrikazJUSKgUkolikoNemaUnetihVlagaPrimesa(sender:)), for: .editingChanged)

        }
        
        let nizVlagaPrimeseTf = [tfVlaga1, tfVlaga2, tfVlaga3, tfVlaga4, tfVlaga5, tfVlaga6,
                        tfPrimese6, tfPrimese5, tfPrimese4, tfPrimese3, tfPrimese3, tfPrimese2, tfPrimese1]
        
        for clan in nizVlagaPrimeseTf {
            clan?.addTarget(self, action: #selector(NapuniLbJUS), for: .editingChanged)
        }
        
    }
    
    func OmoguciTaraUnosOnemuguciBrutoUnos(sender: UITextField) {
        for tfBruto in view.subviews {
            if tfBruto.tag == sender.tag && (tfBruto as! UITextField).text! != "" {
                (tfBruto as! UITextField).isUserInteractionEnabled = false
                (tfBruto as! UITextField).backgroundColor = .green
                
                for tfTara in view.subviews {
                    if tfTara.tag == sender.tag + 6 {
                        (tfTara as! UITextField).isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    func TrenutniPrikazJUSKgUkolikoNemaUnetihVlagaPrimesa(sender: UITextField) {
        let taraPolje = sender.tag
        let brutoPolje = taraPolje - 6
        let JUSpolje = taraPolje + 100_000
        
        var vrednostTaraPolja: Int?
        var vrednostBrutoPolja: Int?
        
        for tfBrutoTara in view.subviews {
            if tfBrutoTara.tag == brutoPolje {
                vrednostBrutoPolja = Int((tfBrutoTara as! UITextField).text!)
            }
            if tfBrutoTara.tag == taraPolje {
                vrednostTaraPolja = Int((tfBrutoTara as! UITextField).text!)
            }
        }
        
        for tfJUS in view.subviews {
            if tfJUS.tag == JUSpolje {
                if vrednostBrutoPolja != nil && vrednostTaraPolja != nil {
                     (tfJUS as! UILabel).text! = String(vrednostBrutoPolja! - vrednostTaraPolja! )
                }
               
            }
        }
        
    }
    
    var ukupniOdbitakKgZbogVlage = 0.0
    var dodatakNaUkupniOdbitakKgZbogVlage = 0.0
    
    var ukupniOdbitakKgZbogPrimesa = 0.0
    var dodatakNaUkupniOdbitakKgZbogPrimesa = 0.0
    
    func NapuniLbJUS(sender: UITextField) {
        dodatakNaUkupniOdbitakKgZbogPrimesa = 0.0
        
        let brutoPolje: Int?
        let taraPolje: Int?
        let vlagaPolje: Int?
        let primesePolje: Int?
        let JUSpolje: Int?
        
        
        if sender.tag >= 10106 && sender.tag <= 10111 {  // u pitanju je polje vlaga
            taraPolje = sender.tag - 10000
            brutoPolje = taraPolje! - 6
            vlagaPolje = sender.tag
            primesePolje = taraPolje! + 1000
            JUSpolje = taraPolje! + 100000
        } else { // u pitanju je polje primese
            taraPolje = sender.tag - 1000
            brutoPolje = taraPolje! - 6
            vlagaPolje = taraPolje! + 10000
            primesePolje = sender.tag
            JUSpolje = taraPolje! + 100000
        }
       
        var vrednostBrutoPolje = Int()
        var vrednostTaraPolje = Int()
        var vrednostPrimesePolje: Double?
        var vrednostVlagaPolje: Double?
        
       
        var odbitakKgZbogPrimesa: Double?
        var odbitakKgZbogVlage: Double?
        
        for tfPolje in view.subviews {
            if tfPolje.tag == brutoPolje! {
                vrednostBrutoPolje = Int((tfPolje as! UITextField).text!)!
            }
            if tfPolje.tag == taraPolje! {
                vrednostTaraPolje = Int((tfPolje as! UITextField).text!)!
            }
            if tfPolje.tag == primesePolje! {
                if let x = (tfPolje as! UITextField).text {
                    if x != "" {
                        vrednostPrimesePolje = Double(x)!
                    } else {
                        vrednostPrimesePolje = JUSnormaRobePrimese[kliknutaRoba]
                    }
                }
            }
            if tfPolje.tag == vlagaPolje! {
                if let x = (tfPolje as! UITextField).text {
                    if x != "" {
                        vrednostVlagaPolje = Double(x)!
                    } else {
                        vrednostVlagaPolje = JUSnormaRobeVlaga[kliknutaRoba]
                    }
                }
            }
            
            let neto = Double(vrednostBrutoPolje - vrednostTaraPolje)

            
            if vrednostPrimesePolje != nil {
                if vrednostPrimesePolje! < JUSnormaRobePrimese[kliknutaRoba] {
                    vrednostPrimesePolje = JUSnormaRobePrimese[kliknutaRoba]
                }
                odbitakKgZbogPrimesa = (neto / 100) * (vrednostPrimesePolje! - JUSnormaRobePrimese[kliknutaRoba])
                dodatakNaUkupniOdbitakKgZbogPrimesa = odbitakKgZbogPrimesa!
             
            }
            
            if vrednostVlagaPolje != nil {
                if vrednostVlagaPolje! < JUSnormaRobeVlaga[kliknutaRoba] {
                    vrednostVlagaPolje = JUSnormaRobeVlaga[kliknutaRoba]
                }
                odbitakKgZbogVlage = (neto / 100) * (vrednostVlagaPolje! - JUSnormaRobeVlaga[kliknutaRoba])
                dodatakNaUkupniOdbitakKgZbogVlage = odbitakKgZbogVlage!
            }
          
            
            if tfPolje.tag == JUSpolje! {
                (tfPolje as! UILabel).text = String(Int(neto - (odbitakKgZbogPrimesa! ) - (odbitakKgZbogVlage ?? 0.0)))
            }
        }
        
        
        var ukupnoJUSkg = 0
        for lbJUSkg in view.subviews {
            if lbJUSkg.tag >= 100_000 {
                if (lbJUSkg as! UILabel).text != "" {
                    ukupnoJUSkg += Int((lbJUSkg as! UILabel).text!)!
                }
            }
        }
        
        lbJUSodbitakKG.text = String(Int(labelaUkupnoNeto.text!)! - ukupnoJUSkg)
        lbJUSukupnoKG.text = String(Int(labelaUkupnoNeto.text!)! - Int(lbJUSodbitakKG.text!)!)
        
        
        let nizPrimeseTf = [tfPrimese6, tfPrimese5, tfPrimese4, tfPrimese3, tfPrimese3, tfPrimese2, tfPrimese1]
        
        if odbitakKgZbogPrimesa != nil {
            for clan in nizPrimeseTf {
                if (clan!).text != "" {
                clan?.addTarget(self, action: #selector(PunimLabeluUkupniOdbitakZbogPrimesa(sender:)), for: .editingDidEnd)
                }
            }
        }
        
        let nizVlagaTf = [tfVlaga1, tfVlaga2, tfVlaga3, tfVlaga4, tfVlaga5, tfVlaga6]
        
        if odbitakKgZbogVlage != nil {
            for clan in nizVlagaTf {
                if (clan!).text != "" {
                    clan?.addTarget(self, action: #selector(PunimLabeluUkupniOdbitakZbogVlage(sender:)), for: .editingDidEnd)
                }
                
            }
        }
    }
    
    var prosecnaPrimesa: Double?
    var netoGdeJeMerenaPrimesa = 0
    var kilazaPutaIzmerenaPrimesa = 0.0
    func PunimLabeluUkupniOdbitakZbogPrimesa(sender: UITextField) {
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = UIColor.yellow
        ukupniOdbitakKgZbogPrimesa = ukupniOdbitakKgZbogPrimesa + dodatakNaUkupniOdbitakKgZbogPrimesa
        lbOdbitakZbogPrimesa.text = String(Int(ukupniOdbitakKgZbogPrimesa))
        
        let tagPoljaZaPrimesu = sender.tag
        let tagPoljaZaTaru = sender.tag - 1000
        let tagPoljaZaBruto = sender.tag - 1006
        
        var vrednostBruto: Int?
        var vrednostTara: Int?
        var vrednostPrimese: Double?
        
        for tf in view.subviews {
            if tf.tag == tagPoljaZaPrimesu {
                vrednostPrimese = Double((tf as! UITextField).text!)
            }
            if tf.tag == tagPoljaZaTaru {
                vrednostTara = Int((tf as! UITextField).text!)
            }
            if tf.tag == tagPoljaZaBruto {
                vrednostBruto = Int((tf as! UITextField).text!)
            }
        }
        if vrednostPrimese != nil {
            netoGdeJeMerenaPrimesa += vrednostBruto! - vrednostTara!
            kilazaPutaIzmerenaPrimesa += (Double((vrednostBruto! - vrednostTara!)) * vrednostPrimese!)
            prosecnaPrimesa = kilazaPutaIzmerenaPrimesa / Double(netoGdeJeMerenaPrimesa)
            lbProsecnePrimese.text = String(prosecnaPrimesa!)

        }
    }
    
    var prosecnaVlaga: Double?
    var netoGdeJeMerenaVlaga = 0
    var kilazaPutaIzmerenaVlaga = 0.0
    func PunimLabeluUkupniOdbitakZbogVlage(sender: UITextField) {
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = UIColor.blue
        ukupniOdbitakKgZbogVlage = ukupniOdbitakKgZbogVlage + dodatakNaUkupniOdbitakKgZbogVlage
        lbOdbitakZbogVlage.text = String(Int(ukupniOdbitakKgZbogVlage))
        
        let tagPoljaZaVlagu = sender.tag
        let tagPoljaZaTaru = sender.tag - 10000
        let tagPoljaZaBruto = sender.tag - 10006
        
        var vrednostBruto: Int?
        var vrednostTara: Int?
        var vrednostVlage: Double?
        
        for tf in view.subviews {
            if tf.tag == tagPoljaZaVlagu {
                vrednostVlage = Double((tf as! UITextField).text!)
            }
            if tf.tag == tagPoljaZaTaru {
                vrednostTara = Int((tf as! UITextField).text!)
            }
            if tf.tag == tagPoljaZaBruto {
                vrednostBruto = Int((tf as! UITextField).text!)
            }
        }
        
        if vrednostVlage != nil {
            netoGdeJeMerenaVlaga += vrednostBruto! - vrednostTara!
            kilazaPutaIzmerenaVlaga += (Double((vrednostBruto! - vrednostTara!)) * vrednostVlage!)
            prosecnaVlaga = kilazaPutaIzmerenaVlaga / Double(netoGdeJeMerenaVlaga)
            lbProsecnaVlaga.text = String(prosecnaVlaga!)
        }
        
    }
    
    
    // ukinuto jer je uvedeno da se automatski dodeljuje broj naloga magacinu da primi
    let maksimalnoKaraktera = 8
    func textField(_ textField: UITextField, shouldChangeCharactersIn upravoIzbrisanoKaraktera: NSRange, replacementString upravoUkucanoKaraktera: String) -> Bool {
        print("cackam nesto po tf func koja regulise maksimalnih 8 karaktera")
        guard let uTfPreModifikacijeImaKaraktera = textField.text else { return true }
        let trenutnoKaraktera = (uTfPreModifikacijeImaKaraktera.characters.count) + upravoUkucanoKaraktera.characters.count - upravoIzbrisanoKaraktera.length
        if trenutnoKaraktera == maksimalnoKaraktera {
            //roSacuvaj.isUserInteractionEnabled = true
        } else {
            //roSacuvaj.isUserInteractionEnabled = false
        }
        return trenutnoKaraktera <= maksimalnoKaraktera
    }
    
    func OmoguciUnosVlagePrimesaIOnemoguciIzmenuBrutoTara(sender: UITextField) {
        for tfBruto in view.subviews {
            if tfBruto.tag == sender.tag - 6 {
                if String(describing: (tfBruto as! UITextField).value(forKey: "text")!) != "" && String(describing: sender.value(forKey: "text")!) != ""  {
                    for tfVlagaPrimese in view.subviews {
                        if tfVlagaPrimese.tag == sender.tag + 1000 || tfVlagaPrimese.tag == sender.tag + 10000 {
                            
                            tfVlagaPrimese.isUserInteractionEnabled = true
                            
                            (tfBruto as! UITextField).isUserInteractionEnabled = false
                            (tfBruto as! UITextField).backgroundColor = UIColor.green
                           
                            sender.isUserInteractionEnabled = false
                            sender.backgroundColor = UIColor.green
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var pikerDatum: UIDatePicker!
    @IBOutlet weak var pikerRobe: UIPickerView!
    
    @IBOutlet weak var tfBrojNalogaMagDaPrimi: UITextField!
    @IBOutlet weak var roSacuvaj: UIButton!
    
    @IBOutlet weak var labelaUkupnoBruto: UILabel!
    @IBOutlet weak var labelaUkupnoTara: UILabel!
    @IBOutlet weak var labelaUkupnoNeto: UILabel!
    

    @IBOutlet weak var tfPrimese1: UITextField!
    @IBOutlet weak var tfPrimese2: UITextField!
    @IBOutlet weak var tfPrimese3: UITextField!
    @IBOutlet weak var tfPrimese4: UITextField!
    @IBOutlet weak var tfPrimese5: UITextField!
    @IBOutlet weak var tfPrimese6: UITextField!
  
    @IBOutlet weak var tfVlaga1: UITextField!
    @IBOutlet weak var tfVlaga2: UITextField!   
    @IBOutlet weak var tfVlaga3: UITextField!
    @IBOutlet weak var tfVlaga4: UITextField!
    @IBOutlet weak var tfVlaga5: UITextField!
    @IBOutlet weak var tfVlaga6: UITextField!

    @IBOutlet weak var lbJUS1: UILabel!
    @IBOutlet weak var lbJUS2: UILabel!
    @IBOutlet weak var lbJUS3: UILabel!
    @IBOutlet weak var lbJUS4: UILabel!
    @IBOutlet weak var lbJUS5: UILabel!
    @IBOutlet weak var lbJUS6: UILabel!
    
    @IBOutlet weak var lbJUSodbitakKG: UILabel!
    @IBOutlet weak var lbJUSukupnoKG: UILabel!
    
    @IBOutlet weak var lbOdbitakZbogVlage: UILabel!
    @IBOutlet weak var lbOdbitakZbogPrimesa: UILabel!
    
    @IBOutlet weak var lbProsecnaVlaga: UILabel!
    @IBOutlet weak var lbProsecnePrimese: UILabel!
    
    
    @IBOutlet weak var tfBruto1: UITextField!; @IBOutlet weak var tfBruto2: UITextField!; @IBOutlet weak var tfBruto3: UITextField!
    @IBOutlet weak var tfBruto4: UITextField!; @IBOutlet weak var tfBruto5: UITextField!; @IBOutlet weak var tfBruto6: UITextField!
    
    @IBOutlet weak var tfTara1: UITextField!; @IBOutlet weak var tfTara2: UITextField!; @IBOutlet weak var tfTara3: UITextField!
    @IBOutlet weak var tfTara4: UITextField!; @IBOutlet weak var tfTara5: UITextField!; @IBOutlet weak var tfTara6: UITextField!
    

    
    var ukupnoBruto = 0
    var ukupnoTara = 0
    
    func TrenutniPrikazLabelaUkupnoBruto(sender: UITextField) {
        // onemuguci promenu robe
        pikerRobe.isUserInteractionEnabled = false
        
        ukupnoBruto = 0
        for view in view.subviews {
            if view.tag >= 100 && view.tag <= 105 {
                let tfView = view as! UITextField
                if String(describing: tfView.value(forKey: "text")!) != "" {
                    ukupnoBruto += Int(String(describing: tfView.value(forKey: "text")!))!
                } else {
                    ukupnoBruto += 0
                }
            }
        }
        labelaUkupnoBruto.text = String(ukupnoBruto)
        labelaUkupnoNeto.text = String(ukupnoBruto - ukupnoTara)
    }
    
    func TrenutniPrikazLabelaUkupnoTara(sender: UITextField) {
        ukupnoTara = 0
        for view in view.subviews {
            if view.tag >= 106 && view.tag <= 111 {
                let tfView = view as! UITextField
                if String(describing: tfView.value(forKey: "text")!) != "" {
                    ukupnoTara += Int(String(describing: tfView.value(forKey: "text")!))!
                } else {
                    ukupnoTara += 0
                }
            }
        }
        labelaUkupnoTara.text = String(ukupnoTara)
        labelaUkupnoNeto.text = String(ukupnoBruto - ukupnoTara)
        lbJUSukupnoKG.text = String(Int(labelaUkupnoNeto.text!)! - (Int(lbJUSodbitakKG.text!) ?? 0)!)
    }
    
    var kliknutaRoba = 0
    let opcijeRobe = ["kukuruz", "psenica", "suncokret"]
    let JUSnormaRobeVlaga = [14.0, 13.0, 9.0]
    let JUSnormaRobePrimese = [2.0, 2.0, 2.0]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return opcijeRobe.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return opcijeRobe[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        kliknutaRoba = row
        print("selektovano je \(opcijeRobe[kliknutaRoba])")
    }
    
    enum Greske: Error {
        case NetoJeNulaIliManjiOdNule
        case BrutoNijeUnet
        case TaraNijeUneta
        case NemaSvakiBrutoSvojNeto
    }
    
    func ProveriDaLiJeUnetMinimumPodataka(ukBruto: Int, ukTara: Int, ukNeto: Int) throws -> Bool {
        var popunjenoBrutoPolja = 0
        var popunjenoTaraPolja = 0
        
        for tfBrutoTara in view.subviews {
            if tfBrutoTara.tag >= 100 && tfBrutoTara.tag <= 105 {
                if (tfBrutoTara as! UITextField).text != "" {
                    popunjenoBrutoPolja += 1
                }
                
            }
            if tfBrutoTara.tag >= 106 && tfBrutoTara.tag <= 111 {
                if (tfBrutoTara as! UITextField).text != "" {
                    popunjenoTaraPolja += 1
                }
            }
        }
        
        
        guard popunjenoBrutoPolja == popunjenoTaraPolja else {
            PrikaziNeuspesniPopUp(poruka: "NemaSvakiBrutoSvojNeto")
            throw Greske.NemaSvakiBrutoSvojNeto
        }

        guard ukNeto > 0 else {
            PrikaziNeuspesniPopUp(poruka: "NetoJeNulaIliManjiOdNule")
            throw Greske.NetoJeNulaIliManjiOdNule
        }
        guard ukBruto > 0 else {
            PrikaziNeuspesniPopUp(poruka: "BrutoNijeUnet")
            throw Greske.BrutoNijeUnet
        }
        guard ukTara > 0 else {
            PrikaziNeuspesniPopUp(poruka: "TaraNijeUneta")
            throw Greske.TaraNijeUneta
        }
        return true
    }
    
    @IBAction func SacuvajUneteOdvage(_ sender: Any) {
        //tfBrojNalogaMagDaPrimi.isUserInteractionEnabled = true
        do {
            let minimumUnosa = try ProveriDaLiJeUnetMinimumPodataka(ukBruto: ukupnoBruto, ukTara: ukupnoTara, ukNeto: ukupnoBruto - ukupnoTara)
            if minimumUnosa {
                UpisiPodatkeUBazu()
            }
        } catch {
            print("Ne mogu da sacuvam odvage jer: \(error)")
        }
    }

    var brojPoslednjegNalogaMagacinuDaPrimi: Int32 = 0
    func ProveriKojiJeBrojNalogaMagacinuDaPrimiNaRedu() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PrijemRobeSaVageOdPG")
        
        do {
            let response = try managedContext.fetch(fetchRequest)

            for podatak in response {
                if podatak.value(forKey: "brojPoslednjegNalogaMagacinuDaPrimi") == nil {
                    brojPoslednjegNalogaMagacinuDaPrimi = 0
                } else {
                    brojPoslednjegNalogaMagacinuDaPrimi = (podatak.value(forKey: "brojPoslednjegNalogaMagacinuDaPrimi") as? Int32)!
                }
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak poslednji broj naloga magacinu da primi! \(error)")
        }
    }
    
    func UpisiPodatkeUBazu() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "PrijemRobeSaVageOdPG", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        zapis.setValue(brojPoslednjegNalogaMagacinuDaPrimi + 1, forKey: "brojPoslednjegNalogaMagacinuDaPrimi")
        zapis.setValue(brojPoslednjegNalogaMagacinuDaPrimi + 1, forKey: "brojNalogaMagacinuDaPrimi")
        zapis.setValue(pikerDatum.date, forKey: "datumPrijema")
        zapis.setValue(opcijeRobe[kliknutaRoba], forKey: "kojaRoba")
        zapis.setValue(false, forKey: "nalogMagacniuDaPrimiUpotrebljen")
        
        zapis.setValue(Int32(ukupnoBruto), forKey: "ukupniBruto")
        zapis.setValue(Int32(ukupnoTara), forKey: "ukupnaTara")
        zapis.setValue(Int32(ukupnoBruto-ukupnoTara), forKey: "ukupnoNeto")
        
        zapis.setValue(prosecnaVlaga, forKey: "prosecnaVlagaNalogaMDP")
        zapis.setValue(prosecnaPrimesa, forKey: "prosecnePrimeseNalogaMDP")
        
        zapis.setValue(Int32(ukupniOdbitakKgZbogVlage), forKey: "odbitakKgZbogVlage")
        zapis.setValue(Int32(ukupniOdbitakKgZbogPrimesa), forKey: "odbitakKgZbogPrimesa")
        zapis.setValue(Int32(ukupniOdbitakKgZbogPrimesa+ukupniOdbitakKgZbogVlage), forKey: "ukupniOdbitakKg")
        zapis.setValue(Int32((ukupnoBruto-ukupnoTara) - Int(ukupniOdbitakKgZbogPrimesa+ukupniOdbitakKgZbogVlage)), forKey: "ukupnoJUSkg")
        
        do {
            try managedContext.save()
            //modal sa opcijom ok da ide na nazad
            print("U bazu podataka je upisana odvaga: \(zapis)")
            ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem odvagu: \(zapis)")
            PrikaziPopUp()
        } catch {
            print("Ne mogu da upisem novu odvagu! \(error)")
        }
    }
    
    func OcistiPoljaZaSledeciUnos() {
        tfBruto1.text = ""; tfBruto2.text = ""; tfBruto3.text = ""; tfBruto4.text = ""; tfBruto5.text = ""; tfBruto6.text = "";
        tfTara1.text = ""; tfTara2.text = ""; tfTara3.text = ""; tfTara4.text = ""; tfTara5.text = ""; tfTara6.text = ""
        
        tfBrojNalogaMagDaPrimi.text = ""
        
        tfVlaga1.text = ""; tfVlaga2.text = ""; tfVlaga3.text = ""; tfVlaga4.text = ""; tfVlaga5.text = ""; tfVlaga6.text = "";
        tfPrimese1.text = ""; tfPrimese2.text = ""; tfPrimese3.text = ""; tfPrimese4.text = ""; tfPrimese5.text = "";
        tfPrimese6.text = "";
        
        for tfLb in view.subviews {
            if tfLb is UITextField {
                (tfLb as! UITextField).text = ""
            }
            if tfLb is UILabel {
                (tfLb as! UILabel).text = ""
            }
        }
    }
    
    func PrikaziPopUp() {
        let popUp = UIAlertController(title: "USPESNO",
            message: "Uspesno ste snimili Nalog Magacina Da Primi sa svim pripadajucim odvagama",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Super",
                                              style: UIAlertActionStyle.default,
                                              handler: {(alert: UIAlertAction!) in
                                                self.performSegue(withIdentifier: "sgGlavniSaUnosOdvagaOdGazdinstava", sender: nil)
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

    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaUnosOdvagaOdGazdinstava", sender: nil)
    }
    
    
}
