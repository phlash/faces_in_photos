-- Source this into sqlite3 command line using:
-- % sqlite3 <path to database file, probably: faces.db>
-- sqlite> .read schema.sql
-- sqlite> .exit
PRAGMA foreign_keys = ON;
--
-- Picasa labelled face data
CREATE TABLE IF NOT EXISTS face_picasa(path,left,top,right,bottom,hash,label);
CREATE INDEX IF NOT EXISTS idx_face_picasa_path on face_picasa (path);
CREATE INDEX IF NOT EXISTS idx_face_picasa_ltrb on face_picasa (left, top, right, bottom);
--
-- scanner task configuration (highest priority, see also cmd line, /etc/defaults/face_scanner)
CREATE TABLE IF NOT EXISTS face_scanner_config(key not null, value);
--
-- where we go looking for image files..
CREATE TABLE IF NOT EXISTS source_paths (path not null);
--
-- store file hashes (unique) and map multiple paths to them
CREATE TABLE IF NOT EXISTS file_hashes (hash primary key);
CREATE INDEX IF NOT EXISTS idx_file_hashes_hash on file_hashes (hash);
CREATE TABLE IF NOT EXISTS file_paths (path not null, size not null, hash references file_hashes(hash) on update restrict on delete restrict not null);
CREATE INDEX IF NOT EXISTS idx_file_paths_path on file_paths (path);
CREATE INDEX IF NOT EXISTS idx_file_paths_hash on file_paths (hash);
--
-- processing state, a list of candidate image files to check and include/ignore
CREATE TABLE IF NOT EXISTS file_candidates (path not null, hash references file_hashes(hash) on update restrict on delete restrict not null);
--
-- store labels for faces, map multiple groups to them (and store average face for the group)
CREATE TABLE IF NOT EXISTS face_labels (label primary key);
CREATE INDEX IF NOT EXISTS idx_face_labels_label on face_labels (label);
CREATE TABLE IF NOT EXISTS face_groups (grp primary key, pickled, label references face_labels(label) on update cascade on delete restrict not null);
CREATE INDEX IF NOT EXISTS idx_face_groups_grp on face_groups (grp);
CREATE INDEX IF NOT EXISTS idx_face_groups_label on face_groups (label);
--
-- store face vector weighting
CREATE TABLE IF NOT EXISTS face_weights(pickled);
--
-- store face data, map to a file hash and face group
CREATE TABLE IF NOT EXISTS face_data (
        left not null, top not null, right not null, bottom not null, pickled not null,
        hash references file_hashes(hash) on update restrict on delete restrict not null,
        grp references face_groups(grp) on update restrict on delete restrict not null,
        inpic
);
CREATE INDEX IF NOT EXISTS idx_face_data_rect on face_data (left, top, right, bottom);
CREATE INDEX IF NOT EXISTS idx_face_data_hash on face_data (hash);
CREATE INDEX IF NOT EXISTS idx_face_data_grp on face_data (grp);
