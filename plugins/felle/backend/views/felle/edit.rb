module Backend::Views::Felle
  class Edit
    include Backend::View

    def checked(cond)
      if cond
        { :checked => :checked }
      else
        {}
      end
    end

    def disabled(cond)
      if cond
        { :disabled => :disabled }
      else
        {}
      end
      
    end

    def selected(cond)
      if cond
        { :selected => :selected }
      else
        {}
      end
    end

    def date_value(o)
      if o
        o.strftime("%F")
      else
        ""
      end
    end

    def checkbox(fell, attr, val)
      r = {:type => :checkbox, :name => "attributes[#{attr}]", :value => 1 }
      if fell
        r.merge!(:checked => :checked) if val == 1
      end
      r
    end
    
  end
end
