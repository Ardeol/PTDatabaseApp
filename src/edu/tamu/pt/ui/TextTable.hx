package edu.tamu.pt.ui;

import haxe.ui.toolkit.containers.ScrollView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.controls.Text;

/** TextTable Class
 *  @author Auroratide
 * 
 *  A basic table whose elements are only text.  This is to be used with the
 *  ListControllers rather than TableView, since TableView is broken.
 *  **************************************************************************/
class TextTable extends ScrollView {
    public var columns(get, never):Int;
    public var rows(get, never):Int;
    public var header(default, null):TextTableRow;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new TextTable
 */
    public function new(?headings:Array<String>) {
        super();
        table = new VBox();
        table.percentWidth = 100;
        table.percentHeight = 100;
        this.addChild(table);
        
        if(headings != null) {
            header = new TextTableRow(headings);
            table.addChild(header);
        }
        else
            header = cast this.getChildAt(0);
        
        tableRows = new Array<TextTableRow>();
    }
    
/*  Class Methods
 *  =========================================================================*/
 
 
/*  Public Methods
 *  =========================================================================*/
    public function addRow(contents:Array<String>):TextTableRow {
        if (contents.length != columns)
            //throw "TextTable addRow given contents with incorrect number of columns";
            trace('ERROR: $columns');
        var r = new TextTableRow(contents);
        table.addChild(r);
        tableRows.push(r);
        return r;
    }
    
    public function row(i:Int):TextTableRow {
        return tableRows[i];
    }
    
    public function remove(row:TextTableRow):Void {
        table.removeChild(row);
        tableRows.remove(row);
    }
    
    public inline function removeAt(i:Int):Void {
        remove(row(i));
    }
    
    public function clear():Void {
        while (rows > 0)
            removeAt(0);
    }
 
/*  Private Members
 *  =========================================================================*/
    private var table:VBox;
    private var tableRows:Array<TextTableRow>;
 
/*  Private Methods
 *  =========================================================================*/
    private function get_columns():Int
        return header.numCells;
    
    private function get_rows():Int
        return tableRows.length;
 
}

abstract TextTableRow(HBox) from HBox to HBox {
    public var numCells(get, never):Int;
    
    public inline function new(contents:Array<String>) {
        this = new HBox();
        this.percentWidth = 100;
        for (s in contents) {
            var text = new Text();
            text.text = s;
            this.addChild(text);
        }
    }
    
    public inline function cell(i:Int):String 
        return textAt(i).text;
    
    public inline function set(i:Int, s:String):Void 
        textAt(i).text = s;
        
    private inline function get_numCells():Int
        return this.numChildren;
    
    private inline function textAt(i:Int):Text 
        return cast(this.getChildAt(i), Text);
}