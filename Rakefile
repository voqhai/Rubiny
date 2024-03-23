task default: [:release]

desc 'Build Sketchup extension'
task :release do
  # Giả sử bạn đang ở trong thư mục gốc của repository Rubiny
  # Đường dẫn tới thư mục ruby cần được chỉnh lại cho đúng
  cmd = %w[git archive
           --format zip
           --output dist/rubiny.zip
           HEAD:curic_rubiny/ruby] # Chỉnh lại đường dẫn này nếu cần
  sh(*cmd)
end


# Upload source code to github
desc 'Upload source code to github'
task :up do
  sh 'git add .'
  sh "git commit -m 'Upload source code to GitHub'"
  sh 'git push origin main'
end
