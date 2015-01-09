package networking
{
    import flash.display.Stage;
    import flash.events.Event;

    import networking.networkers.DummyNetworker;
    import networking.networkers.INetworker;

    /**
     * ...
     * @author Alexey Kuznetsov
     */
    public class Networking
    {
        private static var _flashVars:Object;
        private static var _socialNetworker:INetworker;

        /**
         * Called before init so that listeners may be added before init() as well
         * @param flashVars
         */
        public static function createNetworker(flashVars:Object):void
        {
            _flashVars = flashVars;

//            if (_flashVars.fb_application_id)
//            {
//                _socialNetworker = new FacebookNetworker();
//            }
//            else
//            {
                _socialNetworker = new DummyNetworker(_flashVars);
//            }
        }

        /**
         * Inits social networking things, multiplayer services.
         * @param stage
         * @param multiplayer if true, initing as Playerio multiplayer view.game with appID passed.
         * @param appID appID at Playerio web services
         */
        public static function init(stage:Stage, multiplayer:Boolean = false, appID:String = ""):void
        {
            _socialNetworker.init(_flashVars, appID);
            //InitManager.init();
        }

        public static function getUserFriends():void
        {
            _socialNetworker.getUserFriends();
        }

        public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            _socialNetworker.dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            _socialNetworker.dispatcher.removeEventListener(type, listener, useCapture);
        }

        public static function hasEventListener(type:String):Boolean
        {
            return _socialNetworker.dispatcher.hasEventListener(type);
        }

        public static function dispatchEvent(event:Event):Boolean
        {
            return _socialNetworker.dispatcher.dispatchEvent(event);
        }

        public static function get isLocal():Boolean
        {
            return _socialNetworker is DummyNetworker;
        }

        public static function get isFB():Boolean
        {
//            return _socialNetworker is FacebokNetworker;
            return false;
        }

        public static function get appID():String
        {
            return _socialNetworker.appID;
        }

        public static function getUserData():void
        {
            _socialNetworker.getUserData();
        }

        public static function get uid():String
        {
            return _socialNetworker.uid;
        }

        public static function showSocialInvitePopup():void
        {
            _socialNetworker.showSocialInvitePopup();
        }

        public static function get coreLink():String
        {
            return _socialNetworker.coreLink;
        }
    }
}