-- Source this into sqlite3 command line using:
-- % sqlite3 <path to database file, probably: faces.db>
-- sqlite> .read schema.sql
-- sqlite> .exit
--
-- Yeah I know all the table names are messed up, but this is what I've been working with to date
--
CREATE TABLE IF NOT EXISTS faces (path not null, left not null, top not null, right not null, bottom not null, hash not null, human);
CREATE INDEX IF NOT EXISTS idx_face_path on faces (path);
CREATE INDEX IF NOT EXISTS idx_face_rect on faces (left, top, right, bottom);
CREATE TABLE IF NOT EXISTS groups (id not null, path not null, left not null, top not null, right not null, bottom not null, pickled);
CREATE INDEX IF NOT EXISTS idx_groups_id on groups (id);
CREATE INDEX IF NOT EXISTS idx_groups_rect on groups (left, top, right, bottom);
CREATE INDEX IF NOT EXISTS idx_groups_path on groups (path);
CREATE TABLE IF NOT EXISTS weights (pickled);
CREATE TABLE IF NOT EXISTS tag_groups(grow INT,human);
CREATE INDEX IF NOT EXISTS idx_tag_groups_human on tag_groups (human);
--
-- v2 after actually stopping to think
--
PRAGMA foreign_keys = ON;
-- where we go looking for image files..
CREATE TABLE IF NOT EXISTS source_paths (path not null);
--
-- store file hashes (unique) and map multiple paths to them
CREATE TABLE IF NOT EXISTS file_hashes (hash primary key);
CREATE INDEX IF NOT EXISTS idx_file_hashes_hash on file_hashes (hash);
CREATE TABLE IF NOT EXISTS file_paths (path not null, size not null, hash references file_hashes(hash) on update restrict on delete restrict not null);
CREATE INDEX IF NOT EXISTS idx_file_paths_path on file_paths (path);
--
-- processing state, a list of candidate image files to check and include/ignore
CREATE TABLE IF NOT EXISTS file_candidates (path not null, hash references file_hashes(hash) on update restrict on delete restrict not null);
--
-- store labels for faces, map multiple groups to them (and store average face for the group)
CREATE TABLE IF NOT EXISTS face_labels (label primary key);
CREATE INDEX IF NOT EXISTS idx_face_labels_label on face_labels (label);
CREATE TABLE IF NOT EXISTS face_groups (grp primary key, pickled, label references face_labels(label) on update cascade on delete restrict not null);
CREATE INDEX IF NOT EXISTS idx_face_groups_grp on face_groups (grp);
--
-- store face vector weighting
CREATE TABLE IF NOT EXISTS face_weights(pickled);
--
-- store face data, map to a file hash and face group
CREATE TABLE IF NOT EXISTS face_data (
        left not null, top not null, right not null, bottom not null, pickled not null,
        hash references file_hashes(hash) on update restrict on delete restrict not null,
        grp references face_groups(grp) on update restrict on delete restrict not null
);
CREATE INDEX IF NOT EXISTS idx_face_data_rect on face_data (left, top, right, bottom);
