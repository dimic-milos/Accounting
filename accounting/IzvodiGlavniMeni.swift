//
//  IzvodiGlavniMeni.swift
//  accounting
//
//  Created by Dimic Milos on 5/25/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit

class IzvodiGlavniMeni: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .yellow
        DodajDugmeZaNazad()
        
        tabela.delegate = self
        tabela.dataSource = self
    }
    
    @IBOutlet weak var tabela: UITableView!
    var model = ["Unesi promene sa izvoda"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celija = tableView.dequeueReusableCell(withIdentifier: "prototipCelija", for: indexPath)
        
        celija.textLabel?.text = model[indexPath.row]
        return celija
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "sgDodajPromenuSaIzvoda", sender: nil)
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
        performSegue(withIdentifier: "sgGlavniSaIzvodi", sender: nil)
    }
}
