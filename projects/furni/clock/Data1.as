package {

public class Data
{
    public static const data :XML = <remixable-data>
            <data name="faceCenter" type="Point" value="100, 100"/>
            <data name="hourPoint" type="Point" value="40, 130"/>
            <data name="minutePoint" type="Point" value="40, 130"/>
            <data name="secondPoint" type="Point" value="40, 130"/>
            <data name="facePosition" type="Point" value="50, 50"/>
            <data name="decorationPoint" type="Point"/> <!-- no value -->
            <data name="smoothSeconds" type="Boolean" value="true"/>
        </remixable-data>;

    [Embed(source="face.png")]
    public static const face :Class;

    [Embed(source="hour.png")]
    public static const hourHand :Class;

    [Embed(source="minute.png")]
    public static const minuteHand :Class;

    [Embed(source="second.png")]
    public static const secondHand :Class;

    [Embed(source="1x1blank.png")]
    public static const decoration :Class;
}
}
