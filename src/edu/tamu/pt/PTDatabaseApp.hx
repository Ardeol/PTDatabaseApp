package edu.tamu.pt;

import sys.io.File;
import sys.FileSystem;

import openfl.Lib;

import haxe.ui.toolkit.core.ClassManager;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.themes.GradientTheme;

/** PTDatabaseApp Class
 *  @author  Timothy Foster
 *  @version A.00
 * 
 *  The app.
 *  **************************************************************************/
class PTDatabaseApp {
    public static inline var VERSION = "A.00";
    public static inline var AUTHOR = "Timothy Foster (@tfAuroratide)";

/*  Constructor
 *  =========================================================================*/
    public function new() {
        initHaxeUI();
        started = false;
    
    /*
        Lib.application.onExit.add(function(code) {
            trace("EXITING");
        });
    */
    }
    
/*  Class Methods
 *  =========================================================================*/
    public static function error(msg:String):Void {
        PopupManager.instance.showSimple(msg, "Error");
    }
 
/*  Public Methods
 *  =========================================================================*/
    public function start():Void {
        if(!started) {
            started = true;
        /*
             ui = new MainController(database);
            Toolkit.openFullscreen(function(root) {
                root.addChild(ui.view);
            });
        */
        }
    }
    
    public function exit():Void {
        
    }
 
/*  Private Members
 *  =========================================================================*/
    private var started:Bool;
 
/*  Private Methods
 *  =========================================================================*/
    private function initHaxeUI():Void {
        Toolkit.theme = new GradientTheme();
    //  ClassManager.instance.registerComponentClass(SmartTextInput, "smarttextinput");
        Toolkit.init();
        Toolkit.setTransitionForClass(Popup, "none");
    }
}