require("dotenv").config();
const bodyParser = require("body-parser");
const express = require("express");
const multer = require("multer");
const pgp = require('pg-promise')(); //https://vitaly-t.github.io/pg-promise/index.html
const uuid = require("uuid");


// Create and configure app
const app = express();
const upload = multer();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(upload.array());


// Setup database connection
const db = pgp(`postgres://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/bestiary`);


// Cache uuid namespaces and start app
let uuidNamespaces = {};
app.listen(3000, async function() {
	const rows = await db.any("select namespace_uuid, namespace_name from uuid_namespaces;").then();
	for (let ri = 0; ri < rows.length; ++ri) {
		const row = rows[ri];
		uuidNamespaces[row["namespace_name"]] = row["namespace_uuid"];
	}
	console.log("Server started on port 3000.");
});


function meta(errors, warnings) {
	return {
		"errors":errors,
		"warnings":warnings
	};
};

app.get("/bestiary/lookup", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	const creatureUuid = uuid.v5(req.body.name, uuidNamespaces["base_creatures"]);
	let row = null;
	const query = "select * from base_creatures where creature_uuid = $1;";
	await db.one(query, [creatureUuid]).then(data => row = data);

	res.status(status).json({
		"stats": row,
		"meta": meta(errors, warnings)
	});
});

app.get("/bestiary/search", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	const creatureUuid = uuid.v5(req.body.name, uuidNamespaces["base_creatures"]);
	let rows = null;
	const query = "select creature_name from base_creatures where creature_name like '%' || $1 || '%';";
	await db.any(query, [req.body.name]).then(data => rows = data);

	rows = rows.map(function (element) { return element["creature_name"]; } );

	res.status(status).json({
		"results": rows,
		"meta": meta(errors, warnings)
	});
});

// Notes for website backend in the future

// app.get("/", function(req, res) {
// 	res.redirect("/home");
// });
//
// app.get("/home", function(req, res) {
// 	console.log(req);
// 	res.sendFile(__dirname + "/home.html");
// });
//
// app.get("/login", function(req, res) {
// 	console.log(req);
// 	res.send("<h1>Login</h1>");
// });
//
// app.get("/bestiary", function(req, res) {
// 	console.log(req);
// 	res.send("<h1>Bestiary</h1>");
// });
