needs('GITHUB_REPO', 'HEROKU_REPO')

module GitPusher
  require 'git'
  extend self

  def deploy(github_url)
    raise "Incorrect URL Provided #{github_url}" unless github_url == ENV['GITHUB_REPO']
    repo = open_or_setup(github_url)
    repo.push(repo.remote('heroku'))
  end

  def open_or_setup(github_url)

    local_folder = "repos/#{Zlib.crc32(github_url)}"

    repo = begin
      Git.open(local_folder).tap do |g|
        g.fetch
        g.remote('origin').merge
      end
    rescue ArgumentError => e
      `rm -r #{local_folder}`
      Git.clone(github_url, local_folder)
    end
    repo.add_remote('heroku', ENV['HEROKU_REPO']) unless repo.remote('heroku').url
    repo
  end

  def local_state(github_url)
    repo = open_or_setup(github_url)
    repo.object('HEAD')
  end

end