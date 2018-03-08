module Api::Controllers::Sheet
  class Create
    include Api::Action

    def call(params)
      sheet = user_adapter do |u|
        cnts = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore".split.sort_by{ rand }.join(" ")
        sheet = u.create_sheet(cnts)
        a =     u.store(sheet)
      end
      self.status = 200
      self.body = sheet.to_hash
    end
  end
end
