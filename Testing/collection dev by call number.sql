WITH call_number_mod AS(
SELECT
i.item_record_id,
i.call_number_norm AS call_original,
CASE
	--author in call
	WHEN b.best_author_norm != '' AND i.call_number_norm ~ SPLIT_PART(TRANSLATE(b.best_author_norm,'âáãäåāăąÁÂÃÄÅĀĂĄèéééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuu'), ' ',1) THEN REGEXP_REPLACE(SPLIT_PART(BTRIM(i.call_number_norm),SPLIT_PART(TRANSLATE(b.best_author_norm,'âáãäåāăąÁÂÃÄÅĀĂĄèéééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuu'), ' ',1),1),'[^\w\s\.]','','g')
   --first characters of author in call
	WHEN b.best_author_norm != '' AND i.call_number_norm ~ SUBSTRING(SPLIT_PART(TRANSLATE(b.best_author_norm,'âáãäåāăąÁÂÃÄÅĀĂĄèéééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuu'), ' ',1)FROM 1 FOR 3) THEN REGEXP_REPLACE(SPLIT_PART(BTRIM(i.call_number_norm),SUBSTRING(SPLIT_PART(TRANSLATE(b.best_author_norm,'âáãäåāăąÁÂÃÄÅĀĂĄèéééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuu'), ' ',1)FROM 1 FOR 3),1),'[^\w\s\.]','','g')
	--title in call
	--WHEN i.call_number_norm ~ SPLIT_PART(b.best_title_norm, ' ',1) THEN REGEXP_REPLACE(SPLIT_PART(BTRIM(i.call_number_norm),SPLIT_PART(b.best_title_norm, ' ',1),1),'[^\w\s]','','g')
   --strip year from end
	WHEN BTRIM(i.call_number_norm) ~ '\s*[12][0-9]{3}$' THEN REGEXP_REPLACE(SUBSTRING(BTRIM(i.call_number_norm),1,STRPOS(BTRIM(i.call_number_norm), (regexp_match(BTRIM(i.call_number_norm), '\s*[12][0-9]{3}$'))[1])-1),'[^\w\s\.]','','g')
	--only digits are a volume,copy,series, etc number at the end
	WHEN BTRIM(i.call_number_norm) ~ '(v|vol|c|#|s|season|sea|set|ser|series|p|pt|part|col|collection|b|bk|book)\.?\s*[0-9]{1,3}$' THEN REGEXP_REPLACE(SUBSTRING(BTRIM(i.call_number_norm),1,STRPOS(BTRIM(i.call_number_norm), (regexp_match(BTRIM(i.call_number_norm), '(v|vol|c|#|s|season|sea|set|ser|series|p|pt|part|col|collection|b|bk|book)\.?\s*[0-9]{1,3}$'))[1])-1),'[^\w\s\.]','','g')
	ELSE REGEXP_REPLACE(BTRIM(i.call_number_norm),'[^\w\s\.]','','g')
END AS call_number_norm
FROM
sierra_view.item_record_property i
JOIN
sierra_view.bib_record_item_record_link l
ON
i.item_record_id = l.item_record_id
JOIN
sierra_view.bib_record_property b
ON
l.bib_record_id = b.bib_record_id
JOIN
sierra_view.item_record ir
ON
i.item_record_id = ir.id
AND ir.itype_code_num != '241'
AND ir.location_code ~ '^act'
)

SELECT
COALESCE(CASE
   --call number does not exist
	WHEN ic.call_number_norm = '' OR ic.call_number_norm IS NULL THEN 'no call number'
	--biographies
   WHEN ic.call_number_norm ~ '^(.*biography|.*biog|.*bio)\y' THEN BTRIM(SUBSTRING(ic.call_number_norm FROM '^.*((biography)|(biog)|(bio))\y'))
	--graphic novels & manga
   WHEN ic.call_number_norm ~ '^(.*graphic|.*manga)' AND ic.call_number_norm !~ '\d' THEN BTRIM(SUBSTRING(ic.call_number_norm FROM '^(.*graphic|.*manga)'))
	--call number contains no numbers and a 1 or 2 words
	WHEN ic.call_number_norm !~ '\d' AND (ic.call_number_norm !~ '\s' OR ic.call_number_norm ~ '^([\w\-\.]+\s)[\w\-\.]+$') THEN BTRIM(ic.call_number_norm)
	--call number contains no numbers 2 words
	--WHEN i.call_number_norm !~ '\d' AND i.call_number_norm ~ '^([\w\-\.]+\s)[\w\-\.]+$' THEN SPLIT_PART(REGEXP_REPLACE(i.call_number_norm,'\(|\)|\[|\]','','gi'),' ','1')
	--call number contains no numbers and 3-4 words
	WHEN ic.call_number_norm !~ '\d' AND ic.call_number_norm ~ '^([\w\-\.]+\s)([\w\-\.]+\s){0,2}[\w\-\.]+$' THEN BTRIM(REVERSE(REGEXP_REPLACE(REVERSE(ic.call_number_norm),'^[\w\-\.\/\'']*\s', '')))
	--call number contains no numbers and > 4 words
   WHEN ic.call_number_norm !~ '\d' THEN BTRIM(SPLIT_PART(ic.call_number_norm,' ','1')||' '||SPLIT_PART(ic.call_number_norm,' ','2')||' '||SPLIT_PART(ic.call_number_norm,' ','3'))
	--only digits are a cutter at the end
	WHEN REGEXP_REPLACE(REVERSE(ic.call_number_norm), '^[a-z]*[0-9]{2,3}[a-z]\s?','') !~ '\d' THEN BTRIM(REVERSE(REGEXP_REPLACE(REGEXP_REPLACE(REVERSE(ic.call_number_norm),'^[a-z]*[0-9]{2}[a-z]\s?', ''),'^[\w\-\.\'']*\s', '')))
   --contains an LC number in the 1000-9999 range
   WHEN ic.call_number_norm ~ '(^|\s)[a-z]{1,3}\s?[0-9]{4}(\.\d{1,3})?\s?\.?[a-z][0-9]' THEN BTRIM(SUBSTRING(ic.call_number_norm,'^[a-z\s\[\]\&\-\.\,\(\)]*[a-z]{1,2}\s?[0-9]')||'000-'||SUBSTRING(ic.call_number_norm,'^[a-z\s\[\]\&\-\.\,\(\)]*[a-z]{1,2}\s?[0-9]')||'999')
	--contains an LC number in the 001-999 range
	WHEN ic.call_number_norm ~ '(^|\s)[a-z]{1,3}\s?[0-9]{1,3}(\.\d{1,3})?\s?\.[a-z][0-9]' THEN BTRIM(SUBSTRING(ic.call_number_norm,'^[a-z\s\[\]\&\-\.\,\(\)]*[a-z]{1,2}')||'001-999')
   --contains a dewey number
	WHEN ic.call_number_norm ~ '[0-9]{3}\.?[0-9]*' THEN BTRIM(SUBSTRING(ic.call_number_norm,'^[a-z\s\[\]\&\-\.\,\(\)]*[0-9]{2}')||'0')
  --PS4
	WHEN ic.call_number_norm ~ 'ps4' THEN BTRIM(REVERSE(REGEXP_REPLACE(REVERSE(ic.call_number_norm),'^[\w\-\.\/\'']*\s', '')))
	--mp3
	WHEN ic.call_number_norm ~ 'mp3' THEN BTRIM(REVERSE(REGEXP_REPLACE(REVERSE(ic.call_number_norm),'^[\w\-\.\/\'']*\s', '')))
	--leftover number suffixes
   WHEN ic.call_number_norm ~ '\d' THEN BTRIM(REVERSE(REGEXP_REPLACE(REVERSE(REGEXP_REPLACE(ic.call_number_norm,'\d\w*','')),'^[\w\-\.\/\'']*\s', '')))
	ELSE 'unknown'
END,'unknown') AS call_number_range,
COUNT (i.id) AS "Item total",
SUM(i.checkout_total) AS "Total_Checkouts",
SUM(i.renewal_total) AS "Total_Renewals",
SUM(i.checkout_total) + SUM(i.renewal_total) AS "Total_Circulation",
ROUND(AVG(i.price) FILTER(WHERE i.price>'0' AND i.price <'10000'),2)::MONEY AS "AVG_price",
COUNT(i.id) FILTER(WHERE c.id IS NOT NULL) AS "total_checked_out",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE c.id IS NOT NULL) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_checked_out",
COUNT (i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '1 year')) AS "have_circed_within_1_year",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '1 year')) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_1_year",
COUNT (i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '3 years')) AS "have_circed_within_3_years",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '3 years')) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_3_years",
COUNT (i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '5 years')) AS "have_circed_within_5_years",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '5 years')) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_5_years",
COUNT (i.id) FILTER(WHERE i.last_checkout_gmt is not null) AS "have_circed_within_5+_years",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE i.last_checkout_gmt is not null) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_5+_years",
COUNT (i.id) FILTER(WHERE i.last_checkout_gmt is null) AS "0_circs",
ROUND(100.0 * (CAST(COUNT(i.id) FILTER(WHERE i.last_checkout_gmt is null) AS NUMERIC (12,2)) / CAST(COUNT (i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_0_circs",
ROUND((COUNT(i.id) *(AVG(i.price) FILTER(WHERE i.price>'0' AND i.price <'10000'))/(NULLIF((SUM(i.checkout_total) + SUM(i.renewal_total)),0))),2)::MONEY AS "Cost_Per_Circ_By_AVG_price",
round(cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2))/cast(COUNT (i.id) as numeric (12,2)), 2) as turnover,
round(100.0 * (cast(COUNT(i.id) as numeric (12,2)) / (select cast(COUNT (i.id) as numeric (12,2))from sierra_view.item_record i WHERE i.location_code ~ '^ntn' AND i.item_status_code not in ('w','m','$'))), 6)||'%' as relative_item_total,
round(100.0 * (cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2)) / (SELECT cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2)) from sierra_view.item_record i WHERE i.location_code ~ '^ntn' AND i.item_status_code NOT IN ('w','m','$'))), 6)||'%' as relative_circ
FROM
sierra_view.item_record i
JOIN
call_number_mod ic
ON
i.id = ic.item_record_id
JOIN
sierra_view.item_record_property ip
ON
i.id = ip.item_record_id
JOIN
sierra_view.bib_record_item_record_link l
ON
i.id = l.item_record_id
JOIN sierra_view.bib_record b
ON
l.bib_record_id = b.id
LEFT JOIN
sierra_view.checkout c
ON
i.id = c.item_record_id
JOIN
sierra_view.material_property_myuser m
ON
b.bcode2 = m.code
JOIN
sierra_view.itype_property_myuser it
ON
i.itype_code_num = it.code
LEFT JOIN
sierra_view.language_property_myuser LN
ON
b.language_code = ln.code
WHERE location_code ~ '^act'
--location will take the form ^oln, which in this example looks for all locations starting with the string oln.
AND item_status_code NOT IN ('w','m','$')
GROUP BY 1
ORDER BY 1;