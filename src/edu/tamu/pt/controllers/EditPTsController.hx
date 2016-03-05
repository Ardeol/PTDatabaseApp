package edu.tamu.pt.controllers;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.core.renderers.ComponentItemRenderer;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.data.ArrayDataSource;
import haxe.ui.toolkit.events.UIEvent;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.ui.NameSortSelector;
import edu.tamu.pt.ui.NewPTPopup;
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
        
        this.ptList = getComponentAs(Id.PT_LIST, ListView);
        ptList.itemRenderer = ComponentItemRenderer;
        
        initListView(Id.LABS);
        initListView(Id.OFFICE_HOURS);
        initListView(Id.SCHEDULE);
        
        this.ptListCache = new Array<PeerTeacher>();
        buildPTList();
        
        attachEvent(Id.PT_LIST, UIEvent.CHANGE, function(e) {
        /*  Select PT
         *  Find which PT this is
         *  Load that PT
         * 
         *  Somewhere in here we need to save, before loading ofc; for now, ignoring
         * */
        //  db.save();
            loadPT(ptListCache[ptList.selectedIndex]);
        });
        
        attachEvent(Id.ADD_PT_BTN, UIEvent.MOUSE_UP, function(e) {
            var p = new NewPTPopup();
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
                    case PopupButton.CANCEL:
                    default:
                        PTDatabaseApp.error("Invalid event detected in Add Peer Teacher Dialog.");
                }
            });
        });
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
    public function buildPTList():Void {
        refreshListView(ptList);
        var pts = db.pts(getComponentAs(Id.SORTBY, NameSortSelector).sorter());
        
        for (pt in pts) {
            ptList.dataSource.add({
                text: pt.toString(),
                componentType: "button",
                componentValue: "X",
                controlId: 'remove-${pt.firstname}-${pt.lastname}'
            });
        }
        
        this.ptListCache = pts;
    }
    
    public function loadPT(pt:PeerTeacher):Void {
        currentPT = pt;
        refreshPT();
    }
 
/*  Private Members
 *  =========================================================================*/
    private var currentPT:PeerTeacher;
    private var ptListCache:Array<PeerTeacher>;
    private var ptList:ListView;
 
/*  Private Methods
 *  =========================================================================*/
    private function refreshPT():Void {
        refreshPTBasic();
        refreshPTLabs();
        refreshPTOfficeHours();
        refreshPTSchedule();
    }
    
    private function refreshPTBasic():Void {
        getComponent(Id.FIRSTNAME).text = currentPT.firstname;
        getComponent(Id.LASTNAME).text = currentPT.lastname;
        getComponent(Id.PREFERREDNAME).text = currentPT.preferredname;
        getComponent(Id.EMAIL).text = currentPT.email;
        getComponent(Id.IMAGE).text = currentPT.image;
    }
    
    private function refreshPTLabs():Void {
        var curLabs = getComponent(Id.CUR_LABS);
        curLabs.text = "Current: ";
        for (lab in currentPT.labs)
            curLabs.text += '${lab.code}-${lab.section}, '; // @TODO make prettier (ie. no trailing ,)
        
        var allLabs = db.labs(Sorters.labOrder);
        var listview = getComponentAs(Id.LABS, ListView);
        refreshListView(listview);
        
        for (lab in allLabs) {
            var labinfo:Dynamic = {
                text: lab.toString(),
                subtext: lab.timesString()
            };
            
            if (currentPT.labs.exists(lab.toString())) {
                labinfo.componentType = "button";
                labinfo.componentValue = "X";
                labinfo.controlId = 'remove-${lab.toString()}';
            }
            else if (!currentPT.intersects(lab)) {
                labinfo.componentType = "button";
                labinfo.componentValue = "+";
                labinfo.controlId = 'add-${lab.toString()}';
            }
            
            listview.dataSource.add(labinfo);
        }
    }
    
    private function refreshPTOfficeHours():Void {
        var listview = getComponentAs(Id.OFFICE_HOURS, ListView);
        refreshListView(listview);
        for (oh in currentPT.officeHours) {
            listview.dataSource.add({
                text: oh.toString(),
                componentType: "button",
                componentValue: "X"
            });
        }
    }
    
    private function refreshPTSchedule():Void {
        var listview = getComponentAs(Id.SCHEDULE, ListView);
        refreshListView(listview);
        for (cls in currentPT.schedule) {
            listview.dataSource.add({
                text: cls.toString(),
                subtext: cls.timesString()
            });
        }
    }
    
    private inline function refreshListView(lv:ListView):Void {
        lv.dataSource = new ArrayDataSource();
    }
    
/**
 *  @private
 *  Initializes a ListView with general shared properties.  This essentially allows the view to render components and be unselectable.
 *  @param id ID of the ListView given in the XML file
 *  @return The ListView object found with id
 */
    private function initListView(id:String):ListView {
        var listview = getComponentAs(id, ListView);
        listview.itemRenderer = ComponentItemRenderer;
        listview.allowSelection = false;
        return listview;
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
    var OFFICE_HOUR_ADD = "edit-pts-add-office-hours";
    var OFFICE_HOUR_BTN = "edit-pts-add-office-hours-btn";
    var SCHEDULE = "edit-pts-schedule";
    var SCHEDULE_BTN = "edit-pts-upload-schedule";
    var SORTBY = "edit-pts-sortby";
    var PT_LIST = "edit-pts-pt-list";
    var ADD_PT_BTN = "edit-pts-add-pt-btn";
}