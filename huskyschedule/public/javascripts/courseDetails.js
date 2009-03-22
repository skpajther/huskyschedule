var tabbedWindowDiv;
var overviewDiv;
var classReviewsDiv;
var teacherReviewsDiv;
var mapDiv;
var currentState;

function initCD() {
	initializeCDfields();
}

function initializeCDfields() {
	tabbedWindowDiv = document.getElementById("tabbedwindow");
	overviewDiv = document.getElementById("overview");
   	classReviewsDiv = document.getElementById("classReviews");
   	tabbedWindowDiv.removeChild(classReviewsDiv);
   	teacherReviewsDiv = document.getElementById("teacherReviews");
   	tabbedWindowDiv.removeChild(teacherReviewsDiv);
   	mapDiv = document.getElementById("mediumMapArea");
	tabbedWindowDiv.removeChild(mapDiv);
	currentState = 0;
}

function showTab(tabNumber) {
	if(currentState != tabNumber) {
		switch(currentState) {
			case 0: //overview
				tabbedWindowDiv.removeChild(overviewDiv);
				document.getElementById("overviewtab").className = "normtab";
				break;
			case 1: //class reviews
				tabbedWindowDiv.removeChild(classReviewsDiv);
				document.getElementById("classreviewstab").className = "normtab";
				break;
			case 2: //teacher reviews
				tabbedWindowDiv.removeChild(teacherReviewsDiv);
				document.getElementById("teacherreviewstab").className = "normtab";
				break;
			case 3: //map
				tabbedWindowDiv.removeChild(mapDiv);
				document.getElementById("maptab").className = "normtab";
				break;
			default:
				break;
		}
		switch(tabNumber) {
			case 0: //overview
				tabbedWindowDiv.appendChild(overviewDiv);
				document.getElementById("overviewtab").className = "tabme";
				break;
			case 1: //class reviews
				tabbedWindowDiv.appendChild(classReviewsDiv);
				document.getElementById("classreviewstab").className = "tabme";
				break;
			case 2: //teacher review
				tabbedWindowDiv.appendChild(teacherReviewsDiv);
				document.getElementById("teacherreviewstab").className = "tabme";
				break;
			case 3: //map
				tabbedWindowDiv.appendChild(mapDiv);
				document.getElementById("maptab").className = "tabme";
				break;
			default: //overview
				showTab(0);
				return;
		}	
		currentState = tabNumber;
	}
}