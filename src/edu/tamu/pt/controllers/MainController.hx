package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.Component;

import edu.tamu.pt.db.IDatabase;

/** MainController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class MainController extends Controller {

/*  Constructor
 *  =========================================================================*/
    public function new(db:IDatabase) {
        super("ui/main.xml", db);
        content = getComponent(Id.CONTENT);
        
        content.addChild(new EditPTsController(db).view);
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
    
 
/*  Private Members
 *  =========================================================================*/
    private var content:Component;
 
/*  Private Methods
 *  =========================================================================*/
    
}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "master-container";
    var CONTENT = "content-container";
}