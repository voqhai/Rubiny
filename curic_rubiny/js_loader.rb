module CURIC::Rubiny
  module JSLoader
    class << self
      attr_accessor :dialog
    end

    module_function

    def toggle
      if @dialog && @dialog.visible?
        @dialog.close
      else
        show
      end
    end

    def show
      @dialog = UI::HtmlDialog.new(dialog_options)
      if PLUGIN.debug?
        html_file = File.join(File.dirname(PATH), 'docs', 'index.html')
        @dialog.set_file(html_file)
        p "Load HTML: #{html_file}"
      else
        @dialog.set_url("https://voqhai.github.io/Rubiny/")
      end

      @dialog.add_action_callback('ready') { ready }
      @dialog.add_action_callback('call') do |*args|
        send(args[1].to_sym, *args[2..])
      end
      @dialog.show
    end

    def dialog_options
      {
        dialog_title: 'Rubiny',
        preferences_key: 'com.sketchup.plugins.rubiny',
        resizable: true,
        width: 800,
        height: 600,
        left: 100,
        top: 100,
        min_width: 50,
        min_height: 50,
        max_width:10000,
        max_height: 10000,
        style: UI::HtmlDialog::STYLE_DIALOG
      }
    end

    def ready
      puts 'Rubiny is ready'

      if PLUGIN.debug?
        ruby_url = File.join(File.dirname(PATH), 'docs', 'all_ruby_files.zip')
      else
        ruby_url = 'https://voqhai.github.io/Rubiny/all_ruby_files.zip'
      end

      ruby_url = 'https://voqhai.github.io/Rubiny/all_ruby_files.zip'
      @dialog.execute_script("loadAndProcessZip('#{ruby_url}')")
    end

    def set_database(snippets)
      p 'Set snippets'
      PLUGIN.snippets.database = snippets.each_with_object({}) do |snippet, h|
        h[snippet['id']] = snippet
      end
    end

    def loadrb(file, content)
      puts "Load Ruby file: #{file}"
      id = File.basename(file, '.rb')
      info = PLUGIN.snippets.get_info(id)
      return unless info

      info['ruby_content'] = content
      eval(content)
    rescue => e
      puts e
      puts content
    end

    def run(id)
      snippet = PLUGIN.snippets.find_by_id(id)
      if snippet
        snippet.run
      else
        UI.messagebox("Snippet not found: #{id}")
      end
    end

    def save_to_temp(file, content)
      path = File.join(CURIC::Rubiny::TEMP, file)
      File.open(path, 'w') { |f| f.write(content) }
    end
  end
end
