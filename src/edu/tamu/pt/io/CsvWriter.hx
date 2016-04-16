package edu.tamu.pt.io;

import sys.io.FileOutput;

import edu.tamu.pt.ui.TextTable;

/** CsvWriter Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class CsvWriter extends FileWriter<TextTable> {
    
/**
 *  @inheritDoc
 */
    override private function parse(table:TextTable, out:FileOutput):Void {
        for (r in 0...(table.rows)) {
            var values = new Array<String>();
            for (c in 0...(table.columns))
                values.push('"${table.cell(r, c)}"');
            out.writeString(values.join(","));
            out.writeString("\n");
        }
    }
    
}