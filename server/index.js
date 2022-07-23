var websocket = require('ws');
var os = require('os');
var server = new websocket.Server({ port: 5000 });
var network = os.networkInterfaces();
// console.log(network);
console.log(network["Wi-Fi"])
var mode ;
var match_type;
var no_of_players;
var max_players;
var game_data = {}
var state = {}
var no_of_matches
var no_of_matches_done = 0
var ready_players = 0
var count = 3;
var timer_element
var score = {}




var interfaces = require('os').networkInterfaces();
console.log(interfaces)
  for (var devName in interfaces) {
    var iface = interfaces[devName];

    for (var i = 0; i < iface.length; i++) {
      var alias = iface[i];
      if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal)
        console.log(alias.address)
    }
  }



var lobby_made = false
console.log("server at port 9999");
console.log("helo")

server.on("connection", client => {
    if(server.clients.size == 1)
    {
        lobby_made = true
    }
    console.log("someone_joined");
    console.log("now i have "+server.clients.size)
    client.on("message", message => {
        data = JSON.parse(message)
        perform(client,data);

    });

    client.on("close", (code, reason) => {
        if (server.clients.size === 0)
        {
            mode = undefined;
            match_type = undefined;
            no_of_players = undefined;
            max_players = undefined;
            game_data = {};
            state = {};
            no_of_matches = undefined;
            no_of_matches_done = undefined;
            ready_players = 0;
            count = 0;
        }
        console.log("client_disconected");
    })
});

function perform(client,data)
{
    if (data["mes"] == "setup_match")
    {
        match_type = data["info"]["match_type"];
        max_players = data["info"]["max_players"];
        no_of_matches = data["info"]["no_of_matches"]
        var message = {
            "mes":"put_ip",
            "info":{
                "ip":network["Wi-Fi"][1]["address"]
            }
        }
        client.send(JSON.stringify(message))

    }
    if (data["mes"] == "client_ready")
    {
        ready_client(client,data["info"])
    }
    else if (data["mes"] == "initiate") 
    {
        initiate(client,data["info"]);
    }
    else if (data["mes"] == "player_dead") 
    {
        stop_match(client,data["info"])    
    }
    else if (data["mes"] == "new_match") 
    {
        new_match();
    }
    else if (data["mes"] == "regular_log")
    {
        update_player(client,data["info"]);
    }
    else if (data["mes"] == "enemy_deleted") 
    {
        delete_player(client,data['info']);
    }
    else if (data["mes"] == "bullet_shot")
    {
        bullet_shot(client,data["info"])
    }
    else if (data["mes"] == "swap_weapon")
    {
        weapon_swapped(client,data["info"]);
    }
    else if (data["mes"] == "pickup_weapon") 
    {
        weapon_picked(client,data["info"]);
    }
    else if (data["mes"] == "weapon_changed") 
    {
        weapon_changed(client,data["info"]);    
    }
    else if (data["mes"] == "weapon_reload") 
    {
        weapon_reload(client,data["info"]);    
    }

}

function stop_match(client,data)
{
    score[data["shooter"]] += 1
    console.log(score);
    no_of_matches_done += 1;
    console.log("no_of_mateches done" + no_of_matches_done);
    console.log("no_of_mateches "+no_of_matches);
    if (no_of_matches_done > no_of_matches)
    {
        mode = undefined;
        match_type = undefined;
        no_of_players = undefined;
        max_players = undefined;
        game_data = {};
        state = {};
        no_of_matches = undefined;
        no_of_matches_done = undefined;
        ready_players = 0;
        count = 0;
        for (let item of server.clients.keys())
        {
            // var message = {
            //     "mes":"stop_match",
            //     "id":data["id"],
            //     "info":{
            //         "data":data,
            //         "score":score
            //     }
            // }
            item.close();   //send(JSON.stringify(message));
        }
        return;
    }
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"stop_match",
            "id":data["id"],
            "info":{
                "data":data,
                "score":score
            }
        }
        item.send(JSON.stringify(message));
    }
    setTimeout(new_match,3000);
}

function new_match()
{

    var pos_count = 0
    for (let item of server.clients.keys())
    {
        pos_count += 1;
        var message = {
            "mes":"new_match",
            "pos":pos_count
        }
        item.send(JSON.stringify(message));
    }
    pos_count = 0;
}

function ready_client(client,data)
{
    state[data["id"]] = "ready";
    ready_players += 1;

    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"ready_client",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
    if (ready_players === max_players)
    {
        
        for (let item of server.clients.keys())
        {
            var message = {
                "mes":"start_count",
            }
            item.send(JSON.stringify(message))
        }
        start_count();
    }
}

function start_count()
{
    if (count > 0)
    {
        count -= 1;    
        timer_element = setTimeout(start_count,1000);
    }
    else
    {
        var pos_count = 0
        for (let item of server.clients.keys())
        {
            pos_count += 1;
            var message = {
                "mes":"start_game",
                "pos":pos_count
            }
            item.send(JSON.stringify(message));
        }
        pos_count = 0;
    }
}

function weapon_reload(client,data)
{
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"weapon_reload",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}

function weapon_changed(client,data)
{
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"weapon_changed",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}

function weapon_picked(client,data)
{
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"pickup_weapon",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}

function weapon_swapped(client,data)
{
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"swap_weapon",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}

function bullet_shot(client,data)
{
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"bullet_shot",
            "id":data["id"],            
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}

function delete_player(client,data)
{
    for(let item of server.clients.keys())
    {
        var message = {
            "mes":"delete_enemy",
            "id":data["id"],
            "info":data
        }
        item.send(JSON.stringify(message))
    }
    delete game_data[data["id"]];
    delete state[data["id"]];    
}

function initiate(client,data)
{
    var message = {
        "mes":"create_world",
        "info":game_data,
        "state":state
    }
    client.send(JSON.stringify(message))
    game_data[data["id"]] = data;
    score[data["id"]] = 0;
    state[data["id"]] = "not_ready";
    console.log("inside initiale")
    for (let item of server.clients.keys())
    {
        var message = {
            "mes":"add_enemy",
            "id":data["id"],            
            "info":data,
            "state":state
        }
        item.send(JSON.stringify(message))
    }
}

function update_player(client,data)
{
    game_data[data["id"]] = data;
    for(let item of server.clients.keys())
    {
        var message = {
            "mes":"update_enemy",
            "id":data["id"],
            "info":data
        }
        item.send(JSON.stringify(message))
    }
}