needs('HEROKU_USERNAME', 'HEROKU_API_KEY')

Heroku::Auth.instance_eval do
  # Autologin
  @credentials = [ENV['HEROKU_USERNAME'], ENV['HEROKU_API_KEY']]
  # Set up keys if there aren't any
  key_path = "#{home_directory}/.ssh/id_rsa.pub"
  if available_ssh_public_keys.empty?
    puts "Generating New Pair"

    ssh_dir = File.join(home_directory, ".ssh")
    unless File.exists?(ssh_dir)
      FileUtils.mkdir_p ssh_dir
      unless running_on_windows?
        File.chmod(0700, ssh_dir)
      end
    end

    File.open(key_path, 'w') {|f| f.write(ENV['PUBLIC_KEY']) }
    File.open(key_path[0..-5], 'w') {|f| f.write(ENV['PRIVATE_KEY']) }

    associate_key(key_path)
  end
  ::CURRENT_SSH_KEY = File.read(key_path)
end