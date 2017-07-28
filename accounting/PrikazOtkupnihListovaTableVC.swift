//
//  PrikazOtkupnihListovaTableVC.swift
//  accounting
//
//  Created by Dimic Milos on 6/16/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit

class PrikazOtkupnihListovaTableVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var labelaBrojOtkupnogLista: UILabel!
    @IBOutlet weak var labelaDatumIzradeOtkupnogLista: UILabel!
    @IBOutlet weak var labelaRobaKojaJeOtkupljena: UILabel!
    @IBOutlet weak var labelaJus: UILabel!
    @IBOutlet weak var labelaZaUplatuPGu: UILabel!
    @IBOutlet weak var labelaVrednostPDV: UILabel!
    @IBOutlet weak var labelaUkupnoSkinutoSaUgovora: UILabel!
    @IBOutlet weak var labelaPdvJeUplacen: UILabel!
    @IBOutlet weak var labelaZaUplatuPGuJeUplaceno: UILabel!

    
    @IBOutlet weak var labelaKnjizenoUplateNaOvajOtkupniList: UILabel!
    
    @IBOutlet weak var roProgres: UIProgressView!
    

}
