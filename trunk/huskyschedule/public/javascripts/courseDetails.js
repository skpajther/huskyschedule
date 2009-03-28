
var Curr_Id;
var tab_hash;

function initCD() {
	initializeCDfields();
}

function initializeCDfields(initial_tab_id) {
	tab_hash = new Hash();
	Curr_Id = initial_tab_id;
}

function hideTab(id){
	to_remove = document.getElementById(id);
	tab_label = document.getElementById(id+"_tab");
	parent = to_remove.parentNode
	
	tab_hash.set(id, to_remove);
	
	parent.removeChild(to_remove);
	tab_label.className = "normtab";
	return parent;
}

function showTab(new_id) {
	if(Curr_Id != new_id) {
		parent_div = hideTab(Curr_Id);
		
		new_content = tab_hash.get(new_id);
		new_tab = document.getElementById(new_id+"_tab");
		parent_div.appendChild(new_content);
		new_tab.className = "tabme";
		
		Curr_Id = new_id;
	}
}