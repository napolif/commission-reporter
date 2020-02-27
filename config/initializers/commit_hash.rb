Rails.configuration.x.commit_hash = `git rev-parse --short HEAD`.chomp
Rails.configuration.x.commit_date = `git log -1 --format=%ci`.chomp
