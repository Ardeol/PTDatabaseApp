package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.events.MenuEvent;

import edu.tamu.pt.db.IDatabase;

/** MainController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class MainController extends Controller {

/*  Constructor
 *  =========================================================================*/
    public function new(db:IDatabase) {
        super("ui/main.xml", db);
        content = getComponent(Id.CONTENT);
        
    //  Initial Controller Here
        changeView(new EditPTsController(db));
        
        attachEvent(Id.FILE, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.FILE_LOAD: menuItemNotImplemented();
                case Id.FILE_SAVE: db.save();
                case Id.FILE_EXPORT: menuItemNotImplemented();
                case Id.FILE_EXIT: menuItemNotImplemented();
                default: invalidMenuError();
            }
        });
        
        attachEvent(Id.EDIT, MenuEvent.SELECT, function(e:MenuEvent) {
            switch(e.menuItem.id) {
                case Id.EDIT_PTS: changeView(new EditPTsController(db));
                case Id.EDIT_LABS: menuItemNotImplemented();
                case Id.EDIT_IMPORT_PTS: menuItemNotImplemented();
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