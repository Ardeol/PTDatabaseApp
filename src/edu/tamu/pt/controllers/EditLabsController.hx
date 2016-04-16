package edu.tamu.pt.controllers;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.controls.Button;

import systools.Dialogs;

import edu.tamu.pt.PTDatabaseConfig;
import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.io.LabReader;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.ui.NameSortSelector;
import edu.tamu.pt.ui.SmartListView;
import edu.tamu.pt.ui.renderers.IdComponentItemRenderer;
import edu.tamu.pt.util.Sorters;
import edu.tamu.pt.util.Filters;
import edu.tamu.pt.util.Config;
import edu.tamu.pt.error.Error;

/** EditLabsController Class
 *  @author  Timothy Foster
 *
 *  Allows the user to edit labs.  From this controller, the user may add
 *  peer teachers to labs or import a lab file.  It is much less complicated
 *  than the peer teacher controller since we restrict certain actions like
 *  adding arbitrary classes.  All classes MUST come from the lab file.
 *  **************************************************************************/
class EditLabsController extends Controller {

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new controller instance
 *  @param db The database
 *  @param config The current config file from the application; needed for reading in lab files
 */
    public function new(db:IDatabase, config:PTDatabaseConfig) {
        super("ui/edit-labs.xml", db);
        this.config = config;
        
        this.labListView = getComponentAs(Id.LAB_LIST, SmartListView);
        this.labListView.itemRenderer = IdComponentItemRenderer;
        
        this.labListCache = new Array<ClassSchedule>();
        
        initListView(Id.PTS);
        
        buildLabList();
        
        attachEvent(Id.LAB_LIST, UIEvent.CHANGE, selectLabAction);
        attachEvent(Id.SORTBY, UIEvent.CHANGE, function(e) {
            refreshLabPTs();
        });
        
        attachEvent(Id.PTS, UIEvent.COMPONENT_EVENT, function(e:UIEvent) {
            var actionType = e.component.id.substr(0, PT_ADD_PREFIX.length);
            var pt = e.component.id.substr(PT_ADD_PREFIX.length);
            if (actionType == PT_ADD_PREFIX)
                addPTAction(pt, e);
            else if (actionType == PT_REMOVE_PREFIX)
                removePTAction(pt, e);
            else
                PTDatabaseApp.error("An invalid pt action was attempted");
        });
        
        attachEvent(Id.IMPORT_BTN, UIEvent.MOUSE_UP, importLabsAction);
        attachEvent(Id.CLEAR_BTN, UIEvent.MOUSE_UP, clearLabsAction);
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Constructs the list of labs in the list view
 */
    public function buildLabList():Void {
        labListView.rememberVPos();
        labListView.clear();
        var labs = db.labs(Sorters.labOrder);
        
        for (lab in labs)
            labListView.dataSource.add({ text: lab.toString() });
            
        labListCache = labs;
        labListView.restoreVPos();
    }
    
/**
 *  Mounts a single lab to be manipulated.  All actions will occur on this lab.
 *  @param l
 */
    public function loadLab(l:ClassSchedule):Void {
        db.save();
        currentLab = l;
        refreshLab();
    }
    
/**
 *  Opens up the file dialog for importing a lab file.
 */
    public function importLabs():Void {
        importLabsAction();
    }
    
/**
 *  @inheritDoc
 */
    override public function refresh():Void {
        buildLabList();
        if (currentLab != null)
            currentLab = db.lab(currentLab.toString());
        refreshLab();
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var PT_REMOVE_PREFIX = "rem-pt-"; // This and the following string should be same length!
    private static inline var PT_ADD_PREFIX    = "add-pt-";
 
    private var config:PTDatabaseConfig;
    private var currentLab:ClassSchedule;
    private var labListCache:Array<ClassSchedule>;
    private var labListView:SmartListView;
 
/*  Private Methods
 *  =========================================================================*/
    private function clearLabFields():Void {
        clearLabBasic();
        clearLabPTs();
    }
 
    private function refreshLab():Void {
        refreshLabBasic();
        refreshLabPTs();
    }
    
    private function clearLabBasic():Void {
        getComponent(Id.CLASS).text = "";
        getComponent(Id.LABTIMES).text = "";
    }
    
    private function refreshLabBasic():Void {
        if (currentLab != null) {
            getComponent(Id.CLASS).text = currentLab.toString();
            getComponent(Id.LABTIMES).text = currentLab.timesString();
        }
        else
            clearLabBasic();
    }
    
    private function clearLabPTs():Void {
        getComponent(Id.CUR_PTS).text = "";
        getComponentAs(Id.PTS, SmartListView).clear();
    }
    
    private function refreshLabPTs():Void {
        if (currentLab != null) {
            var currentPTs = db.pts(Filters.hasLab.bind(currentLab));
            getComponent(Id.CUR_PTS).text = "Current: " + currentPTs.join(", ");
            
            var allPTs = db.pts(getComponentAs(Id.SORTBY, NameSortSelector).sorter());
            var listview = getComponentAs(Id.PTS, SmartListView);
            listview.rememberVPos();
            listview.clear();
            
        //  Depending on whether the PT already belongs to the lab, we must display either
        //  an X or +.  If there is an intersection, we do not display the +.
            for (pt in allPTs) {
                var ptLabs = new Array<String>();
                for (lab in pt.labs)
                    ptLabs.push('${lab.code}-${lab.section}');
                
                var ptInfo:Dynamic = {
                    text: pt.toString(),
                    subtext: ptLabs.join(", ")
                };
                
                if (currentPTs.indexOf(pt) >= 0) {
                    ptInfo.componentType = "button";
                    ptInfo.componentValue = "X";
                    ptInfo.componentStyleName = '${PT_REMOVE_PREFIX}btn';
                    ptInfo.componentId = '$PT_REMOVE_PREFIX${pt.toString()}';
                }
                else if (!pt.intersects(currentLab)) {
                    ptInfo.componentType = "button";
                    ptInfo.componentValue = "+";
                    ptInfo.componentStyleName = '${PT_ADD_PREFIX}btn';
                    ptInfo.componentId = '$PT_ADD_PREFIX${pt.toString()}';
                }
                
                listview.dataSource.add(ptInfo);
            }
            listview.restoreVPos();
        }
        else
            clearLabPTs();
    }
    
    private function selectLabsFile(?msg = "Select lab file to import"):String {
        var a = Dialogs.openFile("Import Labs", msg, {
            count: 1,
            extensions: ["*.txt"],
            descriptions: ["*.txt"]
        });
        if (a == null)
            return null;
        return a.length > 0 ? a[0] : null;
    }
    
    private function readLabs(filename:String):Map<String, ClassSchedule> {
        return new LabReader(filename, config.relevantClasses.split(",")).read();
    }
    
    private function includeNonLabClasses(labs:Map<String, ClassSchedule>):Map<String, ClassSchedule> {
    /*
     *  For classes with no labs, we add sectionless labs.
     */
        var nonlabs = config.nonlabClasses.split(",");
        for (nonlab in nonlabs) {
            var c = new ClassSchedule("CSCE", nonlab, "");
            labs.set(c.toString(), c);
        }
        return labs;
    }
    
/*  UI Actions
 *  =========================================================================*/
/**
 *  @private
 *  Event for selecting a lab from the lab list
 */
    private function selectLabAction(?e:UIEvent):Void {
        loadLab(labListCache[labListView.selectedIndex]);
    }
    
    private function addPTAction(ptName:String, ?e:UIEvent):Void {
        if (currentLab == null)
            PTDatabaseApp.error("Cannot add PT.  No lab loaded yet.");
        else {
            var pt = db.pt(ptName);
            if (pt == null)
                PTDatabaseApp.error('PT $ptName does not exist and cannot be added to the lab.');
            else if (pt.intersects(currentLab))
            //  shouldn't occur
                PTDatabaseApp.error('$ptName\'s schedule conflicts with the current lab and cannot be added.');
            else {
                pt.labs.set(currentLab.toString(), currentLab);
                refreshLabPTs();
            }
        }
    }
    
    private function removePTAction(ptName:String, ?e:UIEvent):Void {
        if (currentLab == null)
            PTDatabaseApp.error("Cannot remove PT.  No lab loaded yet.");
        else {
            var pt = db.pt(ptName);
            if (pt == null)
                PTDatabaseApp.error('PT $ptName does not exist and cannot be removed from the lab.');
            else if (!pt.labs.exists(currentLab.toString()))
                PTDatabaseApp.error('Cannot remove $ptName from lab.  The PT was never assigned to it.');
            else {
                pt.labs.remove(currentLab.toString());
                refreshLabPTs();
            }
        }
    }
    
    private function importLabsAction(?e:UIEvent):Void {
    /*
     *  This action must reassign all labs to the current peer teachers.  Since we are utterly replacing labs, the
     *  peer teachers' lab assignments will be messed up.  Therefore, we need to provide the user the option to
     *  cancel the operation, along with provide a warning.  This function automatically will fix problems that
     *  arise, theoretically.
     */
        PopupManager.instance.showSimple("This will update the current labs.  If you wish to reset the labs entirely, clear the labs first.  Continuing with this action will attempt to keep current peer teacher lab assignments.  If conflicts arise, they will be REMOVED automatically.  Do you wish to continue?", "Warning!", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK:
                    var filename = selectLabsFile();
                    if (filename == null || filename.length <= 0)
                        return;
                    
                //  Read in file
                    var labs:Map<String, ClassSchedule> = null;
                    try {  labs = readLabs(filename); }
                    catch (err:Error) {
                        PTDatabaseApp.error(err.message);
                        return;
                    }
                    catch (err:Dynamic) {  return; }
                    if (labs == null)
                        return;
                        
                    labs = includeNonLabClasses(labs);
                    
                //  Labs read in correctly; now remember lab assignments
                    var pts = db.pts();
                    var ptLabs = new Map<PeerTeacher, Array<String>>();
                    for (pt in pts) {
                        ptLabs.set(pt, new Array<String>());
                        for (l in pt.labs.keys())
                            ptLabs.get(pt).push(l);
                    }
                    
                    db.clearLabs();
                    for (lab in labs)
                        db.addLab(lab);
                    
                //  Reassigns the labs the PT had previously
                    for (pt in ptLabs.keys()) {
                        for (labStr in ptLabs.get(pt)) {
                            var lab = db.lab(labStr);
                            if (lab != null && !pt.intersects(lab))
                                pt.labs.set(labStr, lab);
                        }
                    }
                    
                    buildLabList();
                    currentLab = null;
                    refreshLab();
                        
                case PopupButton.CANCEL:
                default:
            }
        });
    }
    
    private function clearLabsAction(?e:UIEvent):Void {
        PopupManager.instance.showSimple("Are you sure you want to clear all labs?", "Clear Labs", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK:
                    db.clearLabs();
                    buildLabList();
                    currentLab = null;
                    refreshLab();
                case PopupButton.CANCEL:
                default:
            }
        });
    }
}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "edit-labs-container";
    var FORM = "edit-labs-form";
    var CLASS = "edit-labs-class";
    var LABTIMES = "edit-labs-labs";
    var CUR_PTS = "edit-labs-current-pts";
    var SORTBY = "edit-labs-sortby";
    var PTS = "edit-labs-pt-list";
    var LAB_LIST = "edit-labs-lab-list";
    var IMPORT_BTN = "edit-labs-import-btn";
    var CLEAR_BTN = "edit-labs-clear-btn";
}