SELECT i.name as 'item_name', o.id as 'object_id' FROM items i
JOIN item_objectdata iod ON i.id = iod.item_id
JOIN objectdata_objects odo ON iod.objectdata_id = odo.objectdata_id
JOIN objects o ON odo.object_id = o.id
WHERE o.id IN (SELECT object_id FROM object_locations)
GROUP BY i.name, o.id
;