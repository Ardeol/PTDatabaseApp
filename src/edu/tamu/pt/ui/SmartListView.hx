package edu.tamu.pt.ui;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.data.ArrayDataSource;

/** SmartListView Class
 *  @author  Timothy Foster
 *
 *  This class has some extra functionality which will help the listview 
 *  remember location and such.
 * 
 *  Example usage:
 *  listview.rememberPos();
 *  listview.clear();
 *  //  Build listview
 *  listview.restorePos();
 *  **************************************************************************/
class SmartListView extends ListView {
/**
 *  The currently remembered value for the vertical scroll position
 */
    public var rememberedVPos(default, null):Float;
    
/**
 *  The currently remembered value for the horizontal scroll position
 */
    public var rememberedHPos(default, null):Float;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  @inheritDoc
 */
    public function new() {
        super();
        this.rememberedVPos = 0;
        this.rememberedHPos = 0;
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Resets the datasource of the list view.  If you have any references to the datasource, they will become invalidated.
 */
    public function clear():Void {
        this.dataSource = new ArrayDataSource();
    }
    
/**
 *  Stores the current vertical scroll position.  You can access this value with rememberedVPos.
 *  @return The vertical scroll position
 */
    public function rememberVPos():Float {
        return this.rememberedVPos = this.vscrollPos;
    }
    
/**
 *  Stores the current horizontal scroll position.  You can access this value with rememberedHPos.
 *  @return The horizontal scroll position
 */
    public function rememberHPos():Float {
        return this.rememberedHPos = this.hscrollPos;
    }
    
/**
 *  Remembers both vertical and horizontal scroll positions.
 */
    public inline function rememberPos():Void {
        rememberVPos();
        rememberHPos();
    }
    
//  A note about the below three functions.  We don't have to check the bottom bound since the rememberedPos variables can never ever be below 0.
    
/**
 *  Sets the vertical scroll position to the remembered value.
 *  @return The new vertical scroll position.
 */
    public function restoreVPos():Float {
        return this.vscrollPos = this.rememberedVPos >= this.vscrollMax ? this.vscrollMax : this.rememberedVPos;
    }
    
/**
 *  Sets the horizontal scroll position to the remembered value.
 *  @return The new horizontal scroll position.
 */
    public function restoreHPos():Float {
        return this.hscrollPos = this.rememberedHPos >= this.hscrollMax ? this.hscrollMax : this.rememberedHPos;
    }
    
/**
 *  Sets both scroll positions to their remembered values.
 */
    public inline function restorePos():Void {
        restoreVPos();
        restoreHPos();
    }
 
}