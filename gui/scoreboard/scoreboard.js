// Default table look
let header = `
	<tr>
		<th>ID</th>
		<th>Player</th>
		<th>Wins</th>
		<th>Deaths</th>
		<th>Cash</th>
		<th>Ping</th>
	</tr>
`

// Set the table default
document.getElementById("playertabe").innerHTML = header

// Creating functions that we can use on the client side Lua code
function SetServerName(servername) {

	// Process the bbcode and store the new, processed
    servername = XBBCODE.process({
		text: name,
		removeMisalignedTags: false,
		addInLineBreaks: false
    }).html

	// Dispaly the server name to the player
	document.getElementById("servername").innerHTML = servername
}

function SetPlayerCount(playercount, maxplayers) {
	document.getElementById("playercount").innerHTML = playercount + " / " + maxplayers
}

function RemovePlayers() {
	// Modify the contents of the table
	document.getElementById("playertabe").innerHTML = header
}

function AddPlayer(id, name, wins, deaths, cash, ping) {
	let row = document.createElement("tr")
	row.innerHTML = "<td>"+id+"</td><td>"+name+"</td><td>"+wins+"</td><td>"+deaths+"</td><td>$"+cash+"</td><td>"+ping+"</td>"
	document.getElementById("playertable").appendChild(row)
}
