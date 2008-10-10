package {

import flash.display.*;
import flash.text.*;

public class Story extends Sprite
{
    public function Story (entry :Object)
    {
        var title :Label = new Label(entry.title, entry.link);
        addChild(title);

        var date :Label = new Label(entry.publishedDate);
        date.y = 20;
        addChild(date);

        var content :Label = new Label(entry.content);
        content.y = 40;
        addChild(content);
    }
}

}
