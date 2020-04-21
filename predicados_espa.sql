----------------------------------  Ejercicios con algunos predicados espaciales ---------------------------------
--------------------------------------------------- DATOS -----------------------------------------------------
--- AGEBS de la ZMVM, COLONIAS de la ZMVM, MANZANAS de la ZMVM, LIMITE de la ZMVM, ESTACIONES del METRO, DENUE de la CDMX, CALLES de la ZMVM ---

------ INTERSECTS----
----- ¿Cuáles son las agebs que intersectan con la colonia Centro de la Ciudad de México? el identificador de esta colonia es 3183) ------

SELECT agebs_cdmx.*
FROM agebs_cdmx 
JOIN colonias 
ON ST_Intersects(agebs_cdmx.geom, colonias .geom)
WHERE colonias.id = 3183;

----- OVERLAPS ------------
--- ¿Cuántos agebs se sobreponen con las colonias de la Ciudad de México? 
---- Estás geometrías comparten parte de sus puntos pero no todos, además, la intersección debe tener la misma dimensión que las geometrías análizadas, 
---- una superficie (bidimensional) para este caso.  

SELECT count(a.*)
FROM agebs_cdmx a
JOIN colonias c
ON ST_Overlaps (a.geom, c.geom);


-------- CONTAINS----------------

---- Se quiere saber sí el total de puntos estan contenidos dentro de una geometría, se utiliza el metodo Contains,
---- En este caso preguntamos, ¿Todas las estaciones del metro están contenidas dentro de la Zona Metropolitana del Valle de Méxco?, con el  resultadoa 
---- se obteniene el total.
----- Total = 192 estaciones ----

SELECT count(estaciones_metro.id)
FROM estaciones_metro, limite_metropolitano
WHERE ST_Contains(limite_metropolitano.geom, estaciones_metro.geom);

-------¿Qué agebs estan dentro de la Colonia Centro?, Contains no considera los puntos que estén sobre el borde, es decir,
------- solo mostrará aquellos que estén dentro sin considerar los que intersectan con el borde.

SELECT agebs_cdmx.*
FROM agebs_cdmx 
JOIN colonias 
ON  ST_Contains(colonias.geom, agebs_cdmx.geom)
WHERE colonias.id = 3183;


-------- WITHIN --------
---- ¿Qué estaciones del metros estan dentro de la colonia Centro? Whithin se entiende como "contenido en", en este
---- caso son las estaciones del metro contenidas en la colonia  Centro.

SELECT estaciones_metro.nombreesta
FROM estaciones_metro 
JOIN colonias
ON ST_Within(estaciones_metro.geom, colonias.geom)
WHERE colonias.id = 3183;


-----------COVERS--------------
---- Selecciona del Denue las papelerias ("comercio al por menor de ariculos de papelería", el codigo de esta actividad es '465311' en el campo "codigo_act") 
---- que se localizan dentro de la colonía Centro, covers considera los puntos que si están contenidos en el borde.  

SELECT denue_cdmx.*
FROM denue_cdmx  
JOIN colonias
ON ST_Covers(colonias.geom, denue_cdmx.geom)
WHERE denue_cdmx.codigo_act = '465311' 
AND colonias.id = 3183;


----------- COVEREDBY -----------
------ ¿Cuántas manzanas de la Ciudad de México tienen menos de 1000 habitantes?, en este caso seleccionara aquellas manzanas que tienen menos de 1000 habitantes
------ que esten dentro de la ciudad de México (tabla ent_cdmx), en este caso CoveredBy es el inverso de Covers, manzanas_zmvm contenidas en ent_cdmx.

SELECT count(manzanas_zmvm.*)
FROM manzanas_zmvm 
JOIN ent_cdmx
ON ST_CoveredBy(manzanas_zmvm.geom, ent_cdmx.geom)
WHERE manzanas_zmvm.pob1 < 1000;


------ ¿Cuál es el total de población que vive en las manzanas que cruza cruza la avenida de los Insurgentes? ------ 
------ Para esta consulta se realiza una suma de las manzanas que intersectan la Av. Insurgentes (Sur, Centro y Norte), se hace uso de la función coalesce para
------ considerar valores nulos en caso de que existieran como 0.

SELECT sum(coalesce(manzanas_zmvm.pob1)) AS Pob_Insurgentes
FROM manzanas_zmvm 
JOIN calles_cdmx_zmvm
ON ST_Intersects(manzanas_zmvm.geom, calles_cdmx_zmvm.geom)
WHERE calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Sur' 
OR calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Centro'
OR calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Norte'; 

------ ¿Cuál es el ageb de la Ciudad de México con mayor número de papelerías? -------
------ En esta consulta se realiza una selección de los agebs que intersectan con el mayor número de papelerías, mediante un conteo se presentan en una tabla que 
------ agrupa por el id de agebs en un orden descendente.

SELECT merge_agebs_zmvm.id AS id_ageb, count(denue_cdmx.codigo_act = '465311') AS Tot_papelerias
FROM merge_agebs_zmvm
JOIN denue_cdmx
ON ST_Intersects(merge_agebs_zmvm.geom, denue_cdmx.geom)
WHERE denue_cdmx.codigo_act = '465311'
GROUP BY merge_agebs_zmvm.id
ORDER BY Tot_papelerias desc;


---################################################################################################################
