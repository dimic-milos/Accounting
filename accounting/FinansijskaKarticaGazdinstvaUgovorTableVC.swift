//
//  FinansijskaKarticaGazdinstvaUgovorTableVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/6/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit

class FinansijskaKarticaGazdinstvaUgovorTableVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBOutlet weak var labelaOpisPromenUgovor: UILabel!
    @IBOutlet weak var labelaBrojUgovora: UILabel!
    @IBOutlet weak var labelaNeotplacenaVrednostUgovora: UILabel!
    @IBOutlet weak var labelaIznosValutneNivelacije: UILabel!
    @IBOutlet weak var labelaIznosNivelacijeDocnje: UILabel!
    @IBOutlet weak var labelaUkupnoDugujePoUgovoru: UILabel!

    @IBOutlet weak var labelaDatumPromene: UILabel!
    
    
    @IBOutlet weak var labelaValutaUgovora: UILabel!
    @IBOutlet weak var labelaRobaKojaJeDataNaOdlozeno: UILabel!
    
    @IBOutlet weak var ukupniSaldoKojiJeDospeoPoValuti: UILabel!
    @IBOutlet weak var ukupniSaldoBezObziraNaValutu: UILabel!

}
