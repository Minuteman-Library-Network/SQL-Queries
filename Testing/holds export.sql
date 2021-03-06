WITH in_transit AS (
SELECT
m.id,
SPLIT_PART(v.field_content,': ',1) AS transit_timestamp,
pickup_loc.name AS origin_loc
FROM
sierra_view.varfield v
JOIN 
sierra_view.record_metadata m
ON
v.record_id = m.id AND m.record_type_code = 'i'
JOIN
sierra_view.location_myuser pickup_loc
ON
SUBSTRING(SPLIT_PART(SPLIT_PART(v.field_content,'from ',2),' to',1)FROM 1 FOR 3) = pickup_loc.code
WHERE
v.varfield_type_code = 'm'
AND v.field_content LIKE '%IN TRANSIT%'
)

SELECT
DISTINCT h.id AS "Hold ID",
h.placed_gmt::DATE AS "Date Placed",
id2reckey(h.patron_record_id)||'a' AS "Patron Number",
pn.last_name||', '||pn.first_name||' '||pn.middle_name AS "Name",
b.best_title AS "Title",
rec_num.record_type_code||rec_num.record_num||'a' AS "Record Number",
pickup_loc.name AS "Pickup Location",
CASE
	WHEN h.is_frozen = 'true' THEN 'Frozen'
	WHEN h.status = '0' THEN 'On hold'
	WHEN h.status = 't' THEN 'In transit'
	ELSE 'Ready for pickup'
	END AS "Hold Status",
CASE
	WHEN h.record_id = l.bib_record_id THEN 'bib'
	ELSE 'item'
	END AS "Hold Type",
REPLACE(REPLACE(i.call_number,'|a',''),'|f','') AS "Call Number",
ir.location_code AS "Item Location",
t.transit_timestamp AS "In Transit Time",
t.origin_loc AS "In Transit Origin",
rm.record_last_updated_gmt::DATE AS "On Holdshelf Date"
FROM
sierra_view.hold h
JOIN
sierra_view.bib_record_item_record_link l
ON
h.record_id = l.bib_record_id OR h.record_id = l.item_record_id
JOIN
sierra_view.bib_record_property b
ON
l.bib_record_id = b.bib_record_id
LEFT JOIN
sierra_view.item_record_property i
ON
l.item_record_id = i.item_record_id AND h.record_id = l.item_record_id
JOIN
sierra_view.patron_record_fullname pn
ON
h.patron_record_id = pn.patron_record_id
LEFT JOIN
sierra_view.item_record ir
ON
i.item_record_id = ir.id
LEFT JOIN
in_transit t
ON
h.record_id = t.id AND ir.item_status_code = 't'
LEFT JOIN
sierra_view.record_metadata rm
ON
ir.id = rm.id AND h.status NOT IN ('0','t')
JOIN
sierra_view.record_metadata rec_num
ON
h.record_id = rec_num.id
JOIN
sierra_view.location_myuser pickup_loc
ON
SUBSTRING(h.pickup_location_code,1,3) = pickup_loc.code

WHERE h.placed_gmt::DATE BETWEEN '2020-03-01' AND '2020-03-19'