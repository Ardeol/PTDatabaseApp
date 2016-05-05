package edu.tamu.pt.test;

import edu.tamu.pt.util.Util;

/** TestUtil Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class TestUtil extends AdvTestCase {

    public function testRelativePath() {
        var wd = "C:\\a\\b\\c\\d\\";
        var w1 = "C:\\e\\f\\g.txt";
        var w2 = "C:\\a\\b\\e.txt";
        var w3 = "C:\\a\\e\\f.txt";
        var w4 = "C:\\a\\b\\c\\e\\f.txt";
        var w5 = "C:\\a\\b\\c\\d\\e.txt";
        var w6 = "C:\\a\\b\\c\\d\\e\\f\\g.txt";
        
        assertEquals("../../../../e/f/g.txt", Util.relativePath(w1, wd));
        assertEquals("../../e.txt",           Util.relativePath(w2, wd));
        assertEquals("../../../e/f.txt",      Util.relativePath(w3, wd));
        assertEquals("../e/f.txt",            Util.relativePath(w4, wd));
        assertEquals("e.txt",                 Util.relativePath(w5, wd));
        assertEquals("e/f/g.txt",             Util.relativePath(w6, wd));
        
        var ld = "/usr/a/b/c/d/";
        var l1 = "/usr/e/f/g.txt";
        var l2 = "/usr/a/b/e.txt";
        var l3 = "/usr/a/e/f.txt";
        var l4 = "/usr/a/b/c/e/f.txt";
        var l5 = "/usr/a/b/c/d/e.txt";
        var l6 = "/usr/a/b/c/d/e/f/g.txt";
        var l7 = "/bin/a/b.txt";
        
        assertEquals("../../../../e/f/g.txt", Util.relativePath(l1, ld));
        assertEquals("../../e.txt",           Util.relativePath(l2, ld));
        assertEquals("../../../e/f.txt",      Util.relativePath(l3, ld));
        assertEquals("../e/f.txt",            Util.relativePath(l4, ld));
        assertEquals("e.txt",                 Util.relativePath(l5, ld));
        assertEquals("e/f/g.txt",             Util.relativePath(l6, ld));
        assertEquals("../../../../../bin/a/b.txt", Util.relativePath(l7, ld));
    }
    
}