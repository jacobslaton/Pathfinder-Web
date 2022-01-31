const utility = require("./utility.js");

const messages = utility.loadMessages();

exports.string = (errors, obj, property) => {
	if (!(property in obj)) {
		errors.push(
			errorMessages.propertyRequired
				.replace("${property}", `${property}`)
		);
	}
	const data = obj[property];
	if (data === null || data === undefined || !isNaN(parseFloat(data))) {
		errors.push(
			errorMessages.expectedString
				.replace("${property}", `${property}`)
		);
	}
	return data;
}
exports.positiveInt = (errors, obj, property) => {
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
exports.unsignedInt = (errors, obj, property) => {
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
exports.Coins = (errors, warnings, obj, property, { objName = "Object" } = {}) => {
	let coins = {};
	if (!(property in obj)) {
		errors.push(
			errorMessages.propertyMissing
				.replace("${objName}", `${objName}`)
				.replace("${property}", `${property}`)
		);
		return coins;
	}

	coinTypes.forEach(type => {
		if (obj.coins[type] === undefined) {
			coins[type] = 0;
			return;
		}
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
	Object.keys(obj.coins).forEach((type) => {
		if (coinTypes.indexOf(type) == -1) {
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
