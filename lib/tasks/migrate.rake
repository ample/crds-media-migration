task :migrate do
  Migrator.migrate(
    '/series' => 'Series',
    '/videos' => 'Video',
    '/music' => 'Song'
  )
end

task :delete_drafts do
  Importer.delete_drafts
end
