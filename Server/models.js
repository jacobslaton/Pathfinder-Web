const coinTypes = ["platinum", "gold", "electrum", "silver", "copper"];
function meta(errors, warnings) {
	return {
		"errors":errors,
		"warnings":warnings
	};
};
function Coins({gold = 0} = {}) {
	let coins = {};
	coinTypes.forEach(type => {
		coins[type] = 0;
	});
	return coins;
}

exports.meta = meta;
exports.Coins = Coins;
exports.coinTypes = coinTypes;
