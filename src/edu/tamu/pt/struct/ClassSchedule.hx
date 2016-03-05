package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** ClassSchedule Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class ClassSchedule {
    public var dept(default, null):String;
    public var code(default, null):String;
    public var section(default, null):String;
    
/*  Constructor
 *  =========================================================================*/
    public function new(dept:String, code:String, section:String) {
        this.dept = dept;
        this.code = code;
        this.section = section;
        times = new Array<Appointment>();
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
    public function intersects(appt:Appointment):Bool {
        for (time in times)
            if (appt.intersects(time))
                return true;
        return false;
    }
    
    public function appointments():Iterator<Appointment> {
        return times.iterator();
    }
    
    public function addAppointment(appt:Appointment):Void {
        if (this.intersects(appt))
            throw new Error("Added appointment conflicted with class " + this.toString(), "ClassSchedule", "addAppointment");
        times.push(appt);
    }
    
    public function toString():String {
        return '$dept-$code-$section';
    }
    
    public function timesString():String {
        return times.join(", ");
    }
 
/*  Private Members
 *  =========================================================================*/
    private var times:Array<Appointment>;
 
/*  Private Methods
 *  =========================================================================*/
    
}