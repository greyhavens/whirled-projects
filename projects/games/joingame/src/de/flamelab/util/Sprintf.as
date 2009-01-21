package de.flamelab.util {
/**
 * class Sprintf
 * static methods for string formatting
 * 
 * @author roland koch, flame@flamelab.de
 * @version 22.12.2006
 * @documentation http://lab.flamelab.de/projects/astoolbox/index.html
 * 
 */

public class Sprintf {
	
	public static var FILLSIGN:String = " "; // default fill sign
	public static var ADJUSTMENT:Number = 0; // default alignment 0:left, 1:right
	public static var PRECISION:Number = 6; // default precision
	
	/**
	 * format string
	 * @param format formatting string
	 * @param mixed arguments
	 * @return formated string	 */
	public static function format(format:String):String{
		
		// no format provided
		if(format == "" || format == null) return "";
		
		// extract format operations
		
		var formatIndex:Number = 0; // index in format
		var delimiterIndex:Number = 0; // position of delimiter
		var result:String = ""; // resultstring
		var argsIndex:Number = 1; // argument index
		var char:String; // current char
		var isBreak:Boolean; // end of format operation
		var fillSign:String; // sign used for filling
		var opIndex:Number; // index of format instruction
		var length:Number; // length of format output
		var adjustment:Number; // adjustment
		var precision:Number; // precision for float
		var order:Number; // order number
		var isPrecision:Boolean; // precision detection
		var isOrder:Boolean; // order detection
		
		while (formatIndex < format.length) {
			
			// get next occurence of delimiter %
			// no more occurences
			if((delimiterIndex = format.indexOf("%", formatIndex)) == -1){
				result += format.substr(formatIndex);
				break;
			}

			// extract format operation
			result += format.substring(formatIndex, delimiterIndex);
			
			formatIndex = delimiterIndex + 1;
			
			// preset values for each match
			fillSign = Sprintf.FILLSIGN;
			adjustment = Sprintf.ADJUSTMENT;
			precision = Sprintf.PRECISION;
			order = 0;
			length = 0;
			opIndex = 0;
			var tmp:Number = 0; // temp store value
			isBreak = false;
			isPrecision = false;
			isOrder = false;
			var sarg:Number = 0; //temp arg value
			
			while(!isBreak && formatIndex < format.length){
				
				// interpret format rules
				switch(char = format.charAt(formatIndex)){
				
					// flags
					case "-": // adjustment
						if(opIndex == 0) adjustment = 1;
						break;
				
					// numbers
					case "0": // 0 can be fillsign or length or precision value
						if (opIndex < 1) fillSign = "0";
						else tmp *= 10;
						if(isPrecision) precision = tmp;
						else if(isOrder) order = tmp;
						else length = tmp;
						opIndex++;
						break;
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
						if(opIndex > 1) tmp = tmp * 10 + Number(char);
						else tmp = Number(char);
						if(isPrecision) precision = tmp;
						else if(isOrder) order = tmp;
						else{
							opIndex++;
							length = tmp;
						}
						break;
					
					// order flags						
					case "$":
						order = length;
						isOrder = true;
						length = 0;
						break;
						
					// decimal digits
					case ".":
						opIndex = 0;
						isPrecision = true;
						break;
					
					// types
					case "u": // unsigned decimal				
					case "d": // signed decimal
						isBreak = true;
						result += postFormat(formatDecimal(arguments[isOrder ? order : argsIndex++], (char == "d")), length, fillSign, adjustment);
						break;
					
					case "f": // float
						isBreak = true;
						result += postFormat(formatFloat(arguments[isOrder ? order : argsIndex++], precision), length, fillSign, adjustment);
						break;
						
					case "s": // string
						isBreak = true;
						result += postFormat(formatString(arguments[isOrder ? order : argsIndex++]), length, FILLSIGN, ADJUSTMENT);
						break;
						
					case "x":
					case "X":
						isBreak = true;
						result += postFormat(formatHex(arguments[isOrder ? order : argsIndex++], (char == "X")), length, FILLSIGN, ADJUSTMENT);
						break;
						
					case "b":
						isBreak = true;
						result += postFormat(formatBin(arguments[isOrder ? order : argsIndex++]), length, FILLSIGN, ADJUSTMENT);
						break;
						
					case "o":
						isBreak = true;
						result += postFormat(formatOct (arguments[isOrder ? order : argsIndex++]), length, FILLSIGN, ADJUSTMENT);
						break;
					
				}
				
				formatIndex++;
				
			}
			
		}

		return result;
		
	}
	
	/**
	 * format output
	 * @param value value to format
	 * @param length length of format
	 * @param fill fill char
	 * @param adjustment orientation
	 * @return formated value	 */
	private static function postFormat(value:String, length:Number, fill:String, adjustment:Number):String{
		
		var tmp:Array = value.split(".");
		
		if(tmp[0].length > length) return tmp[0];
		
		while(tmp[0].length < length) {
			if(adjustment == 1) tmp[0]  += fill;
			else tmp[0] = fill + tmp[0];
			
		}
		
		if(tmp[1]) tmp[0] += "." + tmp[1]
		
		return tmp[0];
		
	}
	
	/**
	 * format decimal 
	 * @param value value to format
	 * @param signed boolean value
	 * @return formated value	 */
	private static function formatDecimal(value:Number, signed:Boolean):String{
		
		if(!signed) value = Math.abs(value);
		
		return String(Math.floor(value));
			
	}
	
	/**
	 * format binary 
	 * @param value value to format
	 * @return formated value
	 */
	private static function formatBin(value:Number):String{
		
		return value.toString(2);
			
	}
	
	/**
	 * format octal 
	 * @param value value to format
	 * @return formated value
	 */
	private static function formatOct(value:Number):String{
		
		return value.toString(8);
			
	}
	
	/**
	 * format hex 
	 * @param value value to format
	 * @param upper upper or lower case
	 * @return formated value
	 */
	private static function formatHex(value:Number, upper:Boolean):String{
		
		var tmp:String = value.toString(16);
		
		if(upper) return "0x" +  tmp.toUpperCase();
		return "0x" +  tmp.toLowerCase();
			
	}
	
	/**
	 * format float 
	 * @param value value to format
	 * @param precision precision of formatting
	 * @return formated value
	 */
	private static function formatFloat(value:Number, precision:Number):String{
		
		var svalue:String = String(value);
		
		var tmp:Array = svalue.split(".");
		
		// no float number
		if(tmp.length != 2) tmp[1] = "";
		
		// precision is 0
		if(precision == 0) return tmp[0];

		var result:String = tmp[0] + ".";
		
		// format precision
		if(tmp[1].length > precision) result += tmp[1].substr(0, precision);
		else {
			precision -= tmp[1].length;
			result += tmp[1];
			while(precision-- > 0) result += "0";
		}
		
		return result;
			
	}
	
	/**
	 * format string 
	 * @param value value to format
	 * @return formated value
	 */
	private static function formatString(value:String):String{
		
		return value;
			
	}
	
}
}