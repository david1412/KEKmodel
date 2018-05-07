-- Calculating power demand in DG2
-- v0.1

/* *************************
Author: Tobias Weinzierl, Gopalam Moram
Date: 03.05.2018

************************ */


UPDATE energiekarten.ergebnis_energie
SET (strombedarfswert, detailgrad_strom) = (select
CASE 
WHEN geb_typologien_id IN (1,2,3,4,5) THEN (bewohner*strombedarfswert_1)
WHEN geb_typologien_id IN (6,10,11,12,13,14) THEN (geb_nutzflaeche * strombedarfswert_1)
WHEN geb_typologien_id IN (7,8,9) THEN (((bewohner*strombedarfswert_1)+(geb_nutzflaeche * strombedarfswert_2))/2)
ELSE 0
END as strombedarf,
2
from energiekarten.standard_aufbereitet as sa join energiekarten.strombedarfswerte as st on sa.geb_typologien_id = st.typologie_id
where ergebnis_energie.gml_id = sa.gml_id );

