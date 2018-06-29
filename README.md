Media Migration
==========

This is the process for migrating existing content in Media and that in
SilverStripe into a cleared out space in Contentful.

Migration Process
----------

1. Export crds-media-prod:

        $ contentful space export --space-id y3a9myzsdjan --management-token $CONTENTFUL_MANAGEMENT_ACCESS_TOKEN

2. Delete _everything_ (including content models) from space:

        $ cd path/to/crds-media-migration
        $ bundle exec rake unpublish_content
        $ bundle exec rake delete_drafts
        $ bundle exec rake deactivate_content_types
        $ bundle exec rake delete_content_types

3. Import data:

        $ contentful space import --space-id 7yxzjki8tjkc --content-file tmp/contentful-export-y3a9myzsdjan-master-2018-06-27T13-42-84.json --management-token $CONTENTFUL_MANAGEMENT_ACCESS_TOKEN

4. Delete Song and Video content models (manually).

5. Check contentful migrations, then create migration records:

        $ cd ../crds-contentful-migrations
        $ bundle exec rake contentful_migrations:pending
        $ cd path/to/crds-media-migration
        $ bundle exec rake create_migration_records

6. Run migrations: (The content types may have to be manually saved after running this command.)

        $ cd ../crds-contentful-migrations
        $ bundle exec rake contentful_migrations:migrate

    Then, make sure series can add Message and Video content types to its `video` field.

7. Delete pages:

        $ cd path/to/crds-media-migration
        $ bundle exec rake undo_pages_migration

    And then manually save the new content types.

8. Remove redirects file:

        $ bundle exec rake purge_redirects

9. Migrate videos:

        $ bundle exec rake migrate_videos
        $ bundle exec rake process_assets
        $ bundle exec rake publish_assets
        $ bundle exec rake publish_videos

10. Migrate music:

        $ bundle exec rake migrate_music
        $ bundle exec rake process_assets
        $ bundle exec rake publish_assets
        $ bundle exec rake publish_music

11. Migrate series:

        $ bundle exec rake migrate_series
        $ bundle exec rake process_assets
        $ bundle exec rake publish_assets
        $ bundle exec rake publish_series
