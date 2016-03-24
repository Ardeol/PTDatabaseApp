package edu.tamu.pt.controllers;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.events.UIEvent;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.ui.NameSortSelector;
import edu.tamu.pt.ui.renderers.IdComponentItemRenderer;
import edu.tamu.pt.util.Sorters;
import edu.tamu.pt.util.Filters;

/** EditLabsController Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class EditLabsController extends Controller {

/*  Constructor
 *  =========================================================================*/
    public function new(db:IDatabase) {
        super("ui/edit-labs.xml", db);
        
        this.labListView = getComponentAs(Id.LAB_LIST, ListView);
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
    }
 
/*  Public Methods
 *  =========================================================================*/
    public function buildLabList():Void {
        refreshListView(labListView);
        var labs = db.labs(Sorters.labOrder);
        
        for (lab in labs)
            labListView.dataSource.add({ text: lab.toString() });
            
        labListCache = labs;
    }
    
    public function loadLab(l:ClassSchedule):Void {
        db.save();
        currentLab = l;
        refreshLab();
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var PT_REMOVE_PREFIX = "rem-pt-"; // This and the following string should be same length!
    private static inline var PT_ADD_PREFIX    = "add-pt-";
 
    private var currentLab:ClassSchedule;
    private var labListCache:Array<ClassSchedule>;
    private var labListView:ListView;
 
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
        refreshListView(getComponentAs(Id.PTS, ListView));
    }
    
    private function refreshLabPTs():Void {
        if (currentLab != null) {
            var currentPTs = db.pts(Filters.hasLab.bind(currentLab));
            getComponent(Id.CUR_PTS).text = "Current: " + currentPTs.join(", ");
            
            var allPTs = db.pts(getComponentAs(Id.SORTBY, NameSortSelector).sorter());
            var listview = getComponentAs(Id.PTS, ListView);
            refreshListView(listview);
            
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
        }
        else
            clearLabPTs();
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
}