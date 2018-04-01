module Api::Controllers::Sheets
  class Update
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      #sleep 2

      result = A(@token_user) do |a|
        sheet = a.sheets[ params[:id] ]
    
        filtered_params = [:title, :content, :preview].inject({}) do |m, k|
          m[k] = params[k] if params[k]
          m
        end
        filtered_params[:content] = remove_styles(filtered_params[:content]) if filtered_params[:content]
        a.update_sheet(sheet, filtered_params)
        @return = sheet.to_hash
      end
      self.status = 200
      self.body = @return.to_json
    end

    def remove_styles(str)
      doc = Nokogiri::HTML.fragment(str)
      doc.css(".medium-insert-buttons").remove
      doc.to_html
    end
  end
end
