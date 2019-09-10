/*
Jeremy Goldstein
Minuteman Library Network

Identifies item level holds that should be transferred to bib level holds
*/

SELECT
ID2RECKEY(l.bib_record_id)||'a' AS bib_number,
b.best_title AS title,
STRING_AGG(DISTINCT h.pickup_location_code,', ') AS pickup_location_code,
COUNT(h.id) AS total_item_level_holds,
--COUNT(l.item_record_id) FILTER (WHERE i.is_available_at_library = TRUE) AS availabile_copies,
STRING_AGG(TO_CHAR(h.placed_gmt, 'YYYY-MM-DD'),', ') AS hold_placed

FROM
sierra_view.hold h

JOIN
sierra_view.record_metadata m
ON
h.record_id = m.id AND m.campus_code = '' AND m.record_type_code = 'i'
LEFT JOIN
sierra_view.bib_record_item_record_link l
ON
m.id = l.item_record_id AND m.record_type_code = 'i'
JOIN
sierra_view.item_record i
ON
l.item_record_id = i.id
LEFT JOIN
sierra_view.varfield as v
on
i.id = v.record_id and v.varfield_type_code = 'v'
JOIN
sierra_view.bib_record_property b
ON
l.bib_record_id = b.bib_record_id

WHERE
h.status = '0'
AND v.field_content IS NULL
AND h.is_frozen = FALSE
AND h.placed_gmt < '2019-09-01'
AND h.pickup_location_code ~ '^ca'

GROUP BY 1,2
HAVING 
COUNT(i.id) FILTER (WHERE i.is_available_at_library = TRUE) > 0

ORDER BY 3,5