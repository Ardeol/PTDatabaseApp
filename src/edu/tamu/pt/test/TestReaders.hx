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
        
        assertTrue(false);
    }
    
}