package edu.tamu.pt.ui;

import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.controls.Text;

/** TextTable Class
 *  @author Auroratide
 * 
 *  A basic table whose elements are only text.  This is to be used with the
 *  ListControllers rather than TableView, since TableView is broken.
 *  **************************************************************************/
abstract TextTable(TextTableComponent) from TextTableComponent {
    public var columns(get, never):Int;
    public var rows(get, never):Int;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new TextTable
 */
    public inline function new() {
        this = new TextTableComponent();
    }
    
/*  Public Methods
 *  =========================================================================*/
    public inline function addRow(contents:Array<String>):Void {
        if (contents.length != columns)
            throw 'TextTable addRow given contents with incorrect number of columns (was ${contents.length} but should be $columns)';
        for (s in contents) {
            var t = new Text();
            t.text = s;
            this.addChild(t);
        }
    }
    
    //public inline function row(i:Int):Array<String> {
        
    //}
    
    public inline function removeRow(i:Int):Void {
        if (i < 0 || i >= rows)
            throw 'Row $i does not exist and cannot be removed.';
        for (j in 0...columns)
            this.removeChildAt((i + 1) * columns);
    }
    
    public inline function clear():Void {
        while (rows > 0)
            removeRow(rows - 1);
    }
    
/*  Private Methods
 *  =========================================================================*/
    private inline function get_columns():Int 
        return this.columns;
        
    private inline function get_rows():Int
    return Math.floor(this.numChildren / columns) - 1;
}

class TextTableComponent extends Grid {}