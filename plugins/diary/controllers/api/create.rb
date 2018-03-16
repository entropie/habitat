# coding: utf-8

module Api::Controllers::Sheets
  class Create
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      user_adapter(@token_user) do |u|
        cnts = "Hey #{@token_user.name}." # Erzähl mir was du heute gemacht hast. "

        adds = begin
                 ::File.readlines(Habitat.quart.media_path("default_sheet.html")).join
               rescue
                 ""
        end
        
        sheet = u.create_sheet(cnts + "<br/>"*3 + adds)
        u.store(sheet)
        @return = sheet.to_hash
      end
      self.status = 200
      self.body = @return.merge(@return.to_hash).to_json
    end
  end
end

