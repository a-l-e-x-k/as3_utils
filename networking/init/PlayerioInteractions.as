/**
 * Author: Alexey
 * Date: 7/22/12
 * Time: 12:34 AM
 */
package networking.init
{
    import events.RequestEvent;

    import flash.display.Stage;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import model.MessageTypes;
    import model.PopupsManager;
    import model.ServerTalker;
    import model.constants.GameConfig;
    import model.userData.UserData;

    import networking.special.ViralEvent;

    import playerio.Client;
    import playerio.Connection;
    import playerio.DatabaseObject;
    import playerio.Message;
    import playerio.PlayerIO;
    import playerio.PlayerIOError;
    import playerio.PlayerIORegistrationError;

    import utils.EventHub;
    import utils.Misc;
    import utils.t;

    public final class PlayerioInteractions
    {
        public static const BASIC_ROOM_TYPE:String = "basic";

        private static var client:Client;
        private static var plobjectLoaded:Boolean = false;
        private static var connectedToRoom:Boolean = false;
        private static var authDataReceived:Boolean = false;

        /**
         * @param emaillogin either login or email
         */
        public static function restorePassword(emaillogin:String):void
        {
            PlayerIO.quickConnect.simpleRecoverPassword(GameConfig.GAME_ID, emaillogin, function ():void
            {
                trace("PlayerioInteractions: restorePassword: success");
                PopupsManager.showRestorePasswordSent();
            }, handlePlayerIOError);
        }

        public static function login(stage:Stage, login:String, password:String):void
        {
            trace("PlayerioInteractions: login: GameConfig.GAME_ID" + GameConfig.GAME_ID + " login: " + login + " password: " + password);
            PlayerIO.quickConnect.simpleConnect(stage, GameConfig.GAME_ID, login, password, saveClient, handlePlayerIOError);
        }

        public static function register(stage:Stage, login:String, password:String, email:String):void
        {
            trace("PlayerioInteractions: register: login: " + login);
            PlayerIO.quickConnect.simpleRegister(stage, GameConfig.GAME_ID, login, password, email, "", "", null, "", saveClient, handlePlayerIOError);
        }

        private static function saveClient($client:Client):void
        {
            trace("PlayerioInteractions: saveClient: connectUserID: " + $client.connectUserId);
            /*
             * Need to set those to false because player may be loggin in agian, after pressing "Create Account" button in guest mode
             */
            plobjectLoaded = false;
            connectedToRoom = false;
            authDataReceived = false;

            EventHub.dispatch(new ViralEvent(ViralEvent.CONNECTED_TO_PLAYERIO, {client: $client})); //networking things will be inited now

            client = $client;

            //if (Networking.isLocal)
//           client.multiplayer.developmentServer = "127.0.0.1:8184"; //local dev serv in test mode

            //  {
//           client.multiplayer.developmentServer = "192.168.48.181:8184";
//            trace("client.multiplayer.: " + client.multiplayer);
            //} //local dev server for virtual machine

            loadPlayerObject();
            connectToRoom();
        }

        private static function loadPlayerObject():void
        {
            client.bigDB.loadMyPlayerObject(function (dbObj:DatabaseObject):void
            {
                if (dbObj.spells == null) //first time plobject is being created at server, so need to wait
                {
                    trace("PlayerioInteractions: plobjectLoaded: FIRST TIME ");
                    plobjectLoaded = true;
                    EventHub.dispatch(new ViralEvent(ViralEvent.PLAYER_OBJECT_LOADED, {obj: dbObj, coins: 0, firstTime: true}));
                    tryDispatchInitComplete();
                }
                else
                {
                    client.payVault.refresh(function ():void
                    {
                        trace("PlayerioInteractions: plobjectLoaded: ");
                        plobjectLoaded = true;
                        EventHub.dispatch(new ViralEvent(ViralEvent.PLAYER_OBJECT_LOADED, {obj: dbObj, coins: 0})); //set coins to client.payVault.coins
                        tryDispatchInitComplete();
                    }, handlePlayerIOError);
                }
            }, handlePlayerIOError);
        }

        private static function connectToRoom():void
        {
            var roomID:String = UserData.isGuest ? "" : UserData.uid;
            trace("PlayerioInteractions: connectToRoom: uid: " + UserData.uid);
            client.multiplayer.createJoinRoom(roomID, BASIC_ROOM_TYPE, false, null,
                    {
                        theboss: true,
                        gameVersion:GameConfig.GAME_VERSION
                    }, onConnectedToRoom, handlePlayerIOError);
        }

        private static function onConnectedToRoom(connection:Connection):void
        {
            trace("PlayerioInteractions: onConnectedToRoom: ");
            connectedToRoom = true;
            EventHub.dispatch(new ViralEvent(ViralEvent.CONNECTED_TO_PLAYERIO_ROOM, connection));
            connection.addMessageHandler(MessageTypes.AUTH_DATA, onAuthDataReceived);
            tryDispatchInitComplete();
        }

        private static function onAuthDataReceived(m:Message):void
        {
            trace("PlayerioInteractions: onAuthDataReceived: ");
            ServerTalker.serviceConnection.removeMessageHandler(MessageTypes.AUTH_DATA, onAuthDataReceived);
            EventHub.dispatch(new ViralEvent(ViralEvent.RECEIVED_AUTH_DATA, m));
            authDataReceived = true;
            tryDispatchInitComplete();
        }

        public static function handlePlayerIOError(error:PlayerIOError):void
        {
            trace("[Error] Playerio error");
            trace(error);
            trace("Error error ID: " + error.errorID);
            trace("Error type: " + error.type);
            trace("Error message: " + error.message);

            if (error.message.toString().indexOf("Stream Error") != -1)
            {
                PopupsManager.showStreamErrorPopup();
            }
            else if (error.message.toString().indexOf("when disconnected from server") != -1)
            {
                PopupsManager.showSendWhenDisconnectedPopup();
            }
            else if (error.message.toString().indexOf("Unable to connect to the API due to ioError") != -1)
            {
                PopupsManager.showStreamErrorPopup();
            }
            else if (error is PlayerIORegistrationError)
            {
                var regError:PlayerIORegistrationError = error as PlayerIORegistrationError;
                var msg:String = (regError.emailError ? regError.emailError + "\n" : "");
                msg += (regError.passwordError ? regError.passwordError + "\n" : "");
                msg += (regError.usernameError ? regError.usernameError + "\n" : "");
                PopupsManager.showMessagePopup(msg);
            }
            else
            {
                PopupsManager.showMessagePopup(error.message);
            }

            writeErrorLogMessage(error);
        }

        private static function writeErrorLogMessage(error:PlayerIOError):void
        {
            if (client != null)
            {
                client.errorLog.writeError(error.name, error.message, error.getStackTrace(), { uid: UserData.uid });
            }
            else
            {
                Misc.delayCallback(function ():void
                {
                    writeErrorLogMessage(error);
                }, 500);
            }
        }

        private static function tryDispatchInitComplete():void
        {
            trace("PlayerioInteractions: tryDispatchInitComplete: plo: " + plobjectLoaded + " con: " + connectedToRoom + " aurh: " + authDataReceived);
            if (plobjectLoaded && connectedToRoom && authDataReceived)
            {
                EventHub.dispatch(new ViralEvent(ViralEvent.START_DATA_LOADED));
            }
        }

        public static function buyCoins(coinsAmount:int):void
        {
            trace("client.payVault.getBuyCoinsInfo");
            client.payVault.getBuyCoinsInfo(
                    "paypal",									//Provider name
                    {											//Purchase arguments
                        coinamount: coinsAmount,						//(See table below)
                        currency: "USD",
                        item_name: coinsAmount + " Coins"//,
                        //sandbox: true
                    },
                    //Success handler
                    function (info:Object):void
                    {
                        t.obj(info);
                        //Open paypal in new window
                        navigateToURL(new URLRequest(info.paypalurl), "_blank");
                        waitForCoinsArrival(UserData.coins);
                    },
                    //Error handler
                    function (e:PlayerIOError):void
                    {
                        trace("Unable to buy coins", e)
                    }
            )

        }

        private static function waitForCoinsArrival(coinsBefore:int):void
        {
            client.payVault.refresh(function ():void
            {
                if (client.payVault.coins > coinsBefore)
                {
                    PopupsManager.showCoinsArrival(client.payVault.coins - coinsBefore);
                    UserData.coins = client.payVault.coins;
                    EventHub.dispatch(new RequestEvent(RequestEvent.PLAYER_UPDATED));
                }
                else
                {
                    Misc.delayCallback(function ():void
                    {
                        waitForCoinsArrival(coinsBefore);
                    }, 500);
                }
            }, handlePlayerIOError);
        }
    }
}
