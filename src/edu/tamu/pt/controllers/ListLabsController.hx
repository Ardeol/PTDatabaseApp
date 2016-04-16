package edu.tamu.pt.controllers;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.util.Sorters;
import edu.tamu.pt.util.Filters;

/** ListLabsController Class
 *  @author  Timothy Foster
 *  @version x.xx.160303
 *
 *  Constructs a raw list of the labs in the database.
 *  **************************************************************************/
class ListLabsController extends ListController {

/*  Constructor
 *  =========================================================================*/
/**
 *  @inheritDoc
 */
    public function new(db:IDatabase) {
        super("ui/list-labs.xml", db, Id.TABLE, Id.EXPORT_BTN);
        buildTable();
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Builds the table.  Each row has lab's name, schedule, and peer teachers assigned to it.
 */
    override public function buildTable():Void {
        super.buildTable();
        
        var labs = db.labs(Sorters.labOrder);
        
        for (lab in labs) {
            var pts = db.pts(Filters.hasLab.bind(lab), Sorters.alpha);
            table.addRow([lab.toString(), lab.timesString(), pts.join(", ")]);
        }
        
    }

}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "list-labs-container";
    var TABLE = "list-labs-table";
    var EXPORT_BTN = "list-labs-export-btn";
}