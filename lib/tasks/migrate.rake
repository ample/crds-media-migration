task :migrate do
  Migrator.migrate(:series)
end

task :delete_drafts do
  Importer.delete_drafts
end
