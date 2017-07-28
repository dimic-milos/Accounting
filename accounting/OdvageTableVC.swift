//
//  OdvageTableVC.swift
//  accounting
//
//  Created by Dimic Milos on 5/19/17.
//  Copyright © 2017 kikokiko. All rights reserved.
//

import UIKit


class OdvageTableVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBOutlet weak var labelaDatum: UILabel!
    
    @IBOutlet weak var labelaBrNalogaMDP: UILabel!
    
    @IBOutlet weak var labelaNeto: UILabel!
    
    @IBOutlet weak var iwOdvagaUpotrebljena: UIImageView!
    
    @IBOutlet weak var labelaKojaRoba: UILabel!

    @IBOutlet weak var roSW: UISwitch!
    
    @IBOutlet weak var lbPrimese: UILabel!
    @IBOutlet weak var lbVlaga: UILabel!
}
