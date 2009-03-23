// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function fix_schedule_table_alignment(main_table, tables_to_fix){
	var height = main_table.style.height;
	for(var i = 0; i < tables_to_fix.length; i++){
		tables_to_fix[i].style.marginTop = (0-height);
	}
}