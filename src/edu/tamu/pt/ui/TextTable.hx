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
/**
 *  Adds a row to the table given an array of strings.  Each string will go into one column.
 *  @param contents One string per column.  The length must match the number of columns in the table.
 */
    public inline function addRow(contents:Array<String>):Void {
        if (contents.length != columns)
            throw 'TextTable addRow given contents with incorrect number of columns (was ${contents.length} but should be $columns)';
        for (s in contents) {
            var t = new Text();
            t.text = s;
            this.addChild(t);
        }
    }
    
/**
 *  Returns the text at the given cell
 *  @param r row
 *  @param c column
 *  @return
 */
    public inline function cell(r:Int, c:Int):String {
        if (r < 0 || r >= rows || c < 0 || c >= columns)
            throw '($r, $c) is an invalid location in table of size ($rows, $columns)';
        return cast(this.getChildAt((r + 1) * columns + c), Text).text;
    }
    
/**
 *  Removes the ith row
 *  @param i
 */
    public inline function removeRow(i:Int):Void {
        if (i < 0 || i >= rows)
            throw 'Row $i does not exist and cannot be removed.';
        for (j in 0...columns)
            this.removeChildAt((i + 1) * columns);
    }
    
/**
 *  Removes all rows in the table except the header.
 */
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