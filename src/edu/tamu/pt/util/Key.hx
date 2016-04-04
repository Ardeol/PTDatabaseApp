package edu.tamu.pt.util;

import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;

/** Key Class
 *  @author Auroratide
 * 
 *  
 *  **************************************************************************/
class Key {

/*  Constructor
 *  =========================================================================*/
    public static function initialize():Void {
        if (!initialized) {
            keymap = new Map<Int, Bool>();
            Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, setKey);
            Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, removeKey);
            initialized = true;
        }
    }
    
/*  Class Methods
 *  =========================================================================*/
    public static function isDown(keyCode:Int):Bool {
        return keymap.exists(keyCode);
    }
    
    public static function keysDown():Array<Int> {
        var a = new Array<Int>();
        for (k in keymap.keys())
            a.push(k);
        return a;
    }
 
/*  Private Members
 *  =========================================================================*/
    private static var initialized:Bool = false;
    private static var keymap:Map<Int, Bool>;
 
/*  Private Methods
 *  =========================================================================*/
    private static function setKey(e:KeyboardEvent):Void {
        keymap.set(e.keyCode, true);
    }
    
    private static function removeKey(e:KeyboardEvent):Void {
        keymap.remove(e.keyCode);
    }
 
}