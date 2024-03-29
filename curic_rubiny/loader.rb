module CURIC
  module Rubiny
    class << self
      attr_accessor :snippets, :source_files, :debug, :local_snippets
      attr_accessor :commnads
      attr_reader :extension_menu
    end

    @source_files ||= []

    LOCAL_DIR = File.join(PATH, 'local').freeze
    PATH_R = File.join(PATH, 'Resources').freeze
    ICON_EX = Sketchup.platform == :platform_osx ? 'pdf' : 'svg'
    ICON = File.join(PATH_R, "icon.png")

    HOST = 'https://voqhai.github.io/Rubiny/'
    GIT_REPO = 'https://github.com/voqhai/Rubiny'

    require 'uri'
    require 'json'
    Sketchup.require "#{PATH}/snippet"
    Sketchup.require "#{PATH}/manager"
    Sketchup.require "#{PATH}/snippets"
    Sketchup.require "#{PATH}/update"

    def self.read_json(file)
      JSON.parse(File.read(file))
    end

    @debug = false
    def self.debug?
      @debug
    end

    def self.register_snippet(snippet)
      unless @snippets[snippet.id]
        status = @snippets.add(snippet)
        return unless status
      end

      snippet.installed = true

      @snippets_menu.add_item(snippet.command)
      @commnads[snippet.id] = snippet
    end

    def self.install(snippet)
      save_to_local(snippet)

      installed = true
    rescue => e
      puts e
      installed = false
    ensure
      register_snippet(snippet) if installed

      installed
    end

    def self.uninstall(id)
      # p "uninstall #{id}"
      @snippets.remove(id)
      dir = File.join(CURIC::Rubiny::LOCAL_DIR, 'snippets', id)
      return false unless File.directory?(dir)

      FileUtils.rm_rf(dir)

      true
    rescue => e
      puts e
      false
    end

    def self.update(snippet, new_info)
      # p "Update #{id}"
      snippet.info = new_info
      save_to_local(snippet)

      updated = true
    rescue => e
      puts e
      updated = false
    ensure
      updated
    end

    def self.build
      Manager.toggle
    end

    def self.save_to_temp(file, content)
      File.open(file, 'w') { |f| f.write(content) }
    end

    def self.save_to_local(snippet)
      info = snippet.info
      ruby_file = info['ruby_file']
      file = File.join(CURIC::Rubiny::LOCAL_DIR, ruby_file)

      dir = File.dirname(file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      save_to_temp(file, info['ruby_content'])

      json_file = File.join(dir, "#{snippet.id}.json")
      data = info.dup

      data.delete('installed')
      data.delete('evaluated')
      data.delete('loaded')
      data.delete('ruby_content')

      save_to_temp(json_file, JSON.pretty_generate(data))
    end

    def self.load_local_snippets
      dir = File.join(CURIC::Rubiny::LOCAL_DIR, 'snippets')

      # Duyệt qua tất cả các folder trong thư mục snippets
      # Mỗi folder là một snippet chứa các file ruby và json cùng 1 folder assets (images, ...)
      Dir.glob(File.join(dir, '*')).each do |folder|
        next unless File.directory?(folder)

        id = File.basename(folder)
        ruby_file = Dir.glob(File.join(folder, '*.rb')).first
        next unless ruby_file

        json_file = Dir.glob(File.join(folder, '*.json')).first
        next unless json_file

        # Đọc file json
        info = JSON.parse(File.read(json_file))
        default_info = {
          'id' => id,
          'name' => id,
          'description' => "Description for #{id}",
          'installed' => true
        }

        info = default_info.merge(info)

        begin
          Sketchup.require(ruby_file)
        rescue LoadError => e
          puts e
          next
        end

        const = Snippet.const(id)
        next unless const

        snippet = const.new(info)
        snippet.installed = true

        register_snippet(snippet)
      end
    end

    def self.reload!
      @snippets = Snippets.new
      build
      load_local_snippets
    end

    def self.check_for_update
      CheckForUpdate.check do |new_snippets|
        next unless new_snippets && new_snippets.size > 0

        names = new_snippets.map { |info| info['name'] }.join("\n")
        mes = "#{PLUGIN_NAME}::New snippets available!\n#{names}"

        notify = UI::Notification.new(PLUGIN_EX, mes)
        notify.icon_name = ICON
        notify.on_accept('Show') do
          Manager.show
        end

        notify.on_dismiss('Close') do
          # Do nothing
        end

        notify.show
      end
    end

    unless file_loaded?(__FILE__)
      @extension_menu = UI.menu('Extensions').add_submenu(PLUGIN_ID)
      @snippets_menu = @extension_menu.add_submenu('Snippets')

      @commnads = {}

      reload!

      UI.add_context_menu_handler do |context_menu|
        @snippets.build_context_menu(context_menu)
      end

      cmd = UI::Command.new(PLUGIN_ID) { build }
      cmd.menu_text = 'Build Snippets'
      cmd.status_bar_text = 'Build Snippets'
      cmd.small_icon = File.join(PATH_R, "icon.#{ICON_EX}")
      cmd.large_icon = File.join(PATH_R, "icon.#{ICON_EX}")

      toolbar = UI::Toolbar.new(PLUGIN_ID)
      toolbar.add_item(cmd)

      @extension_menu.add_item(cmd)


      UI.start_timer(10, false) do
        check_for_update
      end

      UI.start_timer(0.1, false) { toolbar.restore }

      file_loaded(__FILE__)
    end
  end
end
