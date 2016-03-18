package;

import haxe.unit.TestRunner;

import openfl.display.Sprite;
import openfl.Lib;

import edu.tamu.pt.PTDatabaseApp;
import edu.tamu.pt.test.*;

class Main extends Sprite {
    private static inline var RUN_TESTS = false;
    
    private var app:PTDatabaseApp;

    public function new() {
        super();
        
        if (RUN_TESTS)
            runTests();
        else {
            app = new PTDatabaseApp();
            app.start();
        }
    }
    
    public static function runTests():Bool {
        var runner = new TestRunner();
        runner.add(new TestTimeInterval());
        runner.add(new TestAppointment());
        runner.add(new TestReaders());
        runner.add(new TestDatabase<edu.tamu.pt.db.JsonDatabase>());
        runner.add(new TestPeerTeacher());
        
        return runner.run();
    }

}