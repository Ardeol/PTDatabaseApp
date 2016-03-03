package edu.tamu.pt.util;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;

/** Sorters Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class Sorters {

    public static var alpha(default, null):PeerTeacher->PeerTeacher->Int = function(lhs, rhs) {
        if (lhs.lastname < rhs.lastname)
            return -1;
        else if (lhs.lastname == rhs.lastname) {
            if (lhs.firstname < rhs.firstname)
                return -1;
            else if (lhs.firstname == rhs.firstname)
                return 0;
        }
        return 1;
    };
    
    public static var alphaByFirst(default, null):PeerTeacher->PeerTeacher->Int = function(lhs, rhs) {
        if (lhs.firstname < rhs.firstname)
            return -1;
        else if (lhs.firstname == rhs.firstname) {
            if (lhs.lastname < rhs.lastname)
                return -1;
            else if (lhs.lastname == rhs.lastname)
                return 0;
        }
        return 1;
    };
    
    public static var labOrder(default, null):ClassSchedule->ClassSchedule->Int = function(lhs, rhs) {
        if (lhs.toString() == rhs.toString())
            return 0;
        else
            return lhs.toString() < rhs.toString() ? -1 : 1;
    };
    
}