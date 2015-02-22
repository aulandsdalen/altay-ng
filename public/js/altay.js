getPermanentParameters();
$(function(){
	$(".draggable").draggable({grid:[80, 80], containment: "parent", cursor: "move"});
});
var cpuSmoothie = new SmoothieChart({grid:{sharpLines:true},labels:{disabled:false},maxValue:100,minValue:0});
var ramSmoothie = new SmoothieChart({grid:{sharpLines:true},labels:{disabled:false},maxValue:100,minValue:0});
var cpu_line = new TimeSeries();
var ram_line = new TimeSeries();
cpuSmoothie.streamTo(document.getElementById("cpu_usage_graph"), 1000);
ramSmoothie.streamTo(document.getElementById("ram_usage_graph"),1000);
updateMeters();
function rebootMachine() {
	$.get("/reboot.action",function(data){
		if(data.result === 'not authorized')
			alert(data.human_readable);
	});
}
function display_alert(text) {
		$("body").prepend("<div id='alert'><p>"+ text +"</p></div>");
}
function getPermanentParameters() { //get and display static parameters once
	$.getJSON("/system.json", function(data){
		$("title").text(data.altay_version_full);
		//$(".osv").html('<img src='+data.os_logo_image_link+' alt="" class="os_image">');
		$(".name").text(data.altay_version_full);
		//$("#ruby_version").text(data.ruby_version);
		$("#altay_commit").text(data.altay_version_commit);
		$("#cpu_name_data").text(data.cpu_name);
	});	
}
var updateMetersInterval = window.setInterval(updateMeters, 500); //update every 500 msec
var cleanupInterval = window.setInterval(removeMessages, 3000);
function removeMessages() {
	message = document.getElementById('message');
	message.remove();
	clearInterval(cleanupInterval);
}
function updateMeters() {
	$.getJSON("/load.json", function(data){
		var uptime = moment.duration(data.uptime*1000);
		var load_average = data.load_average;
		$("#uptime_data").text(uptime.days() + " days " + uptime.hours() + " hours " + uptime.minutes() + " minutes");
		$("#cpu_percentage_data").text(data.cpu);
		$("#ram_percentage_data").text(data.ram_used);
		$("#phys_mem_data").text(data.ram_total);
		cpu_line.append(new Date().getTime(), data.cpu);
		ram_line.append(new Date().getTime(), data.ram_used);
	});
	$.getJSON("/user.json", function(data){
		$("#logged_in_data").text(data.sessions_count);
		if (data.www_user === 'root') {
			display_alert("Web server running under root, reconfigure it ASAP");
		}
		$("#www_user_data").text(data.www_user);
	});
}
cpuSmoothie.addTimeSeries(cpu_line, {lineWidth:2,strokeStyle:'#cccccc',fillStyle:'rgba(204,204,204,0.30)'});
ramSmoothie.addTimeSeries(ram_line, {lineWidth:2,strokeStyle:'#cccccc',fillStyle:'rgba(204,204,204,0.30)'});
document.getElementById("rebootAction").addEventListener('click', rebootMachine);