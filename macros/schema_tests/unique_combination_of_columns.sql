{% macro test_unique_combination_of_columns(model, quote_columns = false, condition = '1=1') %}
  {{ return(adapter.dispatch('test_unique_combination_of_columns', packages = dbt_utils._get_utils_namespaces())(model, quote_columns, **kwargs)) }}
{% endmacro %}

{% macro default__test_unique_combination_of_columns(model, quote_columns = false, condition = '1=1') %}

{%- set columns = kwargs.get('combination_of_columns', kwargs.get('arg')) %}

{% if not quote_columns %}
    {%- set column_list=columns %}
{% elif quote_columns %}
    {%- set column_list=[] %}
        {% for column in columns -%}
            {% set column_list = column_list.append( adapter.quote(column) ) %}
        {%- endfor %}
{% else %}
    {{ exceptions.raise_compiler_error(
        "`quote_columns` argument for unique_combination_of_columns test must be one of [True, False] Got: '" ~ quote ~"'.'"
    ) }}
{% endif %}

{%- set columns_csv=column_list | join(', ') %}


with validation_errors as (

    select
        {{ columns_csv }}
    from {{ model }}
    where {{ condition }}
    group by {{ columns_csv }}
    having count(*) > 1

)

select count(*)
from validation_errors


{% endmacro %}
