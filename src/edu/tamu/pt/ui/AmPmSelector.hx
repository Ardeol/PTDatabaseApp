package edu.tamu.pt.ui;

import haxe.ui.toolkit.controls.selection.ListSelector;

import edu.tamu.pt.error.Error;

/** AmPmSelector Class
 *  @author  Timothy Foster
 *
 *  Pre-build selector for am/pm.
 *  **************************************************************************/
class AmPmSelector extends ListSelector {
    public var ampm(get, set):String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new AmPmSelector element.
 */
    public function new() {
        super();
        this.text = "am/pm";
        this.dataSource.add({ text: "am" });
        this.dataSource.add({ text: "pm" });
        
        this.selectedIndex = 1;
    }
 
/*  Private Methods
 *  =========================================================================*/
    private function get_ampm():String {
        return this.selectedIndex == 0 ? "am" : "pm";
    }
    
    private function set_ampm(value:String):String {
        value = value.toLowerCase();
        if (value == "am")
            this.selectedIndex = 0;
        else if (value == "pm")
            this.selectedIndex = 1;
        else
            throw new Error("Can only be set to either am or pm");
        return value;
    }

}