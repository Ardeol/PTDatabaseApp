package edu.tamu.pt.test;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.util.Sorters;

/** TestDatabase Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
@:generic class TestDatabase<T:(IDatabase, Constructible)> extends AdvTestCase {
    
    public function testLoad() {
        var db:IDatabase = new T();
        assertFalse(db.load(1));
        assertEquals("ERROR in JsonDatabase load: JsonDatabase load expects a String representing a filename", db.error());
        assertTrue(db.load("test/db.json"));
    }
    
    public function testPTs() {
        var db:IDatabase = new T();
        db.load("test/db.json");
        var pt1 = db.pt("Aurora Starsong");
        assertEquals("Aurora", pt1.firstname);
        assertEquals("Starsong", pt1.lastname);
        assertEquals("starsong.aurora@gmail.com", pt1.email);
        assertEquals("TRF 1:20 - 1:50 pm, 3:00 - 3:30 pm", pt1.officeHours[0].toString());
        
        var pt2 = db.pt("NotInDatabase");
        assertTrue(pt2 == null);
        
        var pts = db.pts(Sorters.alphaByFirst);
        assertEquals(3, pts.length);
        assertEquals("Aurora", pts[0].firstname);
        assertEquals("Beacon", pts[1].firstname);
        assertEquals("Eventide", pts[2].firstname);
    }
}

private typedef Constructible = {
    public function new():Void;
}