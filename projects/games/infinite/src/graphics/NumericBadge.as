package graphics
{
    import flash.text.TextField;
    
    public class NumericBadge extends TextField
    {
        public function NumericBadge (value:int)
        {
            this.htmlText = "<font size='30' color='#ff0000' face='Helvetica, Arial, _sans'><p align='left'>"+value+"</p></font>";
        }
    }
}