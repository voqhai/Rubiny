module CURIC::Rubiny
  module CheckForUpdate
    URL = PLUGIN::HOST + '/all_snippets.json'
    LOCAL_DATA = File.join(PLUGIN::LOCAL_DIR, 'all_snippets.json')

    module_function

    def check(&block)
      Sketchup::Http::Request.new(URL).start do |request, respond|
        if request.status == Sketchup::Http::STATUS_SUCCESS
          data = JSON.parse(respond.body)
          next unless data && data.is_a?(Hash)
          snippets = data['snippets']
          next unless snippets && snippets.size > 0

          new_snippets = check_snippets(snippets)
          block.call(new_snippets)
        else
          puts "Failed to check for update: #{request.status}"
        end
      end
    end

    def check_snippets(snippets)
      last = read_last_snippets || []
      new_snippets = snippets.find_all do |snippet|
        !last.include?(snippet['id'])
      end

      new_snippets
    end

    def read_last_snippets
      file = LOCAL_DATA
      return unless File.exist?(file)

      JSON.parse(File.read(file))
    rescue => e
      puts e
      nil
    end

    def save_last_snippets(snippets)
      data = snippets.map { |info| info['id'] }

      file = LOCAL_DATA
      dir = File.dirname(file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(file, 'w') { |f| f.write(JSON.pretty_generate(data)) }
    end
  end
end
