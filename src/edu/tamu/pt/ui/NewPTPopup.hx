package edu.tamu.pt.ui;

import haxe.ui.toolkit.core.XMLController;

import edu.tamu.pt.ui.SmartTextInput;

/** NewPTPopup Class
 *  @author  Timothy Foster
 *
 *  Formats the popup that appears when creating a new peer teacher from
 *  scratch.
 *  **************************************************************************/
class NewPTPopup extends XMLController {
    public static inline var FIRSTNAME = "new-pt-firstname";
    public static inline var LASTNAME  = "new-pt-lastname";
    
    public var firstname(get, never):String;
    public var lastname(get, never):String;

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new popup
 */
    public function new() {
        super("ui/popups/new-pt.xml");
        
        getComponentAs(FIRSTNAME, SmartTextInput).nextTextInput = getComponentAs(LASTNAME, SmartTextInput);
    }
 
/*  Private Methods
 *  =========================================================================*/
    private function get_firstname():String 
        return getComponent(FIRSTNAME).text;
    
    private function get_lastname():String 
        return getComponent(LASTNAME).text;
}