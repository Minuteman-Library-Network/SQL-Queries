WITH topic_list AS (SELECT
i.id,
i.checkout_total,
i.renewal_total,
i.price,
i.last_checkin_gmt,
CASE
	WHEN REPLACE(d.index_entry,'.','') ~ '(sexual minorities)|(gender)|(aesexual)|(bisexual)|(gay)|(intersex)|(homosexual)|(lesbian)|(stonewall riots)|(masculinity)|(femininity)' THEN 'LGBTQIA+ & Gender Studies'
	WHEN REPLACE(d.index_entry,'.','') ~ '(south asia)|(indic)|(pakistan)|(\yindia\y)|(bengali)|(afghan(?!\swar))|(bangladesh)|(nepal)|(sri lanka)|(bhutan)' THEN 'South Asian'
	WHEN REPLACE(d.index_entry,'.','') ~ '(east asia)|(asian americans)|(chin(a|ese))|(japan)|(korea)|(taiwan)|(vietnam)|(cambodia)|(mongolia)|(lao(s|tian))|(myanmar)|(malay)|(thai)|(philippin)|(indonesia)|(polynesia)|(brunei)|(east timor)|(pacific island)|(tibet autonomous)' THEN 'East Asian & Pacific Islander'
	WHEN REPLACE(d.index_entry,'.','') ~ '(gamblers)|(drug use)|(drug abuse)|(substance abuse)|(alcoholi)|(addiction)' THEN 'Substance Abuse & Addiction'
	WHEN REPLACE(d.index_entry,'.','') ~ '(bullying)|(aggressiveness)|(abuse)|(violent crimes)|(violence)|(violence against)' THEN 'Abuse & Violence'
	WHEN REPLACE(d.index_entry,'.','') ~ '(indigenous)|(aboriginal)|((?<!east\s)\yindians(?!\sbaseball))|(apache)|(cherokee)|(navajo)|(trail of tears)|(aztecs)|(indian art)|(maya(s|n))|(ojibwa)|(iroquois)|(nez perce)|(shoshoni)|(pueblo indian)|(seminole)|(eskimos)|(inuit)|(inca(s|n))|(algonquia?n)' THEN 'Indigenous'
	WHEN REPLACE(d.index_entry,'.','') ~ '(hispanic)|(mexican)|(latin american)|(cuban(?!\smissile))|(puerto rican)|(dominican)|(salvadoran)' THEN 'Hispanic & Latino'
	WHEN REPLACE(d.index_entry,'.','') ~ '(multicultural)|(cross cultural)|(diasporas)|(minorities)|(ethnic identity)|((race|ethnic) relations)|(racially mixed)|(bilingual)' THEN 'Multicultural'
	WHEN REPLACE(d.index_entry,'.','') ~ '(arab)|(middle east)|(palestin)|(bedouin)|(israel)|(saudi)|(yemen)|(iraq)|(iran)|(egypt)|(leban(an|ese))|(qatar)|(syria)|(turkey\y)' THEN 'Arab & Middle Eastern'
	WHEN REPLACE(d.index_entry,'.','') ~ '(equality)|(immigra)|(feminis)|(womens rights)|(sexism)|(racism)|(suffrag)|(sex role)|(social (change)|(justice)|(movements)|(problems)|(reformers)|(responsibilit))|(sustainable development)|(environmental)|(poverty)|(abortion)|((human|civil) rights)|(prejudice)|(protest movements)|(homeless)|(public (health|welfare))|(discrimination)|(refugee)' THEN 'Equity & Social Issues'
	WHEN REPLACE(d.index_entry,'.','') ~ '(disabilit)|(blind)|(deaf)|(terminally ill)|(amputees)|(patients)' THEN 'Disabilities & Special Needs'
   WHEN REPLACE(d.index_entry,'.','') ~ '(acceptance)|(personality disorder)|(autis(m|tic))|(anxiety)|(aspergers)|(compulsive disorder)|(schizophrenia)|(eating disorders)|(learning disabilit)|(mental (health)|(disabilit)|(illness))|(resilience personality)|(suicid)|(intellectual disability)|(self (esteem|confidence|acceptance))|(emotional problems)|(depressi)|(stress (psychology|disorder|psychology))' THEN 'Mental & Emotional Health'
	WHEN REPLACE(d.index_entry,'.','') ~ '(african american)|(africans)|(harlem renaissance)|(abolition)|(segregation)|(slavery)|(underground railroad)|(apartheid)' THEN 'Black'
	WHEN REPLACE(d.index_entry,'.','') ~ '(working class)|(social mobility)|(standard of living)|(social classes)|(poor)|(\ycaste\y)|(social stratification)|(classism)' THEN 'Class'
	--still unsure how to handle religion as a category and exploring options...Christianity is not particularly a diverse category but its also a nice basis for comparison
	--investigate buddhism, hinduism, agnosticism?
	WHEN REPLACE(d.index_entry,'.','') ~ '(protestant)|(bible)|(nativity)|(adventis)|(mormon)|(baptist)|(catholic)|(methodis)|(pentecost)|(episcopal)|(lutheran)|(clergy)|(church)|(evangelicalism)|(christianity)|(easter)|(christmas)' THEN 'Christianity'
	WHEN REPLACE(d.index_entry,'.','') ~ '(jews)|(judaism)|(hanukkah)|(purim)|(passover)|(zionism)|(hasidism)|(antisemitism)|(rosh hashanah)|(yom kippur)|(sabbath)|(sukkot)|(pentateuch)|(synagogue)' THEN 'Judaism'
	WHEN REPLACE(d.index_entry,'.','') ~ '((?<!terrorism.*)islam(?!(ic fundamentalism|\sterrorism)))|(\ysufi(sm)?)|(ramadan)|(id al fitr)|(quran)|(sunnites)|(shiah)|(muslim)|(mosques)|(qawwali)' THEN 'Islam'
	WHEN REPLACE(d.index_entry,'.','') ~ '(\yzen\y)|(dalai lama)|(buddhis)' THEN 'Buddhism'
	WHEN REPLACE(d.index_entry,'.','') ~ '(\yhindu(?!(stan|\skush)))|(divali)|(\yholi\y)|(bhagavadgita)|(upanishads)' THEN 'Hinduism'
	WHEN REPLACE(d.index_entry,'.','') ~ '(agnosticism)|(atheism)|(secularism)' THEN 'Angosticism & Atheism'
END AS topic

FROM
sierra_view.item_record i
JOIN
sierra_view.bib_record_item_record_link l
ON
i.id = l.item_record_id
JOIN
sierra_view.phrase_entry d
ON
l.bib_record_id = d.record_id AND d.index_tag = 'd'

WHERE i.location_code ~ '^wlm'
GROUP BY 1,2,3,4,5,6)

SELECT *

FROM
(SELECT
CASE
	WHEN t.topic IS NOT NULL THEN t.topic
	ELSE 'None of the Above'
END AS topic,
COUNT (DISTINCT i.id) AS "Item total",
SUM(i.checkout_total) AS "Total_Checkouts",
SUM(i.renewal_total) AS "Total_Renewals",
SUM(i.checkout_total) + SUM(i.renewal_total) AS "Total_Circulation",
ROUND(AVG(i.price) FILTER(WHERE i.price>'0' AND i.price <'10000'),2)::MONEY AS "AVG_price",
COUNT(DISTINCT i.id) FILTER(WHERE c.id IS NOT NULL) AS "total_checked_out",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE c.id IS NOT NULL) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_checked_out",
COUNT (DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '1 year')) AS "have_circed_within_1_year",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '1 year')) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_1_year",
COUNT (DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '3 years')) AS "have_circed_within_3_years",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '3 years')) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_3_years",
COUNT (DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '5 years')) AS "have_circed_within_5_years",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt >= (localtimestamp - interval '5 years')) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_5_years",
COUNT (DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt is not null) AS "have_circed_within_5+_years",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt is not null) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_5+_years",
COUNT (DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt is null) AS "0_circs",
ROUND(100.0 * (CAST(COUNT(DISTINCT i.id) FILTER(WHERE i.last_checkout_gmt is null) AS NUMERIC (12,2)) / CAST(COUNT (DISTINCT i.id) AS NUMERIC (12,2))), 4)||'%' AS "Percentage_0_circs",
ROUND((COUNT(DISTINCT i.id) *(AVG(i.price) FILTER(WHERE i.price>'0' AND i.price <'10000'))/(NULLIF((SUM(i.checkout_total) + SUM(i.renewal_total)),0))),2)::MONEY AS "Cost_Per_Circ_By_AVG_price",
round(cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2))/cast(COUNT (i.id) as numeric (12,2)), 2) as turnover,
round(100.0 * (cast(COUNT(DISTINCT i.id) as numeric (12,2)) / (select cast(COUNT (DISTINCT i.id) as numeric (12,2))from sierra_view.item_record i WHERE i.location_code ~ '^wlm')), 6)||'%' as relative_item_total,
round(100.0 * (cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2)) / (SELECT cast(SUM(i.checkout_total) + SUM(i.renewal_total) as numeric (12,2)) from sierra_view.item_record i WHERE i.location_code ~ '^wlm')), 6)||'%' as relative_circ


FROM
sierra_view.item_record i
LEFT JOIN
topic_list t
ON
i.id = t.id AND i.location_code ~ '^wlm'
JOIN
sierra_view.bib_record_item_record_link l
ON
i.id = l.item_record_id
LEFT JOIN
sierra_view.checkout c
ON
i.id = c.item_record_id

GROUP BY 1)a

ORDER BY CASE
	WHEN topic = 'None of the Above' THEN 2
	ELSE 1
END,topic