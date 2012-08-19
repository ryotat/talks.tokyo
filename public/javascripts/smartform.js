// String型にreplaceAll()関数を追加
String.prototype.replaceAll = function ( before, after ) {
    return this.split( before ).join( after );  
}

String.prototype.strip = function() {
    return String(this).replace(/^\s+|\s+$/g, '');
}

function append_empty_form(sel, i) {
	jQuery(sel).append('<form action="http://localhost:3000/talk/update" enctype="multipart/form-data" id="edittalk" method="post"><input id="talk_series_id" name="talk[series_id]" type="hidden" value="5" /><dt>Date YYYY/MM/DD    Time HH:MM</dt><dd><input id="talk_date_string'+i+'" name="talk[date_string]" size="11" type="text" /> From <input id="talk_start_time_string'+i+'" name="talk[start_time_string]" size="5" type="text" /> to <input id="talk_end_time_string'+i+'" name="talk[end_time_string]" size="5" type="text" /></dd><dt>Title</dt><dd><input class="wide" id="talk_title'+i+'" name="talk[title]" size="60" type="text" /></dd><dt>Abstract</dt><dd><textarea class="wide" cols="57" id="talk_abstract'+i+'" name="talk[abstract]" rows="10"></textarea></dd><dt>Speaker\'s name and affiliation</dt><dd><input class="wide" id="talk_name_of_speaker'+i+'" name="talk[name_of_speaker]" size="60" type="text" /></dd><dt>Speaker\'s e-mail</dt><dd><input class="wide" id="talk_speaker_email" name="talk[speaker_email]" size="60" type="text" value="" /><p class="emailcheck"><input id="talk_send_speaker_email" name="talk[send_speaker_email]" type="checkbox" value="1" /><input name="talk[send_speaker_email]" type="hidden" value="0" />Check this box to send an e-mail to the speaker when you save this talk.</p></dd><dt>Venue</dt><dd><input class="wide" id="talk_venue_name'+i+'" name="talk[venue_name]" size="60" type="text" value="Venue to be confirmed" /></dd><p><input name="commit" type="submit" value="Save" /> or <a href="http://localhost:3000/show/index/7">Cancel</a></p></form>').hide().fadeIn("fast");

}

function parse_smart_form(box) {
    var del = "：:\\s"; // delimiters

    // Define Item
    var Item = function(id, key, re, joiner) {
	this.id    = id;
	this.hasDefaultValue=true;
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
	}
    };

    // Main
    (function(box, Talk) {
    var talk = new Talk();

    var textArray = box.val().split("\n");
    var currentKey = "";
    var talks = new Array();
    for (var i=0; i<textArray.length; i++) {
	var hit=false;
	for (var key in talk) {
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
	if (!hit & textArray[i].length>0 && currentKey.length>0) {
		    talk[currentKey].insert_line(textArray[i]);
	}
    }
    talks.push(talk);

    // $('#box').empty()
    for (var i=0; i<talks.length; i++) {
	// append_empty_form('#box',i);
	for (var key in talks[i]) {
	    talks[i][key].show('');
	}
    }
    })(box,  // Define Talk Object here
       function() {
	this.comment = new Item("","#","(.*)", "");
	this.date= new Item("talk_date_string",
			    "Time|Date\\s*(?:& Time|)|日時|日程",
			    "(.*)", "");
	this.venue= new Item("talk_venue_name",
			     "Place|Venue|Location|@|場所|会場",
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

	this.date.show = function(index) {
	    (function(obj, index, normalizeNumber, hour24, yearWestern) {
	    var str = obj.strArray.join("");
	    var restr_time = "(?:[^０-９\\d午前後]*\\s*((?:午前|午後|)\\s*[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)(?:\\s*(?:[-－ー〜～~]+|から)\\s*|)(?:((?:午前|午後|)[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)";
	    var re = new RegExp("(?:((?:平成\\s*|)[０-９\\d]+)\\s*[年/／]\\s*|)([０-９\\d]+)\\s*[月/／]\\s*([０-９\\d]+)\\s*(?:日|)"+restr_time);
	    var match = str.match(re);
	    if (match) {
		var d=new Date();
		var year=yearWestern(match[1] || d.getFullYear());
		var month=match[2];
		var day=match[3];
		var starth=match[4];
		var startm=match[5];
		var endh=match[6];
		var endm=match[7];
	    }
	    else {
		var re = new RegExp("(?:"
				    +"(?:Monday|Mon)|"
				    +"(?:Tuesday|Tue)|"
				    +"(?:Wednesday|Wed)|"
				    +"(?:Thursday|Thu)|"
				    +"(?:Friday|Fri)|"
				    +"(?:Saturday|Sat)|"
				    +"(?:Sunday|Sun)|)[\\s,]*"
				    +"((?:January|Jan)|"
				    +"(?:February|Feb)|"
				    +"(?:March|Mar)|"
				    +"(?:April|Apr)|"
				    +"May|"
				    +"(?:June|Jun)|"
				    +"(?:July|Jul)|"
				    +"(?:August|Aug)|"
				    +"(?:September|Sep)|"
				    +"(?:October|Oct)|"
				    +"(?:November|Nov)|"
				    +"(?:December|Dec))\\s*"
				    +"([０-９\\d]+)[sthrd\\s,]*"
				    +"(?:([０-９\\d]+)|)"+restr_time);
		var match=str.match(re);
		if (match) {
		    var d=new Date();
		    var year=match[3] || d.getFullYear();
		    var map = {"Jan":"1", "Feb":"2", "Mar":"3", "Apr":"4", "May":"5", "Jun":"6", "Jul":"7", "Aug":"8", "Sep":"9", "Oct":"10", "Nov":"11", "Dec":"12"};
		    var month=map[match[1].substring(0,3)];
		    var day=match[2];
		    var starth=match[4];
		    var startm=match[5];
		    var endh=match[6];
		    var endm=match[7];
		}
	    }
		if (year && month && day) {
		    obj.show_str(index,normalizeNumber(year)+"/"
				 +normalizeNumber(month)+"/"
				 +normalizeNumber(day));
		}
		if (!starth || !startm || !endh || !endm)  {
		    var re = new RegExp(restr_time);
		    var match=str.match(re);
		    if (match) {
			var starth=match[1];
			var startm=match[2];
			var endh=match[3];
			var endm=match[4];
		    }
		}
		jQuery("#talk_start_time_string"+index).val(normalizeNumber(hour24(starth))+":"+normalizeNumber(startm||"00"));
		jQuery("#talk_end_time_string"+index).val(normalizeNumber(hour24(endh))+":"+normalizeNumber(endm||"00"));
	    })(this, index, 
	       // Define normalizeNumber
	       function( inStr ){
		   var outStr=inStr;
		   var convMap= {"１":"1","２":"2","３":"3","４":"4","５":"5","６":"6","７":"7","８":"8","９":"9","０":"0"};
		   if( typeof( inStr ) != "string" ) { return inStr; }
		   if( inStr.length==0 ) { return "00"; }
		   for ( var key in convMap ){ outStr = outStr.replaceAll( key, convMap[key] );   }
		   return outStr;
	       },
	       // Define hour24
	       function(str) {
		   if( typeof( str ) != "string" ) { return str; }
		   str=str.strip();
		   if (str.substring(0,2)=="午前") {
		       str = str.substring(2,str.length);
		   }
		   else if (str.substring(0,2)=="午後") {
		       str = String(12+parseInt(str.substring(2,str.length)));
		   }
		   return str;
	       },
	       // Define yearWestern
	       function(str) {
		   if( typeof( str ) != "string" ) { return str; }
		   str=str.strip();
		   if (str.substring(0,2)=="平成") {
		       str = String(1988+parseInt(str.substring(2,str.length)));
		   }
		   return str;
	       });


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
			    out+=" "+this.strArray[i];
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

    } // End of Talk object definition
      );

}
