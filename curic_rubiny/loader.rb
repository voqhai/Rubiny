module CURIC
  module Rubiny
    class << self
      attr_accessor :snippets, :source_files, :debug, :local_snippets
      attr_reader :extension_menu
    end

    @source_files ||= []

    LOCAL_DIR = File.join(PATH, 'local').freeze
    PATH_R = File.join(PATH, 'Resources').freeze
    ICON_EX = Sketchup.platform == :platform_osx ? 'pdf' : 'svg'

    Sketchup.require "#{PATH}/command"
    Sketchup.require "#{PATH}/js_loader"
    Sketchup.require "#{PATH}/snippets"

    def self.read_json(file)
      JSON.parse(File.read(file))
    end

    @debug = true
    def self.debug?
      @debug
    end

    def self.register_snippet(snippet)
      status = @snippets.add(snippet)
      return unless status

      @snippets_menu.add_item(snippet)
    end

    def self.install(snippet)
      p "Install #{snippet.id}"
      info = snippet.info
      ruby_file = info['ruby_file']
      file = File.join(CURIC::Rubiny::LOCAL_DIR, ruby_file)

      dir = File.dirname(file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      save_to_temp(file, info['ruby_content'])

      json_file = File.join(dir, "#{snippet.id}.json")
      data = info.dup
      data.delete('ruby_content')
      save_to_temp(json_file, JSON.pretty_generate(data))

      true
    rescue
      false
    end

    def self.uninstall(id)
      # p "uninstall #{id}"
    end

    def self.update(id)
      # p "Update #{id}"
    end

    def self.build
      # @snippets = Snippets.new
      JSLoader.toggle
    end

    def self.save_to_temp(file, content)
      File.open(file, 'w') { |f| f.write(content) }
    end

    def self.load_snippets
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
          'name' => "Name for #{id}",
          'description' => "Description for #{id}"
        }

        info = default_info.merge(info)

        begin
          Sketchup.require(ruby_file)
        rescue LoadError => e
          puts e
          next
        end

        class_name = id.split('_').map(&:capitalize).join
        const = CURIC::Rubiny.const_get(class_name)
        next unless const

        snippet = const.new(info)
        snippet.installed = true

        register_snippet(snippet)
      end
    end

    def self.reload!
      @snippets = Snippets.new
      build
      load_snippets
    end

    unless file_loaded?(__FILE__)
      @extension_menu = UI.menu('Extensions').add_submenu(PLUGIN_ID)
      @snippets_menu = @extension_menu.add_submenu('Snippets')

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

      UI.start_timer(0.1, false) { toolbar.restore }

      file_loaded(__FILE__)
    end
  end
end
