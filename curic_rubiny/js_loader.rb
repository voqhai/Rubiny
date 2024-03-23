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
      @dialog ||= UI::HtmlDialog.new(dialog_options)
      @dialog.set_url("https://voqhai.github.io/Rubiny/")
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
      ruby_url = 'https://voqhai.github.io/Rubiny/ruby/rubiny.zip'
      @dialog.execute_script("loadAndProcessZip('#{ruby_url}')")
    end

    def loadrb(file, content)
      puts "Load Ruby file: #{file}"
      puts content
      # Sketchup.require(file)
    end
  end
end
