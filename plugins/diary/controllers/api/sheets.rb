module Api::Controllers::Sheets
  class Sheets

    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      sheets = diary.with_user(session_user) {|d| d.sheets }

      sheets.each do |sheet|
        retval[sheet.title] = sheet.to_hash
      end

      self.status = 200
      self.body = retval.to_json
    end
  end
end
