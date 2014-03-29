list = []

Dir.glob("./airplane_flyer/airplanes/*.jpg") do |file|
  list << file
end

File.open('./filelist.txt', 'w') do |f|
  list.each do |line|
    f.write "#{line.split("/").last}\n"
  end
end