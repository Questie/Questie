SELECT o.id, o.name, ol.map_id, ol.x, ol.y FROM objects o
JOIN object_locations ol ON o.id = ol.object_id
GROUP BY o.name, o.id, ol.map_id, ol.x, ol.y
;