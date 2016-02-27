package edu.tamu.pt.io;

import sys.io.FileInput;

import edu.tamu.pt.struct.PeerTeacher;

/** StudentScheduleReader Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class StudentScheduleReader extends FileReader<PeerTeacher> {
/**
 *  @inheritDoc
 */
    override private function parse(stream:FileInput):PeerTeacher {
        return null;
    }
}