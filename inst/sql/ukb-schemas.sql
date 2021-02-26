/*
   Note several "*_id" fields are renamed from similarly-named fields in the
   original tables. See R/tidy-schemas.R for details.
*/
CREATE TABLE fields(
  "field_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "availability" INTEGER,
  "stability_id" INTEGER,
  "private" INTEGER,
  "value_type_id" INTEGER,
  "base_type" INTEGER,
  "item_type_id" INTEGER,
  "strata_id" INTEGER,
  "instanced" INTEGER,
  "arrayed" INTEGER,
  "sexed_id" INTEGER,
  "units" TEXT,
  "category_id" INTEGER,
  "encoding_id" INTEGER,
  "instance_id" INTEGER,
  "instance_min" INTEGER,
  "instance_max" INTEGER,
  "array_min" INTEGER,
  "array_max" INTEGER,
  "notes" TEXT,
  "debut" DATE,
  "version" DATE,
  "num_participants" INTEGER,
  "item_count" INTEGER,
  "showcase_order" INTEGER
);
CREATE TABLE encodings(
  "encoding_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "availability" INTEGER,
  "value_type_id" INTEGER,
  "structure" INTEGER,
  "num_members" INTEGER,
  "descript" TEXT
);
CREATE TABLE categories(
  "category_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "availability" INTEGER,
  "group_type" INTEGER,
  "descript" TEXT,
  "notes" TEXT,
  "parent_id" INTEGER,
  "showcase_order" INTEGER
);
CREATE TABLE returns(
  "archive_id" INTEGER PRIMARY KEY,
  "application_id" INTEGER,
  "title" TEXT,
  "availability" INTEGER,
  "personal" INTEGER,
  "notes" TEXT
);
CREATE TABLE instances(
  "instance_id" INTEGER PRIMARY KEY,
  "descript" TEXT,
  "num_members" INTEGER
);
CREATE TABLE insvalues(
  "instance_id" INTEGER,
  "index" INTEGER,
  "title" TEXT,
  "descript" TEXT,
  PRIMARY KEY ("instance_id", "index")
);
CREATE TABLE recommended(
  "category_id" INTEGER,
  "field_id" INTEGER
);
CREATE TABLE snps(
  "affy_id" INTEGER PRIMARY KEY,
  "rs_id" INTEGER,
  "chr_id" INTEGER,
  "pos_int" INTEGER,
  "pos_end_int" INTEGER,
  "nitems" INTEGER,
  "num_aa0" INTEGER,
  "num_ab1" INTEGER,
  "num_bb2" INTEGER,
  "num_xx3" INTEGER,
  "loctype_int" INTEGER,
  "strand" TEXT,
  "strand_vs_snp" TEXT,
  "ref" TEXT,
  "allele_a" TEXT,
  "allele_b" TEXT
);
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
CREATE TABLE schema(
  "schema_id" INTEGER PRIMARY KEY,
  "name" TEXT,
  "descript" TEXT,
  "notes" TEXT
);
CREATE TABLE recordtab(
  "table_name" TEXT PRIMARY KEY,
  "field_id" INTEGER,
  "parent_name" TEXT,
  "title" TEXT,
  "available" INTEGER,
  "private" INTEGER
);
CREATE TABLE recordcol(
  "column_name" TEXT,
  "table_name" TEXT,
  "value_type_id" INTEGER,
  "encoding_id" INTEGER,
  "orda" INTEGER,
  "units" TEXT,
  "notes" TEXT,
  PRIMARY KEY ("column_name", "table_name")
);
CREATE TABLE valuetypes(
  "value_type_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);
CREATE TABLE stability(
  "stability_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);
CREATE TABLE itemtypes(
  "item_type_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);
CREATE TABLE strata(
  "strata_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);
CREATE TABLE sexed(
  "sexed_id" INTEGER PRIMARY KEY,
  "title" TEXT,
  "description" TEXT
);
