SELECT
i.call_number_norm,
--needs to account for [a-z][0-9]+ variations call numbers and suffixes
CASE
	WHEN i.call_number_norm = '' OR i.call_number_norm IS NULL THEN 'no call number'
	WHEN i.call_number_norm !~ '\d' AND REVERSE(i.call_number_norm) ~ '^[a-z\.]+\s?,[a-z]' THEN REVERSE(REGEXP_REPLACE(REVERSE(TRIM(BOTH FROM i.call_number_norm)),'^\w+\s?,?\w+', ''))
	WHEN i.call_number_norm !~ '\d' THEN REVERSE(REGEXP_REPLACE(REVERSE(TRIM(BOTH FROM i.call_number_norm)),'^\w*\s', ''))
	WHEN TRIM(BOTH FROM i.call_number_norm) ~ '^[0-9]' THEN SUBSTRING(TRIM(BOTH FROM i.call_number_norm),'^[0-9]{2}')||'0'
	WHEN REVERSE(TRIM(BOTH FROM i.call_number_norm)) ~ '^[0-9]{3}[12]' THEN REVERSE(REGEXP_REPLACE(REGEXP_REPLACE(REVERSE(TRIM(BOTH FROM i.call_number_norm)),'^[0-9]{3}[12]',''),'^\w*\s', ''))
	WHEN TRIM(BOTH FROM i.call_number_norm) ~ '\[0-9]\s\w+$' THEN REVERSE(REGEXP_REPLACE(REGEXP_REPLACE(REVERSE(TRIM(BOTH FROM i.call_number_norm)),'^\w*\s', ''),'^\w*\s', ''))
	ELSE 'unknown'
END AS call_number_range,
id2reckey(ir.id)||'a'

FROM
sierra_view.item_record_property i
JOIN
sierra_view.item_record ir
ON
i.item_record_id = ir.id
AND
ir.location_code ~ '^brk'
ORDER BY 2, 1