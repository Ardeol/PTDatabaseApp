package edu.tamu.pt.test;

import edu.tamu.pt.io.LabReader;
import edu.tamu.pt.io.StudentScheduleReader;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.Day;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.TimeInterval;

/** TestReaders Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class TestReaders extends AdvTestCase {

    public function testLabReader() {
        var reader = new LabReader("test/Spring2016.txt");
        var m = reader.read();
        assertTrue(m.exists("CSCE-315-501"));
        assertTrue(m.exists("CSCE-313-510"));
        assertFalse(m.exists("CSCE-314-500"));
        
        var a1 = new Appointment();
        a1.addDay(Day.T);
        a1.addInterval(new TimeInterval("11:30 am - 12:30 pm"));
        
        assertTrue(m["CSCE-315-501"].intersects(a1));
        assertFalse(m["CSCE-313-510"].intersects(a1));
    }
    
    public function testStudentScheduleReader() {
        var reader = new StudentScheduleReader("test/Timothy_Foster.txt");
        var pt = reader.read();
        assertEquals("Timothy", pt.firstname);
        assertEquals("Foster", pt.lastname);
        assertEquals(5, pt.schedule.length);
        var cls = findClass("CSCE-420-500", pt.schedule);
        assertEquals("TR 11:10 am - 12:25 pm", cls.timesString());
        cls = findClass("EPSY-430-200", pt.schedule);
        assertEquals("R 3:55 - 6:30 pm", cls.timesString());
        
        reader = new StudentScheduleReader("test/Antonia_Jones.txt");
        pt = reader.read();
        assertEquals("Antonia", pt.firstname);
        assertEquals("Jones", pt.lastname);
        assertEquals(5, pt.schedule.length);
        cls = findClass("CSCE-314-502", pt.schedule);
        assertEquals("MWF 1:50 - 2:40 pm", cls.timesString());
        cls = findClass("CSCE-312-502", pt.schedule);
        assertEquals("TR 5:30 - 6:45 pm, W 10:00 am - 12:00 pm", cls.timesString());
    }
    private function findClass(clsStr:String, schedule:Array<ClassSchedule>):ClassSchedule {
    //  We assume there is at least one class in the schedule
        var cls = schedule[0];
        var i = 1;
        while (cls.toString() != clsStr && i < schedule.length)
            cls = schedule[i++];
        return cls;
    }
    
}