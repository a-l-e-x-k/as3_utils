/**
 * Author: Alexey
 * Date: 10/13/12
 * Time: 12:40 AM
 */
package utils
{
    import fl.motion.AdjustColor;

    import flash.filters.ColorMatrixFilter;

    public class ColorUtils
	{
        public static function getColorMatrixFilter(hue:int, saturation:int, brightness:int, contrast:int):ColorMatrixFilter
        {
            var colorFilter:AdjustColor = new AdjustColor();
            //all 4 must contain a value of an integer, if one is not set, it will not work
            colorFilter.hue = hue;
            colorFilter.saturation = saturation;
            colorFilter.brightness = brightness;
            colorFilter.contrast = contrast;

            var mMatrix:Array = colorFilter.CalculateFinalFlatArray();
            return new ColorMatrixFilter(mMatrix);
        }

		public static function HexToDec(hex:String):Array
		{
			var a:int = giveDec(hex.substring(0, 1));
			var b:int = giveDec(hex.substring(1, 2));
			var c:int = giveDec(hex.substring(2, 3));
			var d:int = giveDec(hex.substring(3, 4));
			var e:int = giveDec(hex.substring(4, 5));
			var f:int = giveDec(hex.substring(5, 6));

			var red:int = (a * 16) + b;
			var green:int = (c * 16) + d;
			var blue:int = (e * 16) + f;

			return [red, green, blue];
		}

		public static function decToHex(red:int, green:int, blue:int):String
		{
			var a:String = giveHex(Math.floor(red / 16));
			var b:String = giveHex(red % 16);
			var c:String = giveHex(Math.floor(green / 16));
			var d:String = giveHex(green % 16);
			var e:String = giveHex(Math.floor(blue / 16));
			var f:String = giveHex(blue % 16);

			return a + b + c + d + e + f;
		}

		public static function giveDec(hex:String):int
		{
			var value:int;

			if (hex == "A")
				value = 10;
			else if (hex == "B")
				value = 11;
			else if (hex == "C")
				value = 12;
			else if (hex == "D")
				value = 13;
			else if (hex == "E")
				value = 14;
			else if (hex == "F")
				value = 15;
			else
				value = int(hex);

			return value;
		}

		public static function giveHex(dec:int):String
		{
			var value:String;

			if (dec == 10)
				value = "A";
			else if (dec == 11)
				value = "B";
			else if (dec == 12)
				value = "C";
			else if (dec == 13)
				value = "D";
			else if (dec == 14)
				value = "E";
			else if (dec == 15)
				value = "F";
			else
				value = "" + dec;

			return value;
		}

		/**
		 * Converts an RGB color value to HSL. Conversion formula
		 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
		 * Assumes r, g, and b are contained in the set [0, 255] and
		 * returns h, s, and l in the set [0, 1].
		 *
		 * @param   r       The red color value
		 * @param   g       The green color value
		 * @param   b       The blue color value
		 * @return  Array           The HSL representation
		 */
		public static function rgbToHsl(r:int, g:int, b:int):Array
		{
			r /= 255;
			g /= 255;
			b /= 255;

			var max:int = Math.max(r, g, b);
			var min:int = Math.min(r, g, b);
			var h:Number, s:Number, l:Number = (max + min) / 2;

			if (max == min)
			{
				h = s = 0; // achromatic
			}
			else
			{
				var d:Number = max - min;
				s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
				switch (max)
				{
					case r:
						h = (g - b) / d + (g < b ? 6 : 0);
						break;
					case g:
						h = (b - r) / d + 2;
						break;
					case b:
						h = (r - g) / d + 4;
						break;
				}
				h /= 6;
			}

			return [h, s, l];
		}

		/**
		 * Converts an HSL color value to RGB. Conversion formula
		 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
		 * Assumes h, s, and l are contained in the set [0, 1] and
		 * returns r, g, and b in the set [0, 255].
		 *
		 * @param   h       The hue
		 * @param   s       The saturation
		 * @param   l       The lightness
		 * @return  Array           The RGB representation
		 */
		public static function hslToRgb(h:Number, s:Number, l:Number):Array
		{
			var r:Number;
			var g:Number;
			var b:Number;

			if (s == 0)
			{
				r = g = b = l; // achromatic
			}
			else
			{
				var q:Number = l < 0.5 ? l * (1 + s) : l + s - l * s;
				var p:Number = 2 * l - q;
				r = hue2rgb(p, q, h + 1 / 3);
				g = hue2rgb(p, q, h);
				b = hue2rgb(p, q, h - 1 / 3);
			}

			return [r * 255, g * 255, b * 255];
		}

		public static function hue2rgb(p:Number, q:Number, t:Number):Number
		{
			if (t < 0) t += 1;
			if (t > 1) t -= 1;
			if (t < 1 / 6) return p + (q - p) * 6 * t;
			if (t < 1 / 2) return q;
			if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
			return p;
		}

		/**
		 * Converts an RGB color value to HSV. Conversion formula
		 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
		 * Assumes r, g, and b are contained in the set [0, 255] and
		 * returns h, s, and v in the set [0, 1].
		 *
		 * @param   r       The red color value
		 * @param   g       The green color value
		 * @param   b       The blue color value
		 * @return  Array           The HSV representation
		 */
		public static function rgbToHsv(r:Number, g:Number, b:Number):Array
		{
			r = r / 255;
			g = g / 255;
			b = b / 255;

			var max:Number = Math.max(r, g, b);
			var min:Number = Math.min(r, g, b);
			var h:Number = max;
			var s:Number;
			var d:Number = max - min;

			s = max == 0 ? 0 : d / max;

			if (max == min)
			{
				h = 0; // achromatic
			}
			else
			{
				switch (max)
				{
					case r:
						h = (g - b) / d + (g < b ? 6 : 0);
						break;
					case g:
						h = (b - r) / d + 2;
						break;
					case b:
						h = (r - g) / d + 4;
						break;
				}
				h /= 6;
			}

			return [h, s, max];
		}

		/**
		 * Converts an HSV color value to RGB. Conversion formula
		 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
		 * Assumes h, s, and v are contained in the set [0, 1] and
		 * returns r, g, and b in the set [0, 255].
		 *
		 * @param   h       The hue
		 * @param   s       The saturation
		 * @param   v       The value
		 * @return  Array           The RGB representation
		 */
		public static function hsvToRgb(h:Number, s:Number, v:Number):Array
		{
			var r:Number;
			var g:Number;
			var b:Number;

			var i:Number = Math.floor(h * 6);
			var f:Number = h * 6 - i;
			var p:Number = v * (1 - s);
			var q:Number = v * (1 - f * s);
			var t:Number = v * (1 - (1 - f) * s);

			switch (i % 6)
			{
				case 0:
					r = v;
					g = t;
					b = p;
					break;
				case 1:
					r = q;
					g = v;
					b = p;
					break;
				case 2:
					r = p;
					g = v;
					b = t;
					break;
				case 3:
					r = p;
					g = q;
					b = v;
					break;
				case 4:
					r = t;
					g = p;
					b = v;
					break;
				case 5:
					r = v;
					g = p;
					b = q;
					break;
			}

			return [r * 255, g * 255, b * 255];
		}
	}
}
