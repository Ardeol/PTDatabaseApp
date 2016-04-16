package edu.tamu.pt.ui;

import haxe.ui.toolkit.controls.selection.ListSelector;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.util.Sorters;

/** NameSortSelector Class
 *  @author  Timothy Foster
 *
 *  Pre-built Sort by name selector.  This element generates a simple
 *  list view which allows the user to sort a list of names by either first
 *  or last name.  To get the selected sorter, simply call the sorter()
 *  method.
 * 
 *  A UIEvent.CHANGE event still needs to be added for the element for it to
 *  do anything, of course.
 *  **************************************************************************/
class NameSortSelector extends ListSelector {

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new NameSortSelector element.
 */
    public function new() {
        super();
        this.text = "Sort by";
        this.dataSource.add({ text: "First Name" });
        this.dataSource.add({ text: "Last Name" });
        
        this.selectedIndex = 1;
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Returns the proper PeerTeacher sorter given what the user has selected.  By default, this is by Last Name.
 *  @return A PeerTeacher sorter.
 */
    public function sorter():PeerTeacher->PeerTeacher->Int {
        return this.selectedIndex == 0 ? Sorters.alphaByFirst : Sorters.alpha;
    }

}