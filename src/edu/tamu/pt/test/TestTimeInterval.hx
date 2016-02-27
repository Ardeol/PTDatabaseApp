package edu.tamu.pt.test;

import edu.tamu.pt.struct.TimeInterval;

/** TestTime Class
 *  @author  Timothy Foster
 *  @version x.xx.160222
 *  
 *  Unit tests for the Time struct.
 *  **************************************************************************/
class TestTimeInterval extends AdvTestCase {
    public function testSetters() {
        var t = new TimeInterval();
        t.start = 500;
        t.end = 600;
        
        assertEquals(500, t.start);
        assertEquals(600, t.end);
        
        t.start = 1440;
        assertEquals(0, t.start);
        
        t.end = 1600;
        assertEquals(160, t.end);
        
        t.start = -40;
        t.end = -40;
        assertEquals(1400, t.start);
        assertEquals(1400, t.end);
    }
    
    public function testFromCommon() {
        assertEquals(0, TimeInterval.fromCommon("12:00 AM"));
        assertEquals(360, TimeInterval.fromCommon("06:00 AM"));
        assertEquals(810, TimeInterval.fromCommon("01:30 pm"));
        assertEquals(810, TimeInterval.fromCommon("1:30 PM"));
        assertEquals(1439, TimeInterval.fromCommon("11:59 pm"));
        assertError(function() {  TimeInterval.fromCommon("13:00 am"); });
        assertError(function() {  TimeInterval.fromCommon(""); });
        
    /*  Bonus
        assertEquals(360, Time.fromCommon("6 am"));
    /*  */
    }
    
    public function testConstructor() {
        var t = new TimeInterval("5:00 - 7:00 pm");
        assertEquals(1020, t.start);
        assertEquals(1140, t.end);
        
        t = new TimeInterval("11:00 am - 1:00 pm");
        assertEquals(660, t.start);
        assertEquals(780, t.end);
        
        t = new TimeInterval("11:30 am - 12:30 pm");
        assertEquals("11:30 am - 12:30 pm", t.toString());
    }
    
    public function testIntersects() {
        var t_100_300 = new TimeInterval("1:00 - 3:00 pm");
        var t_200_300 = new TimeInterval("2:00 - 3:00 pm");
        var t_900_1030 = new TimeInterval("9:00 - 10:30 am");
        var t_1100_1200 = new TimeInterval("11:00 am - 12:00 pm");
        var t_1200_120 = new TimeInterval("12:00 - 1:20 pm");
        
        assertTrue(t_100_300.intersects(t_200_300));
        assertFalse(t_200_300.intersects(t_900_1030));
        assertFalse(t_900_1030.intersects(t_1100_1200));
        assertTrue(t_1100_1200.intersects(t_1200_120));
    }
    
    public function testToString() {
        var t = new TimeInterval();
        t.start = 12 * 60;
        t.end = 13 * 60;
        assertEquals("12:00 - 1:00 pm", t.toString());
        t.start = 13 * 60 + 20;
        t.end = 14 * 60 + 30;
        assertEquals("1:20 - 2:30 pm", t.toString());
        t.start = 9 * 60;
        t.end = 10 * 60;
        assertEquals("9:00 - 10:00 am", t.toString());
        t.start = 0;
        t.end = 6 * 60;
        assertEquals("12:00 - 6:00 am", t.toString());
        t.start = 11 * 60 + 30;
        t.end = 12 * 60 + 30;
        assertEquals("11:30 am - 12:30 pm", t.toString());
    }
}