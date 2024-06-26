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
        p "Load HTML: #{html_file}" if PLUGIN.debug?
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
        dialog_title: PLUGIN_ID,
        preferences_key: "com.sketchup.plugins.#{PLUGIN_ID}",
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
      puts 'Rubiny is ready' if PLUGIN.debug?
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
      puts 'Sync Local Snippets' if PLUGIN.debug?

      PLUGIN.snippets.each(&:check_installed)

      installed = PLUGIN.snippets.find_all(&:installed?)
      @dialog.execute_script("app.installed = #{installed.map(&:info).to_json};")
    end

    def loadrb(file, content)
      puts "Load Ruby file: #{file}" if PLUGIN.debug?
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
      p "Update: #{snippet_data['id']}" if PLUGIN.debug?
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
    rescue => e
      d = {
        id: snippet.id,
        message: e.message,
        backtrace:  e.backtrace.to_a
      }
      @dialog.execute_script("app.handleException(#{d.to_json})")
    end

    def play_value(snippet_data)
      value = snippet_data['value']
      p "Play value: #{value}" if PLUGIN.debug?

      snippet = get_snippet(snippet_data)
      if snippet
        snippet.play_value(value)
      else
        # Missing Ruby Snippet Object
        UI.messagebox("Snippet not found!")
      end
    rescue => e
      d = {
        id: snippet.id,
        message: e.message,
        backtrace:  e.backtrace.to_a
      }
      @dialog.execute_script("app.handleException(#{d.to_json})")
    end

    # Get value of snippet to set on UI
    def get_value(snippet_data)
      p "Get Value: #{snippet_data['id']}" if PLUGIN.debug?
      snippet = get_snippet(snippet_data)
      return unless snippet

      value = snippet.get_value
      p "Value: #{value}" if PLUGIN.debug?
      @dialog.execute_script("app.setSnippetValue('#{snippet.id}', #{value})")
    end

    def show_settings(snippet_data)
      snippet = get_snippet(snippet_data)
      if snippet
        snippet.show_settings
      else
        UI.messagebox("Snippet not found!")
      end
    end

    def hover(current, old)
      if current
        current_snippet = get_snippet(current)
        current_snippet.hover_changed(true) if current_snippet
      end

      if old
        old_snippet = get_snippet(old)
        old_snippet.hover_changed(false) if old_snippet
      end
    end

    def create_issue(error)
      title = "Error: ##{error['id']} - #{error['message']}"
      body = "```ruby\n#{error['backtrace'].join("\n")}\n```"

      encoded_title = URI.encode_www_form_component(title)
      encoded_body = URI.encode_www_form_component(body)

      url = "#{GIT_REPO}/issues/new?title=#{encoded_title}&body=#{encoded_body}"
      UI.openURL(url)
    end

    def loaded(snippet)
      @dialog.execute_script("app.loadedSnippet('#{snippet.id}')")
    end

    def get_snippet(snippet_data)
      CURIC::Rubiny.snippets[snippet_data['id']] || CURIC::Rubiny.snippets.create(snippet_data)
    end

    def show_help
      UI.openURL(GIT_REPO)
    end
  end
end
