def load_file_data(file_name)
  file = File.join(Rails.root, "spec", "files", file_name)
  File.read(file)
end
