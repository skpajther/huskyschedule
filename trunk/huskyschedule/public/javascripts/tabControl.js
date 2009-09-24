var showingId;
var tabs;

function initializeTabs() {
	tabs = new Array();
	for(var i=0; i<initializeTabs.arguments.length; i++)
		tabs.push(initializeTabs.arguments[i]);
	showingId = 0;
}

function showTab(newTab) {
	if(newTab != tabs[showingId]) {
		document.getElementById(tabs[showingId]).style.display="none";
		document.getElementById(tabs[showingId]+"_tab").className = "normtab";
		document.getElementById(newTab).style.display="inline";
		document.getElementById(newTab+"_tab").className = "tabme";
		for(var i=0; i<tabs.length; i++) {
			if(tabs[i] == newTab) {
				showingId = i;
				return;
			}
		}
	}
}