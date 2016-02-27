package edu.tamu.pt.test;

import edu.tamu.pt.struct.Day;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.TimeInterval;

/** TestAppointment Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class TestAppointment extends AdvTestCase {
    public function testDay() {
        assertEquals("M", new Day("M"));
        assertEquals("T", new Day("Tu"));
        assertError(function() {  new Day("N"); });
        var d1 = new Day("M");
        var d2 = new Day("F");
        var d3 = new Day("Su");
        assertTrue(d1 < d2);
        assertFalse(d2 < d1);
        assertTrue(d3 > d2);
    }
    
    public function testToString() {
        var a1 = new Appointment();
        a1.addDay(Day.M);
        a1.addDay(Day.W);
        a1.addInterval(new TimeInterval("10:00 - 11:00 am"));
        assertEquals("MW", a1.daysString());
        assertEquals("10:00 - 11:00 am", a1.timesString());
        assertEquals("MW 10:00 - 11:00 am", a1.toString());
        
    //  If given in wrong order, does it return correct order (eg. TR vs RT)
        var a2 = new Appointment();
        a2.addDay(Day.R);
        a2.addDay(Day.T);
        a2.addInterval(new TimeInterval("2:00 - 2:30 pm"));
        a2.addInterval(new TimeInterval("11:30 am - 12:30 pm"));
        assertEquals("TR", a2.daysString());
        assertEquals("11:30 am - 12:30 pm, 2:00 - 2:30 pm", a2.timesString());
        assertEquals("TR 11:30 am - 12:30 pm, 2:00 - 2:30 pm", a2.toString());
    }
    
    public function testIntersects() {
        var a1 = new Appointment();
        a1.addDay(Day.M);
        a1.addDay(Day.W);
        a1.addInterval(new TimeInterval("10:00 - 11:00 am"));
        var a2 = new Appointment();
        a2.addDay(Day.R);
        a2.addDay(Day.T);
        a2.addInterval(new TimeInterval("2:00 - 2:30 pm"));
        a2.addInterval(new TimeInterval("11:30 am - 12:30 pm"));
        var a3 = new Appointment();
        a3.addDay(Day.W);
        a3.addInterval(new TimeInterval("10:30 am - 12:00 pm"));
        var a4 = new Appointment();
        a4.addDay(Day.T);
        a4.addDay(Day.R);
        a4.addInterval(new TimeInterval("10:00 am - 2:00 pm"));
        
        assertFalse(a1.intersects(a2));
        assertTrue(a1.intersects(a3));
        assertFalse(a1.intersects(a4));
        assertFalse(a2.intersects(a3));
        assertTrue(a2.intersects(a4));
        assertFalse(a3.intersects(a4));
    }
}