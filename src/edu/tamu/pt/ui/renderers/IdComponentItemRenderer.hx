package edu.tamu.pt.ui.renderers;

import haxe.ui.toolkit.core.renderers.ComponentItemRenderer;

/** IdComponentItemRenderer Class
 *  @author Timothy Foster
 * 
 *  Simple extension to allow for custom Ids.  I'm not sure why this is not
 *  already implemented in the HaxeUI library.
 *  **************************************************************************/
class IdComponentItemRenderer extends ComponentItemRenderer {
/**
 *  @inheritDoc
 */
    override private function set_data(value:Dynamic):Dynamic {
        var d = super.set_data(value);
        if (value.componentId != null)
            _component.id = value.componentId;
        return d;
    }
}