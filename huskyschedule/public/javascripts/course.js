
function Course(parameters){
	//Storage Variables
	this.sln = parameters["sln"];
	this.deptabbrev = parameters["deptabbrev"];
	this.number = parameters["number"];
	this.section = parameters["section"];
	this.id = parameters["id"];
	
	//Methods
	this.display_text = display_text;
}

function display_text(){
	return this.sln+": "+this.deptabbrev+" "+this.number+" "+this.section;
}