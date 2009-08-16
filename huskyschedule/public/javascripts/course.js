
function Course(parameters){
	//Storage Variables
	this.sln = parameters["sln"];
	this.deptabbrev = parameters["deptabbrev"];
	this.number = parameters["number"];
	this.section = parameters["section"];
	this.id = parameters["id"];
	this.color = parameters["color"];
	this.hours = parameters["hours"];
	this.credits = parameters["credits"];
	this.vlpa = parameters["vlpa"];
	this.is = parameters["is"];
	this.nw = parameters["nw"];
	this.qsr = parameters["qsr"];
	this.c = parameters["c"];
	//this.reqiuresQuiz = parameters["requiresQuiz"];
	//this.requiresLab = parameters["requiresLab"];
	this.default_quiz_section = parameters["default_quiz_section"];
	this.default_lab = parameters["default_lab"];
	this.quiz_sections = parameters["quiz_sections"];
	this.labs = parameters["labs"];
	this.parent_id = parameters["parent_id"];
	
	
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