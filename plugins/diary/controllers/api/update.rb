module Api::Controllers::Sheets
  class Update
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      result = user_adapter(@token_user) do |a|
        sheet = a.sheets[ params[:id] ]
        a.update_sheet(sheet, :content => params[:content])
        @return = sheet.to_hash
      end
      self.status = 200
      self.body = @return.to_json
    end
  end
end
