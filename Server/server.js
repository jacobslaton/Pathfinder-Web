require("dotenv").config();
const express = require("express");

const app = express();

app.listen(3000, function() {
	console.log("Server started on port 3000.");
});

app.get("/", function(req, res) {
	res.redirect("/home");
});

app.get("/home", function(req, res) {
	console.log(req);
	res.sendFile(__dirname + "/home.html");
});

app.get("/login", function(req, res) {
	console.log(req);
	res.send("<h1>Login</h1>");
});

app.get("/bestiary", function(req, res) {
	console.log(req);
	res.send("<h1>Bestiary</h1>");
});
