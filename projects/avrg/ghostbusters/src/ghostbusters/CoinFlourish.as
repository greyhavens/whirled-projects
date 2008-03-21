//
// $Id: AlphaFade.as 359 2007-12-03 21:08:33Z dhoover $
//
// Nenya library - tools for developing networked games
// Copyright (C) 2002-2007 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/nenya/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package ghostbusters {

import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.Animation;
import com.threerings.flash.TextFieldUtil;

public class CoinFlourish extends Sprite
    implements Animation
{
    public function CoinFlourish (coins :int, done :Function)
    {
        _done = done;

        this.addChild(TextFieldUtil.createField(
            "You made " + coins + " coins!", {
                outlineColor: 0xFFFFFF,
                autoSize: TextFieldAutoSize.CENTER,
                defaultTextFormat: TextFieldUtil.createFormat({
                    font: "Arial", size: 48, color: 0xFF7733
                })
        }));
    }

    public function updateAnimation (elapsed :Number) :void
    {
        Game.log.debug("Spamming animation: " + elapsed);

        if (elapsed < 500) {
            this.alpha = elapsed / 500;

//        } else if (elapsed < 1000
//            this.alpha = 1;

        } else if (elapsed < 1000) {
            this.alpha = (1000 - elapsed) / 500;

        } else {
            this.alpha = 0;
            _done();
        }
    }

    protected var _done :Function;
}
}
