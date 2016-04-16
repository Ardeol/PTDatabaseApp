package edu.tamu.pt;

import sys.io.File;
import sys.FileSystem;

import openfl.Lib;
import openfl.Assets;
import openfl.events.MouseEvent;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.ClassManager;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.themes.GradientTheme;

import edu.tamu.pt.controllers.MainController;
import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.ui.CustomUIRegistrar;
import edu.tamu.pt.ui.themes.CustomThemesRegistrar;
import edu.tamu.pt.ui.themes.SimplySimpleSimplicityTheme;
import edu.tamu.pt.util.Config;

/** PTDatabaseApp Class
 *  @author  Timothy Foster
 *  @version A.00
 * 
 *  The app.
 *  **************************************************************************/
class PTDatabaseApp {
    public static inline var VERSION = "A.00";
    public static inline var AUTHOR = "Timothy Foster (@tfAuroratide)";
    
    public var config(default, null):PTDatabaseConfig;
    public var database(default, null):IDatabase;
    public var directory(get, never):String;

/*  Constructor
 *  =========================================================================*/
    public function new() {
        databaseLoadErrorFlag = false;
    
        initHaxeUI();
        initConfig();
        initDatabase();
        started = false;
    
        setExitHandler();
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
        
            ui = new MainController(this);
            Toolkit.openFullscreen(function(root) {
                root.addChild(ui.view);
            });
            
            if (databaseLoadErrorFlag)
                error(database.error());
                
            Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, function(e) {
                error("Right Click does not work in this application. Use Ctrl+C for copy or Ctrl+V for paste (use Command instead of Ctrl for Mac).");
            });
        }
    }
    
    public function saveConfig():Void {
        var file = File.write(CONFIG_PATH);
        file.writeString(config.toString());
        file.close();
    }
    
    public function exit():Void {
        database.save();
        saveConfig();
      #if openfl_legacy
        Lib.close();
      #else
        Sys.exit(0);
      #end
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var CONFIG_PATH = "data/config.ini";
 
    private var started:Bool;
    private var ui:MainController;
    
/**
 *  This flag is used to indicate whether the database load failed.
 *  If it did, we need to display an error upon start.
 */
    private var databaseLoadErrorFlag:Bool;
 
/*  Private Methods
 *  =========================================================================*/
    private function get_directory():String {
        var finalSlashIndex = config.dbpath.lastIndexOf("/");
        if (finalSlashIndex < 0)
            finalSlashIndex = config.dbpath.lastIndexOf("\\");
        var initialDirectory = "";
        if (finalSlashIndex >= 0)
            initialDirectory = config.dbpath.substring(0, finalSlashIndex);
        return initialDirectory;
    }
 
    private function initHaxeUI():Void {
        CustomThemesRegistrar.registerAll();
    //  Toolkit.theme = new SimplySimpleSimplicityTheme();
        Toolkit.theme = new GradientTheme();
        CustomUIRegistrar.registerAll();
        Toolkit.init();
        Toolkit.setTransitionForClass(Popup, "none");
    }
    
    private function initConfig():Void {
        config = new PTDatabaseConfig();
        try {
            config.parse(Assets.getText(CONFIG_PATH));
        }
        catch (e:Dynamic) {}
        saveConfig();
    }
    
    private function initDatabase():Void {
        database = new DatabaseType();
        if (!database.load(config.dbpath)) {
        //  This means there was no file in the file given by the config
        //  Our strategy is to test the default path, and if that fails, create an empty database
        //  If that fails, well, it ain't pretty.
            config.dbpath = PTDatabaseConfig.DBPATH_DEFAULT;
            if (!database.load(config.dbpath))
                databaseLoadErrorFlag = !database.save(config.dbpath);
        }
    }
    
    private function setExitHandler():Void {
      #if openfl_legacy
        Lib.current.stage.onQuit = exit;
      #else
        Lib.current.stage.application.onExit.add(function(code) {
            exit();
        });
      #end
    }
}

typedef DatabaseType = edu.tamu.pt.db.JsonDatabase