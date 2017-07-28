//
//  DOOGlavniMeni.swift
//  accounting
//
//  Created by Dimic Milos on 5/14/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit
import CoreData

class DOOGlavniMeni: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .green
        DodajDugmeZaNazad()
    }
    
    func DodajDugmeZaNazad() {
        let dugmeNazad = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        dugmeNazad.setTitle("Nazad", for: .normal)
        dugmeNazad.backgroundColor = .blue
        dugmeNazad.addTarget(self, action: #selector(IdiNaPocetak), for: .touchUpInside)
        view.addSubview(dugmeNazad)
    }
    
    func IdiNaPocetak(selector: UIButton) {
        performSegue(withIdentifier: "sgGlavniSaDoo", sender: nil)
    }
}
