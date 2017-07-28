//
//  GazdinstvoPreuzimaRobuPoUgovoruTableVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/5/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit

class GazdinstvoPreuzimaRobuPoUgovoruTableVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBOutlet weak var labelaRobaKojaSeDajeNaKooperaciju: UILabel!
    @IBOutlet weak var labelaNacinRazduzenja: UILabel!
    @IBOutlet weak var labelaNacelnaVrednostUgovora: UILabel!
    @IBOutlet weak var labelaRealizovanaVrednostUgovora: UILabel!
    @IBOutlet weak var labelaDogovorenaKolicina: UILabel!
    @IBOutlet weak var labelaBrojUgovora: UILabel!
    @IBOutlet weak var labelaPreuzeoDoSada: UILabel!
    @IBOutlet weak var labelaPreostajeDaPreuzme: UILabel!

    
}
