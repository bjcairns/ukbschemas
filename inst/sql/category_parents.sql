/* Join the parent_id's from table catbrowse, which are unique by child_id,
into table categories. */

ALTER TABLE categories
ADD "parent_id" INTEGER;

INSERT INTO categories (
  category_id, 
  title, 
  availability, 
  group_type, 
  descript, 
  notes, 
  parent_id)
VALUES (
  119,
  "Reaction time test",
  0,
  1,
  "This category contains data on a test to assess reaction time and is based on 12 rounds of the card-game 'Snap'. The participant is shown two cards at a time; if both cards are the same, they press a button-box that is on the table in front of them as quickly as possible. For each of the 12 rounds, the following data were collected: the pictures shown on the cards (Index of card A, Index of card B), the number of times the participant clicked the 'snap' button, and the time it took to first click the 'snap' button. <p> This was a follow-up to touchscreen Category 100032.",
  NULL,
  NULL);

UPDATE categories
SET parent_id = (
  SELECT parent_id
  FROM catbrowse
  WHERE child_id = categories.category_id
);
  
/* Check it worked */
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

/* Drop catbrowse */
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
