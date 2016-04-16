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
        var i = 0;
        for (s in contents) {
            var cell = new TextTableCell(s, header(i++).percentWidth);
            if (rows % 2 == 1)
                cell.alternate = true;
            this.addChild(cell);
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
        return cellComponent(r, c).text;
    }
    
/**
 *  Removes the ith row
 *  @param i
 */
    public inline function removeRow(i:Int):Void {
        if (i < 0 || i >= rows)
            throw 'Row $i does not exist and cannot be removed.';
        unsafeRemoveRow(i);
        for (j in i...rows)
            alternateRow(j);
    }
    
/**
 *  Removes all rows in the table except the header.
 */
    public inline function clear():Void {
        while (rows > 0)
            unsafeRemoveRow(rows - 1);
    }
    
/*  Private Methods
 *  =========================================================================*/
    private inline function get_columns():Int 
        return this.columns;
        
    private inline function get_rows():Int
        return Math.floor(this.numChildren / columns) - 1;
        
    private inline function header(c:Int):TextTableHeadComponent
        return cast(this.getChildAt(c), TextTableHeadComponent);
        
    private inline function cellComponent(r:Int, c:Int):TextTableCell
        return cast(this.getChildAt((r + 1) * columns + c), TextTableCell);
        
    private inline function unsafeRemoveRow(i:Int):Void {
        for (j in 0...columns)
            this.removeChildAt((i + 1) * columns);
    }
    
    private inline function alternateRow(r:Int):Void {
        for (i in 0...columns) {
            var cell = cellComponent(r, i);
            cell.alternate = !cell.alternate;
        }
    }
}

private abstract TextTableCell(TextTableCellComponent) from TextTableCellComponent to TextTableCellComponent {
    public var text(get, set):String;
    public var alternate(get, set):Bool;
    
    public inline function new(?txt:String = "", ?headerPercentWidth:Float = 0.0) {
        this = new TextTableCellComponent();
        this.percentWidth = headerPercentWidth;
        var t = new Text();
        t.percentWidth = 100;
        t.text = txt;
        this.addChild(t);
    }
    
    private var component(get, never):Text;
    private inline function get_component():Text 
        return cast(this.getChildAt(0), Text);
    
    private inline function get_text():String 
        return component.text;
    private inline function set_text(value:String):String 
        return component.text = value;
        
    private inline function get_alternate():Bool
        return this.styleName == "alternate";
    private inline function set_alternate(value:Bool):Bool {
        if (value)
            this.styleName = "alternate";
        else
            this.styleName = "";
        return value;
    }
    
}

class TextTableComponent extends Grid {}
class TextTableCellComponent extends VBox {}
class TextTableHeadComponent extends TextTableCellComponent {}