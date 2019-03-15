/* The following table adds value types to the data dictionary */
CREATE TABLE valuetypes(
  "value_type_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);

/* Add the value types from 
     http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type
*/
INSERT INTO valuetypes (value_type_id, title, description)
VALUES
  (11, "Integer", "whole numbers, for example the age of a participant on a particular date"),
  (21, "Categorical (single)", "a single answer selected from a coded list or tree of mutually exclusive options, for example a yes/no choice"),
  (22, "Categorical (multiple)", "sets of answers selected from a coded list or tree of options, for instance concurrent medications"),
  (31, "Continuous", "floating-point numbers, for example the height of a participant"),
  (41, "Text", "data composed of alphanumeric characters, for example the first line of an address"),
  (51, "Date", "a calendar date, for example 14th October 2010"),
  (61, "Time", "a time, for example 13:38:05 on 14th October 2010"),
  (101, "Compound", "a set of values required as a whole to describe some compound property, for example an ECG trace"),
  (0, NULL, NULL);
