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

var Style = function(id, title, re, joiner) {
    this.id    = id;
    this.re    = new RegExp("^(?:"+title+")\\s*["+del+"]\\s*(?:"+re+")|^(?:"+title+")$");
    this.strArray   = new Array();
    if (joiner) {
	this.joiner = joiner;
    }
    else {
	this.joiner = "";
    }
}

Style.prototype = {
    parse_line: function(line) {
	if (line.match(this.re)) {
	    if (RegExp.$1.length>0) {
		this.strArray.push(RegExp.$1);
	    }
	    return true;
	}
	return false;
    },
    show: function() {
	if (this.strArray.length>0) {
	    this.show_str(this.strArray.join(this.joiner));
	}
    },
    show_str: function(str) {
	$("#"+this.id).val(str.strip());
    }
};


function parse_smart_form(box) {
    var styles = { date: new Style("talk_date_string",
				   "Time|Date\\s*(?:& Time|)|日時|日程",
				   "(.*)", ""),
		   venue: new Style("talk_venue_name",
				    "Place|Venue|@|場所|会場",
				    "(.*)",", "),
		   abst: new Style("talk_abstract",
				   "Abstract|(?:講演|セミナー|)(?:アブストラクト|概要|要旨)(?:.*[Aa]bstract[^"+del+"]|)",
				   "(.*)"),
		   speaker: new Style("talk_name_of_speaker",
				      "Speaker|(?:発表者|講演者|スピーカー|講師)(?:.*[Ss]peaker[^"+del+"]|)",
				      "(.*)",", "),
		   supervisor: new Style("talk_name_of_speaker",
					 "指導教員","(.*)",", "),
		   title: new Style("talk_title",
				    "Title|(?:講演|セミナー|)(?:題目|タイトル|演題)(?:.*[Tt]itle[^"+del+"]|)",
				    "(.*)", " ")};

    styles.date.show = function() {
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
	    this.show_str(normalizeNumber(year)+"/"
		+normalizeNumber(match[2])+"/"
		+normalizeNumber(match[3]));
	    $("#talk_start_time_string").val(normalizeNumber(hour24(match[4]))+":"+normalizeNumber(match[5]||"00"));
	    $("#talk_end_time_string").val(normalizeNumber(hour24(match[6]))+":"+normalizeNumber(match[7]||"00"));
	}
    };

    styles.title.show = function() {
	if (this.strArray.length>0) {
	    var str=this.strArray.join(this.joiner).strip();
	    str=str.replace(/^["“]|["”]$/g, '');
	    this.show_str(str);
	}
    };
    // アブスト中に日本語の中に半角スペースを入れない
    styles.abst.show = function() {
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
	    this.show_str(out);

	}
    };

    // 数理輪講のため
    styles.supervisor.show = function() {
	if (this.strArray.length>0) {
	    this.show_str($("#"+this.id).val()+"　（指導教員："+this.strArray.join(this.joiner)+"）");
	}
    };


    var textArray = box.val().split("\n");
    var currentKey = "";
    for (var i=0; i<textArray.length; i++) {
	var hit=false;
	for (var key in styles) {
	    if (styles[key].parse_line(textArray[i])) {
		currentKey = key;
		hit=true;
		break;
	    }
	}
	if (!hit & textArray[i].length>0 && currentKey.length>0) {
		    styles[currentKey].strArray.push(textArray[i]);
	}
    }
    for (var key in styles) {
	styles[key].show();
    }
}
