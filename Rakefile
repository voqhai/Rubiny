task default: [:release]

desc 'Build Sketchup extension'
task :release do
  # Giả sử bạn đang ở trong thư mục gốc của repository Rubiny
  # Đường dẫn tới thư mục ruby cần được chỉnh lại cho đúng
  cmd = %w[git archive
           --format zip
           --output docs/ruby/rubiny.zip
           HEAD:snippets] # Chỉnh lại đường dẫn này nếu cần
  sh(*cmd)
end

# Upload source code to github
desc 'Upload source code to github'
task :up do
  sh 'git add .'
  sh "git commit -m 'Upload source code to GitHub'"
  sh 'git push origin main'
end

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
      "additional_files" => additional_files
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
