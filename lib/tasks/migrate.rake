# ---------------------------------------- | Migrating

task :migrate_series do
  Migrator.migrate('/series' => 'Series')
end

task :migrate_music do
  Migrator.migrate('/music' => 'Song')
end

task :migrate_videos do
  Migrator.migrate('/videos' => 'Video')
end

# ---------------------------------------- | Processing

task :process_assets do
  Importer.process_assets
end

# ---------------------------------------- | Publishing

task :publish_assets do
  Importer.publish_assets
end

task :publish_videos do
  Importer.publish_entries('video')
end

task :publish_series do
  Importer.publish_entries('message')
  Importer.publish_entries('series')
end

task :publish_music do
  Importer.publish_entries('song')
end

# ---------------------------------------- | Unpublishing

task :unpublish_content do
  Importer.unpublish_content
end

task :deactivate_content_types do
  Importer.deactivate_content_types
end

# ---------------------------------------- | Deleting

task :delete_drafts do
  Importer.delete_drafts
end

task :delete_content_types do
  Importer.delete_content_types
end

# ---------------------------------------- | Migrations

task :create_migration_records do
  Importer.create_migration_records
  Importer.publish_entries('migrations')
end

# ---------------------------------------- | Redirects

task :purge_redirects do
  Redirector.purge!
end

# ---------------------------------------- | Miscellaneous

task :undo_pages_migration do
  env = Importer.send(:env)
  ct = env.content_types.find('migrations')
  ct.entries.all.each do |entry|
    next unless entry.fields[:version] == 20180614135537
    entry.unpublish
    entry.destroy
  end
  pages_ct = env.content_types.find('page')
  pages_ct.deactivate
  pages_ct.destroy
end
