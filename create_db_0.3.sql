--Creation of the KEK Database
-- v0.3

---geometry column added in standard_aufbereitet

/* *************************
Author: Tobias Weinzierl
Date: 24.04.2018

************************ */

CREATE Schema IF NOT EXISTS energiekarten;

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS energiekarten.baualtersklassen (
	id serial PRIMARY KEY,
	name text
);

CREATE TABLE energiekarten.geb_typologien(
	id SERIAL PRIMARY KEY,
	name text
);

CREATE TABLE energiekarten.standard_aufbereitet(
	id serial PRIMARY KEY,
	kundennummer text,
	baualtersklassen_id INT,
	geb_typologien_id INT,
	geb_nutzflaeche float,
	bewohner int,
	gml_id text,
	geom geometry,
	FOREIGN KEY (baualtersklassen_id) REFERENCES energiekarten.baualtersklassen(id),
	FOREIGN KEY (geb_typologien_id) REFERENCES energiekarten.geb_typologien(id),
	UNIQUE (id, kundennummer, gml_id)
	);

/*
Um Objekte eindeutig identifizierne zu können, muss eigentlich gml_id, Kundennummer und id aus der Tabelle standard_aufbereitet
als UNIQUE(gml_id, Knd_nr, id) gekennzeichnet werden.
Das ist dann ein eindeutiger KEY mit dem jedes Objekt identifiziert werden kann.
*/
	
CREATE TABLE IF NOT EXISTS energiekarten.szenario_1 (
	id serial PRIMARY KEY,
	faktor_szenario_1 float,
	waermebedarfswert_szenario_1 float
);

CREATE TABLE IF NOT EXISTS energiekarten.szenario_2 (
	id serial PRIMARY KEY,
	faktor_szenario_2 float,
	waermebedarfswert_szenario_2 float
);

CREATE TABLE IF NOT EXISTS energiekarten.szenario_3 (
	id serial PRIMARY KEY,
	faktor_szenario_3 float,
	waermebedarfswert_szenario_3 float
);	

	
CREATE TABLE IF NOT EXISTS energiekarten.ergebnis_energie(
	id serial PRIMARY KEY,
	aufbereitet_id int REFERENCES energiekarten.standard_aufbereitet(id),
	gml_id text,
	waermebedarfswert float,
	detailgrad_waerme int,
	strombedarfswert float,
	detailgrad_strom int,
	geom geometry,
	szenario_1_id int REFERENCES	energiekarten.szenario_1(id),
	szenario_2_id int REFERENCES	energiekarten.szenario_2(id),
	szenario_3_id int REFERENCES	energiekarten.szenario_3(id)
);



CREATE TABLE IF NOT EXISTS energiekarten.waermebedarfswerte_bis_DG3(
	id serial PRIMARY KEY,
	typologie_id int,
	baualtersklassen_id int,
	waermebedarfswert float,
	detailgrad int,
	FOREIGN KEY (typologie_id) REFERENCES energiekarten.geb_typologien(id),
	FOREIGN KEY (baualtersklassen_id) REFERENCES energiekarten.baualtersklassen(id)
);

CREATE TABLE IF NOT EXISTS energiekarten.strombedarfswerte_dg_2(
	id serial PRIMARY KEY,
	typologie_id int,
	strombedarfswert_1 float,
	strombedarfswert_2 float,
	FOREIGN KEY (typologie_id) REFERENCES energiekarten.geb_typologien(id)
);

CREATE TABLE IF NOT EXISTS energiekarten.sanierungsgrade(
	id serial PRIMARY KEY,
	name text,
	faktor float
);

CREATE TABLE IF NOT EXISTS energiekarten.waermebedarfswerte_DG4(
	waermebedarfswert_DG3_id int,
	sanierungs_id int,
	waermebedarfswert_DG4 float, --dieser muss noch berechnet werden über den waermebedarfswert_DG3 * faktor aus Sanierungstabelle
	PRIMARY KEY (waermebedarfswert_DG3_id, sanierungs_id),
	FOREIGN KEY (waermebedarfswert_DG3_id) REFERENCES energiekarten.waermebedarfswerte_bis_DG3(id),
	FOREIGN KEY (sanierungs_id) REFERENCES energiekarten.sanierungsgrade(id)
);

CREATE TABLE IF NOT EXISTS energiekarten.fachdaten_aufbereitet(
	id serial PRIMARY KEY,
	sanierungsgrad_id int REFERENCES energiekarten.sanierungsgrade(id),
	gebaeude_aufbereitet_id int REFERENCES energiekarten.standard_aufbereitet(id),
	verbrauchsjahr int,
	stromverbrauch float,
	waermeverbrauch float
);