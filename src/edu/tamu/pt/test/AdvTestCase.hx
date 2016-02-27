package edu.tamu.pt.test;

import haxe.unit.TestCase;

/** AdvTestCase Class
 *  @author  Timothy Foster
 *  @version x.xx.160221
 *  
 *  Extends the standard library TestCase to include error assertions.
 *  **************************************************************************/
class AdvTestCase extends TestCase {
/**
 *  This assert passes of stmt throws an error.
 *  @param stmt A function to execute
 *  @param c
 */
    public function assertError(stmt:Void->Void, ?c:haxe.PosInfos):Void {
        currentTest.done = true;
        try {
            stmt();
        }
        catch (err:Dynamic) {
            return;
        }
        currentTest.success = false;
        currentTest.error = "expected an error but received no error";
        currentTest.posInfos = c;
        throw currentTest;
    }
}