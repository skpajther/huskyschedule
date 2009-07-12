
function Course(parameters){
	//Storage Variables
	this.sln = parameters["sln"];
	this.deptabbrev = parameters["deptabbrev"];
	this.number = parameters["number"];
	this.section = parameters["section"];
	this.id = parameters["id"];
	this.color = parameters["color"];
	
	//Methods
	this.display_text = display_text;
	this.display_name = display_name;
}

function display_name(){
	return this.deptabbrev+" "+this.number+" "+this.section;
}

function display_text(){
	return this.sln+": "+this.deptabbrev+" "+this.number+" "+this.section;
}