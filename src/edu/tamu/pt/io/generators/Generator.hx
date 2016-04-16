package edu.tamu.pt.io.generators;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.io.FileWriter;

/** Generator Class
 *  @author  Timothy Foster
 * 
 *  Generic base for all other generators.  A generator converts the database
 *  into an HTML file.  The HTML file can then be used on a website, printed,
 *  converted to a PDF, or whatever is needed.
 * 
 *  Theoretically, the generator can be used to make other kinds of files.
 *  But that would be up to future people to do.  I ain't doin' it.
 *  **************************************************************************/
class Generator extends FileWriter<IDatabase> {
    
    public var extension(get, never):String;
    
    public function new() {
        super("");
    }
    
    private function get_extension():String
        return "";
}