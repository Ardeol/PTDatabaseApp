package edu.tamu.pt.controllers;

import haxe.ui.toolkit.data.ArrayDataSource;
import haxe.ui.toolkit.events.UIEvent;

import systools.Dialogs;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.io.FileWriter;
import edu.tamu.pt.io.CsvWriter;
import edu.tamu.pt.ui.TextTable;
import edu.tamu.pt.util.Sorters;

/** ListController Class
 *  @author  Timothy Foster
 *  
 *  Shows a list in the form of a table.  This class is meant to be extended.
 *  **************************************************************************/
class ListController extends Controller {
    
    public static inline var EXPORT_EXTENSION = "csv";

/*  Constructor
 *  =========================================================================*/
/**
 *  Constructs a new ListController
 *  @param xmlpath Path to the XML view
 *  @param db Reference to the database
 *  @param tableID The id of the table in the XML view
 *  @param exportID The id of the export button in the XML view
 */
    public function new(xmlpath:String, db:IDatabase, tableID:String, exportID:String) {
        super(xmlpath, db);
        table = getComponentAs(tableID, TextTableComponent);
        attachEvent(exportID, UIEvent.MOUSE_UP, exportAction);
        exporter = new CsvWriter("");
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Builds the table.  Should be overridden.
 */
    public function buildTable():Void {
        clearTable();
    }
    
/**
 *  Exports the contents of the table to a file
 */
    public function export():Void {
        exportAction();
    }

/**
 *  @inheritDoc
 */
    override public function refresh():Void {
        buildTable();
    }
    
/**
 *  @inheritDoc
 */
    override public function close():Void {
        db = null;
    }
 
/*  Private Members
 *  =========================================================================*/
    private var table:TextTable;
    private var exporter:FileWriter<TextTable>;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Clears all entries in the table, including the header
 */
    private inline function clearTable():Void {
        table.clear();
    }
    
/**
 *  @private
 *  Called when the export button is pressed.
 *  @param e
 */
    private function exportAction(?e:UIEvent):Void {
        var location = Dialogs.saveFile("Save Database As", "Save the Database as a JSON file", "", {
            count: 1,
            extensions: ['*.$EXPORT_EXTENSION'],
            descriptions: ['*.$EXPORT_EXTENSION']
        });
        if (location == null || location.length <= 0)
            return;
        
        var patt = new EReg('\\.$EXPORT_EXTENSION$$', "");
        if (!patt.match(location))
            location += '.$EXPORT_EXTENSION';
            
        if (exporter == null) {
            PTDatabaseApp.error("The programmer failed to set the exporter, so a file couldn't be generated.  We're sorry.");
            return;
        }
        
        exporter.path = location;
        exporter.write(table);
    }
 
}