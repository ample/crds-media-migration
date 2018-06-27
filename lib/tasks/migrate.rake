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
