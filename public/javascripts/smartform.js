var del = "：:\\s"; // delimiters

var normalizeNumber = function( inStr ){
    var outStr=inStr;
    var convMap= {"１":"1","２":"2","３":"3","４":"4","５":"5","６":"6","７":"7","８":"8","９":"9","０":"0"};
    if( typeof( inStr ) != "string" ) { return inStr; }
    if( inStr.length==0 ) { return "00"; }
    for ( var key in convMap ){ outStr = outStr.replaceAll( key, convMap[key] );   }
    return outStr;
}
 
// String型にreplaceAll()関数を追加
String.prototype.replaceAll = function ( before, after ) {
  return this.split( before ).join( after );  
}

String.prototype.strip = function() {
    return String(this).replace(/^\s+|\s+$/g, '');
}

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
		if (this.hasDefaultValue) {
		    this.strArray = [match[1]];
		    this.hasDefaultValue=false;
		}
		else {
		    var tmp=new Item(this.id);
		    tmp.re = this.re;
		    tmp.joiner = this.joiner;
		    tmp.hasDefaultValue=false;
		    if (match[1].length>0)
		    tmp.strArray.push(match[1]);
		    tmp.show = this.show;
		    return tmp;
		}
	    }
	    else if (match[1].length>0) {
		this.strArray.push(match[1]);
		this.hasDefaultValue=false;
	    }
	    return true;
	}
	return false;
    },
    show: function(index) {
	if (this.strArray.length>0) {
	    this.show_str(index,this.strArray.join(this.joiner));
	}
    },
    show_str: function(index,str) {
	$("#"+this.id+index).val(str.strip());
    }
};

function append_empty_form(sel, i) {
	$(sel).append('<form action="http://localhost:3000/talk/update" enctype="multipart/form-data" id="edittalk" method="post"><input id="talk_series_id" name="talk[series_id]" type="hidden" value="5" /><dt>Date YYYY/MM/DD    Time HH:MM</dt><dd><input id="talk_date_string'+i+'" name="talk[date_string]" size="11" type="text" /> From <input id="talk_start_time_string'+i+'" name="talk[start_time_string]" size="5" type="text" /> to <input id="talk_end_time_string'+i+'" name="talk[end_time_string]" size="5" type="text" /></dd><dt>Title</dt><dd><input class="wide" id="talk_title'+i+'" name="talk[title]" size="60" type="text" /></dd><dt>Abstract</dt><dd><textarea class="wide" cols="57" id="talk_abstract'+i+'" name="talk[abstract]" rows="10"></textarea></dd><dt>Speaker\'s name and affiliation</dt><dd><input class="wide" id="talk_name_of_speaker'+i+'" name="talk[name_of_speaker]" size="60" type="text" /></dd><dt>Speaker\'s e-mail</dt><dd><input class="wide" id="talk_speaker_email" name="talk[speaker_email]" size="60" type="text" value="" /><p class="emailcheck"><input id="talk_send_speaker_email" name="talk[send_speaker_email]" type="checkbox" value="1" /><input name="talk[send_speaker_email]" type="hidden" value="0" />Check this box to send an e-mail to the speaker when you save this talk.</p></dd><dt>Venue</dt><dd><input class="wide" id="talk_venue_name'+i+'" name="talk[venue_name]" size="60" type="text" value="Venue to be confirmed" /></dd><p><input name="commit" type="submit" value="Save" /> or <a href="http://localhost:3000/show/index/7">Cancel</a></p></form>');

}

function parse_smart_form(box) {
    var Talk= function() {
	this.date= new Item("talk_date_string",
			    "Time|Date\\s*(?:& Time|)|日時|日程",
			    "(.*)", "");
	this.venue= new Item("talk_venue_name",
			     "Place|Venue|@|場所|会場",
			     "(.*)",", ");
	this.abst= new Item("talk_abstract",
			    "Abstract|(?:講演|セミナー|)(?:アブストラクト|概要|要旨)(?:.*[Aa]bstract[^"+del+"]|)",
			    "(.*)");
	this.speaker= new Item("talk_name_of_speaker",
			       "Speaker|(?:発表者|講演者|スピーカー|講師)(?:.*[Ss]peaker[^"+del+"]|)",
			       "(.*)",", ");
	this.supervisor= new Item("talk_name_of_speaker",
				  "指導教員","(.*)",", ");
	this.title= new Item("talk_title",
			     "Title|(?:講演|セミナー|)(?:題目|タイトル|演題)(?:.*[Tt]itle[^"+del+"]|)",
			     "(.*)", " ");

	this.date.show = function(index) {
	    var str = this.strArray.join("");
	    var re = new RegExp("(?:((?:平成\\s*|)[０-９\\d]+)\\s*[年/／]\\s*|)([０-９\\d]+)\\s*[月/／]\\s*([０-９\\d]+)\\s*(?:日|)(?:[^０-９\\d午前後]*\\s*((?:午前|午後|)\\s*[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)(?:\\s*(?:[-－ー〜～~]+|から)\\s*|)(?:((?:午前|午後|)[０-９\\d]+)\\s*[時:：](?:\\s*([０-９\\d]+)(?:分|)|)|)");
	    var hour24 = function(str) {
		if( typeof( str ) != "string" ) { return str; }
		str=str.strip();
		if (str.substring(0,2)=="午前") {
		    str = str.substring(2,str.length);
		}
		else if (str.substring(0,2)=="午後") {
		    str = String(12+parseInt(str.substring(2,str.length)));
		}
		return str;
	    };
	    var yearWestern = function(str) {
		if( typeof( str ) != "string" ) { return str; }
		str=str.strip();
		if (str.substring(0,2)=="平成") {
		    str = String(1988+parseInt(str.substring(2,str.length)));
		}
		return str;
	    };

	    var match = str.match(re);
	    if (match) {
		var d=new Date();
		var year=yearWestern(match[1] || d.getFullYear());
		this.show_str(index,normalizeNumber(year)+"/"
			      +normalizeNumber(match[2])+"/"
			      +normalizeNumber(match[3]));
		$("#talk_start_time_string"+index).val(normalizeNumber(hour24(match[4]))+":"+normalizeNumber(match[5]||"00"));
		$("#talk_end_time_string"+index).val(normalizeNumber(hour24(match[6]))+":"+normalizeNumber(match[7]||"00"));
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
		this.show_str(index, $("#"+this.id+index).val()+"　（指導教員："+this.strArray.join(this.joiner)+"）");
	    }
	};

    }; // Talk オブジェクトの定義ここまで
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
		    talk[currentKey].strArray.push(textArray[i]);
	}
    }
    talks.push(talk);

    $('#box').empty()
    for (var i=0; i<talks.length; i++) {
	append_empty_form('#box',i);
	for (var key in talks[i]) {
	    talks[i][key].show(i);
	}
    }
}
