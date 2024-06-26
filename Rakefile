task default: [:release]

require 'json'
require 'rake/packagetask'

desc "Generate all_snippets.json"
task :generate_json do
  snippets_info = { "snippets" => [] }

  Dir.glob("docs/snippets/*").each do |snippet_folder|
    next unless File.directory?(snippet_folder)

    id = File.basename(snippet_folder)
    ruby_file = Dir.glob("#{snippet_folder}/*.rb").first
    json_file = Dir.glob("#{snippet_folder}/*.json").first
    image = Dir.glob("#{snippet_folder}/assets/*.png").first
    additional_files = Dir.glob("#{snippet_folder}/assets/*").reject do |file|
      file == ruby_file || file == image
    end

    # read json file
    info = JSON.parse(File.read(json_file))
    default_info = {
      "id" => id,
      "name" => "Name for #{id}",
      "description" => "Description for #{id}",
      "ruby_file" => ruby_file ? ruby_file.gsub(/^docs\//, '') : nil,
      "image" => image,
      "additional_files" => additional_files,
      "ceated_at" => File.ctime(json_file).to_s,
      "updated_at" => File.mtime(json_file).to_s
    }

    snippets_info["snippets"] << default_info.merge(info)
  end

  File.write("docs/all_snippets.json", JSON.pretty_generate(snippets_info))
end

require 'zip'
require 'fileutils'
desc "Package all Ruby files into a single zip"
task :zip_all_ruby do
  ruby_files = FileList['docs/snippets/**/*.rb']
  zip_name = "all_ruby_files.zip"
  FileUtils.rm("docs/#{zip_name}") if File.exist?("docs/#{zip_name}")

  Zip::File.open(zip_name, create: true) do |zipfile|
    ruby_files.each do |file|
      # Add file to zip, removing the leading path to match structure in all_snippets.json
      zipfile.add(file.sub(/^docs\//, ''), file)
    end
  end

  # Move the zip file to the docs directory, if needed
  # remove if exist
  FileUtils.mv(zip_name, "docs/#{zip_name}") unless File.exist?("docs/#{zip_name}")
end

# Upload source code to github
desc 'Upload source code to github'
task :build do
  # make all json files
  Rake::Task[:generate_json].invoke
  # make all ruby files
  Rake::Task[:zip_all_ruby].invoke

  # Upload to github
  sh 'git add .'
  sh "git commit -m 'Build snippets'"
  sh 'git push origin main'
end
require 'zip'
desc 'Build Sketchup extension'
task :release do
  version = `git describe --tags`.strip

  # Thiết lập tên file và đường dẫn của file nén cuối cùng
  rb_file = 'curic_rubiny.rb'
  plugin_name = 'curic_rubiny'
  rbz_filename = "releases/#{plugin_name}-#{version}.rbz"

  # Tạo thư mục releases nếu nó chưa tồn tại
  FileUtils.mkdir_p('releases') unless Dir.exist?('releases')

  # Xóa file rbz cũ nếu đã tồn tại
  FileUtils.rm_f(rbz_filename) if File.exist?(rbz_filename)

  # Tạo file nén mới
  Zip::File.open(rbz_filename, Zip::File::CREATE) do |zipfile|
    # Thêm file rb vào root của file nén
    zipfile.add(File.basename(rb_file), rb_file)

    # Duyệt qua tất cả file và thư mục con bên trong plugin_name
    Dir.glob("#{plugin_name}/**/{*,.*}").each do |file|
      next unless File.file?(file) # Bỏ qua nếu là thư mục
      next if file.include?("#{plugin_name}/local/") || file.include?("#{plugin_name}/docs/") # Bỏ qua các thư mục không mong muốn

      # Thêm file vào file nén, bảo toàn cấu trúc thư mục
      zipfile.add(file, file)
    end
  end

  puts "Archive created at #{rbz_filename}"
end
