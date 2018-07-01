# faces_in_photos
some scripts to find and tag faces in photograph image files, 'cause Picasa is dead..

## Blogged
https://ashbysoft.com/wiki/Face%20Recognition

## Proper design time

As per my blog, it's time to think a little on information flow, integration points and process life cycles:
* UX: labelled faces are available to use in any image manager app as additional image info.
* UX: unlabelled faces are grouped and presented for labelling, possibly via extension to gThumb or standalone app.
* UX: face detection and labelling takes place as soon as images are available (not just while viewer is active: a Picasa peeve).
* UX: new unlabelled faces are notified via selectable channels (cron output?) so the humans can help.
* UX: moving images around, re-naming folders etc. does not trigger re-labelling.
* UX: labels do not change while viewing faces (this annoys me a lot in Picasa!), but can be refreshed.

These UX stories lead design towards the following principles:
* Invariant image identification: hashes, not pathnames. This also has a beneficial side effect of duplicate detection.
* Face labels stored with images: providing shared access (yet another Picasa peeve), with mappers or plugins to viewer apps.
* Scheduled task to process images: (using find -ctime and last run marker?), hash, detect, label & notify unknowns.
* Scheduled task to handle removal: 2-pass search using mark/release strategy, part of image processing task maybe?
* Viewer adapters (mappers/plugins): can draw labelled boxes on image(s) in view, uphold no changes while viewing policy.

Early decisions:
* Metadata in images or separate files?
  * Not all formats support metadata.
  * Editing source files is bad (invariance broken).
  * How to manage file movements if separate (via new images/removal processes, greatly assisted by hash identification, not paths)?
  * Metadata in SQLite, which points to a series of storage paths that form the corpus of images. Published schema :)
  * file hash <= file path mapping. Updated/created/removed by scheduled scanner. Index both columns for lookup.
  * file hash <= face data (rectangles, pickled vector of face descriptor values) mapping.
  * face data => face group mapping.
  * face group => face label mapping (supports multiple averages).
* Scanner outputs:
  * New/Removed file paths & hashes, duplicates indicated.
  * New/Removed faces (by label/group/path).
  * New Unknown faces (by group/path).

