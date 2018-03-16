module Api::Controllers::Sheets
  class Sheet
    include Api::Action
    ### include Hanami::Action::Session

    include Diary::ApiControllerMethods 

    def call(params)
      #sleep 2
      sheet = user_adapter(@token_user) do |a|
        a.sheets[ params[:id] ]
      end
      @return.merge!(sheet.to_hash) if sheet

      self.status = 200
      self.body = @return.to_json
    end

  end
end
