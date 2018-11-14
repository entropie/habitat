import "spectre.css"


import 'jquery';

import 'jquery-tags-input/src/jquery.tagsinput.js'
import 'jquery-tags-input/src/jquery.tagsinput.css' 




import '../../../plugins/backend/src/backend.sass'
import "../../../plugins/backend/src/fa.css.sass"

import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/monokai.css'

import CodeMirror from 'codemirror';
import 'codemirror/keymap/emacs'
import 'codemirror/mode/haml/haml.js'
import 'codemirror/mode/markdown/markdown.js'
import 'codemirror/addon/edit/continuelist.js'
import 'codemirror/addon/fold/foldcode.js'
import 'codemirror/addon/fold/markdown-fold.js'
import 'codemirror/addon/fold/comment-fold.js'

function betterTab(cm) {
  if (cm.somethingSelected()) {
    cm.indentSelection("add");
  } else {
    cm.replaceSelection(cm.getOption("indentWithTabs")? "\t":
      Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
  }
}

$(document).ready(function() {
    console.log("backend deine mama");


    if($(".cm-form").length) {
        var jform  = $(".cm-form")
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
            matchBrackets: true,
            extraKeys: { Tab: betterTab },
            height: "100%"
        });
    }
});

