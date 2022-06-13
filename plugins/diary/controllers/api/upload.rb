module Api::Controllers::Sheets
  class Upload
    include Backend::Action
    include Diary::ApiControllerMethods 

    def call(params)
      # filename = A(@token_user) do |a|
      #   sheet = a.sheets[ params[:id] ]
      #   base_file = a.upload(sheet, params[:files].first)
      #   sheet.http_dir(base_file)
      # end

      # @return = { "files" => [{:url => filename }] }
      self.status = 200
      self.body = @return.to_json
    end

  end
end
