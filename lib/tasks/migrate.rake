task :migrate do
  Migrator.migrate(
    '/series' => 'Series',
    '/videos' => 'Video',
    '/music' => 'Song'
  )
end

task :delete do
  Importer.delete_drafts
end

task :unpublish do
  Importer.unpublish_content
end
