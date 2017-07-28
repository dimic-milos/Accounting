//
//  FinansijskaKarticaGazdinstvaAvansTableVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/6/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit

class FinansijskaKarticaGazdinstvaAvansTableVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var labelaOpisPromeneAvans: UILabel!
    @IBOutlet weak var labelaBanka: UILabel!
    @IBOutlet weak var labelaIzvod: UILabel!
    @IBOutlet weak var labelaOdlivIznos: UILabel!
    @IBOutlet weak var labelaKompenzovano: UILabel!
    @IBOutlet weak var labelaOstajeOtvoreno: UILabel!
    @IBOutlet weak var labelaValuta: UILabel!

    @IBOutlet weak var labelaDatumPromene: UILabel!
    
    @IBOutlet weak var ukupniSaldoKojiJeDospeoPoValuti: UILabel!
    @IBOutlet weak var ukupniSaldoBezObziraNaValutu: UILabel!

    @IBOutlet weak var progresAvansa: UIProgressView!
}
