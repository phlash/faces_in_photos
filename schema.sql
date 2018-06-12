-- Source this into sqlite3 command line using:
-- % sqlite3 <path to database file, prb: faces.db>
-- sqlite> .read schema.sql
-- sqlite> .exit
--
-- Yeah I know all the table names are messed up, but this is what I've been working with to date
--
CREATE TABLE faces (path not null, left not null, top not null, right not null, bottom not null, human);
CREATE INDEX idx_face_path on faces (path);
CREATE INDEX idx_face_rect on faces (left, top, right, bottom);
CREATE TABLE groups (id not null, path not null, left not null, top not null, right not null, bottom not null, pickled);
CREATE INDEX idx_groups_id on groups (id);
CREATE INDEX idx_groups_rect on groups (left, top, right, bottom);
CREATE INDEX idx_groups_path on groups (path);
CREATE TABLE weights (pickled);
CREATE TABLE tag_groups(grow INT,human);
CREATE INDEX idx_tag_groups_human on tag_groups (human);
