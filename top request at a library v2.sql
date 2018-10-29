﻿--Gathers the most requested titles at each location, for www.minlib.net/booklists/recommended-reads/top-request-by-library
--Jeremy Goldstein with enormous assist from Ray Voelker

DROP TABLE IF EXISTS temp_holds_data
;

CREATE TEMP TABLE temp_holds_data AS
SELECT
h.pickup_location_code,
h.record_id,
r.record_type_code, 
r.record_num,
CASE
    WHEN r.record_type_code = 'i' THEN (
        SELECT
        l.bib_record_id
        FROM
        sierra_view.bib_record_item_record_link as l
        WHERE
        l.item_record_id = h.record_id
        LIMIT 1
    )
    WHEN r.record_type_code = 'j' THEN (
        SELECT
        l.bib_record_id
        FROM
        sierra_view.bib_record_volume_record_link as l
        WHERE
        l.volume_record_id = h.record_id
        LIMIT 1
    )
    WHEN r.record_type_code = 'b' THEN (
        h.record_id
    )
    ELSE NULL
END AS bib_record_id

FROM
sierra_view.hold as h

JOIN
sierra_view.record_metadata as r
ON
  r.id = h.record_id
;


DROP TABLE IF EXISTS temp_location_holds_counts;
CREATE TEMP TABLE temp_location_holds_counts AS
SELECT
t.pickup_location_code,
t.bib_record_id,
count(t.bib_record_id) as count_holds_on_title

FROM
temp_holds_data as t

GROUP BY
t.pickup_location_code,
t.bib_record_id

HAVING
count(t.bib_record_id) > 1

ORDER BY
t.pickup_location_code,
count_holds_on_title
;


SELECT
DISTINCT ON (field_booklist_entry_location)
l.name AS field_booklist_entry_location,
'https://find.minlib.net/iii/encore/record/C__R'||id2reckey(t.bib_record_id) AS field_booklist_entry_encore_url,
b.best_title as title,
b.best_author AS field_booklist_entry_author,
'https://syndetics.com/index.aspx?isbn='||SUBSTRING(MAX(s.content) FROM '[0-9]+')||'/SC.gif&client=minuteman' AS field_booklist_entry_cover,
t.count_holds_on_title

FROM (
    SELECT
    t2.pickup_location_code,
    MAX(t2.count_holds_on_title) as max_count

    FROM
    temp_location_holds_counts as t2

    GROUP BY
    t2.pickup_location_code
) AS c

JOIN
sierra_view.location_myuser l
ON
substring(c.pickup_location_code from 1 for 3) = l.code

JOIN
temp_location_holds_counts as t
ON
  t.pickup_location_code = c.pickup_location_code
  AND t.count_holds_on_title = c.max_count

JOIN
sierra_view.bib_record_property b
ON
t.bib_record_id = b.bib_record_id

JOIN sierra_view.subfield s
ON
b.bib_record_id = s.record_id AND s.marc_tag = '020' AND s.tag = 'a'

GROUP BY
1,2,3,4,6
ORDER BY
1
;