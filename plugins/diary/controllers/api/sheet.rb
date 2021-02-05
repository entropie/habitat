module Api::Controllers::Sheets
  class Sheet
    include Api::Action
    ### include Hanami::Action::Session

    include Diary::ApiControllerMethods 

    def call(params)
      sheet = diary.with_user(session_user) do |d|
        d.find(:id => params[:id]).first
      end
      
      retval.merge!(sheet.to_hash) if sheet

      self.status = 200
      self.body = retval.to_json
    end

  end
end
