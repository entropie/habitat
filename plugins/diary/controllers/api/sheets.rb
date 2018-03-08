module Api::Controllers::Sheets
  class Index

    include Api::Action
    include Diary

    def call(params)
      sheets = user_adapter do |a|
        a.sheets
      end
      self.status = 200
      self.body = { sheets: sheets.map{|s| s.to_hash } }.to_json
    end
  end
end
