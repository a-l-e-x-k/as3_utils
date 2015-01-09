package utils
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;

/**
 * ...
 * @author Alexey Kuznetsov
 */
public final class Misc
{
	public static function definitionExists(definition:String):Boolean
	{
		var exists:Boolean = true;
		try
		{
			getDefinitionByName(definition) as Class;
		}
		catch (e:Error)
		{
			exists = false;
		}
		return exists;
	}

	public static function addDarkenFilter(target:DisplayObjectContainer, alpha:Number = 0.3):void
	{
		var filter:ColorMatrixFilter = new ColorMatrixFilter(
				[1 - alpha, 0, 0, 0, 0,
					0, 1 - alpha, 0, 0, 0,
					0, 0, 1 - alpha, 0, 0,
					0, 0, 0, 1, 0]);

		target.filters = [filter];
	}

	public static function ceilWithPrecision(number:Number, degree:int):Number
	{
		return Math.ceil(number * Math.pow(10, degree)) / Math.pow(10, degree);
	}

	public static function floorWithPrecision(number:Number, degree:int):Number
	{
		return Math.floor(number * Math.pow(10, degree)) / Math.pow(10, degree);
	}

	public static function applyColorTransform(mc:MovieClip, color:uint):void
	{
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = color;
		mc.transform.colorTransform = colorTransform;
	}

	/**
	 * Returns random number including the one passed as limit (e.g. by passing 10 u'll get 10 back once in a while)
	 * @param limit
	 * @return
	 */
	public static function randomNumber(limit:int):int
	{
		var randomNumber:int = Math.floor(Math.random() * (limit + 1));
		return randomNumber;
	}

	public static function createRectangle(width:int, height:int, xx:Number = 0, yy:Number = 0, color:uint = 0x000000):Shape
	{
		var rect:Shape = new Shape();
		rect.graphics.beginFill(color);
		rect.graphics.drawRect(0, 0, width, height);
		rect.graphics.endFill();
		rect.x = xx;
		rect.y = yy;
		return rect;
	}

	public static function addSimpleButtonListeners(moviebutton:MovieClip):void
	{
		moviebutton.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void
		{
            if (e.currentTarget.currentFrame != 3)
			    e.currentTarget.gotoAndStop(2);
		});
		moviebutton.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop(1);
		});
		moviebutton.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop(3);
		});
		moviebutton.addEventListener(MouseEvent.MOUSE_UP, function (e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop(1);
		});
        moviebutton.mouseChildren = false;
        moviebutton.buttonMode = true;
	}

	public static function autosize(txt:TextField, maxWidth:int = 220):void
	{
		var myFormat:TextFormat = txt.getTextFormat();

		while (txt.textWidth > maxWidth)
		{
			myFormat = txt.getTextFormat();
			myFormat.size = int(myFormat.size) - 1;
			txt.setTextFormat(myFormat);
		}

		txt.y = 35 - int(myFormat.size) * 0.5;
	}

	public static function mask(obj:DisplayObjectContainer, x:int, y:int, width:int, height:int):void
	{
		var mask:Shape = new Shape();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(x, y, width, height);
		mask.graphics.endFill();
		obj.mask = mask;
	}

	public static function delayCallback(func:Function, delay:int):void
	{
		var timer:Timer = new Timer(delay, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (e:TimerEvent):void
		{
			func();
			timer = null;
		});
		timer.start();
	}

	public static function tryRemoveObject(child:DisplayObjectContainer, parent:DisplayObjectContainer):void
	{
		if (child != null && parent.contains(child)) parent.removeChild(child);
		child = null;
	}

	public static function get currentUNIXMillisecs():Number
	{
		return new Date().time;
	}

    public static function get currentUNIXSecs():Number
    {
        return Math.round(new Date().time / 1000);
    }

	public static function meters(pixels:Number):Number
	{
		return pixels / 30;
	}

	public static function radians(degs:Number):Number
	{
		return degs * Math.PI / 180;
	}

	public static function degrees(rad:Number):Number
	{
		return (180 * rad) / Math.PI;
	}

	public static function arrayToVector(arr:Array):Vector.<Number>
	{
		var r:Vector.<Number> = new Vector.<Number>();
		for each (var obj:Number in arr)
		{
			r.push(obj);
		}
		return r;
	}
}
}