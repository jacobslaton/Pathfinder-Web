require("dotenv").config();
const bodyParser = require("body-parser");
const express = require("express");
const fs = require("fs");
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

// Load errors and warnings
let langaugeCode = "eng";
const errorMessages = JSON.parse(fs.readFileSync(`${process.env.MESSAGES}/${langaugeCode}/errors.json`));
const warningMessages = JSON.parse(fs.readFileSync(`${process.env.MESSAGES}/${langaugeCode}/warnings.json`));

// Start app
let uuidNamespaces = {};
app.listen(process.env.PORT, async function() {
	// Cache uuid namespaces
	const rows = await db.any("select namespace_uuid, namespace_name from uuid_namespaces;").then();
	for (let ri = 0; ri < rows.length; ++ri) {
		const row = rows[ri];
		uuidNamespaces[row["namespace_name"]] = row["namespace_uuid"];
	}
	console.log(`Server started on port ${process.env.PORT}.`);
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

function parsePositiveInt(errors, obj, property) {
	if (!(property in obj)) {
		console.log(errorMessages);
		errors.push(
			errorMessages.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	let data = parseInt(obj[property], 10);
	if (isNaN(data) || data != parseFloat(obj[property]) || data <= 0) {
		errors.push(
			errorMessages.expectedPositiveInt
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
function parseUnsignedInt(errors, obj, property) {
	if (!(property in obj)) {
		errors.push(
			errorMessages.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	let data = parseInt(obj[property], 10);
	if (isNaN(data) || data != parseFloat(obj[property]) || data < 0) {
		errors.push(
			errorMessages.expectedUnsignedInt
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
function parseCoins(errors, warnings, obj, property, { objName = "Object" } = {}) {
	let coins = {};
	if (!(property in obj)) {
		errors.push(
			errorMessages.propertyMissing
				.replace("${objName}", `${objName}`)
				.replace("${property}", `${property}`)
		);
		return coins;
	}

	const coinTypes = ["platinum", "gold", "electrum", "silver", "copper"];
	coinTypes.forEach(type => {
		if (obj.coins[type] === undefined) return;
		let pieces = parseUnsignedInt(errors, obj.coins, type);
		if (!isNaN(pieces)) {
			if (pieces > 0) {
				coins[type] = pieces;
			} else if (pieces < 0) {
				errors.push(
					errorMessages.coinageNegativeCoins
						.replace("${type}", `${type}`)
				);
			} else {
				warnings.push(
					warningMessages.coinageZeroCoins
						.replace("${type}", `${type}`)
				);
			}
		}
	});

	let addedWarning = false;
	Object.keys(obj.coins).forEach((key) => {
		if (coinTypes.indexOf(key) == -1) {
			addedWarning = true;
			warnings.push(
				warningMessages.coinageUnsupported
					.replace("${type}", `${type}`)
			);
		}
	});
	if (addedWarning) warnings.push(warningMessages.coinageSupported);
	return coins;
}
function sumCoins(obj) {
	let gp = 0;
	const coinTypes = {
		"platinum": 10,
		"gold": 1,
		"electrum": 0.5,
		"silver": 0.1,
		"copper": 0.01
	};
	for (type in obj) gp += obj[type] * coinTypes[type];
	return gp;
}

app.get("/utility/calculate-exp", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let currentExp = parseUnsignedInt(errors, req.body, "currentExp");
	let coins = parseCoins(errors, warnings, req.body, "coins");
	if (errors.length > 0) {
		res.status(400).json({ "meta": meta(errors, warnings) });
		return;
	}

	// Logic goes here
	const progression = {
		1:  { "exp":       0, "gold":      0 },
		2:  { "exp":    2000, "gold":   1000 },
		3:  { "exp":    3000, "gold":   3000 },
		4:  { "exp":    4000, "gold":   6000 },
		5:  { "exp":    6000, "gold":  10500 },
		6:  { "exp":    8000, "gold":  16000 },
		7:  { "exp":   12000, "gold":  23500 },
		8:  { "exp":   16000, "gold":  33000 },
		9:  { "exp":   24000, "gold":  46000 },
		10: { "exp":   30000, "gold":  62000 },
		11: { "exp":   50000, "gold":  82000 },
		12: { "exp":   65000, "gold": 108000 },
		13: { "exp":   95000, "gold": 140000 },
		14: { "exp":  130000, "gold": 185000 },
		15: { "exp":  190000, "gold": 240000 },
		16: { "exp":  255000, "gold": 315000 },
		17: { "exp":  410000, "gold": 410000 },
		18: { "exp":  500000, "gold": 530000 },
		19: { "exp":  750000, "gold": 685000 },
		20: { "exp": 1050000, "gold": 880000 }
	};
	let nextLevel = 1;
	let runningExpTotal = runningExpTotal = progression[nextLevel]["exp"];
	for (; runningExpTotal < currentExp && nextLevel <= 20; ++nextLevel) {
		console.log(runningExpTotal);
		runningExpTotal += progression[nextLevel]["exp"];
	}
	--nextLevel;
	console.log(runningExpTotal);

	console.log(0.8 * progression[nextLevel]["exp"] / progression[nextLevel]["gold"]);

	res.status(status).json({
		"level": nextLevel,
		"totalExp": 0,
		"meta": meta(errors, warnings)
	});
});

app.get("/utility/split-gold", async function(req, res) {
	let status = 200;
	let errors = [];
	let warnings = [];

	let partySize = parsePositiveInt(errors, req.body, "partySize");
	let coins = parseCoins(errors, warnings, req.body, "coins", { objName: "Request" });
	if (errors.length > 0) {
		res.status(400).json({ "meta": meta(errors, warnings) });
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
