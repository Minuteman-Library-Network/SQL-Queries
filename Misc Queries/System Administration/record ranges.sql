/*
Jeremy Goldstein
Minuteman Library Network

Record Ranges, reproduces Innopac report
*/

SELECT 
record_type_code,
accounting_unit_code_num,
start_num,
last,
current_count,
deleted_count,
max_num,
size

FROM
sierra_view.record_range

ORDER BY accounting_unit_code_num, record_type_code