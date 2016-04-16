package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** PeerTeacher Class
 *  @author  Timothy Foster
 *
 *  Contains all the information prevelant for a Peer Teacher.  This includes
 *  name, email, current actual schedule, all assigned labs, and office
 *  hours.
 * 
 *  I had made a mistake exposing all of the internal structures with this
 *  class.  It can be refactored, but it would take some significant effort.
 *  **************************************************************************/
class PeerTeacher {
    public var firstname(default, default):String;
    public var lastname(default, default):String;
    public var preferredname(default, default):String;
    public var email(default, default):String;
    public var image(default, default):String;
    public var schedule(default, null):Array<ClassSchedule>;
    public var labs(default, null):Map<String, ClassSchedule>;  // should be Array<String> ?
    public var officeHours(default, null):Array<Appointment>;

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new PeerTeacher object.  All peer teachers must have a first and last name.
 *  @param firstname
 *  @param lastname
 */
    public function new(firstname:String, lastname:String) {
        this.firstname = firstname;
        this.lastname = lastname;
        this.preferredname = "";
        this.email = "";
        this.image = "";
        this.schedule = new Array<ClassSchedule>();
        this.labs = new Map<String, ClassSchedule>();
        this.officeHours = new Array<Appointment>();
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Determines if any of this PT's schedule interferes with the proposed schedule.
 *  @param other Any object with the intersects() method.  This could be an appointment, class schedule, or even another PT.
 *  @return true if there is a conflict, false otherwise
 */
    public function intersects<T:Intersectable>(other:T):Bool {
    //  The conflict finder functions could be used here, but this happens to be faster
        for (cls in schedule) for (appt in cls.appointments())
            if (other.intersects(appt))
                return true;
        for (lab in labs) for (appt in lab.appointments())
            if (other.intersects(appt))
                return true;
        for (appt in officeHours)
            if (other.intersects(appt))
                return true;
                
        return false;
    }
    
/**
 *  Returns an array representing the labs which conflict with the current object
 *  @param other Any object with the intersects() method.  This could be an appointment, class schedule, or even another PT.
 */
    public function findConflictingLabs<T:Intersectable>(other:T):Array<ClassSchedule> {
        var conflicts = new Array<ClassSchedule>();
        for (lab in labs) for (appt in lab.appointments())
            if (other.intersects(appt))
                conflicts.push(lab);
        return conflicts;
    }
    
/**
 *  Returns an array representing the office hours which conflict with the current object
 *  @param other Any object with the intersects() method.  This could be an appointment, class schedule, or even another PT.
 */
    public function findConflictingOfficeHours<T:Intersectable>(other:T):Array<Appointment> {
        var conflicts = new Array<Appointment>();
        for (appt in officeHours)
            if (other.intersects(appt))
                conflicts.push(appt);
        return conflicts;
    }
    
/**
 *  Returns an array representing the classes which conflict with the current object.  These are NOT assigned labs.
 *  @param other Any object with the intersects() method.  This could be an appointment, class schedule, or even another PT.
 */
    public function findConflictingClasses<T:Intersectable>(other:T):Array<ClassSchedule> {
        var conflicts = new Array<ClassSchedule>();
        for (cls in schedule) for (appt in cls.appointments())
            if (other.intersects(appt))
                conflicts.push(cls);
        return conflicts;
    }
    
/**
 *  Removes any conflicts this PT has with the proposed item.
 *  @param other Any object with the intersects() method.  This could be an appointment, class schedule, or even another PT.
 */
    public function removeConflictsWith<T:Intersectable>(other:T):Void {
        var labConflicts = findConflictingLabs(other);
        var ohConflicts = findConflictingOfficeHours(other);
        var classConflicts = findConflictingClasses(other);
        for (l in labConflicts)
            this.labs.remove(l.toString());
        for (oh in ohConflicts)
            this.officeHours.remove(oh);
        for (c in classConflicts)
            this.schedule.remove(c);
    }
    
/**
 *  Removes the old schedule, replacing it with the proposed one.  Because a
 *  schedule takes priority over lab assignments and office hours, they are
 *  kept in all cases.  Does not remove conflicting labs or office hours.
 *  @param newSchedule All of the classes in the PT's updated schedule
 */
    public function replaceSchedule(newSchedule:Array<ClassSchedule>):Void {
        clearSchedule();
        for (cls in newSchedule)
            this.schedule.push(cls);
    }
    
/**
 *  Removes all lab assignments from the PT
 */
    public function clearLabs():Void {
        for (lab in labs.keys())
            labs.remove(lab);
    }
    
/**
 *  Removes all office hour assignment from the PT
 */
    public function clearOfficeHours():Void {
        while (this.officeHours.length > 0)
            this.officeHours.pop();
    }
    
/**
 *  Clears the pt's current class schedule.  This does NOT include labs or office hours.
 */
    public function clearSchedule():Void {
        while (this.schedule.length > 0)
            this.schedule.pop();
    }
 
/**
 *  Returns the name of the peer teacher; note that preferred name is NOT used here
 *  @return FIRSTNAME LASTNAME
 */
    public function toString():String {
        return '$firstname $lastname';
    }

}

private typedef Intersectable = {
    public function intersects(appt:Appointment):Bool;
}