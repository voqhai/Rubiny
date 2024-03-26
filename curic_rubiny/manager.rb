module CURIC::Rubiny
  module Manager
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
      if CURIC::Rubiny.debug?
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
        min_width: 400,
        min_height: 400,
        max_width:10000,
        max_height: 10000,
        style: UI::HtmlDialog::STYLE_DIALOG
      }
    end

    def ready
      puts 'Rubiny is ready'

      if CURIC::Rubiny.debug?
        ruby_url = File.join(File.dirname(PATH), 'docs', 'all_ruby_files.zip')
      else
        ruby_url = "#{CURIC::Rubiny::HOST}/all_ruby_files.zip"
      end

      ruby_url = "#{CURIC::Rubiny::HOST}/all_ruby_files.zip"
      @dialog.execute_script("loadAndProcessZip('#{ruby_url}')")
    end

    def loaded_database(snippets)
      # All snippets on server is loaded
      CURIC::Rubiny::CheckForUpdate.save_last_snippets(snippets)
      sync_local_snippets
    end

    # Get snippets from local (installed)
    def sync_local_snippets
      puts 'Sync Local Snippets'

      PLUGIN.snippets.each(&:check_installed)

      installed = PLUGIN.snippets.find_all(&:installed?)
      @dialog.execute_script("app.installed = #{installed.map(&:info).to_json};")
    end

    def loadrb(file, content)
      puts "Load Ruby file: #{file}"
      id = File.basename(file, '.rb')
      info = CURIC::Rubiny.snippets.get_info(id)
      return unless info

      info['ruby_content'] = content
      eval(content)
    rescue => e
      puts e
      puts content
    end

    def install(snippet_data)
      snippet = get_snippet(snippet_data)
      if snippet
        status = CURIC::Rubiny.install(snippet)
        if status
          UI.messagebox("Snippet installed: #{snippet.name}")
        else
          UI.messagebox("Failed to install snippet: #{snippet.name}")
        end
        sync_local_snippets
      else
        UI.messagebox("Snippet not found")
      end
    end

    def uninstall(snippet_data)
      return unless UI.messagebox("Remove #{snippet_data['name']}\nAre you sure?", MB_YESNO) == IDYES

      snippet = get_snippet(snippet_data)
      status = CURIC::Rubiny.uninstall(snippet_data['id'])

      snippet.installed = status

      @dialog.execute_script("app.uninstalledSnippet('#{snippet.id}', #{status})")

      sync_local_snippets
    end

    def update(snippet_data)
      p "Update: #{snippet_data['id']}"
      snippet = get_snippet(snippet_data)
      if snippet
        status = CURIC::Rubiny.update(snippet, snippet_data)
        sync_local_snippets
        @dialog.execute_script("app.updatedSnippet('#{snippet.id}', #{status})")
      else
        UI.messagebox("Snippet not found")
      end
    end

    def play(snippet_data)
      snippet = get_snippet(snippet_data)
      if snippet
        snippet.play
      else
        UI.messagebox("Snippet not found!")
      end
    end

    def play_value(snippet_data)
      value = snippet_data['value']
      p "Play value: #{value}"

      snippet = get_snippet(snippet_data)
      if snippet
        snippet.play_value(value)
      else
        # Missing Ruby Snippet Object
        UI.messagebox("Snippet not found!")
      end
    end

    # Get value of snippet to set on UI
    def get_value(snippet_data)
      p "Get Value: #{snippet_data['id']}"
      snippet = get_snippet(snippet_data)
      return unless snippet
      value = snippet.get_value
      @dialog.execute_script("app.setSnippetValue('#{snippet.id}', '#{value}')")
    end

    def loaded(snippet)
      @dialog.execute_script("app.loadedSnippet('#{snippet.id}')")
    end

    def get_snippet(snippet_data)
      CURIC::Rubiny.snippets[snippet_data['id']] || CURIC::Rubiny.snippets.create(snippet_data)
    end
  end
end
