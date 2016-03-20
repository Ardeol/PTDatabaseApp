package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.events.MenuEvent;

import systools.Dialogs;

import edu.tamu.pt.PTDatabaseApp;
import edu.tamu.pt.db.IDatabase;

/** MainController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class MainController extends Controller {

/*  Constructor
 *  =========================================================================*/
    public function new(app:PTDatabaseApp) {
        super("ui/main.xml", app.database);
        this.app = app;
        content = getComponent(Id.CONTENT);
        
    //  Initial Controller Here
        changeView(new EditPTsController(db));
        
        attachEvent(Id.FILE, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.FILE_LOAD: 
                    var locations = Dialogs.openFile("Load Database", "Load a database file", {
                        count: 1,
                        extensions: ["*.json"],
                        descriptions: ["*.json"]
                    });
                    if (locations == null || locations.length <= 0)
                        return;
                    
                    var location = locations[0];
                    
                    if (!db.load(location))
                        PTDatabaseApp.error("Database could not be loaded.  " + db.error());
                    else {
                        app.config.section("").set(PTDatabaseApp.CONFIG_DBPATH, location);
                        app.saveConfig();
                        current.refresh();
                    }
                case Id.FILE_SAVE:
                    db.save();
                case Id.FILE_EXPORT:
                //  @TODO The initialDirectory code doesn't work
                    var finalSlashIndex = app.config.get(PTDatabaseApp.CONFIG_DBPATH).lastIndexOf("/");
                    if (finalSlashIndex < 0)
                        app.config.get(PTDatabaseApp.CONFIG_DBPATH).lastIndexOf("\\");
                    var initialDirectory = "";
                    if (finalSlashIndex >= 0)
                        initialDirectory = app.config.get(PTDatabaseApp.CONFIG_DBPATH).substring(0, finalSlashIndex);
                    
                    var location = Dialogs.saveFile("Save Database As", "Save the Database as a JSON file", initialDirectory, {
                        count: 1,
                        extensions: ["*.json"],
                        descriptions: ["*.json"]
                    });
                    
                    if (location == null || location.length <= 0)
                        return;
                        
                    if (!~/\.json$/.match(location))
                        location += ".json";

                    if (!db.save(location))
                        PTDatabaseApp.error("Could not save database to location.  " + db.error());
                    else {
                        app.config.section("").set(PTDatabaseApp.CONFIG_DBPATH, location);
                        app.saveConfig();
                    }
                case Id.FILE_EXIT:
                    app.exit();
                default: invalidMenuError();
            }
        });
        
        attachEvent(Id.EDIT, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.EDIT_PTS: changeView(new EditPTsController(db));
                case Id.EDIT_LABS: menuItemNotImplemented();
                case Id.EDIT_IMPORT_PTS: 
                    var editController = new EditPTsController(db);
                    changeView(editController);
                    editController.importPTSchedules();
                case Id.EDIT_IMPORT_LABS: menuItemNotImplemented();
                default:invalidMenuError();
            }
        });
        
        attachEvent(Id.LIST, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.LIST_PTS: changeView(new ListPTsController(db));
                case Id.LIST_LABS: changeView(new ListLabsController(db));
                case Id.LIST_EXPORT_PTS: menuItemNotImplemented();
                case Id.LIST_EXPORT_LABS: menuItemNotImplemented();
                default: invalidMenuError();
            }
        });
        
        attachEvent(Id.GENERATE, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.GENERATE_WEBSITE: menuItemNotImplemented();
                case Id.GENERATE_POSTER: menuItemNotImplemented();
                case Id.GENERATE_BLOCK: menuItemNotImplemented();
                default: invalidMenuError();
            }
        });
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Changes the current view to the view of a new controller
 *  @param controller The new controller to use
 */
    public function changeView(controller:Controller):Void {
        if(current != null) {
            current.close();
            content.removeChild(current.view);
        }
        current = controller;
        content.addChild(current.view);
    }
 
/*  Private Members
 *  =========================================================================*/
    private var content:Component;
    private var current:Controller;
    private var app:PTDatabaseApp;
 
/*  Private Methods
 *  =========================================================================*/
    private inline function invalidMenuError():Void {
        PTDatabaseApp.error("Invalid menu option selected.");
    }
    
/**
 *  @TMP
 */
    private inline function menuItemNotImplemented():Void {
        PTDatabaseApp.error("This item is not yet implemented.");
    }
}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "master-container";
    var CONTENT = "content-container";
    var TOP_BAR = "top-bar";
    var FILE = "file-menubutton";
    var EDIT = "edit-menubutton";
    var LIST = "list-menubutton";
    var GENERATE = "generate-menubutton";
    
    var FILE_LOAD = "file-menu-load";
    var FILE_SAVE = "file-menu-save";
    var FILE_EXPORT = "file-menu-export";
    var FILE_EXIT = "file-menu-exit";
    
    var EDIT_PTS = "edit-menu-pts";
    var EDIT_LABS = "edit-menu-labs";
    var EDIT_IMPORT_PTS = "edit-menu-import-pts";
    var EDIT_IMPORT_LABS = "edit-menu-import-labs";
    
    var LIST_PTS = "list-menu-pts";
    var LIST_LABS = "list-menu-labs";
    var LIST_EXPORT_PTS = "list-menu-export-pts";
    var LIST_EXPORT_LABS = "list-menu-export-labs";
    
    var GENERATE_WEBSITE = "generate-menu-website";
    var GENERATE_POSTER = "generate-menu-poster";
    var GENERATE_BLOCK = "generate-menu-block";
}