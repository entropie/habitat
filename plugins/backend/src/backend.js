import "spectre.css"

import { compareAsc, format,add } from 'date-fns'


import 'jquery-tags-input/src/jquery.tagsinput.js'
import 'jquery-tags-input/src/jquery.tagsinput.css' 

import 'webpack-jquery-ui/tabs'

import "jquery-datetimepicker"
import "jquery-datetimepicker/jquery.datetimepicker.css"


import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/monokai.css'

import CodeMirror from 'codemirror';
import 'codemirror/keymap/emacs'
import 'codemirror/mode/haml/haml.js'
import 'codemirror/mode/sass/sass.js'
import 'codemirror/mode/javascript/javascript.js'
import 'codemirror/mode/markdown/markdown.js'
import 'codemirror/addon/edit/continuelist.js'
import 'codemirror/addon/fold/foldcode.js'
import 'codemirror/addon/fold/markdown-fold.js'
import 'codemirror/addon/fold/comment-fold.js'
import 'codemirror/addon/display/autorefresh.js'


function convertToSlug(text) {
    return text.trim()
        .toLowerCase()
        .replace(/ /g, '-')
        .replace(/[^\w-]+/g, '');
}

function betterTab(cm) {
  if (cm.somethingSelected()) {
    cm.indentSelection("add");
  } else {
    cm.replaceSelection(cm.getOption("indentWithTabs")? "\t":
      Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
  }
}

function dateLineLinkclick() {
    let dl = $(this);
    $(dl).find(".remove-day-link").click(function() {
        dl.remove();
    });
}


function setBookingIdentField(regexp, val) {
    let identfield = $('#events-edit input[name="ident"]');
    if( identfield.is(':disabled') )
        return false;
    let newident = identfield.val().replace(regexp, val);
    identfield.attr("value", newident);
}

function replaceIdentFromTypeChange() {
    setBookingIdentField(/^[\w\s]+--/, $(this).find(':selected').data("humantype") + "--")
}

jQuery.datetimepicker.setLocale('de');

$(document).ready(function() {
    console.log("backend");
   
    
    $('.datepicker').datetimepicker({
        timepicker: true,
        onChangeDateTime:function(dp,$input){
            var date, datestr;
            if($input.attr("name") === "dates[begin][]") {
                date = new Date(Date.parse($input.val()));
                date = add(date, { minutes: 60 })
                datestr = format(date, "yyyy/MM/dd HH:mm");

                setBookingIdentField(/\d\d?\-\d\d$/, format(date, "II-yy"))

                $input.parent().parent().parent().parent().find('input[name="dates[end][]"]').attr("value", datestr)
            }
        }
    });

    if($("#events-edit").length) {
        $("#add-date-template-link").click(function() {
            let ele2copy = $("#add-date-template .date-line:last-child").clone();
            console.log(ele2copy);
            ele2copy.find(".datepicker").datetimepicker();
            $(ele2copy).each(dateLineLinkclick);
            ele2copy.insertAfter( $("#events-edit .date-line").filter(":last") ).addClass("toadd");
        });

        $('#events-edit select[name="type"]').each(function() {
            $(this).on('change', replaceIdentFromTypeChange)
        });


        $(".date-line").each(dateLineLinkclick);
    }

    if($("#db-template-edit").length) {
        var hsh = window.location.hash;
        $("#db-template-edit .tabs").tabs();

        var setTabActive = function(tbhsh) {
            var scrollmem = $('body').scrollTop();
            window.location.hash = tbhsh;
            $('html,body').scrollTop(scrollmem);
            $("#db-template-edit input.at").attr("value", tbhsh);
        }
        
        if(hsh.length > 0) {
            console.log("yo");
            setTabActive(hsh);
        };
        
        $("#db-template-edit .tabs li a").click(function() {
            setTabActive(this.hash);
            
            return true;
        });
    }

    if($("#db-fell-edit").length) {
        var hsh = window.location.hash;
        $("#db-fell-edit .tabs").tabs();

        // $("#db-template-edit .tabs li").each(function() {
        //     var href = $(this).find("a").attr("href");
        // });

        var setTabActive = function(tbhsh) {
            var scrollmem = $('body').scrollTop();
            window.location.hash = tbhsh;
            $('html,body').scrollTop(scrollmem);
            $("#db-fell-edit input.at").attr("value", tbhsh);
        }
        
        if(hsh.length > 0) {
            console.log("yo");
            setTabActive(hsh);
        };
        
        $("#db-fell-edit .tabs li a").click(function() {
            setTabActive(this.hash);
            
            return true;
        });
    }

    if($(".cm-form").length) {
        $(".cm-form").each(function() {

            var jform  = $(this)
            var beditorid = jform.attr("id");
            // console.log(beditorid, $(jform).attr("data-codemirror-mode"));
            var cmmode = $(jform).attr("data-codemirror-mode");
            // if($(".cm-mode")) {
            //     console.log( $(".cm-mode").find("option:selected").val() );
            // }
            var beditor = CodeMirror.fromTextArea( document.getElementById(beditorid), {
                lineNumbers: false,
                lineWrapping: true,
                mode: cmmode,
                autoRefresh: true,
                matchBrackets: true,
                extraKeys: { Tab: betterTab },
                height: "100%"
            });
        })
    }
});


