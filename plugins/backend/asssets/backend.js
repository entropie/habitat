// ::backend::

import "spectre.css"

import 'jquery';

import 'jquery-tags-input/src/jquery.tagsinput.js'
import 'jquery-tags-input/src/jquery.tagsinput.css' 

import '../../../plugins/backend/asssets/backend.sass'

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

    if($("#snippet-form").length)
        var beditor = CodeMirror.fromTextArea(document.getElementById("snippet-form"), {
            lineNumbers: false,
            lineWrapping: true,
            mode: "text/x-haml",
            // keyMap: "emacs",
            matchBrackets: true,
            extraKeys: { Tab: betterTab }
        });

});
