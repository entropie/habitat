module Api::Controllers::Sheet
  class Update
    include Api::Action

    def call(params)
      result = user_adapter do |a|
        sheet = a.sheets[ params[:id] ]
        a.update_sheet(sheet, :content => params[:content])
        self.status = 200
        self.body = sheet.to_hash.to_json
      end
    end
  end
end
