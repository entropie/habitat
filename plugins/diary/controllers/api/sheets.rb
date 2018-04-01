module Api::Controllers::Sheets
  class Sheets

    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      sheets = A(@token_user) do |a|
        @return[:sheets] = a.sheets.map(&:to_hash)
      end
      self.status = 200
      self.body = @return.to_json
    end
  end
end
