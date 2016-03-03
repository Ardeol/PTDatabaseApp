package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.XMLController;

import edu.tamu.pt.db.IDatabase;

/** MainController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class MainController extends XMLController {

/*  Constructor
 *  =========================================================================*/
    public function new(db:IDatabase) {
        super("ui/main.xml");
        this.db = db;
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
    
 
/*  Private Members
 *  =========================================================================*/
    private var db:IDatabase;
 
/*  Private Methods
 *  =========================================================================*/
    
}