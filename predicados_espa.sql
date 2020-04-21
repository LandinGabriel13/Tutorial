----------------------------------  Ejercicios con algunos predicados espaciales ---------------------------------
--------------------------------------------------- DATOS -----------------------------------------------------
-- AGEBS de la ZMVM, COLONIAS de la ZMVM, MANZANAS de la ZMVM, LIMITE de la ZMVM, ESTACIONES del METRO, DENUE de la CDMX, 
-- CALLES de la ZMVM ---

---------- INTERSECTS (A,B)-------
-- Devuelve verdadero si el objeto geométrico (A) intersecta espacialmente con el segundo (B).
-- Ejemplo: ¿Cuáles son las agebs que intersectan con la colonia Centro de la Ciudad de México? 
-- Nota: el identificador de la colonia Centro es 3183 --

SELECT agebs_cdmx.*
FROM agebs_cdmx 
JOIN colonias 
ON ST_Intersects(agebs_cdmx.geom, colonias .geom)
WHERE colonias.id = 3183;

---------- OVERLAPS (A,B)---------
-- Las geometrías en este predicado solamente comparten parte de sus puntos, es decir, no debe existir un sobreposición 
-- completa de ambas geometrías. La sobreposición debe tener la misma dimensión que las geometrías analizadas (Surface-Surface, 
-- LineString-LineString...). 
-- Para el siguiente ejemplo la geometría es de Surface-Surface, con una dimensión de 2.
-- ¿Cuántos agebs se sobreponen con las colonias de la Ciudad de México? 

SELECT count(a.*)
FROM agebs_cdmx a
JOIN colonias c
ON ST_Overlaps (a.geom, c.geom);


---------- CONTAINS (A,B)----------------
-- El predicado Contains devuelve las geometrías(B) contenidas completamente en el interior de la segunda geometría(A). 
-- Para el siguiente ejemplo queremos saber si todas las estaciones del metro están contenidas dentro de la Zona Metropolitana 
-- del Valle de Méxco, con el  resultado se obteniene el total de las estaciones.
-- Resultado: 192 estaciones ----

SELECT count(estaciones_metro.id)
FROM estaciones_metro, limite_metropolitano
WHERE ST_Contains(limite_metropolitano.geom, estaciones_metro.geom);

-- Otro ejemplo un poco más interesante es saber, ¿cuántas de todas las estaciones se localizan dentro de la Ciudad de México?

SELECT count(estaciones_metro)
FROM estaciones_metro
JOIN ent_cdmx
ON ST_Contains(ent_cdmx.geom, estaciones_metro.geom);

-- Resultado: 181 estaciones ----

-- Enseguida se muestran otros ejemplos del uso de Contains e Intersects.
-- ¿Cuántos agebs estan dentro de la Colonia Centro?
-- Nota: Contains no considera los puntos que están sobre el borde, solo devuelve aquellos que están completamente contenidos
-- dentro de la otra geometría, en este caso los agebs dentro de las colonias.

SELECT agebs_cdmx.*
FROM agebs_cdmx 
JOIN colonias 
ON  ST_Contains(colonias.geom, agebs_cdmx.geom)
WHERE colonias.id = 3183;

-- Resultado: 8 agebs -----

-- Ahora, hagamos la consulta con Intersects y observemos la diferencia.

SELECT agebs_cdmx.*
FROM agebs_cdmx 
JOIN colonias 
ON  ST_Intersects(colonias.geom, agebs_cdmx.geom)
WHERE colonias.id = 3183;

-- Resultado: 36 agebs ----


----------- WITHIN (A,B) --------
-- Este predicado es el contrario de Contains, es decir, devolvera verdadero si la geometría A esta completamente dentro de la geometría B. 
-- Ejemplo: ¿Qué estaciones del metros estan dentro de la colonia Centro? 
-- Nota: Whithin se entiende como "contenido en", en este caso son las estaciones del metro contenidas en la colonia Centro.

SELECT estaciones_metro.nombreesta
FROM estaciones_metro 
JOIN colonias
ON ST_Within(estaciones_metro.geom, colonias.geom)
WHERE colonias.id = 3183;

-- Resultado: 14 estaciones se localizan dentro de la colonia Centro ----

-----------COVERS--------------
-- Selecciona del Denue las papelerias que se localizan dentro de la colonía Centro. Nota: Covers si considera los puntos contenidos en el borde.
-- La descripción para papelerías en el Denue es: "comercio al por menor de ariculos de papelería", haremos la selección de éstas mediante 
-- su código de actividad que corresponde a '465311' en el campo "codigo_act".  

SELECT denue_cdmx.*
FROM denue_cdmx  
JOIN colonias
ON ST_Covers(colonias.geom, denue_cdmx.geom)
WHERE denue_cdmx.codigo_act = '465311' 
AND colonias.id = 3183;


----------- COVEREDBY -----------
-- ¿Cuántas manzanas de la Ciudad de México tienen menos de 1000 habitantes?, en este caso seleccionara aquellas manzanas que tienen menos de 1000 habitantes
-- que esten dentro de la ciudad de México (tabla ent_cdmx), en este caso CoveredBy es el inverso de Covers, manzanas_zmvm contenidas en ent_cdmx.

SELECT count(manzanas_zmvm.*)
FROM manzanas_zmvm 
JOIN ent_cdmx
ON ST_CoveredBy(manzanas_zmvm.geom, ent_cdmx.geom)
WHERE manzanas_zmvm.pob1 < 1000;


-- ¿Cuál es el total de población que vive en las manzanas que cruza cruza la avenida de los Insurgentes? ------ 
-- Para esta consulta se realiza una suma de las manzanas que intersectan la Av. Insurgentes (Sur, Centro y Norte), se hace uso de la función coalesce para
-- considerar valores nulos en caso de que existieran como 0.

SELECT sum(coalesce(manzanas_zmvm.pob1)) AS Pob_Insurgentes
FROM manzanas_zmvm 
JOIN calles_cdmx_zmvm
ON ST_Intersects(manzanas_zmvm.geom, calles_cdmx_zmvm.geom)
WHERE calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Sur' 
OR calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Centro'
OR calles_cdmx_zmvm.osm_name = 'Avenida Insurgentes Norte'; 

-- ¿Cuál es el ageb de la Ciudad de México con mayor número de papelerías? -------
-- En esta consulta se realiza una selección de los agebs que intersectan con el mayor número de papelerías, mediante un conteo se presentan en una tabla que 
-- agrupa por el id de agebs en un orden descendente.

SELECT merge_agebs_zmvm.id AS id_ageb, count(denue_cdmx.codigo_act = '465311') AS Tot_papelerias
FROM merge_agebs_zmvm
JOIN denue_cdmx
ON ST_Intersects(merge_agebs_zmvm.geom, denue_cdmx.geom)
WHERE denue_cdmx.codigo_act = '465311'
GROUP BY merge_agebs_zmvm.id
ORDER BY Tot_papelerias desc;


--################################################################################################################
