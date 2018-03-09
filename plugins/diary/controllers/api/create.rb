# coding: utf-8

module Api::Controllers::Sheets
  class Create
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      user_adapter(@token_user) do |u|
        cnts = "Hey #{@token_user.name}. Erzähl mir was du heute gemacht hast. "
        sheet = u.create_sheet(cnts)
        u.store(sheet)
        @return = sheet.to_hash
      end
      self.status = 200
      self.body = @return.merge(@return.to_hash).to_json
    end
  end
end

