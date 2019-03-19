/* Join the parent_id's from table catbrowse, which are unique by child_id,
into table categories. */

UPDATE categories
SET parent_id = (
  SELECT parent_id
  FROM catbrowse
  WHERE child_id = categories.category_id
);
  
/* Check it worked
.mode tabs
SELECT 'Checking "parent_id" seems correctly added to "categories" (expect 0):', SUM(counts) FROM (
  SELECT count(*) as counts
  FROM categories c JOIN catbrowse cb ON c.category_id = cb.child_id
  WHERE c.parent_id != cb.parent_id
  UNION ALL
  SELECT count(*) as counts
  FROM categories c JOIN catbrowse cb ON c.category_id = cb.child_id
  WHERE c.parent_id = cb.parent_id
  UNION ALL
  SELECT -count(*) as counts FROM catbrowse);

/* Drop catbrowse
DROP TABLE catbrowse;

/* The following would recreate catbrowse:

CREATE TABLE catbrowse(
  "parent_id" INTEGER, 
  "child_id" INTEGER PRIMARY KEY); 
INSERT INTO catbrowse SELECT DISTINCT 
    parent_id, category_id AS child_id 
  FROM categories 
  WHERE parent_id IS NOT NULL;

*/

