WITH overdrive AS(SELECT
rm.record_type_code||rm.record_num AS record_number,
b.best_title_norm,
b.best_author_norm

FROM
sierra_view.record_metadata rm
JOIN
sierra_view.phrase_entry v
ON
rm.id = v.record_id AND rm.record_type_code = 'b' AND v.index_tag = 'i'
AND SUBSTRING(v.index_entry FROM '^[0-9]+')::NUMERIC IN (
'9780060735562',
'9780061972638',
'9780062107879',
'9780062200594',
'9780062200686',
'9780062237743',
'9780062249234',
'9780062259677',
'9780062292087',
'9780062331908',
'9780062351456',
'9780062363251',
'9780062498724',
'9780062570628',
'9780062666390',
'9780062676634',
'9780062679123',
'9780062679185',
'9780062682840',
'9780062694263',
'9780062822956',
'9780062849588',
'9780062912794',
'9780062956644',
'9780062975966',
'9780063015890',
'9780147525345',
'9780307266040',
'9780307351937',
'9780307388629',
'9780307414199',
'9780307414274',
'9780307575852',
'9780307575951',
'9780307596635',
'9780307756435',
'9780307888860',
'9780307940803',
'9780307940957',
'9780316135412',
'9780316137492',
'9780316146487',
'9780316167482',
'9780316254342',
'9780316298650',
'9780316445153',
'9780345516862',
'9780345532367',
'9780358237006',
'9780374314316',
'9780374719555',
'9780385360135',
'9780385528221',
'9780385528832',
'9780385528849',
'9780385528856',
'9780385528863',
'9780385533812',
'9780385535014',
'9780385538503',
'9780385538527',
'9780385542005',
'9780440000181',
'9780449807903',
'9780525515036',
'9780525526414',
'9780525531074',
'9780525566533',
'9780525577959',
'9780525595281',
'9780525595304',
'9780525595328',
'9780525620792',
'9780525636137',
'9780525638780',
'9780544445277',
'9780553418309',
'9780553418613',
'9780593098684',
'9780593099629',
'9780593113639',
'9780593156865',
'9780593165799',
'9780593168080',
'9780593211182',
'9780593213872',
'9780593292761',
'9780593402726',
'9780679604860',
'9780698157293',
'9780698198487',
'9780739346426',
'9780739346747',
'9780739353356',
'9780743563307',
'9780758289803',
'9780763661083',
'9780765386618',
'9780765395092',
'9780792776604',
'9780792788225',
'9780792789635',
'9780802195036',
'9780804152976',
'9780804165181',
'9780804165228',
'9780812995954',
'9780979074943',
'9781094136981',
'9781101052549',
'9781101530641',
'9781101530658',
'9781101662977',
'9781101871980',
'9781101928745',
'9781101976449',
'9781101980217',
'9781101989203',
'9781250017901',
'9781250113436',
'9781250204806',
'9781250222503',
'9781250230119',
'9781250249265',
'9781250317971',
'9781250767011',
'9781250780430',
'9781328699022',
'9781400126347',
'9781400128594',
'9781415961773',
'9781415965122',
'9781419748660',
'9781427244543',
'9781429956789',
'9781429957656',
'9781429957847',
'9781439116050',
'9781439168035',
'9781440620171',
'9781442369795',
'9781442372771',
'9781442384354',
'9781442465978',
'9781451627305',
'9781453213766',
'9781453231524',
'9781453278970',
'9781466856516',
'9781466864580',
'9781466866744',
'9781470345822',
'9781476710822',
'9781476717753',
'9781476727660',
'9781476770406',
'9781476794341',
'9781478931751',
'9781481526180',
'9781481540414',
'9781481550949',
'9781481552646',
'9781481553643',
'9781481554503',
'9781490658797',
'9781501104428',
'9781501111686',
'9781501141232',
'9781501141249',
'9781501141270',
'9781501141300',
'9781501141386',
'9781501163425',
'9781501176241',
'9781501181016',
'9781508217114',
'9781508218234',
'9781508218289',
'9781508226635',
'9781508238133',
'9781508252221',
'9781508254508',
'9781508265436',
'9781508297475',
'9781512401097',
'9781520073996',
'9781524703660',
'9781524705282',
'9781524722562',
'9781524745189',
'9781524761004',
'9781524781651',
'9781534429581',
'9781534451148',
'9781538716762',
'9781549147333',
'9781549154072',
'9781555979805',
'9781569479223',
'9781587676802',
'9781590516805',
'9781594747274',
'9781594748639',
'9781607013198',
'9781607888840',
'9781608142408',
'9781609415945',
'9781611208542',
'9781613124598',
'9781613126608',
'9781614239758',
'9781620111857',
'9781620112182',
'9781620114605',
'9781620115152',
'9781620116708',
'9781620117583',
'9781620117651',
'9781620117682',
'9781620117705',
'9781620125298',
'9781620125991',
'9781620128190',
'9781620130797',
'9781620130988',
'9781634210959',
'9781681686899',
'9781683691440',
'9781776597208',
'9781797105550',
'9781797121758',
'9781982136475',
'9781982137991',
'9781982153946',
'9781984825032',
'9781984826794'

)
JOIN
sierra_view.bib_record_property b
ON
rm.id = b.bib_record_id)

SELECT
MAX(rm.record_num) AS record_number,
b.best_title_norm,
SUBSTRING(b.best_author_norm,1,4)
FROM
sierra_view.bib_record_property b
JOIN
overdrive o
ON
--CASE
--	WHEN LENGTH(b.best_title_norm) < 20 THEN b.best_title_norm = o.best_title_norm 
--	ELSE 
SUBSTRING(b.best_title_norm,1,20) = SUBSTRING(o.best_title_norm,1,20)
--b.best_title_norm = o.best_title_norm 
AND SUBSTRING(b.best_author_norm,1,4) = SUBSTRING(o.best_author_norm,1,4) AND b.material_code = 'a'
JOIN
sierra_view.record_metadata rm
ON
b.bib_record_id = rm.id
GROUP BY 2,3