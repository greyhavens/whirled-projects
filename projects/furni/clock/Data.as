package {

public class Data
{
    public static const data :XML = <remixable-data>
            <data name="faceCenter" type="Point" value="111, 157"/>
            <data name="hourPoint" type="Point" value="5, 39"/>
            <data name="minutePoint" type="Point" value="5, 49"/>
            <data name="facePosition" type="Point"/> <!-- no value -->
            <data name="decorationPoint" type="Point"/> <!-- no value -->
            <data name="smoothSeconds" type="Boolean" value="false"/>
        </remixable-data>;

    [Embed(source="brit_face.swf")]
    public static const face :Class;

    [Embed(source="brit_hour_hand.png")]
    public static const hourHand :Class;

    [Embed(source="brit_minute_hand.png")]
    public static const minuteHand :Class;

    [Embed(source="1x1blank.png")]
    public static const secondHand :Class;

    [Embed(source="1x1blank.png")]
    public static const decoration :Class;
}
}
