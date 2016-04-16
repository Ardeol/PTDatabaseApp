package edu.tamu.pt.controllers;

import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.core.renderers.ComponentItemRenderer;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.data.ArrayDataSource;
import haxe.ui.toolkit.events.UIEvent;

import systools.Dialogs;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.error.Error;
import edu.tamu.pt.io.StudentScheduleReader;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.ui.NameSortSelector;
import edu.tamu.pt.ui.AmPmSelector;
import edu.tamu.pt.ui.NewPTPopup;
import edu.tamu.pt.ui.SmartListView;
import edu.tamu.pt.ui.SmartTextInput;
import edu.tamu.pt.ui.renderers.IdComponentItemRenderer;
import edu.tamu.pt.util.Filters;
import edu.tamu.pt.util.Sorters;

/** EditPTsController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class EditPTsController extends Controller {

/*  Constructor
 *  =========================================================================*/
    public function new(db:IDatabase) {
        super("ui/edit-pts.xml", db);
        
        this.ptList = getComponentAs(Id.PT_LIST, SmartListView);
        ptList.itemRenderer = IdComponentItemRenderer;
        
        initListView(Id.LABS);
        initListView(Id.OFFICE_HOURS);
        initListView(Id.SCHEDULE);
        
        this.ptListCache = new Array<PeerTeacher>();
        buildPTList();
        
        var pn = getComponentAs(Id.PREFERREDNAME, SmartTextInput);
        var em = getComponentAs(Id.EMAIL, SmartTextInput);
        var im = getComponentAs(Id.IMAGE, SmartTextInput);
        pn.nextTextInput = em;
        em.nextTextInput = im;
        
        var ohd = getComponentAs(Id.OFFICE_HOURS_ADD_DAYS, SmartTextInput);
        var ohs = getComponentAs(Id.OFFICE_HOURS_ADD_START, SmartTextInput);
        var ohe = getComponentAs(Id.OFFICE_HOURS_ADD_END, SmartTextInput);
        ohd.nextTextInput = ohs;
        ohs.nextTextInput = ohe;
        
        attachEvent(Id.SORTBY, UIEvent.CHANGE, function(e) {
            buildPTList();
        });
        
        attachEvent(Id.PT_LIST, UIEvent.CHANGE, selectPTAction);
        attachEvent(Id.ADD_PT_BTN, UIEvent.MOUSE_UP, addPTAction);
        attachEvent(Id.PT_LIST, UIEvent.COMPONENT_EVENT, function(e:UIEvent) {
            removePTAction(e.component.id.substr(PT_REMOVE_PREFIX.length), e);
        });
        
        attachEvent(Id.PREFERREDNAME, UIEvent.CHANGE, updatePTBasicInfo);
        attachEvent(Id.EMAIL, UIEvent.CHANGE, updatePTBasicInfo);
        attachEvent(Id.IMAGE, UIEvent.CHANGE, updatePTBasicInfo);
        
        attachEvent(Id.OFFICE_HOUR_BTN, UIEvent.MOUSE_UP, addOfficeHoursAction);
        attachEvent(Id.OFFICE_HOURS, UIEvent.COMPONENT_EVENT, function(e:UIEvent) {
            removeOfficeHoursIndex(Std.parseInt(e.component.id.substr(OFFICE_HOUR_REMOVE_PREFIX.length)), e);
        });
        
        attachEvent(Id.LABS, UIEvent.COMPONENT_EVENT, function(e:UIEvent) {
            var actionType = e.component.id.substr(0, LAB_ADD_PREFIX.length);
            var lab = e.component.id.substr(LAB_ADD_PREFIX.length);
            if (actionType == LAB_ADD_PREFIX)
                addLabAction(lab, e);
            else if (actionType == LAB_REMOVE_PREFIX)
                removeLabAction(lab, e);
            else
                PTDatabaseApp.error("An invalid lab action was attempted.");
        });
        
        attachEvent(Id.SCHEDULE_BTN, UIEvent.MOUSE_UP, updateSinglePTScheduleAction);
        attachEvent(Id.SCHEDULE_CLEAR, UIEvent.MOUSE_UP, clearScheduleAction);
        
        attachEvent(Id.IMPORT_BULK_BTN, UIEvent.MOUSE_UP, importBulkSchedulesAction);
        attachEvent(Id.CLEAR_ALL_BTN, UIEvent.MOUSE_UP, clearAllPTsAction);
    }
    
/*  Public Methods
 *  ==========================================================================*/
/**
 *  Refreshes the list of peer teachers.
 */
    public function buildPTList():Void {
        ptList.rememberVPos();
        ptList.clear();
        var pts = db.pts(getComponentAs(Id.SORTBY, NameSortSelector).sorter());
        
        for (pt in pts) {
            ptList.dataSource.add({
                text: pt.toString(),
                componentType: "button",
                componentValue: "X",
                componentId: '$PT_REMOVE_PREFIX${pt.firstname} ${pt.lastname}'
            });
        }
        
        this.ptListCache = pts;
        ptList.restoreVPos();
    }
    
/**
 *  Loads the specified peer teacher.
 *  @param pt
 */
    public function loadPT(pt:PeerTeacher):Void {
        db.save();
        currentPT = pt;
        refreshPT();
    }
    
/**
 *  Opens up the dialog for importing multiple peer teachers
 */
    public function importPTSchedules():Void {
        importBulkSchedulesAction();
    }
    
/**
 *  @inheritDoc
 */
    override public function refresh():Void {
        buildPTList();
        if(currentPT != null)
            currentPT = db.pt(currentPT.toString());
        refreshPT();
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var PT_REMOVE_PREFIX = "remove-";
    private static inline var OFFICE_HOUR_REMOVE_PREFIX = "remove-oh-";
    private static inline var LAB_ADD_PREFIX    = "add-lab-"; // It is extremely convenient to have this and the remove version be the same length
    private static inline var LAB_REMOVE_PREFIX = "rem-lab-"; // if these change, make sure the are same length
    
/**
 *  @private
 *  The currently selected peer teacher.  All changes will be made on this PT.
 */
    private var currentPT:PeerTeacher;
    
/**
 *  @private
 *  Contains the list of most recently loaded peer teachers from the database.  In general, if access to the pt list is needed, use this.
 */
    private var ptListCache:Array<PeerTeacher>;
    
/**
 *  @private
 *  The actual ListView of the list of PTs; sorry for the terrible variable name...
 */
    private var ptList:SmartListView;
 
/*  Private Methods
 *  =========================================================================*/
    private function clearPTFields():Void {
        clearPTBasic();
        clearPTLabs();
        clearPTOfficeHours();
        clearPTSchedule();
    }
 
    private function refreshPT():Void {
        refreshPTBasic();
        refreshPTLabs();
        refreshPTOfficeHours();
        refreshPTSchedule();
    }
    
    private function clearPTBasic():Void {
        getComponent(Id.FIRSTNAME).text = "";
        getComponent(Id.LASTNAME).text = "";
        getComponent(Id.PREFERREDNAME).text = "";
        getComponent(Id.EMAIL).text = "";
        getComponent(Id.IMAGE).text = "";
    }
    
    private function refreshPTBasic():Void {
        if (currentPT != null) {
            getComponent(Id.FIRSTNAME).text = currentPT.firstname;
            getComponent(Id.LASTNAME).text = currentPT.lastname;
            getComponent(Id.PREFERREDNAME).text = currentPT.preferredname;
            getComponent(Id.EMAIL).text = currentPT.email;
            getComponent(Id.IMAGE).text = currentPT.image;
        }
        else
            clearPTBasic();
    }
    
    private function clearPTLabs():Void {
        getComponent(Id.CUR_LABS).text = "";
        getComponentAs(Id.LABS, SmartListView).clear();
    }
    
    private function refreshPTLabs():Void {
        if (currentPT != null) {
            var curLabs = getComponent(Id.CUR_LABS);
            curLabs.text = "Current: ";
            for (lab in currentPT.labs)
                curLabs.text += '${lab.code}-${lab.section}, '; // @TODO make prettier (ie. no trailing ,)
            
            var allLabs = db.labs(Sorters.labOrder);
            var listview = getComponentAs(Id.LABS, SmartListView);
            listview.rememberVPos();
            listview.clear();
            
            for (lab in allLabs) {
                var labinfo:Dynamic = {
                    text: lab.toString(),
                    subtext: lab.timesString()
                };
                
                if (currentPT.labs.exists(lab.toString())) {
                    labinfo.componentType = "button";
                    labinfo.componentValue = "X";
                    labinfo.componentStyleName = '${LAB_REMOVE_PREFIX}btn';
                    labinfo.componentId = '$LAB_REMOVE_PREFIX${lab.toString()}';
                }
                else if (!currentPT.intersects(lab)) {
                    labinfo.componentType = "button";
                    labinfo.componentValue = "+";
                    labinfo.componentStyleName = '${LAB_ADD_PREFIX}btn';
                    labinfo.componentId = '$LAB_ADD_PREFIX${lab.toString()}';
                }
                
                listview.dataSource.add(labinfo);
                listview.restoreVPos();
            }
        }
        else
            clearPTLabs();
    }
    
    private function clearPTOfficeHours():Void {
        getComponentAs(Id.OFFICE_HOURS, SmartListView).clear();
    }
    
    private function refreshPTOfficeHours():Void {
        if (currentPT != null) {
            getComponent(Id.OFFICE_HOURS_ADD_DAYS).text = "";
            getComponent(Id.OFFICE_HOURS_ADD_START).text = "";
            getComponentAs(Id.OFFICE_HOURS_ADD_START_AMPM, AmPmSelector).ampm = "pm";
            getComponent(Id.OFFICE_HOURS_ADD_END).text = "";
            getComponentAs(Id.OFFICE_HOURS_ADD_END_AMPM, AmPmSelector).ampm = "pm";
            
            var listview = getComponentAs(Id.OFFICE_HOURS, SmartListView);
            listview.clear();
            var i = 0;
            for (oh in currentPT.officeHours) {
                listview.dataSource.add({
                    text: oh.toString(),
                    componentType: "button",
                    componentValue: "X",
                    componentId: '$OFFICE_HOUR_REMOVE_PREFIX$i'
                });
                ++i;
            }
        }
        else
            clearPTOfficeHours();
    }
    
    private function clearPTSchedule():Void {
        getComponentAs(Id.SCHEDULE, SmartListView).clear();
    }
    
    private function refreshPTSchedule():Void {
        if (currentPT != null) {
            var listview = getComponentAs(Id.SCHEDULE, SmartListView);
            listview.clear();
            for (cls in currentPT.schedule) {
                listview.dataSource.add({
                    text: cls.toString(),
                    subtext: cls.timesString()
                });
            }
        }
        else
            clearPTSchedule();
    }
    
    private inline function selectPTScheduleFiles(?msg = "Select peer teacher schedule files to import"):Array<String> {
        return Dialogs.openFile("Import Schedules", msg, {
            count: 1,
            extensions: ["*.txt"],
            descriptions: ["*.txt"]
        });
    }
    
/*  UI Actions
 *  =========================================================================*/
/**
 *  @private
 *  Event for selecting a peer teacher from the peer teacher list
 */
    private function selectPTAction(?e:UIEvent):Void {
        loadPT(ptListCache[ptList.selectedIndex]);
    }
    
/**
 *  @private
 *  Event for creating a new peer teacher
 */
    private function addPTAction(?e:UIEvent):Void {
        var p = new NewPTPopup();
    //  We use a pop up to determine the information of the PT that needs to be added
    //  This is because a blank PT should never be added; all PTs must have a first/last name
        PopupManager.instance.showCustom(p.view, "Add a Peer Teacher", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK: 
                    var f = p.firstname;
                    var l = p.lastname;
                    if (f.length == 0 || l.length == 0)
                        PTDatabaseApp.error("You must provide both a first and last name when creating a Peer Teacher.");
                    else if (db.pt('$f $l') != null)
                        PTDatabaseApp.error('Peer Teacher with name $f $l already exists and hence cannot be created.');
                    else {
                        var newpt = new PeerTeacher(f, l);
                        db.addPT(newpt);
                        buildPTList();
                        loadPT(newpt);
                        PopupManager.instance.showSimple('Peer teacher $f $l has been successfully added!', "Success");
                    }
                case PopupButton.CANCEL: // nothing happens
                default:
                    PTDatabaseApp.error("Invalid event detected in Add Peer Teacher Dialog.");
            }
        });
    }
    
/**
 *  @private
 *  Event for removing a specific peer teacher.  To attach this, you can bind it to the peer teacher in question.
 *  @param name FIRSTNAME LASTNAME
 */
    private function removePTAction(name:String, ?e:UIEvent):Void {
        PopupManager.instance.showSimple('Are you sure you want to remove $name from the database?', "Remove a Peer Teacher", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK:
                    var pt = db.pt(name);
                    if (pt != null) {
                    //  We need to ensure the removed PT is not the currently selected one, otherwise editing a non-existent PT becomes possible
                        var wasCurrent = pt == currentPT;
                        db.removePT(pt);
                        buildPTList();
                        if (wasCurrent) {
                            currentPT = null;
                            clearPTFields();
                        }
                        db.save();
                        PopupManager.instance.showSimple('Peer teacher $name has been successfully removed!', "Success");
                    }
                    else
                        PTDatabaseApp.error('Attempted to remove non-existent PT $name.  This PT does not exist and therefore cannot be removed.');
                case PopupButton.CANCEL:
                default: PTDatabaseApp.error("Invalid event detected in Remove Peer Teacher Dialog");
            }
        });
    }
    
/**
 *  @private
 *  Updates the current PT's basic info (preferred name, email, and image).
 */
    private function updatePTBasicInfo(?e:UIEvent):Void {
        if(currentPT != null) {
            currentPT.preferredname = getComponent(Id.PREFERREDNAME).text;
            currentPT.email = getComponent(Id.EMAIL).text;
            currentPT.image = getComponent(Id.IMAGE).text;
        }
    }
    
/**
 *  @private
 *  Attempts to add office hours in the office hours field to the current peer teacher.
 *  Errors if PT not loaded, format is bad, or a conflict arises.
 */
    private function addOfficeHoursAction(?e:UIEvent):Void {
        if (currentPT == null)
            PTDatabaseApp.error("Office hours cannot be added.  No PT is selected yet.");
        else {
            var days = getComponent(Id.OFFICE_HOURS_ADD_DAYS).text;
            var start = getComponent(Id.OFFICE_HOURS_ADD_START).text;
            var startm = getComponentAs(Id.OFFICE_HOURS_ADD_START_AMPM, AmPmSelector).ampm;
            var end = getComponent(Id.OFFICE_HOURS_ADD_END).text;
            var endm = getComponentAs(Id.OFFICE_HOURS_ADD_END_AMPM, AmPmSelector).ampm;
            var raw = '$days $start $startm - $end $endm';
            
            try {
                var appt = new Appointment(raw);
                if (!currentPT.intersects(appt)) {
                    currentPT.officeHours.push(appt);
                    refreshPTOfficeHours();
                    refreshPTLabs();
                }
                else {
                //  There is a conflict somewhere
                    PTDatabaseApp.error("This PT's current schedule or assignments conflict with the proposed office hours.  The office hours cannot be added.");
                }
            }
            catch (err:Dynamic) {
            //  Format is bad
                PTDatabaseApp.error("Cannot add office hours due to improper formatting.  The first field represents the days, formatted as, for instance, \"MWF\", \"TR\", \"Su\", and so on.  The other two fields are times, and they must include both hours and minutes (eg. \"10:00\", not \"10\").");
            }
        }
    }
    
/**
 *  @private
 *  Event for removing office hours from the current peer teacher.
 *  @param index The index of the office hours to remove
 */
    private function removeOfficeHoursIndex(index:Int, ?e:UIEvent):Void {
        if (currentPT == null) 
            PTDatabaseApp.error("Office hours cannot be removed.  No PT is selected yet.");
        else if (index < 0 || index >= currentPT.officeHours.length)
            PTDatabaseApp.error("Office hours cannot be removed.  Invalid office hours were selected.");
        else {
            var appt = currentPT.officeHours[index];
            currentPT.officeHours.remove(appt);
            refreshPTOfficeHours();
            refreshPTLabs();
            getComponent(Id.OFFICE_HOURS_ADD_DAYS).text = appt.daysString();
            var r = ~/(\d?\d:\d\d)\s*([ap]m)?\s*-\s*(\d?\d:\d\d)\s*([ap]m)/;
            if (r.match(appt.timesString())) {
                getComponent(Id.OFFICE_HOURS_ADD_START).text = r.matched(1);
                getComponentAs(Id.OFFICE_HOURS_ADD_START_AMPM, AmPmSelector).ampm = r.matched(2) == null ? r.matched(4) : r.matched(2);
                getComponent(Id.OFFICE_HOURS_ADD_END).text = r.matched(3);
                getComponentAs(Id.OFFICE_HOURS_ADD_END_AMPM, AmPmSelector).ampm = r.matched(4);
            }
        }
    }
    
/**
 *  @private
 *  Event for adding a lab to the current peer teacher
 *  @param labStr The lab code to add; should be in the database
 */
    private function addLabAction(labStr:String, ?e:UIEvent):Void {
        if (currentPT == null)
            PTDatabaseApp.error("Cannot add lab.  No PT is selected yet.");
        else {
            var lab = db.lab(labStr);
            if (lab == null)
                PTDatabaseApp.error('Lab $labStr does not exist and cannot be added to PT.');
            else if (currentPT.intersects(lab))
            //  Honestly this shouldn't occur, but we'll catch it anyways
                PTDatabaseApp.error('Lab $labStr conflicts with current PT\'s schedule and cannot be added.');
            else {
                currentPT.labs.set(lab.toString(), lab);
                refreshPTLabs();
            }
        }
    }
    
/**
 *  @private
 *  Event for removing a lab from the current peer teacher
 *  @param labStr The lab code to remove
 */
    private function removeLabAction(labStr:String, ?e:UIEvent):Void {
        if (currentPT == null)
            PTDatabaseApp.error("Cannot remove lab.  No PT is selected yet.");
        else if (!currentPT.labs.exists(labStr))
            PTDatabaseApp.error("Cannot remove lab.  The PT is not assigned to this lab.");
        else {
            currentPT.labs.remove(labStr);
            refreshPTLabs();
        }
    }
    
/**
 *  @private
 *  Reads a peer teacher from the given file.
 *  @param filename Path to the file
 *  @return A Peer Teacher with a name and schedule
 *  @throws Error if there is a problem with the file or parsing
 */
    private function readPT(filename:String):PeerTeacher {
        return new StudentScheduleReader(filename).read();
    }
    
/**
 *  @private
 *  Event for importing many schedules at once
 */
    private function importBulkSchedulesAction(?e:UIEvent):Void {
    //  First we need to warn the user about the potential issues.
    //  Namely, new PTs will be created as needed, and schedules will be overriden.  Conflicts will be removed.
        PopupManager.instance.showSimple("New peer teachers will be created if they do not already exist.  Furthermore, existing schedules will be replaced and conflicts will be resolved.  When resolving conflicts, CURRENT LAB ASSIGNMENTS AND OFFICE HOURS MAY BE REMOVED.  Are you sure?", "Warning!", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK:
                    var filenames = selectPTScheduleFiles();
                    if (filenames == null || filenames.length <= 0)
                        return;
                        
                    var allPTs:Array<PeerTeacher> = db.pts();
                //  The map will make things a little faster
                    var ptmap = new Map<String, PeerTeacher>();
                    for (p in allPTs)
                        ptmap.set(p.toString(), p);
                        
                //  Scan all the selected files
                    for (filename in filenames) {
                        var pt:PeerTeacher = null;
                        
                        try {  pt = readPT(filename); }
                        catch (err:Error) {
                            PTDatabaseApp.error(err.message);
                            continue;
                        }
                        catch (err:Dynamic) {  continue; }
                        
                        if (pt == null)
                            continue;
                        else if (!ptmap.exists(pt.toString())) {
                            db.addPT(pt);
                        //  Add to map, in case there are two files with the same name
                            ptmap.set(pt.toString(), pt);
                        }
                        else 
                            replaceSchedule(ptmap.get(pt.toString()), pt.schedule);
                    }
                    
                    buildPTList();
                    refreshPT();
                case PopupButton.CANCEL:
                default:
            }
        });
    }
    
/**
 *  Simply replaces the peer teacher's schedule in a safe manner.  Conflicts are resolved simultaneously.
 *  Does not refresh the screen.
 *  @param pt
 *  @param schedule
 */
    private function replaceSchedule(pt:PeerTeacher, schedule:Array<ClassSchedule>):Void {
        for (cls in schedule)
            pt.removeConflictsWith(cls);
        pt.replaceSchedule(schedule);
    }
    
/**
 *  Also safely replaces the peer teacher's schedule, but will include a warning if conflicts exist.
 *  The warning details exactly what the conflicts are.  Refreshes the screen.
 *  @param pt
 *  @param schedule
 */
    private function replaceScheduleWithWarning(pt:PeerTeacher, schedule:Array<ClassSchedule>):Void {
    //  First we need to find if there are conflicts
    //  If there are, we must popup the problem and specify what is wrong
        var labConflicts = new Array<ClassSchedule>();
        var ohConflicts  = new Array<Appointment>();
        for (cls in schedule) {
        //  the for loops ensure no duplicates arise
            for (l in pt.findConflictingLabs(cls))
                if (labConflicts.indexOf(l) < 0)
                    labConflicts.push(l);
            for (oh in pt.findConflictingOfficeHours(cls))
                if (ohConflicts.indexOf(oh) < 0)
                    ohConflicts.push(oh);
        }
        
        if (labConflicts.length <= 0 && ohConflicts.length <= 0) {
            replaceSchedule(pt, schedule);
            refreshPT();
        }
        else {
            var message = "The new schedule conflicts with ";
            if (labConflicts.length > 0)
                message += 'current lab assignments (${labConflicts.join(", ")}) ';
            if (ohConflicts.length > 0) {
                if (labConflicts.length > 0)
                    message += "and ";
                message += 'current office hours (${ohConflicts.join("; ")})';
            }
            message += ".  If you continue, these conflicts will be removed.  Do you wish to continue?";
            PopupManager.instance.showSimple(message, "Continue?", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
                switch(btn) {
                    case PopupButton.OK:
                        replaceSchedule(pt, schedule);
                        refreshPT();
                    case PopupButton.CANCEL:
                    default:
                }
            });
        }
    }
    
/**
 *  @private
 *  Event for updating the current PT's schedule
 *  @param e
 */
    private function updateSinglePTScheduleAction(?e:UIEvent):Void {
        if (currentPT == null)
            PTDatabaseApp.error("No PT is selected yet.");
        else {
            var filenames = selectPTScheduleFiles();
            if (filenames == null || filenames.length <= 0) // no file selected
                return;
            
            var filename = filenames[0];
            
        //  Read in the file
            var pt:PeerTeacher = null;
            var importErrorMessage = "The file could not be imported.";
            try {  pt = readPT(filename); }
            catch (err:Error) {
                PTDatabaseApp.error('$importErrorMessage  ${err.message}');
                return;
            }
            catch (err:Dynamic) {
                PTDatabaseApp.error(importErrorMessage);
                return;
            }
            if (pt == null) {
                PTDatabaseApp.error("The file could not be imported.");
                return;
            }
            
        //  Some sanity checks.  First, we need to make sure the name matches the current PT.
        //  Otherwise, we might be importing the wrong schedule.  Let's make a pop up to alert the user of this.
            if (currentPT.firstname != pt.firstname || currentPT.lastname != pt.lastname) {
                PopupManager.instance.showSimple('The name on the imported file (${pt.toString()}) does not match the name of the currently loaded peer teacher (${currentPT.toString()}).  If you continue, you may be overriding the incorrect PT\'s schedule.  Continue anyways?', "Warning!", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
                    switch(btn) {
                        case PopupButton.OK:
                            replaceScheduleWithWarning(currentPT, pt.schedule);
                        case PopupButton.CANCEL:
                        default:
                    }
                });
            }
            else
                replaceScheduleWithWarning(currentPT, pt.schedule);
        }
    }
    
/**
 *  Event for clearing the schedule of the current peer teacher
 *  @param e
 */
    private function clearScheduleAction(?e:UIEvent):Void {
        if (currentPT == null)
            PTDatabaseApp.error("Cannot clear schedule since no PT is loaded.");
        else {
        //  We need to make sure this is what the user wants to do, so we make a popup
            PopupManager.instance.showSimple('Are you sure you want to clear the schedule for ${currentPT.toString()}?', "Clear Schedule", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
                switch(btn) {
                    case PopupButton.OK:
                        currentPT.clearSchedule();
                        refreshPTLabs();
                        refreshPTSchedule();
                    case PopupButton.CANCEL:
                    default:
                }
            });
        }
    }
    
    private function clearAllPTsAction(?e:UIEvent):Void {
        PopupManager.instance.showSimple("Are you sure?  This action is irreversible.", "Clear Peer Teachers", [PopupButton.OK, PopupButton.CANCEL], function(btn) {
            switch(btn) {
                case PopupButton.OK:
                    currentPT = null;
                    db.clearPts();
                    buildPTList();
                    refreshPT();
                case PopupButton.CANCEL:
                default:
            }
        });
    }
}

@:enum private abstract Id(String) from String to String {
    var CONTAINER = "edit-pts-container";
    var FORM = "edit-pts-form";
    var FIRSTNAME = "edit-pts-firstname";
    var LASTNAME = "edit-pts-lastname";
    var PREFERREDNAME = "edit-pts-preferredname";
    var EMAIL = "edit-pts-email";
    var IMAGE = "edit-pts-image";
    var CUR_LABS = "edit-pts-current-labs";
    var LABS = "edit-pts-lab-list";
    var OFFICE_HOURS = "edit-pts-office-hour-list";
    var OFFICE_HOURS_ADD_DAYS = "edit-pts-add-office-hours-days";
    var OFFICE_HOURS_ADD_START = "edit-pts-add-office-hours-start";
    var OFFICE_HOURS_ADD_START_AMPM = "edit-pts-add-office-hours-start-ampm";
    var OFFICE_HOURS_ADD_END = "edit-pts-add-office-hours-end";
    var OFFICE_HOURS_ADD_END_AMPM = "edit-pts-add-office-hours-end-ampm";
    var OFFICE_HOUR_BTN = "edit-pts-add-office-hours-btn";
    var SCHEDULE = "edit-pts-schedule";
    var SCHEDULE_BTN = "edit-pts-upload-schedule";
    var SCHEDULE_CLEAR = "edit-pts-clear-schedule";
    var SORTBY = "edit-pts-sortby";
    var PT_LIST = "edit-pts-pt-list";
    var ADD_PT_BTN = "edit-pts-add-pt-btn";
    var IMPORT_BULK_BTN = "edit-pts-import-bulk-btn";
    var CLEAR_ALL_BTN = "edit-pts-clear-btn";
}