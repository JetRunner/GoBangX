import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1

ApplicationWindow {
    id:entranceWindow;
    property var default_font: "微软雅黑";
    font.family: entranceWindow.default_font;
    visible: true
    minimumWidth: 1024
    minimumHeight: 768
    title: qsTr("五子棋X GoBangX")
     MessageDialog {
         id: messageDialog
         title: "关于我们"
         text: "许灿文/王雪/韩哲昊/徐劲草 ©2017"
         informativeText :"五子棋GoBang 使用Qt Quick 开发，已全面开源于Github。"
         onAccepted: {
             messageDialog.close();
         }
         Component.onCompleted: visible = false
     }

    Rectangle{
        id:root;
        color:"#FFFFFF";
        width: parent.width;
        height:parent.height;
        anchors.centerIn: parent;
    Item{
        id:welcome;
        anchors.centerIn: parent;
        width:395;
        height:295;
    Image {
          id:logo;
          width: 395;
          height:91;
          source: "img/gobang.png"
     }
    Button{
        id:beginGame;
        text:"开始游戏";
        anchors.horizontalCenter:parent.horizontalCenter;
        anchors.top:logo.bottom;
        anchors.topMargin: 50;
        width:100;
        onClicked: function(){
            restart.clicked();
            welcome.visible=false;
            game.visible=true;
            bamboo.opacity=0.3;
        }
    }
    Button{
        id:aboutUs;
        text:"关于我们";
        anchors.horizontalCenter:parent.horizontalCenter;
        anchors.top:beginGame.bottom;
        anchors.topMargin: 20;
        width:100;
        onClicked: function (){
            messageDialog.open();
        }
    }
    Button{
        id:exitGame;
        text:"退出游戏";
        anchors.horizontalCenter:parent.horizontalCenter;
        anchors.top:aboutUs.bottom;
        anchors.topMargin: 20;
        width:100;
        onClicked: function (){
            Qt.quit();
        }
    }
    }
    Image {
          id:bamboo;
          width:544*0.9;
          height:359*0.9;
          source: "img/bamboo.png";
          anchors.left:parent.left;
          anchors.bottom:parent.bottom;
     }
    Item{
        id:game;
        width:960;
        height:640;
        visible: false;
        anchors.centerIn: parent;
        property var board: [];
        property var turn: 1;
        property var winner: 0;
        property var total: 1;
        property var burning: false;
        property var blocking: false;
        property var blinding: 0;


    Rectangle{
        id:chessBoard;
        property var operation: 0;
        property var paintX: 0;
        property var paintY: 0;
        Rectangle {
        Rectangle {
            width:592;
            height:592;
            anchors.centerIn: parent;
            color:"#00FFFFFF";
            Canvas{
                    id:canvas;
                    anchors.fill: parent;
                    visible: !(game.blinding===game.turn);
                    onPaint: {
                        var ctx = getContext("2d");
                        if(chessBoard.operation===0){
                            ctx.clearRect(0,0,canvas.width,canvas.height);
                        }

                        if(chessBoard.operation===1){
                            ctx.beginPath();
                                ctx.fillStyle = game.turn===1 ? "white":"black";
                                var circle = {
                                    x : chessBoard.paintX,    //圆心的x轴坐标值
                                    y : chessBoard.paintY,    //圆心的y轴坐标值
                                    r : 15      //圆的半径
                                };
                                //以canvas中的坐标点(100,100)为圆心，绘制一个半径为50px的圆形
                                ctx.arc(circle.x, circle.y, circle.r, 0, Math.PI * 2, true);
                                //按照指定的路径绘制弧线
                                ctx.fill();
                                ctx.stroke();
                        }
                        if(chessBoard.operation===2){
                            ctx.clearRect(chessBoard.paintX-48,chessBoard.paintY-48,96,96);
                        }
                        if(chessBoard.operation===3){
                            ctx.beginPath();
                            ctx.fillStyle="#646464";
                            ctx.strokeRect(chessBoard.paintX-14,chessBoard.paintY-14,28,28);//绘制矩形轮廓
                            ctx.fillRect(chessBoard.paintX-14,chessBoard.paintY-14,28,28);//绘制矩形
                        }

                    }
              }



            MouseArea {
                id:mouseArea;
                anchors.fill: parent
                onClicked: {
                    var x=Math.round(this.mouseX/32);
                    var y=Math.round(this.mouseY/32);
                    chessBoard.paintX= 8+x*32;
                    chessBoard.paintY= 8+y*32;
                    if(game.burning===1){
                        for(var i=x-1;i<=x+1;i++){
                            for(var j=y-1;j<=y+1;j++){
                                game.board[i][j]=0;
                            }
                        }
                        game.total++;
                        if(game.turn===game.blinding)game.blinding=0;
                        game.turn=game.turn%2+1;
                        chessBoard.operation=2;
                        game.burning=0;
                        canvas.requestPaint();
                    }
                    else if(game.blocking===1){
                        if(game.board[x][y]===0){
                        if(skill.obstacle_counter===3){
                            skill.obstacle_counter=0;
                            game.blocking=0;
                        }
                        else{
                            game.board[x][y]=3;
                            chessBoard.operation=3;
                            skill.obstacle_counter++;
                            canvas.requestPaint();
                        }
                        }
                    }

                    else if(game.board[x][y]===0){
                        game.board[x][y]=game.turn;
                        game.total++;
                        if(game.turn===game.blinding)game.blinding=0;
                        game.turn=game.turn%2+1;
                        chessBoard.operation=1;
                        canvas.requestPaint();
                        if(isWin(x,y)){
                            mouseArea.enabled=false;
                            game.winner=game.turn;
                        }
                    }
                    function isWin(x, y)
                    {
                        return f1(x,y) || f2(x,y) || f3(x,y) || f4(x,y);
                    }

                    function f1(x, y)
                    {
                        for(var i = 0; i < 5; ++i)
                        {
                            if(y - i >= 0 &&
                                y + 4 - i <= 19 &&
                                    //竖直方向比较
                                game.board[x][y-i] === game.board[x][y+1-i] &&
                                game.board[x][y-i] === game.board[x][y+2-i] &&
                                game.board[x][y-i] === game.board[x][y+3-i] &&
                                game.board[x][y-i] === game.board[x][y+4-i] )
                             return 1;
                        }
                        return 0;
                    }

                    function f2(x, y)
                    {
                        var i;
                        for (i = 0; i < 5; i++)
                        {
                            if(x - i >= 0 &&
                               x + 4 - i <= 19 &&
                                    //水平方向比较
                               game.board[x - i][y] === game.board[x + 1 - i][y] &&
                               game.board[x - i][y] === game.board[x + 2 - i][y] &&
                               game.board[x - i][y] === game.board[x + 3 - i][y] &&
                               game.board[x - i][y] === game.board[x + 4 - i][y])
                               return 1;
                        }
                        return 0;
                    }

                    function f3(x, y)
                    {
                        for (var i = 0; i < 5; i++)
                        {
                            //斜着比较
                            if(x - i >= 0 &&
                               y - i >= 0 &&
                               x + 4 - i <= 19 &&
                               y + 4 - i <= 19 &&
                               game.board[x - i][y - i] === game.board[x + 1 - i][y + 1 - i] &&
                               game.board[x - i][y - i] === game.board[x + 2 - i][y + 2 - i] &&
                               game.board[x - i][y - i] === game.board[x + 3 - i][y + 3 - i] &&
                               game.board[x - i][y - i] === game.board[x + 4 - i][y + 4 - i])
                               return 1;
                        }
                        return 0;
                    }

                    function f4(x, y)
                    {
                        for (var i = 0; i < 5; i++)
                        {
                            //斜着比较
                            if(x + i <= 19 &&
                               y - i >= 0 &&
                               x - 4 + i >= 0 &&
                               y + 4 - i <= 19 &&
                               game.board[x + i][y - i] === game.board[x - 1 + i][y + 1 - i] &&
                               game.board[x + i][y - i] === game.board[x - 2 + i][y + 2 - i] &&
                               game.board[x + i][y - i] === game.board[x - 3 + i][y + 3 - i] &&
                               game.board[x + i][y - i] === game.board[x - 4 + i][y + 4 - i])
                               return 1;
                        }
                        return 0;
                    }

                }
            }
        }
        Image {
            id:chessBoardBg;
            z:-1;
            width:640;
            height:640;
            source: "img/chessboard.png"
            anchors.centerIn: parent;
            opacity:0.7;
        }

        anchors.verticalCenter: parent.verticalCenter;
        anchors.left:parent.left;
        color:"#00FFFFFF";
        width:640;
        height:640;
        }
        color:"#98FFFFFF";
        width:640;
        height:640;
    }
    Item{
        id:gameStatus;
        anchors.top:chessBoard.top;
        anchors.left: chessBoard.right;
        anchors.leftMargin: 50;
        Text{
            id:urTurn;
            font.family: entranceWindow.default_font;
            font.pixelSize : 30;
            text: game.winner ? (game.winner ===1 ? "白方获胜!" : "黑方获胜!"):(game.turn === 1 ? "黑方执子" : "白方执子");
        }
        Text{
            id:totalRound;
            font.family: entranceWindow.default_font;
            anchors.left:urTurn.right;
            anchors.leftMargin: 30;
            anchors.verticalCenter: urTurn.verticalCenter;
            anchors.topMargin: 20;
            font.pixelSize : 25;
            text: "第"+game.total+"回合";
        }
    }

    Item{
        id:skill;
        anchors.left:chessBoard.right;
        anchors.leftMargin:20;
        anchors.top:gameStatus.bottom;
        anchors.topMargin: 70;
        property var obstacle_set_amount: game.turn === 1 ? obstacle_set_black:obstacle_set_white;
        property var blind_light_amount: game.turn === 1 ? blind_light_black:blind_light_white;
        property var burn_down_amount: game.turn === 1 ? burn_down_black:burn_down_white;
        property var burn_down_black: 2;
        property var burn_down_white: 2;
        property var obstacle_set_black: 2;
        property var obstacle_set_white: 2;
        property var blind_light_black: 2;
        property var blind_light_white: 2;
        property var obstacle_counter: 0;
        Image{
            id:skillIcon;
            source: "img/skill.png";
            height:75;
            width:300;
        }

        Item{
            id:skill_obstacle_set;
            anchors.top:skillIcon.bottom;

            Image{
                id:obstacle_set_icon;
                height:40;
                width:40;
                source: "img/obstacle_set.png";
            }
            Text{
                id:obstacle_set_describe;
                text:"放置障碍:这回合你可以放置3个障碍。";
                anchors.leftMargin: 20;
                anchors.left:obstacle_set_icon.right;
                anchors.verticalCenter: obstacle_set_icon.verticalCenter;
                font.family: entranceWindow.default_font;
            }
            Item{
                id:obstacle_set_cast;
                anchors.top:obstacle_set_icon.bottom;
                anchors.topMargin: 10;
                anchors.left:obstacle_set_describe.left;
                Text{
                    anchors.verticalCenter: parent.verticalCenter;
                    text:"X"+skill.obstacle_set_amount;
                    font.family: entranceWindow.default_font;
                    font.pixelSize: 20;
                }
                Button{
                    anchors.left:parent.left;
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.leftMargin: 190;
                    text:"使用";
                    height:40;
                    width:50;
                    onClicked:function(){
                        if(game.blocking===1)return;
                        if(game.turn===1){
                            if(skill.obstacle_set_black){
                                skill.obstacle_set_black--;
                                game.blocking=1;
                                game.burning=0;
                            }
                        }
                        else {
                            if(skill.obstacle_set_white){
                                skill.obstacle_set_white--;
                                game.blocking=1;
                                game.burning=0;
                            }
                        }
                    }
                }
            }
        }
        Item{
            id:skill_blind_light;
            anchors.top:skill_obstacle_set.bottom;
            anchors.topMargin: 80;
            Image{
                anchors.top:parent.top;
                id:blind_light_icon;
                height:40;
                width:40;
                source: "img/blind_light.png";
            }
            Text{
                id:blind_light_describe;
                text:"致盲之光:下回合对手将看不见棋盘。"
                anchors.leftMargin: 20;
                anchors.left:blind_light_icon.right;
                anchors.verticalCenter: blind_light_icon.verticalCenter;
                font.family: entranceWindow.default_font;
            }
            Item{
                id:blind_light_cast;
                anchors.top:blind_light_icon.bottom;
                anchors.topMargin: 10;
                anchors.left:blind_light_describe.left;
                Text{
                    anchors.verticalCenter: parent.verticalCenter;
                    text:"X"+skill.blind_light_amount;
                    font.family: entranceWindow.default_font;
                    font.pixelSize: 20;
                }
                Button{
                    anchors.left:parent.left;
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.leftMargin: 190;
                    text:"使用";
                    height:40;
                    width:50;
                    onClicked:function(){
                        if(game.blinding)return;
                        else{
                            if(game.turn===1){
                                if(skill.blind_light_black){
                                    skill.blind_light_black--;
                                }
                                game.blinding=2;
                            }
                            else {
                                if(skill.blind_light_white){
                                    skill.blind_light_white--;
                                }
                                game.blinding=1;
                            }
                        }
                    }
                }
            }
        }
        Item{
                    id:skill_burn_down;
                    anchors.top:skill_blind_light.bottom;
                    anchors.topMargin: 80;
                    Image{
                        anchors.top:parent.top;
                        id:burn_down_icon;
                        height:40;
                        width:40;
                        source: "img/burn_down.png";
                    }
                    Text{
                        id:burn_down_describe;
                        text:"火烧联营:点选目标，烧毁选择3*3范围的棋子。"
                        anchors.leftMargin: 20;
                        anchors.left:burn_down_icon.right;
                        anchors.verticalCenter: burn_down_icon.verticalCenter;
                        font.family: entranceWindow.default_font;
                    }
                    Item{
                        id:burn_down_cast;
                        anchors.top:burn_down_icon.bottom;
                        anchors.topMargin: 10;
                        anchors.left:burn_down_describe.left;
                        Text{
                            anchors.verticalCenter: parent.verticalCenter;
                            text:"X"+skill.burn_down_amount;
                            font.family: entranceWindow.default_font;
                            font.pixelSize: 20;
                        }
                        Button{
                            anchors.left:parent.left;
                            anchors.verticalCenter: parent.verticalCenter;
                            anchors.leftMargin: 190;
                            text:"使用";
                            height:40;
                            width:50;
                            onClicked:function(){
                                if(game.burning===1)return;
                                if(game.turn===1){
                                    if(skill.burn_down_black){
                                        skill.burn_down_black--;
                                        game.burning=1;
                                        game.blocking=0;
                                    }
                                }
                                else {
                                    if(skill.burn_down_white){
                                        skill.burn_down_white--;
                                        game.burning=1;
                                        game.blocking=0;
                                    }
                                }
                            }
                        }
                    }
                }
    }

    Item{
        anchors.bottom:chessBoard.bottom;
        anchors.left: chessBoard.right;
        anchors.leftMargin: 60;
    Button{
        id:back;
        text:"返回菜单";
        anchors.bottom:parent.bottom;
        width:100;
        onClicked: function (){
            welcome.visible=true;
            game.visible=false;
            bamboo.opacity=1;
        }
    }
    Button{
        id:restart;
        text:"重开一局";
        anchors.bottom:parent.bottom;
        anchors.left: back.right;
        anchors.leftMargin: 30;
        width:100;
        onClicked: function(){
            mouseArea.enabled=true;
            game.turn=1;
            game.total=1;
            game.board=[];
            game.winner=0;
            chessBoard.operation=0;
            skill.burn_down_black=2;
            skill.burn_down_white=2;
            skill.obstacle_set_white=2;
            skill.obstacle_set_black=2;
            skill.blind_light_white=2;
            skill.blind_light_black=2;
            canvas.requestPaint();
            for(var i=0;i<=19;i++){
                game.board[i]=new Array();
                for(var j=0;j<=19;j++){
                    game.board[i][j]=0;
                }
            }
        }
    }
    }
    }
    }

}
