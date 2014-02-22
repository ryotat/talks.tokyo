// String型にreplaceAll()関数を追加
String.prototype.replaceAll = function ( before, after ) {
    return this.split( before ).join( after );  
}

String.prototype.strip = function() {
    return String(this).replace(/^\s+|\s+$/g, '');
}

function parse_smart_form(box) {
    var del = "：:\\s"; // delimiters

    // Define Item
    var Item = function(id, key, re, joiner) {
	this.id    = id;
	this.hasDefaultValue=true;
	this.allowEmptyLine=false;
	this.strArray   = new Array();
	if (re) {
	    this.re    = new RegExp("^(?:"+key+")\\s*["+del+"]\\s*(?:"+re+")|^(?:"+key+")$");
	}
	if (joiner) {
	    this.joiner = joiner;
	}
	else {
	    this.joiner = "";
	}
    }

    Item.prototype = {
	set_default: function(item) {
	    if (this.hasDefaultValue && item.strArray.length>0) {
		this.strArray = item.strArray;
	    }
	},
	parse_line: function(line) {
	    var match = line.match(this.re);
	    if (match && match.length>=2) {
		if (this.strArray.length>0) {
		    if (this.hasDefaultValue) { // Existing entry is a default value, overwrite
			this.insert_line(match[1]);
		    }
		    else { // Signal the beginning of a new talk by new Item
			var tmp=new Item(this.id);
			tmp.re = this.re;
			tmp.joiner = this.joiner;
			tmp.hasDefaultValue=true;
			tmp.insert_line(match[1]);
			tmp.show = this.show;
			return tmp;
		    }
		}
		else {
		    this.insert_line(match[1]);
		}
		return true;
	    }
	    return false;
	},
	insert_line: function(line) {
	    if (line && line.length>0) { // Insert no empty line
		if (this.hasDefaultValue) { // Overwrite default value
		    this.strArray = [line];
		    this.hasDefaultValue=false;
		}
		else { // Insert line at the end
		    this.strArray.push(line);
		}
	    }
	},
	show: function(index) {
	    if (this.strArray.length>0) {
		this.show_str(index,this.strArray.join(this.joiner));
	    }
	},
	show_str: function(index,str) {
	    jQuery("#"+this.id+index).val(str.strip());
	    jQuery("#"+this.id+index).removeClass('blur');
	},
	isAssigned: function() {
	    return this.strArray.length>0 && !this.hasDefaultValue;
	}
    };

    // Main
    var talk = new Talk();

    var textArray = box.val().split("\n");
    var currentKey = "";
    var talks = new Array();
    for (var i=0; i<textArray.length; i++) {
	var hit=false;
	for (var key in talk) {
	    if (key == "parse_default") {
		continue;
	    }
	    var tmp=talk[key].parse_line(textArray[i]);
	    if (tmp) {
		if (typeof(tmp)=="object") {
		    var talk_old=talk;
		    talks.push(talk_old);
		    talk = new Talk();
		    talk[key]=tmp;
		    talk.date.set_default(talk_old.date);
		    talk.venue.set_default(talk_old.venue);
		    talk.speaker.set_default(talk_old.speaker);
		}
		currentKey = key;
		hit=true;
		break;
	    }
	}
	
	if (!hit) {
	    if(textArray[i].length>0) {
		if (currentKey.length>0) {
		    talk[currentKey].insert_line(textArray[i]);
		}
		else {
		    currentKey = talk.parse_default(textArray[i],i);
		}
	    }
	    else if (currentKey.length>0 && talk[currentKey].allowEmptyLine) {
		talk[currentKey].insert_line("\n\n");
	    }
	    else {
		currentKey = "";
	    }
	}
    }
    talks.push(talk);

    // Show them
    for (var i=0; i<talks.length; i++) {
	// append_empty_form('#box',i);
	for (var key in talks[i]) {
	    if (key == "parse_default") {
		continue;
	    }
	    talks[i][key].show('');
	}
    }


    // Define Talk Object here
    function Talk() {
	var restr_time = "(?:[^０-９\\d午前後]*\\s*((?:午前|午後|)\\s*[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)(?:\\s*(?:[-－ー〜～~]+|から)\\s*|)(?:((?:午前|午後|)[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)";
	var restr_date_time_ja = "^(?:((?:平成\\s*|)[０-９\\d]+)\\s*[年/／]\\s*|)([０-９\\d]+)\\s*[月/／]\\s*([０-９\\d]+)\\s*(?:日|)"+restr_time;
	var restr_wday_en = "(?:"
	    +"(?:Monday|Mon)|"
	    +"(?:Tuesday|Tue)|"
	    +"(?:Wednesday|Wed)|"
	    +"(?:Thursday|Thu)|"
	    +"(?:Friday|Fri)|"
	    +"(?:Saturday|Sat)|"
	    +"(?:Sunday|Sun)|)[\\s,]*";
	var restr_mon_en = "((?:January|Jan|01)|"
	    +"(?:February|Feb|02)|"
	    +"(?:March|Mar|03)|"
	    +"(?:April|Apr|04)|"
	    +"(?:May|05)|"
	    +"(?:June|Jun|06)|"
	    +"(?:July|Jul|07)|"
	    +"(?:August|Aug|08)|"
	    +"(?:September|Sep|09)|"
	    +"(?:October|Oct|10)|"
	    +"(?:November|Nov|11)|"
	    +"(?:December|Dec|12))\\s*";
	var restr_date_en = "([０-９\\d]+)[sthrdn\\s,]*";
	var restr_date_time_uk = "^"+restr_wday_en
	    +restr_date_en
	    +restr_mon_en
	    +"(?:([０-９\\d]+)|)"+restr_time;
	var restr_date_time_us = "^"+restr_wday_en
	    +restr_mon_en
	    +restr_date_en
	    +"(?:([０-９\\d]+)|)"+restr_time;

	this.comment = new Item("","#","(.*)", "");
	this.date= new Item("talk_date_string",
			    "Time|Date\\s*(?:& Time|)|When|時間|日時|日程",
			    "(.*)", "");
	this.venue= new Item("talk_venue_name",
			     "Place|Venue|Location|Where|@|場所|会場",
			     "(.*)",", ");
	this.abst= new Item("talk_abstract",
			    "Abstract|(?:講演|セミナー|)(?:アブストラクト|概要|要旨)(?:.*[Aa]bstract[^"+del+"]|)",
			    "(.*)");
	this.speaker= new Item("talk_name_of_speaker",
			       "Speaker|Lecturer|(?:発表者|講演者|スピーカー|講師)(?:.*[Ss]peaker[^"+del+"]|)",
			       "(.*)",", ");
	this.supervisor= new Item("talk_name_of_speaker",
				  "指導教員","(.*)",", ");
	this.title= new Item("talk_title",
			     "Title|(?:講演|セミナー|)(?:題目|タイトル|演題)(?:.*[Tt]itle[^"+del+"]|)",
			     "(.*)", " ");
	this.comment.show = function(index) {
	    // Don't show comments.
	}

	this.abst.allowEmptyLine = true;

	this.date.show = function(index) {
	    var str    = this.strArray.join("").strip();
	    var arry   = matchDateTime(str);
	    var year   = arry[0];
	    var month  = arry[1];
	    var day    = arry[2];
	    var starth = arry[3];
	    var startm = arry[4];
	    var endh   = arry[5];
	    var endm   = arry[6];
	    if (year && month && day) {
		this.show_str(index,year+"/"+month+"/"+day);
	    }
	    if (typeof(starth)=='undefined' || typeof(endh)=='undefined')  {
		var re = new RegExp(restr_time);
		var match=str.match(re);
		if (match) {
		    var starth=match[1];
		    var startm=match[2] || "00";
		    var endh=match[3];
		    var endm=match[4] || "00";
		}
	    }
	    if (typeof(starth)!='undefined' && typeof(startm)!='undefined') {
		jQuery("#talk_start_time_string"+index).val(starth+":"+(startm || "00")); // This prevents 3pm from being displayed as 15:0
	    }
	    if (typeof(endh)!='undefined' && typeof(endm)!='undefined') {
		jQuery("#talk_end_time_string"+index).val(endh+":"+ (endm || "00"));
	    }
	};

	this.title.show = function(index) {
	    if (this.strArray.length>0) {
		var str=this.strArray.join(this.joiner).strip();
		str=str.replace(/^["“]|["”]$/g, '');
		this.show_str(index,str);
	    }
	};
	// アブスト中に日本語の中に半角スペースを入れない
	this.abst.show = function(index) {
	    if (this.strArray.length>0) {
		var out="";
		var isDoubleByteAt = function(str, i) {
		    return (str.charCodeAt(i)>255);
		};
		for (var i=0; i<this.strArray.length; i++) {
		    if (out.length>0) {
			if (isDoubleByteAt(out,out.length-1) && isDoubleByteAt(this.strArray[i],0)) {
			    out+=this.strArray[i];
			}
			else {
			    if (this.strArray[i]=="\n\n" || out.slice(-1)=="\n") {
				out+=this.strArray[i];
			    }
			    else {
				out+=" "+this.strArray[i];
			    }
			}
		    }
		    else {
			out=this.strArray[i];
		    }
		}
		this.show_str(index,out);

	    }
	};

	// 数理輪講のため
	this.supervisor.show = function(index) {
	    if (this.strArray.length>0) {
		this.show_str(index, jQuery("#"+this.id+index).val()+"　（指導教員："+this.strArray.join(this.joiner)+"）");
	    }
	};

	// Fall back to default if nothing matches
	this.parse_default = function(line, pos) {
	    if (matchDateTime(line.strip()).length>0) {
		this.date.insert_line(line);
		return "date";
	    }
	    if (pos==0) {
		// Assume that this is the title
		this.title.insert_line(line);
		return "title";
	    }
	    if (this.date.isAssigned() &&
		this.venue.isAssigned() &&
		this.speaker.isAssigned() &&
		this.title.isAssigned()) {
		// Assume that this is the abstract
		this.abst.insert_line(line);
		return "abst";
	    }
	    return "";
	};
	
	// Define matchDateTime;
	function matchDateTime(str) {
	    var re  = new RegExp(restr_date_time_ja);
	    var match = str.match(re);
	    var default_year = (new Date()).getFullYear();
	    if (match) {
		var year=yearWestern(match[1] || default_year);
		var month=normalizeNumber(match[2]);
		var day=normalizeNumber(match[3]);
		var starth=hour24(match[4]);
		var startm=normalizeNumber(match[5] || "00");
		var endh=hour24(match[6], starth>=12);
		var endm=normalizeNumber(match[7] || "00");
		return [year, month, day, starth, startm, endh, endm];
	    }

	    var re = new RegExp(restr_date_time_us);
	    var match=str.match(re);
	    if (match) {
		var year=normalizeNumber(match[3] || default_year);
		var month=normalizeMonth(match[1]);
		var day=normalizeNumber(match[2]);
		var starth=hour24(match[4]);
		var startm=normalizeNumber(match[5] || "00");
		var endh=hour24(match[6], starth>=12);
		var endm=normalizeNumber(match[7] || "00");
		return [year, month, day, starth, startm, endh, endm];
	    }

	    var re = new RegExp(restr_date_time_uk);
	    var match=str.match(re);
	    if (match) {
		var year=normalizeNumber(match[3] || default_year);
		var month=normalizeMonth(match[2]);
		var day=normalizeNumber(match[1]);
		var starth=hour24(match[4]);
		var startm=normalizeNumber(match[5] || "00");
		var endh=hour24(match[6], starth>=12);
		var endm=normalizeNumber(match[7] || "00");
		return [year, month, day, starth, startm, endh, endm];
	    }
	    return [];
	}


    } // End of Talk object definition

    // Define normalizeNumber
    function normalizeNumber( inStr ){
	var outStr=inStr;
	var convMap= {"１":"1","２":"2","３":"3","４":"4","５":"5","６":"6","７":"7","８":"8","９":"9","０":"0"};
	if( typeof( inStr ) != "string" ) { return inStr; }
	if( inStr.length==0 ) { return "00"; }
	for ( var key in convMap ){ outStr = outStr.replaceAll( key, convMap[key] );   }
	return +outStr;
    }
    // Define normalizeMonth
    function normalizeMonth(str) {
	var map = {"Jan":"1", "Feb":"2", "Mar":"3", "Apr":"4", "May":"5", "Jun":"6", "Jul":"7", "Aug":"8", "Sep":"9", "Oct":"10", "Nov":"11", "Dec":"12"};
	return +map[str.substring(0,3)];
    }

    // Define hour24
    function hour24(str, pm) {
	if( typeof( str ) != "string" ) { return str; }
	if( typeof(pm)=='undefined') { pm = false; }
	str=str.strip();
	out = normalizeNumber(str);
	if (str.substring(0,2)=="午前") {
	    out = normalizeNumber(str.substring(2,str.length));
	}
	else if (str.substring(0,2)=="午後") {
	    out = 12+normalizeNumber(str.substring(2,str.length));
	}
	else if (pm && out<12) {
	    out +=12;
	}
	return out;
    }
    // Define yearWestern
    function yearWestern(str) {
	if( typeof( str ) != "string" ) { return str; }
	str=str.strip();
	out=normalizeNumber(str);
	if (str.substring(0,2)=="平成") {
	    out = 1988+normalizeNumber(str.substring(2,str.length));
	}
	return out;
    }
}
