module Api::Controllers::Sheets
  class Update
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      result = user_adapter(@token_user) do |a|
        sheet = a.sheets[ params[:id] ]
        content = remove_styles(params[:content])
        a.update_sheet(sheet, :content => content, :title => params[:title])
        @return = sheet.to_hash
      end
      self.status = 200
      self.body = @return.to_json
    end

    def remove_styles(str)
      doc = Nokogiri::HTML.fragment(str)
      doc.css("a").each do |a|
        a.remove_attribute("style")
      end
      doc.css("span").each do |a|
        a.replace(a.text)
      end
      doc.to_html
    end
  end
end
