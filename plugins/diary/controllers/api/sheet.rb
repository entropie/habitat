module Api::Controllers::Sheet
  class Index
    include Api::Action

    def call(params)
      # sheet = user_adapter do |u|
      #   sheet = u.create_sheet("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore")
      #   a =     u.store(sheet)
      # end

      sheet = user_adapter do |a|
        a.sheets[ params[:id] ]
      end
      self.status = 200
      self.body = sheet.to_hash.to_json
    end
  end
end
