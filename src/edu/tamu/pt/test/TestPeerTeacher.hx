package edu.tamu.pt.test;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.TimeInterval;

/** TestPeerTeacher Class
 *  @author Auroratide
 * 
 *  
 *  **************************************************************************/
class TestPeerTeacher extends AdvTestCase {
    
    public function testClear() {
        var pt = buildPT();
        pt.clearLabs();
        assertFalse(pt.labs.exists("CSCE-315-501"));
        assertFalse(pt.labs.exists("CSCE-313-500"));
        pt.clearOfficeHours();
        assertEquals(0, pt.officeHours.length);
        pt.clearSchedule();
        assertEquals(0, pt.schedule.length);
    }
    
    public function testFindConflicts() {
        var pt = buildPT();
        var appt = new Appointment("MW 9:00 am - 12:00 pm");
        
        var classes = pt.findConflictingClasses(appt);
        assertEquals(1, classes.length);
        assertEquals("CSCE-315-501", classes[0].toString());
        
        var officeHours = pt.findConflictingOfficeHours(appt);
        assertEquals(0, officeHours.length);
        
        var labs = pt.findConflictingLabs(appt);
        assertEquals(1, labs.length);
        assertEquals("CSCE-221-501", labs[0].toString());
    }
    
    public function testReplaceSchedule() {
        var pt = buildPT();
        var newSchedule = new Array<ClassSchedule>();
        var cls = new ClassSchedule("CSCE", "315", "502");
        cls.addAppointment(new Appointment("MWF 11:30 am - 12:20 pm"));
        newSchedule.push(cls);
        cls = new ClassSchedule("CSCE", "313", "500");
        cls.addAppointment(new Appointment("TR 2:20 - 3:10 pm"));
        cls.addAppointment(new Appointment("F 8:00 - 10:00 am"));
        newSchedule.push(cls);
        
        for (c in newSchedule)
            pt.removeConflictsWith(c);
        assertFalse(pt.labs.exists("CSCE-221-501"));
        assertTrue(pt.labs.exists("CSCE-221-507"));
        
        pt.replaceSchedule(newSchedule);
        assertEquals(2, pt.schedule.length);
        assertEquals("CSCE-315-502", pt.schedule[0].toString());
        assertEquals("CSCE-313-500", pt.schedule[1].toString());
    }
    
    private function buildPT():PeerTeacher {
        var pt = new PeerTeacher("Aurora", "Starsong");
        var cls = new ClassSchedule("CSCE", "315", "501");
        cls.addAppointment(new Appointment("MWF 10:20 - 11:10 am"));
        pt.schedule.push(cls);
        cls = new ClassSchedule("CSCE", "313", "500");
        cls.addAppointment(new Appointment("TR 2:20 - 3:10 pm"));
        cls.addAppointment(new Appointment("F 8:00 - 10:00 am"));
        pt.schedule.push(cls);
        
        pt.officeHours.push(new Appointment("T 11:00 am - 1:00 pm"));
        pt.officeHours.push(new Appointment("R 11:00 am - 12:00 pm"));
        
        cls = new ClassSchedule("CSCE", "221", "501");
        cls.addAppointment(new Appointment("MW 11:30 am - 12:20 pm"));
        pt.labs.set(cls.toString(), cls);
        
        cls = new ClassSchedule("CSCE", "221", "507");
        cls.addAppointment(new Appointment("MW 8:00 - 8:50 am"));
        
        pt.labs.set(cls.toString(), cls);
        
        return pt;
    }
}