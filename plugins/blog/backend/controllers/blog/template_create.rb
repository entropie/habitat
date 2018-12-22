module Backend::Controllers::Blog
  class TemplateCreate
    include Api::Action

    def call(params)
      if request.post?

        anchor = { :anchor => params[:at][1..-1] } if params[:at] and !params[:at].to_s.empty?
        
        oident, ident = params[:oident], params[:identifier]

        tmpl = if oident.to_s.empty? # new
                 Blog::Templates::TemplateDummy.new("foo")
               elsif ident == oident #
                 Blog.templates[ident]
               end

        tmpl.with_operator.update_or_create(ruby: params[:ruby], javascript: params[:javascript], sass: params[:styles])

        redirect_to "#{routes.template_path(ident)}#{params[:at]}"

        p tmpl
        p oident, ident
        
      end

      #exit
    end
  end
end
