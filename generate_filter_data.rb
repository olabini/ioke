
timestamp = Time.now.strftime("%Y-%m-%d %H:%M")

commit = nil
begin
  commit_lines = `git branch -v --no-color`.to_a
  commit = commit_lines.grep(/^\* /).first.split[2]
rescue Exception
  commit = `hg heads`.to_a[0].split[1]
end

File.open("version_data.properties", "w") do |f|
  f.puts("DATE=#{timestamp}")
  f.puts("COMMIT=#{commit}")
end

