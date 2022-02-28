const utility = require("./utility.js");
const models = require("./models.js");

const messages = utility.loadMessages();

function string(errors, obj, property) {
	if (!(property in obj)) {
		errors.push(
			messages.errors.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	const data = obj[property];
	if (data === null || data === undefined || !isNaN(parseFloat(data))) {
		errors.push(
			messages.errors.expectedString
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
function positiveInt(errors, obj, property) {
	if (!(property in obj)) {
		errors.push(
			messages.errors.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	let data = parseInt(obj[property], 10);
	if (isNaN(data) || data != parseFloat(obj[property]) || data <= 0) {
		errors.push(
			messages.errors.expectedPositiveInt
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
function unsignedInt(errors, obj, property) {
	if (!(property in obj)) {
		errors.push(
			messages.errors.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	let data = parseInt(obj[property], 10);
	if (isNaN(data) || data != parseFloat(obj[property]) || data < 0) {
		errors.push(
			messages.errors.expectedUnsignedInt
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
function Coins(errors, warnings, obj, property, { objName = "Object" } = {}) {
	let coins = {};
	if (!(property in obj)) {
		errors.push(
			messages.errors.propertyMissing
				.replace("${objName}", `${objName}`)
				.replace("${property}", `${property}`)
		);
		return coins;
	}

	models.coinTypes.forEach(type => {
		if (obj.coins[type] === undefined) {
			coins[type] = 0;
			return;
		}
		let pieces = unsignedInt(errors, obj.coins, type);
		if (!isNaN(pieces)) {
			if (pieces > 0) {
				coins[type] = pieces;
			} else if (pieces < 0) {
				errors.push(
					messages.errors.coinageNegativeCoins
						.replace("${type}", `${type}`)
				);
			} else {
				warnings.push(
					messages.warnings.coinageZeroCoins
						.replace("${type}", `${type}`)
				);
			}
		}
	});

	let addedWarning = false;
	Object.keys(obj.coins).forEach((type) => {
		if (models.coinTypes.indexOf(type) == -1) {
			addedWarning = true;
			warnings.push(
				messages.warnings.coinageUnsupported
					.replace("${type}", `${type}`)
			);
		}
	});
	if (addedWarning) warnings.push(messages.warnings.coinageSupported);
	return coins;
}

exports.string = string;
exports.positiveInt = positiveInt;
exports.unsignedInt = unsignedInt;
exports.Coins = Coins;
