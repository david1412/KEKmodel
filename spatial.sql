--SET search_path = public,energymap;
--CREATE EXTENSION postgis;

--SELECT * FROM  public.spatial_ref_sys WHERE srid = 4326
/*
CREATE TABLE buildings(
	id SERIAL ,
	name character varying,
	stories integer,
	area_sum numeric
)
*/
--SELECT version()

/* CREATE TABLE  energymap.buildings AS
SELECT * FROM buildings WHERE false 
*/

--SELECT postgis_version()

/* SELECT AddGeometryColumn(
	'energymap',
	'buildings',
	'base_geom', 
	 4326 ,
	'MULTIPOLYGON',2)
*/
--ALTER TABLE buildings ADD COLUMN center_geom geometry('Point', 25833) -- standard way to create the in line geomentry

-- creating polyogon data
/*
INSERT INTO buildings (name, stories, base_geom)
VALUES (
	      'Maxstraße 33, 18055 Rostock',
				2,
				ST_GeometryFromText('MultiPolygon(((12 54 , 12.1 54 , 12.1 54.1, 12 54.1, 12 54)))',4326) 
	)

-- deleting the data set

DELETE FROM buildings
*/
/*
SELECT 
    ST_AsText(base_geom),
		ST_AsText(ST_Transform(ST_PointOnSurface(base_geom),25833)) -- wct format and utm format
FROM
		buildings
*/
-- updating 

UPDATE 
  buildings 
SET 
  center_geom = ST_Transform(ST_PointOnSurface(base_geom),25833)

SELECT 
   ST_AsText(center_geom)
FROM
   buildings 

--CREATE SEQUENCE energymap.buildings_id_sequ START 1 OWNED BY buildings.id

CREATE TABLE energymap.pois (
	id SERIAL ,
	geom geometry('Point',25833)
)
ALTER TABLE buildings AlTER COLUMN base_geom  TYPE geometry('MultiPolygon', 25833) USING  
ST_Transform(base_geom, 25833) -- changing the transformation from 3283 

SELECT ST_AsText(base_geom) FROM buildings

UPDATE buildings 
SET base_geom = ST_GeometryFromText('MultiPolygon(((300000 5900000 , 300100 5900000 , 300100 5900050 , 300000 5900050, 300000 5900000)))', 25833)-- base position

--crs in UTM
/*
SELECT ST_AsText(base_geom) FROM buildings 

INSERT INTO pois (geom) VALUES (ST_GeometryFromText('Point(300050 5900075)', 25833)); -- outside
INSERT INTO pois (geom) VALUES (ST_GeometryFromText('Point(300050 5900150)', 25833)); -- inside
INSERT INTO pois (geom) VALUES (ST_GeometryFromText('Point(300050 5900000)', 25833)) ;-- on the line
*/
SELECT 
  a.id,
  ST_AsText(a.geom) a ,
	ST_AsText(b.base_geom) b,
  ST_WithIN(a.geom, b.base_geom) OR ST_TOUCHES(a.geom, b.base_geom) within_and_touch,
	--ST_Contains(b.base_geom, a.geom)
	ST_Distance(a.geom, b.base_geom) distance, -- cal distance
	ST_Intersects(a.geom, b.base_geom) intersects
FROM 
 pois AS a JOIN 
 buildings As b ON true
 
ORDER BY ID -- id order
 --ST_AsText(geom) FROM pois
 
UPDATE 
 
  buildings 
SET 
 area_sum = ST_area(base_geom) * stories -- example 
 
UPDATE
 pois
SET
 geom= ST_GeometryFromText('Point(300050 5900025)',25833)
WHERE 
			id= 1
 
create table energymap.gemeinden As select * from "gemeinden_mecklenburg-vorpommern"

SELECT ST_Transform(geom, 25833) FROM gemeinden LIMIT 10

UPDATE
 gemeinden
SET
geom= ST_SetSRID(geom,4326)

ALTER TABLE gemeinden AlTER COLUMN geom  TYPE geometry('MultiPolygon', 25833) USING  
ST_Transform(geom, 25833) -- changing the transformation from 3283 


UPDATE
 buildings 
SET
 base_geom = ST_Translate(base_geom, 0 , 50000) -- 50 km to north


SELECT 
 g.gid,
 g.gem_name,
 --ST_Distance(g.geom,b.base_geom),
 b.base_geom
FROM
 gemeinden g JOIN
 buildings b ON ST_Intersects(b.base_geom,g.geom)
ORDER BY
 ST_Distance(g.geom,b.base_geom)

LIMIT 10
 --buildings b ON ST_Within(b.base_geom,g.geom)
  --buildings b ON ST_Interscepts(b.base_geom,g.geom)
--gemeinden g JOIN
 
--buildings b ON ST_within(b.base_geom,g.geom)

-- how many geometries are there in the table

SELECT count(*) FROM gemeinden -- instead of * we need to change the name

CREATE INDEX gemeinden_geom_gist ON gemeinden USING gist(geom) -- index scan 

SELECT 
 a.gid,
 b.gid,
 ST_Area(ST_Intersection(a.geom,b.geom))
FROM 
 gemeinden AS a JOIN
 gemeinden AS b ON a.geom && b.geom AND ST_Intersects(a.geom,b.geom)
WHERE
 a.gid != b.gid
ORDER BY
 ST_Area(ST_Intersection(a.geom,b.geom)) DESC
LIMIT 10

SELECT 
--ST_GeometryType(ST_Intersection(
  ST_CollectionExtract(ST_Intersection(
     (select geom from gemeinden where gid =79),
	   (select geom from gemeinden where gid =100)
	),3) -- geometry type by taking this 
	
-- search for invalid geo

SELECT 
 ST_isvalidReason(geom)
FROM
 gemeinden
WHERE
 NOT ST_isValid(geom)
 
INSERT INTO buildings(base_geom)
VALUES ( 
 ST_GeometryFromText('MultiPolygon(((300000 5900000 , 300100 5900000, 300000 5900050,300100 5900050, 300000 5900000)))', 25833))
 
 
SELECT 
 --ST_IsValidReason(base_geom)
 ST_MakeValid(base_geom)
FROM
 buildings
WHERE
 NOT ST_IsValid(base_geom)