# coding: utf-8

module Api::Controllers::Sheets
  class Create
    include Api::Action
    include Diary::ApiControllerMethods 

    def call(params)
      arghash = {}
      [:title, :content].each do |target_key|
        arghash[target_key] = params[target_key] if params[target_key]
      end
      sheet = diary.create(arghash)

      self.status = 200
      self.body = retval.merge(sheet.to_hash).to_json
    end
  end
end

