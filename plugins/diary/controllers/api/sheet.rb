module Api::Controllers::Sheets
  class Sheet
    include Api::Action
    ### include Hanami::Action::Session

    include Diary::ApiControllerMethods 

    def call(params)
      sheet = diary.find(:id => params[:id]).first
      @return.merge!(sheet.to_hash) if sheet

      self.status = 200
      self.body = @return.to_json
    end

  end
end
