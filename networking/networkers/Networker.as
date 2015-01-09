/**
 * Author: Alexey
 * Date: 5/7/12
 * Time: 9:50 PM
 */
package networking.networkers
{
import flash.events.EventDispatcher;

public class Networker
{
	protected var _appID:String = "";
	protected var _uid:String = "";
	protected var _dispatcher:EventDispatcher = new EventDispatcher();

	public function Networker()
	{
	}

	public function get dispatcher():EventDispatcher
	{
		return _dispatcher;
	}

	public function get appID():String
	{
		return _appID;
	}

	public function get uid():String
	{
		return _uid;
	}
}
}
