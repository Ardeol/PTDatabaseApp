package edu.tamu.pt.controllers;

import haxe.ui.toolkit.containers.TableView;
import haxe.ui.toolkit.controls.selection.ListSelector;
import haxe.ui.toolkit.events.UIEvent;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.ui.NameSortSelector;
import edu.tamu.pt.util.Sorters;

/** ListPTsController Class
 *  @author  Timothy Foster
 *  @version x.xx.160303
 *  
 *  Constructs a raw list of the peer teachers in the database.
 *  **************************************************************************/
class ListPTsController extends ListController {

/*  Constructor
 *  =========================================================================*/
/**
 *  @inheritDoc
 */
    public function new(db:IDatabase) {
        super("ui/list-pts.xml", db, Id.TABLE);
        this.sortby = getComponentAs(Id.SORTBY, NameSortSelector);
        
        attachEvent(Id.SORTBY, UIEvent.CHANGE, function(e) {  buildTable(); });
        
        buildTable();
    }
    
/*  Public Methods
 *  =========================================================================*/
/**
 *  Builds the table.  Each row has the PT's name, labs, and office hours.
 */
    override public function buildTable():Void {
        super.buildTable();
        
        var pts = db.pts(sortby.sorter());
        
    /*  TableView Version 
        for (pt in pts) {
            var labs = new Array<String>();
            var reg = ~/[a-zA-Z]*-(\d*-\d*)/;
            for (lab in pt.labs) {
                if (reg.match(lab.toString()))
                    labs.push(reg.matched(1));
            }
            
            table.dataSource.add({
                "colA": pt.firstname,
                "colB": pt.lastname,
                "colC": labs.join(", "),
                "colD": pt.officeHours.join("; ")
            });
        }
    /*  */
    
    /*  TextTable version */
        for (pt in pts) {
            var labs = new Array<String>();
            var reg = ~/[a-zA-Z]*-(\d*-\d*)/;
            for (lab in pt.labs) {
                if (reg.match(lab.toString()))
                    labs.push(reg.matched(1));
            }
            
            table.addRow([pt.firstname, pt.lastname, labs.join(", "), pt.officeHours.join("; ")]);
        }
    /*  */
    }
    
/*  Private Members
 *  =========================================================================*/
    private var sortby:NameSortSelector;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @inheritDoc
 */
    override private function buildHeader():Void {
    /*  TableView 
        table.dataSource.add({
            "colA": "Name",
            "colB": "",
            "colC": "Labs",
            "colD": "Office Hours"
        });
    /*  */
    }
 
}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "list-pts-container";
    var TABLE = "list-pts-table";
    var SORTBY = "list-pts-sortby";
}