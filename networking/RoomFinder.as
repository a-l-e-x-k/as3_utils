/**
 * Author: Alexey
 * Date: 9/8/12
 * Time: 7:42 PM
 */
package networking
{
    import model.*;
    import model.constants.GameConfig;

    import networking.init.PlayerioInteractions;

    import playerio.Connection;

    /**
     * Troubles with finding a room where game will be held
     * Or makes player's room opened to everyone.
     * Its job it to find room and receive "startGame" message
     */
    public class RoomFinder
    {
        private static var targetConnection:Connection;
        public static var targetGameType:String;
        private static var targetMapID:String;

        public static function findRoom(gameType:String, mapID:int = -1):void
        {
            trace("Searching for new room w type: " + gameType + " mapID: " + mapID);
            targetGameType = gameType;
            targetMapID = mapID.toString();
            var searchriteria:Object = {gameType: gameType, mapID: mapID, open: "1"};
            if (mapID != -1) //don't include it into search when map not specified (player doesnt care about map -> can connect to those who care)
            {
                searchriteria.mapID = mapID;
            }
            ServerTalker.client.multiplayer.listRooms(PlayerioInteractions.BASIC_ROOM_TYPE, searchriteria, 1, 0, onGotRoomList, PlayerioInteractions.handlePlayerIOError);
        }

        public static function playAgain():void
        {
            //TODO: handle "Play again" for RequestedBattles in some other way (so that you play with person with whom you just played)
            if (targetConnection && targetConnection.connected) //if room onwer did not close the connection
            {
                trace("Attempting to play again at prev connection...");
                targetConnection.addMessageHandler(MessageTypes.START_GAME, GameStartHelper.onStartGameMessageReceived);
                ServerTalker.playAgain(targetGameType, targetMapID);
            }
            else
            {
                trace("RoomFinder: playAgain: room owner closed connection. Finding other room");
                findRoom(targetGameType);
            }
        }

        private static function onGotRoomList(rooms:Array):void
        {
            trace("Rooms loaded: " + rooms.length);
            if (rooms.length > 0) //if there is a visible room here
            {
                ServerTalker.client.multiplayer.joinRoom(rooms[0].id, {gameVersion: GameConfig.GAME_VERSION}, onJoinedOtherRoom, PlayerioInteractions.handlePlayerIOError);  //random - so not 1st room in list but any
            }
            else
            {
                openOwnRoom(ServerTalker.serviceConnection);
            } //make our room visible for other dudes & create game
        }

        /**
         * No other opened rooms with target game type were found
         * Players make it's own room visible and waits for opponents
         * If it will be waiting for too long room will create NPC for player
         * @param connection
         */
        private static function openOwnRoom(connection:Connection):void
        {
            targetConnection = connection;
            GameStartHelper.setGameConnection(targetConnection);
            targetConnection.send(MessageTypes.OPEN_DOORS, targetGameType, targetMapID);
        }

        /**
         * Sends "ready" message to the room. And waits for "gameStart" message
         * @param connection
         */
        private static function onJoinedOtherRoom(connection:Connection):void
        {
            GameStartHelper.setGameConnection(connection);
            connection.send(MessageTypes.IM_READY);
        }
    }
}
