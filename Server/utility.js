const fs = require("fs");

const coinTypes = ["platinum", "gold", "electrum", "silver", "copper"];

exports.loadMessages = (langaugeCode = "eng") => {
	const errors = JSON.parse(fs.readFileSync(`${process.env.MESSAGES}/${langaugeCode}/errors.json`));
	const warnings = JSON.parse(fs.readFileSync(`${process.env.MESSAGES}/${langaugeCode}/warnings.json`));
	return { "errors": errors, "warnings": warnings };
}
exports.sumCoins = (obj) => {
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
exports.addCoins = (lhs, rhs) => {
	let result = Coins();
	coinTypes.forEach(type => {
		console.log(lhs[type], "+", rhs[type]);
	});
}
exports.crToExp = (cr) => {
	let exp = 100;
	if (cr <= 0) {
		switch (cr) {
			case -4: exp =  50; break;
			case -3: exp =  65; break;
			case -2: exp = 100; break;
			case -1: exp = 135; break;
			case  0: exp = 200; break;
		}
	} else if (cr % 2 == 1) {
		exp = 4 * Math.pow(2, Math.floor(cr / 2));
	} else {
		exp = 3 * Math.pow(2, Math.floor(cr / 2));
	}
	return exp;
}
exports.totalExpToNextLevel = (level) => {
	let exp = 0;
	switch (level) {
		case  2: exp =   2000; break;
		case  3: exp =   3000; break;
		case  4: exp =   4000; break;
		case  5: exp =   6000; break;
		case  6: exp =   8000; break;
		case  7: exp =  12000; break;
		case  8: exp =  16000; break;
		case  9: exp =  24000; break;
		case 10: exp =  30000; break;
		case 11: exp =  50000; break;
		case 12: exp =  65000; break;
		case 13: exp =  95000; break;
		case 14: exp = 130000; break;
		case 15: exp = 190000; break;
		case 16: exp = 255000; break;
		case 17: exp = 410000; break;
		case 18: exp = 500000; break;
		case 19: exp = 750000; break;
	}
	if (level >= 20) {
		exp = 1050000 * Math.pow(2, level-20);
	}
	return exp;
}
exports.totalGoldToNextLevel = (level) => {
	let gold = 0;
	switch (level) {
		case  2: gold =   1000; break;
		case  3: gold =   3000; break;
		case  4: gold =   6000; break;
		case  5: gold =  10500; break;
		case  6: gold =  16000; break;
		case  7: gold =  23500; break;
		case  8: gold =  33000; break;
		case  9: gold =  46000; break;
		case 10: gold =  62000; break;
		case 11: gold =  82000; break;
		case 12: gold = 108000; break;
		case 13: gold = 140000; break;
		case 14: gold = 185000; break;
		case 15: gold = 240000; break;
		case 16: gold = 315000; break;
		case 17: gold = 410000; break;
		case 18: gold = 530000; break;
		case 19: gold = 685000; break;
	}
	if (level >= 20) {
		gold = 880000 * Math.pow(2, level-20);
	}
	return gold;
}
