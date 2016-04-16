package;

import openfl.display.Sprite;
import openfl.Lib;

import edu.tamu.pt.PTDatabaseApp;

class Main extends Sprite {
    
    private var app:PTDatabaseApp;

    public function new() {
        super();
        app = new PTDatabaseApp();
        app.start();
    }

}