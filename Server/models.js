exports.meta = (errors, warnings) => {
	return {
		"errors":errors,
		"warnings":warnings
	};
};
exports.Coins = ({gold = 0} = {}) => {
	let coins = {};
	coinTypes.forEach(type => {
		coins[type] = 0;
	});
	return coins;
}
