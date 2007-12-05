package def {

/**
 * Typesafe storage for single elements of enemy or ally waves.
 */
public class WaveElementDefinition
{
    public var typeName :String;
    public var count :int;
    
    public function WaveElementDefinition (typeName :String, count :int)
    {
        this.typeName = typeName;
        this.count = count;
    }

    public function toString () :String
    {
        return "Wave element [" + count + " x " + typeName + "]";
    }
}

}
