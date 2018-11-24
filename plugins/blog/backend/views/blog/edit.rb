module Backend::Views::Blog
  class Edit
    include Backend::View

    def templates_select(post)
      ret = "<select class='form-select' name='template'>%s</select>"
      options = []
      Blog.templates.each do |tmpls,tmpl|
        selected = ""
        if (post && post.template && tmpl == post.template) or
          (tmpl == C[:default_template])
          selected = " selected='selected' "
        end
        options << "<option %s value='%s'>%s</option>" % [selected, tmpls.to_s, tmpls.to_s]
      end
      _raw(ret % options.join)
    end

  end
end
