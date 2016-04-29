package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.MenuEvent;

import systools.Dialogs;

import edu.tamu.pt.PTDatabaseApp;
import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.io.generators.Generator;
import edu.tamu.pt.io.generators.WebPageGenerator;
import edu.tamu.pt.io.generators.PosterGenerator;

/** MainController Class
 *  @author  Timothy Foster
 *
 *  This is the all-encompassing screen.  This controller is mainly 
 *  responsible for the menu actions, though.  The other controllers are
 *  added to this one and handle their own logic.  They never need to talk
 *  to each other.
 * 
 *  This works by only ever having one view up at a time.  Each of the other
 *  controllers has an associated view.  When we want to see one view, we
 *  completely destroy the current one first.  This way, two views never need
 *  to talk to each other since two are never active at once.
 * 
 *  Use the changeView() method in order to change to another controller's
 *  view.
 *  **************************************************************************/
class MainController extends Controller {

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates the main controller
 *  @param app The entire application
 */
    public function new(app:PTDatabaseApp) {
        super("ui/main.xml", app.database);
        this.app = app;
        content = getComponent(Id.CONTENT);
        
        startInitialController();
        
    //  We need to attach the events to each of the menues in the top bar
        attachEvent(Id.FILE, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.FILE_NEW:
                    menuItemNotImplemented();
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
                        app.config.dbpath = location;
                        app.saveConfig();
                        current.refresh();
                    }
                case Id.FILE_SAVE:
                    db.save();
                case Id.FILE_EXPORT:
                    var location = Dialogs.saveFile("Save Database As", "Save the Database as a JSON file", app.directory, {
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
                        app.config.dbpath = location;
                        app.saveConfig();
                    }
                case Id.FILE_EXIT:
                    app.exit();
                default: invalidMenuError();
            }
        });
        
        attachEvent(Id.EDIT, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.EDIT_PTS:  changeView(new EditPTsController(db));
                case Id.EDIT_LABS: changeView(new EditLabsController(db, app.config));
                case Id.EDIT_IMPORT_PTS: 
                    var editController = new EditPTsController(db);
                    changeView(editController);
                    editController.importPTSchedules();
                case Id.EDIT_IMPORT_LABS:
                    var editController = new EditLabsController(db, app.config);
                    changeView(editController);
                    editController.importLabs();
                default:invalidMenuError();
            }
        });
        
        attachEvent(Id.LIST, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.LIST_PTS: changeView(new ListPTsController(db));
                case Id.LIST_LABS: changeView(new ListLabsController(db));
                case Id.LIST_EXPORT_PTS: new ListPTsController(db).export();
                case Id.LIST_EXPORT_LABS: new ListLabsController(db).export();
                default: invalidMenuError();
            }
        });
        
        attachEvent(Id.GENERATE, MenuEvent.SELECT, function(e:MenuEvent) {
            var generator:Generator = null;
            
            switch(e.menuItem.id) {
                case Id.GENERATE_WEBSITE: generator = new WebPageGenerator();
                case Id.GENERATE_POSTER:  generator = new PosterGenerator();
                case Id.GENERATE_BLOCK:   menuItemNotImplemented();
                default: invalidMenuError();
            }
            
            if (generator == null)
                return;
            var location = Dialogs.saveFile("Generate To", "Generate file to", app.directory, {
                count: 1,
                extensions: ['*.${generator.extension}'],
                descriptions: ['*.${generator.extension}']
            });
            if (location == null || location.length <= 0)
                return;
                
            var patt = new EReg('\\.${generator.extension}$$', "");
            if (!patt.match(location))
                location += '.${generator.extension}';
                
            generator.path = location;
            try {
                generator.write(db);
            }
            catch (err:Dynamic) {
                PTDatabaseApp.error("Generation failed for an unknown reason.");
            }
        });
        
        attachEvent(Id.HELP, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.HELP_ABOUT:
                    PopupManager.instance.showSimple("This application was created by " + PTDatabaseApp.AUTHOR + " in 2016 to help make peer teacher management simpler.  Source code is available and may be extended freely at github.com/Ardeol/PTDatabaseApp.\n\nVersion: " + PTDatabaseApp.VERSION, "About", PopupButton.CLOSE);
                default: invalidMenuError();
            }
        });
    }

/*  Public Methods
 *  =========================================================================*/
/**
 *  Changes the current view to the view of a new controller
 *  @param controller The new controller to use
 * 
 *  @usage changeView(new EditPTsController(db));
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
    private inline function startInitialController():Void {
        changeView(new EditPTsController(db));
    }
 
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
    var HELP = "help-menubutton";
    
    var FILE_NEW  = "file-menu-new";
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
    
    var HELP_ABOUT = "help-menu-about";
}