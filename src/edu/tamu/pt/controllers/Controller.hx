package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.XMLController;

import edu.tamu.pt.db.IDatabase;

/** Controller Class
 *  @author  Timothy Foster
 *  @version x.xx.160303
 * 
 *  General Controller that all other controllers should extend.  It includes
 *  a consistent reference to the database.
 *  **************************************************************************/
class Controller extends XMLController {

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new Controller.
 *  @param xmlpath XML path which renders the view.
 *  @param db Reference to the database.
 */
    public function new(xmlpath:String, db:IDatabase) {
        super(xmlpath);
        this.db = db;
    }
 
/*  Private Members
 *  =========================================================================*/
    private var db:IDatabase; // for peoples in the future, in Haxe, private is actually protected
    
}