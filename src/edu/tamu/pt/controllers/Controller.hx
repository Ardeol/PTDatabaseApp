package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.data.ArrayDataSource;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.ui.renderers.IdComponentItemRenderer;

/** Controller Class
 *  @author  Timothy Foster
 *  @version x.xx.160305
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
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Adequately closes the controller.  Call any time the controller needs to change.
 */
    public function close():Void {
        db.save();
        db = null;
    }
    
/**
 *  Reloads the entire view, or at least the parts that are relevant
 */
    public function refresh():Void {}

/*  Private Members
 *  =========================================================================*/
    private var db:IDatabase; // for peoples in the future, in Haxe, private is actually protected
    
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Initializes a ListView with general shared properties.  This essentially allows the view to render components and be unselectable.
 *  @param id ID of the ListView given in the XML file
 *  @return The ListView object found with id
 */
    private function initListView(id:String):ListView {
        var listview = getComponentAs(id, ListView);
        listview.itemRenderer = IdComponentItemRenderer;
        listview.allowSelection = false;
        return listview;
    }
    
    private inline function refreshListView(lv:ListView):Void {
        lv.dataSource = new ArrayDataSource();
    }
}