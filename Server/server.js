require("dotenv").config();
const bodyParser = require("body-parser");
const express = require("express");
const models = require("./models.js");
const multer = require("multer");
const pgp = require("pg-promise")(); //https://vitaly-t.github.io/pg-promise/index.html
const utility = require("./utility.js");
const uuid = require("uuid");
const verify = require("./verify.js");

// Create and configure app
const app = express();
const upload = multer();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(upload.array());

// Setup
const db = pgp(`postgres://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/pathfinder`);
const messages = utility.loadMessages();

// Start app
let uuidNamespaces = {};
app.listen(process.env.PORT, async function() {
	// Cache uuid namespaces
	const rows = await db.any("select uuid, name from uuid_namespaces;").then();
	for (let ri = 0; ri < rows.length; ++ri) {
		const row = rows[ri];
		uuidNamespaces[row["name"]] = row["uuid"];
	}
	console.log(`Server started on port ${process.env.PORT}.`);
});

app.get("/bestiary/lookup", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	// Verify Input
	const name = verify.string(errors, req.body, "name");
	if (errors.length > 0) {
		res.status(400).json({ "meta": models.meta(errors, warnings) });
		return;
	}

	const creatureUuid = uuid.v5(name, uuidNamespaces["base_creatures"]);
	let row = null;
	const query = "select * from base_creatures where uuid = $1;";
	await db.any(query, [creatureUuid]).then(data => row = data);
	if ("length" in row) {
		if (row.length <= 0) {
			warnings.push(
				messages.warnings.lookupNoResults
					.replace("${name}", `${name}`)
			);
			res.status(404).json({ "meta": models.meta(errors, warnings) });
			return;
		} else if (row.length > 1) {
			errors.push(
				messages.errors.databaseNotUnique
			);
			res.status(500).json({ "meta": models.meta(errors, warnings) });
			return;
		}
	}
	row = row[0];

	res.status(status).json({
		"stats": row,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/bestiary/search", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	const name = verify.string(errors, req.body, "name");
	let rows = null;
	const query = "select name from base_creatures where name like '%' || $1 || '%';";
	await db.any(query, [name,]).then(data => rows = data);

	rows = rows.map(function (element) { return element["name"]; } );

	res.status(status).json({
		"results": rows,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/utility/calculate-exp", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let currentExp = verify.unsignedInt(errors, req.body, "currentExp"); // should be float
	let coins = verify.Coins(errors, warnings, req.body, "coins");
	if (errors.length > 0) {
		res.status(400).json({ "meta": models.meta(errors, warnings) });
		return;
	}

	let convertedGold = utility.sumCoins(coins);
	let nextLevel = 2;
	let runningExpTotal = 0;
	for (; runningExpTotal + utility.totalExpToNextLevel(nextLevel) <= currentExp && nextLevel <= 20; ++nextLevel) {
		runningExpTotal += utility.totalExpToNextLevel(nextLevel);
	}
	let totalExpForNextLevel = runningExpTotal + utility.totalExpToNextLevel(nextLevel);

	let multiplier = 0.8 * utility.totalExpToNextLevel(nextLevel) / utility.totalGoldToNextLevel(nextLevel);
	let nextMultiplier = 0.8 * utility.totalExpToNextLevel(nextLevel + 1) / utility.totalGoldToNextLevel(nextLevel + 1);
	let expToNextLevel = totalExpForNextLevel - currentExp;
	let gpToNextLevel = +(expToNextLevel / multiplier).toFixed(2);
	console.log(nextLevel, multiplier, gpToNextLevel);
	let xpGained = 0;
	if (convertedGold <= gpToNextLevel) {
		xpGained = convertedGold * multiplier;
	} else {
		xpGained = gpToNextLevel * multiplier + (convertedGold - gpToNextLevel) * nextMultiplier;
	}
	xpGained = +xpGained.toFixed(2);
	console.log();

	res.status(status).json({
		"level": nextLevel - (convertedGold <= gpToNextLevel ? 1 : 0),
		"totalExp": currentExp + xpGained,
		"xpGained": xpGained,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/utility/split-gold", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let partySize = verify.positiveInt(errors, req.body, "partySize");
	let coins = verify.Coins(errors, warnings, req.body, "coins", { objName: "Request" });
	if (errors.length > 0) {
		res.status(400).json({ "meta": models.meta(errors, warnings) });
		return;
	}

	let share = {};
	let remainder = {};
	Object.keys(coins).forEach((key) => {
		share[key] = Math.floor(coins[key] / partySize);
		remainder[key] = coins[key] % partySize;
	});

	res.status(status).json({
		"share": share,
		"remainder": remainder,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/general/planes/lookup", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	// Verify Input
	const name = verify.string(errors, req.body, "name");
	if (errors.length > 0) {
		res.status(400).json({ "meta": models.meta(errors, warnings) });
		return;
	}

	const planeUuid = uuid.v5(name, uuidNamespaces["planes"]);
	let row = null;
	const query = "select * from planes where uuid = $1;";
	await db.any(query, [planeUuid]).then(data => row = data);
	if ("length" in row) {
		if (row.length <= 0) {
			warnings.push(
				messages.warnings.lookupNoResults
					.replace("${name}", `${name}`)
			);
			res.status(404).json({ "meta": models.meta(errors, warnings) });
			return;
		} else if (row.length > 1) {
			errors.push(
				messages.errors.databaseNotUnique
			);
			res.status(500).json({ "meta": models.meta(errors, warnings) });
			return;
		}
	}
	row = row[0];

	res.status(status).json({
		"stats": row,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/general/planes/search", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let rows = null;
	let [query, params] = buildSearchQuery(req.body);
	query = "select * from planes where " + query + ";";
	await db.any(query, params).then(data => rows = data);

	res.status(status).json({
		"results": rows,
		"query": query,
		"params": params,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/characters/lookup", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	// Verify Input
	const name = verify.string(errors, req.body, "name");
	if (errors.length > 0) {
		res.status(400).json({ "meta": models.meta(errors, warnings) });
		return;
	}

	const characterUuid = uuid.v5(name, uuidNamespaces["characters"]);
	let row = null;
	const query = "select * from characters where uuid = $1;";
	await db.any(query, [characterUuid]).then(data => row = data);
	if ("length" in row) {
		if (row.length <= 0) {
			warnings.push(
				messages.warnings.lookupNoResults
					.replace("${name}", `${name}`)
			);
			res.status(404).json({ "meta": models.meta(errors, warnings) });
			return;
		} else if (row.length > 1) {
			errors.push(
				messages.errors.databaseNotUnique
			);
			res.status(500).json({ "meta": models.meta(errors, warnings) });
			return;
		}
	}
	row = row[0];

	res.status(status).json({
		"stats": row,
		"meta": models.meta(errors, warnings)
	});
});
app.get("/characters/search", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	const name = verify.string(errors, req.body, "name");
	let rows = null;
	const query = "select name from base_creatures where name like '%' || $1 || '%';";
	await db.any(query, [name,]).then(data => rows = data);

	rows = rows.map(function (element) { return element["name"]; } );

	res.status(status).json({
		"results": rows,
		"meta": models.meta(errors, warnings)
	});
});

let paramCount = 0;
function buildSearchQuery(node, depth = 0) {
	let queries = [];
	let params = [];
	let op = node["operator"];
	if ("expressions" in node) {
		node["expressions"].forEach(item => {
			let [subQueries, subParams] = buildSearchQuery(item, depth + 1);
			console.log(subQueries, subParams);
			queries.push(subQueries);
			params = params.concat(subParams);
		});
	} else {
		for (let key in node) {
			if (key == "operator") continue;
			queries.push(`(${key} ${op} $${++paramCount})`);
			params.push(node[key]);
		}
		op = "and";
	}
	queries.forEach((item, ii) => {
		if (typeof item == "object") {
			queries[ii] = `(${item.join(` ${op} `)})`;
		}
	});
	queries = `(${queries.join(` ${op} `)})`;
	if (queries.length == 1) queries = queries[0];

	console.log(depth, op, queries);
	if (depth == 0) paramCount = 0;
	return [queries, params];
};
app.get("/test", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let rows = null;
	let [query, params] = buildSearchQuery(req.body);
	query = "select * from planes where " + query + ";";
	await db.any(query, params).then(data => rows = data);

	res.status(status).json({
		"results": rows,
		"query": query,
		"params": params,
		"meta": models.meta(errors, warnings)
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
