package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** ClassSchedule Class
 *  @author  Timothy Foster
 *
 *  Represents the appointmentss required for a particular section for a
 *  course.
 *  **************************************************************************/
class ClassSchedule {
    public var dept(default, null):String;
    public var code(default, null):String;
    public var section(default, null):String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new class schedule
 *  @param dept Eg. CSCE
 *  @param code eg. 221
 *  @param section eg. 502
 */
    public function new(dept:String, code:String, section:String) {
        this.dept = dept;
        this.code = code;
        this.section = section;
        times = new Array<Appointment>();
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Determines if the given appointment conflicts with any of the appointments
 *  in this schedule.
 *  @param appt
 *  @return true if a conflict exists, false otherwise
 */
    public function intersects(appt:Appointment):Bool {
        for (time in times)
            if (appt.intersects(time))
                return true;
        return false;
    }
    
/**
 *  Allows for iteration across all appointments in this object
 */
    public function appointments():Iterator<Appointment> {
        return times.iterator();
    }
    
/**
 *  Adds an appointment to the schedule.  The appointment must not conflict with
 *  any other appointment in the schedule.
 *  @param appt
 *  @throws Error When a conflict exists
 */
    public function addAppointment(appt:Appointment):Void {
        if (this.intersects(appt))
            throw new Error("Added appointment conflicted with class " + this.toString(), "ClassSchedule", "addAppointment");
        times.push(appt);
    }
    
/**
 *  Shows the string code of the course, which is simply '$dept-$code-$section'.
 *  This is generally used as the key in maps and such.
 *  @return '$dept-$code-$section'; if the class has no section, the last '-' is omitted
 */
    public function toString():String {
        return section.length > 0 ? '$dept-$code-$section' : '$dept-$code';
    }
    
/**
 *  Returns a string representing each of the individual appointments in the schedule
 *  @return Comma separated list of appointment string representations
 */
    public function timesString():String {
        return times.join(", ");
    }
 
/*  Private Members
 *  =========================================================================*/
    private var times:Array<Appointment>;
    
}