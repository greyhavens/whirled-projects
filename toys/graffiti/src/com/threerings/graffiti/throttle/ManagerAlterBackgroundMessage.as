// $Id$

package com.threerings.graffiti.throttle {

public class ManagerAlterBackgroundMessage extends AlterBackgroundMessage
{
    public function ManagerAlterBackgroundMessage (backgroundMessage :AlterBackgroundMessage)
    {
        super(backgroundMessage.type, backgroundMessage.value);
    }
}
}
