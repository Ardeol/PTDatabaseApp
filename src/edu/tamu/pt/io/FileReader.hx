package edu.tamu.pt.io;

import sys.io.File;
import sys.io.FileInput;

/** FileReader Class
 *  @author  Timothy Foster
 *  @version x.xx.160225
 * 
 *  Reads data from a file and outputs the corresponding object.  This class
 *  is meant to be extended, and parse() should be overridden.
 *  **************************************************************************/
class FileReader<T> {
/**
 *  File path to read from
 */
    public var path:String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new FileReader for a given path.
 *  @param path Valid file path.
 */
    public function new(path:String) {
        this.path = path;
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Read the file and return an object corresponding to the read data.
 *  @return Object representing the contents of the file.
 */
    public function read():T {
        var handle = File.read(path);
        var result = parse(handle);
        handle.close();
        return result;
    }
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Uses a FileInput stream to construct an object.
 *  @param stream A FileInput stream.
 */
    private function parse(stream:FileInput):T {
        return null;
    }
}