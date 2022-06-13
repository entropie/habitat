module Api::Controllers::Sheets
  class Update
    include Backend::Action
    include Diary::ApiControllerMethods 

    def call(params)
      values_hash = {}
      [:content, :title].each do |tv|
        values_hash[tv] = params[tv] if params[tv]
      end

      sheet = diary.find(id: params[:id]).first
      newsheet = diary.update_sheet(sheet, values_hash)

      self.status = 200
      self.body = retval.merge(newsheet.to_hash).to_json
    end

  end
end
