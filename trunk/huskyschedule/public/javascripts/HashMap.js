function HashMap(numElements) {
	this.holder = new Array(numElements * 2 + 1);
}

//key is a string, value is anything
HashMap.prototype.insert = function(key, value) {
	var hashVal = hash(key);
}

HashMap.prototype.get = function(key) {

}

HashMap.prototype.hash(key) = function(key) {
	var hashVal = 0;
	for(var i=0; i<key.length(); i++)
		hashVal = 37*hashVal + key.charAt(i);
	hashVal %= size;
	if(hashVal < 0)
		hashVal += size;
	return hashVal;
}

