//
//  AppDelegate.swift
//  accounting
//
//  Created by Dimic Milos on 5/14/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData
var dummyAppDelegate: AppDelegate?

struct JednaFirma {
    var naziv: String
    var mesto: String
    var adresa: String
    var maticniBroj: String
    var tekuciRacun: String
    var pib: String
}
extension JednaFirma {
    init(Osnovno naziv: String, mesto: String, adresa: String, maticniBroj: String, tekuciRacun: String, pib: String) {
        self.naziv = naziv
        self.mesto = mesto
        self.adresa = adresa
        self.maticniBroj = maticniBroj
        self.tekuciRacun = tekuciRacun
        self.pib = pib
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var pzvImeGazdinstva: String?
    var pzvBPG: Int64?
    var pzvAdresa: String?
    var pzvPovratniTekuciRacunGazdinstva: String?
    
    var pzvBruto: Int32?
    var pzvTara: Int32?
    var pzvNeto: Int32?
    var pzvBrNalogaMagDP: [Int32]?
    var pzvKojaRoba: String?
    var pzvOdbitak: Int32?
    var pzvJUS: Int32?
    var pzvPotencijalniDatumPrijema: Date?
    
    var pzvCenaZaKgSaPDV: Double?
    var pzvSwTelKel = false
    
    var pzvUkupnaVrednostOtvorenihAvansa: Decimal?
    var pzvUkupnaVrednostOtvorenihUgovora: Decimal?
    var pzvUkupniSaldoBezObziraNaValutu: Decimal?
    var pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojAvansaVrednost: Dictionary? = [Int: Decimal]()
    var pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednost: Dictionary? = [Int : Decimal]()
    var pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneDocnje: Dictionary? = [Int : Decimal]()
    var pzvPovratniRecnikZaPrenosInformacijaNaOtkupniListBrojUgovoraVrednostKompenzovaneValutneKlauzule: Dictionary? = [Int : Decimal]()
    
    var poslednjiSegvejKojiJePozvaoFiltriranaGazdinstva: String?
    var poslednjiSegvejKojiJePozvaoFinansijskaKarticaGazdinstva: String?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dummyAppDelegate = self
        UpisiInicijalnePodatkeBaze()
        return true
    }
    
    func UpisiInicijalnePodatkeBaze() {
        
        var nizFirmi = [JednaFirma]()
        nizFirmi.append(JednaFirma(Osnovno: "AgroPan", mesto: "Pancevo", adresa: "Vojvode Radomira Putnika 3", maticniBroj: "08185085", tekuciRacun: "160-69764-13", pib: "101049140"))
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entitet = NSEntityDescription.entity(forEntityName: "SviDOO", in: managedContext)
        let zapis = NSManagedObject(entity: entitet!, insertInto: managedContext)
        
        for clan in nizFirmi {
            
            if !ProveravamDaLiUBaziVecImaTaFirma(intMaticniBroj: clan.maticniBroj) {
                zapis.setValue(clan.adresa, forKey: "adresa")
                zapis.setValue(clan.maticniBroj, forKey: "maticniBroj")
                zapis.setValue(clan.mesto, forKey: "mesto")
                zapis.setValue(clan.naziv, forKey: "naziv")
                zapis.setValue(clan.pib, forKey: "pib")
                zapis.setValue(clan.tekuciRacun, forKey: "tekuciRacun")
                do {
                    try managedContext.save()
                    print("U bazu podataka je upisan zapis inicijalizator firme preko hard kodinga\(zapis)")
                    ProveriJebBrojInsertujEvent(jebBroj: Int64(arc4random()), event: "U bazu upisujem inicijalizator firme iz hard kodinga: \(zapis)")
                } catch {
                    print("Ne mogu da upisem novi inicijalizator preko hard kodinga! \(error)")
                }
            }
        }
    }
    
    func ProveravamDaLiUBaziVecImaTaFirma(intMaticniBroj: String) -> Bool {
        var rezultat = false
        
        let filter = intMaticniBroj
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return true
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SviDOO")
        let predicate = NSPredicate(format: "maticniBroj CONTAINS[cd] %@", filter)
        fetchRequest.predicate = predicate
        do {
            let response = try managedContext.fetch(fetchRequest)
            for _ in response {
                //print("naisao sam na firmu sa istim maticnim brojem vec upisanim u bazu")
                rezultat = true
            }
        } catch let error as NSError {
            print("Ne mogu da preuzmem podatak za prikaz svih gazdinstava u tabeli! \(error)")
        }
        return rezultat
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "accounting")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

