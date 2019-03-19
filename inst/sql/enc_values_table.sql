/* The following table adds a single encodings values table to the database.
   The advantage of this is that every encoding code can now be accessed from 
   a single table; no conditional evalution required.
*/
CREATE TABLE encvalues(
  "encoding_id" INTEGER,
  "code_id" INTEGER,
  "parent_id" INTEGER,
  "type" TEXT,
  "value" TEXT,
  "meaning" TEXT,
  "selectable" INTEGER,
  "showcase_order" INTEGER,
  PRIMARY KEY ("encoding_id", "code_id")
);

/* Add the encoding values from each of the type-specific tables

Note that this code generates the code_id as needed from the count of how 
many records in esimpint have a rowid less than or equal to the current 
record and have the same encoding_id as the current record.

In sqlite3 3.25+ it should (also) be possible to do this with windowing, i.e.:

  row_number() OVER (PARTITION BY encoding_id ORDER BY rowid) AS code_id

*/

/* esimpint */
INSERT INTO encvalues SELECT
  e.encoding_id,
  (SELECT count(*) 
    FROM esimpint AS f
    WHERE f.rowid<=e.rowid AND f.encoding_id=e.encoding_id
  ) AS code_id,
  NULL AS parent_id,
  e.value,
  e.meaning
FROM esimpint as e;

/* esimpstring */
INSERT INTO encvalues SELECT
  e.encoding_id,
  (SELECT count(*) 
    FROM esimpstring AS f
    WHERE f.rowid<=e.rowid AND f.encoding_id=e.encoding_id
  ) AS code_id,
  NULL AS parent_id,
  e.value,
  e.meaning
FROM esimpstring as e;

/* esimpreal */
INSERT INTO encvalues SELECT
  e.encoding_id,
  (SELECT count(*) 
    FROM esimpreal AS f
    WHERE f.rowid<=e.rowid AND f.encoding_id=e.encoding_id
  ) AS code_id,
  NULL AS parent_id,
  e.value,
  e.meaning
FROM esimpreal as e;

/* esimpdate */
INSERT INTO encvalues SELECT
  e.encoding_id,
  (SELECT count(*) 
    FROM esimpdate AS f
    WHERE f.rowid<=e.rowid AND f.encoding_id=e.encoding_id
  ) AS code_id,
  NULL AS parent_id,
  e.value,
  e.meaning
FROM esimpdate as e;

/* ehierint */
INSERT INTO encvalues SELECT
  encoding_id,
  code_id,
  parent_id,
  value,
  meaning
FROM ehierint;

/* ehierstring */
INSERT INTO encvalues SELECT
  encoding_id,
  code_id,
  parent_id,
  value,
  meaning
FROM ehierstring;

/* Confirm all went right */
.mode tabs
SELECT 'Checking "encvalues" seems successfully populated (expect 0):', SUM(counts) FROM (
  SELECT count(*) AS counts FROM esimpint
  UNION ALL
  SELECT count(*) AS counts FROM esimpstring
  UNION ALL
  SELECT count(*) AS counts from esimpreal
  UNION ALL
  SELECT count(*) AS counts from esimpdate
  UNION ALL
  SELECT count(*) AS counts from ehierint
  UNION ALL
  SELECT count(*) AS counts from ehierstring
  UNION ALL
  SELECT -count(*) AS counts FROM encvalues);
  
DROP TABLE esimpint;
DROP TABLE esimpstring;
DROP TABLE esimpreal;
DROP TABLE esimpdate;
DROP TABLE ehierint;
DROP TABLE ehierstring;

