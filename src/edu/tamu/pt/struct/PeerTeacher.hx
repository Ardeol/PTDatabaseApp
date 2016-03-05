package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** PeerTeacher Class
 *  @author  Timothy Foster
 *  @version A.00
 *
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
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
    public function intersects<T:Intersectable>(other:T):Bool {
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
 
    public function toString():String {
        return '$firstname $lastname';
    }
 
/*  Private Members
 *  =========================================================================*/
    
 
/*  Private Methods
 *  =========================================================================*/
/*  @deprecated
    private function set_email(value:String):String {
        if (value.indexOf("@") < 0)
            throw new Error('Not a valid email address: $value', "PeerTeacher", "set_email");
        return email = value;
    }
    
    private function set_image(value:String):String {
        if (!~/\.(png|jpe?g)$/.match(value))
            throw new Error('Not a recognized image format.  Only jpg and png recognized, but image was $value', "PeerTeacher", "set_image");
        return image = value;
    }
*/
}

private typedef Intersectable = {
    public function intersects(appt:Appointment):Bool;
}