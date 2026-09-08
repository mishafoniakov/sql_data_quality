-- depends_on: {{ ref('lab_passports') }}
-- depends_on: {{ ref('lab_ids') }}

{{ config(materialized='table') }}

{% call statement('lab_id_for_loops', fetch_result=False) %}
do $match$
declare
  item RECORD;
  lab RECORD;
begin
  drop table if exists {{ this.schema }}.item_lab_map;
  create table {{ this.schema }}.item_lab_map (
    item_id varchar,
    passport_id varchar,
    lab_id varchar,
    lab_id_add_1 varchar,
    lab_id_add_2 varchar,
    lab_id_add_3 varchar,
    item_type int
  );
  alter table {{ this.schema }}.item_lab_map add constraint unique_item_id UNIQUE (item_id);
  ALTER TABLE {{ this.schema }}.item_lab_map ADD CONSTRAINT unique_lab_id UNIQUE (lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3);
  for item in select * from {{ ref('lab_passports') }} loop
    for lab in select * from {{ ref('lab_ids') }} loop
      if (item.item_type = lab.item_type and item.start_date = lab.lab_date) and
        (coalesce(item.id_main, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL))) then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;
for item in select * from {{ ref('lab_passports') }} where item_id not in (select item_id from {{ this.schema }}.item_lab_map) loop
    for lab in select * from {{ ref('lab_ids') }} where lab_id not in (select lab_id from {{ this.schema }}.item_lab_map) loop
      if (item.item_type = lab.item_type and item.start_date = lab.lab_date) and
         (coalesce(item.id_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_5, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_6, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_7, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_8, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_9, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL))) then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;

for item in select * from {{ ref('lab_passports') }} where item_id not in (select item_id from {{ this.schema }}.item_lab_map) loop
    for lab in select * from {{ ref('lab_ids') }} where lab_id not in (select lab_id from {{ this.schema }}.item_lab_map) loop
      if (item.item_type = lab.item_type) and
        (coalesce(item.id_main, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_5, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_6, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_7, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_8, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_9, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL))) then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;
for item in select * from {{ ref('lab_passports') }} where item_id not in (select item_id from {{ this.schema }}.item_lab_map) loop
    for lab in select * from {{ ref('lab_ids') }} where lab_id not in (select lab_id from {{ this.schema }}.item_lab_map) loop
      if (coalesce(item.id_main, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_alt_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_1, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_2, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_3, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_4, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_5, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_6, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_7, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_8, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL)) or
		coalesce(item.id_extra_9, NULL) in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL))) then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;

for item in select * from {{ ref('lab_passports') }} where item_id not in (select item_id from {{ this.schema }}.item_lab_map) loop
    for lab in select * from {{ ref('lab_ids') }} where lab_id not in (select lab_id from {{ this.schema }}.item_lab_map) loop
      if (item.item_type = lab.item_type) and (coalesce(split_part(item.id_main, '/', 2), '') in (coalesce(lab.lab_id, NULL), coalesce(lab.lab_id_add_1, NULL), coalesce(lab.lab_id_add_2, NULL), coalesce(lab.lab_id_add_3, NULL))) then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;

for item in select * from {{ ref('lab_passports') }} where item_id not in (select item_id from {{ this.schema }}.item_lab_map) loop
    for lab in select * from {{ ref('lab_ids') }} where lab_id not in (select lab_id from {{ this.schema }}.item_lab_map) loop
      if (item.item_type = lab.item_type) and (lab.lab_id like '%' || item.id_main || '%') or
		(lab.lab_id_add_1 like '%' || item.id_main || '%') or
		(lab.lab_id_add_2 like '%' || item.id_main || '%') or
		(lab.lab_id_add_3 like '%' || item.id_main || '%') then
          insert into {{ this.schema }}.item_lab_map(item_id, passport_id, lab_id, lab_id_add_1, lab_id_add_2, lab_id_add_3, item_type)
            values (item.item_id, item.id_main, lab.lab_id, lab.lab_id_add_1, lab.lab_id_add_2, lab.lab_id_add_3, lab.item_type)
            ON CONFLICT DO NOTHING;
          exit;
      end if;
    end loop;
  end loop;

end $match$;
{% endcall %}

select * from {{ this.schema }}.item_lab_map
