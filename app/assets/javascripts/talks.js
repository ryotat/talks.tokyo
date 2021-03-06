jQuery.noConflict(); // so that Prototype and jQuery can coexist
(function($){
    $(document).ready(function() {
	var fix_top_support = function() {
	    if ($(window).width() > 980 ) {
		$('div.navbar-fixed-top').parent('body').css('padding-top','80px');
	    }
	    else {
		$('body').css('padding-top','0px');
	    }
	};
	fix_top_support();
	$(window).on('resize', fix_top_support);
	
	$('body').tooltip({
	    selector: "[rel*=tooltip]"
	});
	$(document).on(
	    'click',
	    "[rel*=talks-modal]",
	    function(event) {
		$(this).talks('modal',event);
	    }
	).on('mouseenter', 
	    "[rel*=talks-hidden-btn]",
	    function() {
		$(this).find('a.hide').css({"display":"inline"});
	    }
	).on("mouseleave",
	     "[rel*=talks-hidden-btn]",
	     function() {
		 $(this).find('a.hide').css({"display":"none"});
	     }
	).on('ajax:success',
	     "[rel*=receive-json]",
	     function(event, data, status, xhr) {
		 var target=$(this).data('target');
		 var close=$(this).data('close');
		 $.fn.talks('show_flash', data, target, close);
	     }
	).on('ajax:success',
	     "[rel*=receive-html]",
	     function(event, data, status, xhr) {
		 var target=$(this).data('target');
		 $(target).html(data);
	     }
	);
	$("[rel*=observe]").talks('observe_form');
	$("[rel*=talks-home-tab]").talks('dynamic_tab');
	$(".subnav").bootstrap_subnav_fix();
    });

    var methods = {
	default_value : function(text) {
	    this.talks('blurInputDefault',text);
	    this.focus( function(event){ $(this).talks('focusInputDefault',text); });
	    this.blur( function(event){ $(this).talks('blurInputDefault', text); });
	},
	focusInputDefault : function(text) {
	    if(this.val() == text) {
		this.removeClass('blur');
		this.val('');
	    }
	},
	blurInputDefault : function(text) {
	    if(this.val() == '' ) {
		this.addClass('blur');
		this.val(text);
	    }
	},
	setField : function(value) {
	    this.effect('highlight', {}, 1000);
	    this.val(value);
	},
	helper : function (list_id, prefix) {
	    return this.each(function () {
		var field_begin = (prefix=='talk_') ? 0 : 7;
		$(this).focus(function() {
		    var pos=$(this).offset();
		    var offset=$('#edit_talk_help').offset();
		    $('#edit_talk_help').offset({top: pos.top, left: offset.left});
		    $('#edit_talk_help').load('/talks/help?list_id='+list_id+'&field='+this.id.substring(field_begin)+'&prefix='+prefix);
		});
	    });
	},
	observer : function(action) {
	    var $this = this;
	    var typingTimer;              
	    var doneTypingInterval = 500;
	    var doneTyping = function() {
		action($this);
	    };
	    this.bind('keyup change',function() {
		clearTimeout(typingTimer);
		if ($this.val()) {
		    typingTimer = setTimeout(doneTyping, doneTypingInterval);
		}
	    });
	},
	observe_field : function(target, url) {
	    this.talks('observer', function($this) {
		$(target).load(url(encodeURIComponent($this.val())));
	    });
	},
	observe_form : function() {
	    var $this=this;
	    var target=this.data('target');
	    var url=this.data('observer-url');
	    this.find('input,textarea').talks('observer',function(el) {
		$.ajax({
		    type: "POST",
		    url: url,
		    data: $this.serialize(),
		    success: function(data) {
			if (url.indexOf('.json') != -1) {
			    $.fn.talks('show_flash', data, target);
			}
			else {
			    $(target).html(data);
			}
		    }
		});
	    });
	},
	show_flash: function(data, target, close) {
	    if (data.confirm) {
		$(target).html('<div class="alert alert-success">'+data.confirm+'</div>');
		$(target).effect('highlight', {}, 1000);
		if (close) {
		    $(close).leanModalClose();
		}
	    }
	    if (data.error) {
		$(target).html('<div class="alert alert-error">'+data.error+'</div>');
		$(target).effect('highlight', {}, 1000);
	    }
	},
	replace_button: function(content) {
	    this.tooltip('hide');
	    this.replaceWith(content);
	},
	calendar_with_talks : function(opt) {
	    var $this=this;
	    if (typeof(opt.dates)=='undefined') { opt.dates = []; }
	    if (typeof(opt.titles)=='undefined') { opt.titles = []; }
	    if (typeof(opt.date)=='undefined') { opt.date = ''; }
	    if (typeof(opt.trigger)=='undefined') { opt.trigger = 'click'; }
	    $this.datepicker({beforeShowDay: function(d) {
		var ind=[];
		$.each(opt.dates, function(i,e){ if ((e-d)==0) { ind.push(i); }});
		if (ind.length>0) {
		    var str="";
		    for( var i=0; i<ind.length; i++) {
			str+=opt.titles[ind[i]];
		    }
		    return [true, "highlight list%d_color".replace('%d',opt.ids[ind[0]]), encodeURIComponent(str)];
		}
		else {
		    return [true, ""];
		}
	    }, afterShow: function(inst) {
		inst.dpDiv.find('td.highlight').each(function() { 
		    var a = $(this).children('a');
		    a.tooltip({title: decodeURIComponent(this.title), html:true, trigger: opt.trigger});
		this.title='';});
	    }, onSelect: function(date, inst) {
		if (opt.trigger=='click') {
		    inst.inline = false;
		}
		var aogn=inst.dpDiv.find('a:hover');
		var a=inst.dpDiv.find('div.tooltip a');
		$(document).keyup(function(e){if(e.which==27){ aogn.tooltip('hide'); }});
		a.click(function() {
		    location.href = $(this).attr('href');
		});
	    }, dateFormat: 'yy/mm/dd'});
	    $this.datepicker("setDate",opt.date);
	},
	dynamic_tab : function() {
	    var target=this.data('target');
	    var href=this.data('href');
	    var deftab=this.data('deftab');
	    if (target) {
		var loadTab = function(tab) {
		    $(target).load(href.replace(/%s/g, tab));
		};
		$(this).find('a#%s'.replace(/%s/,deftab)).tab('show');
		loadTab(deftab);
		$(this).find('a').click(function (e) {
		    e.preventDefault();
		    $(this).tab('show');
		    loadTab(this.id);
		});
	    }
	},
	modal : function(e) {
	    var href=$(this).attr('href');
	    var target='talks-modal';
	    e.preventDefault();
	    if ($('#'+target).length==0) {
		$('body').append("<div id='%s' class='lean_modal'><button type='button' class='modal_close close'>&times;</button><div class='modal-body'></div></div>".replace('%s',target));
	    }
	    $('#'+target+' .modal-body').load(href);
	    $('#'+target).leanModalShow({ top : 100, closeButton: ".modal_close"});
	}
    };
    $.fn.talks = function( method ) {
	// Method calling logic
	if ( methods[method] ) {
	    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	} else if ( typeof method === 'object' || ! method ) {
	    return methods.init.apply( this, arguments );
	} else {
	    $.error( 'Method ' +  method + ' does not exist on jQuery.talks' );
	}    
  };
    $.fn.bootstrap_subnav_fix = function() {
	// fix sub nav on scroll
	var $win = $(window),
	$nav = $(this),
	navHeight = $('.navbar').first().height(),
	navTop = $nav.length && $nav.offset().top - navHeight,
	isFixed = 0,
	default_visible = $(this).data('visible');
	if (!default_visible) {
	    $nav.addClass('hide');
	}
	processScroll();
	
	$win.on('scroll', processScroll);

	function processScroll() {
	    var i, scrollTop = $win.scrollTop();
	    if (scrollTop >= navTop && !isFixed) {
		isFixed = 1;
		$nav.addClass('subnav-fixed');
		if ($win.width()<980) {
		    $nav.addClass('subnav-fixed-top');
		}
		else {
		    $nav.removeClass('subnav-fixed-top');
		}
		if (!default_visible) {
		    $nav.removeClass('hide');
		}
	    } else if (scrollTop <= navTop && isFixed) {
		isFixed = 0;
		$nav.removeClass('subnav-fixed');
		if (!default_visible) {
		    $nav.addClass('hide');
		}
	    }
	}

    };

})(jQuery);

var hsv_rgb = function(h, s, v) {
    return jQuery.map([h, h-120, h+120],
		function(x) {
		    x =  (x+180)%360-180;
		    return Math.floor((Math.abs(x) > 120) ? v*(1-s) : (Math.abs(x) > 60 ? v*(1-(Math.abs(x)/60.0-1)*s) : v)).toString(16);
		    }).join('');
};



/** Helper functions **/

function setVenue(name,prefix) {
    jQuery('#'+prefix+'venue_name').talks('setField',name);
}

function setSpeaker(name,email,prefix) {
    jQuery('#'+prefix+'name_of_speaker').talks('setField',name);
    jQuery('#'+prefix+'speaker_email').talks('setField',email);
}

function setTiming(start,finish,prefix) {
    jQuery('#'+prefix+'start_time_string').talks('setField',start);
    jQuery('#'+prefix+'end_time_string').talks('setField',finish);
}


