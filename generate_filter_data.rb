
timestamp = Time.now.strftime("%Y-%m-%d %H:%M")
commit = `git branch -v --no-color`.split[1..2].join(" ")

File.open("version_data.properties", "w") do |f|
  f.puts("DATE=#{timestamp}")
  f.puts("COMMIT=#{commit}")
end

