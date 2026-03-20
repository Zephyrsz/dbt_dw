with source as (
    select * from {{ source('raw', 'project_user_counts') }}
),
renamed as (
    select
        cast(project_id as integer) as project_id,
        cast(user_count as integer) as user_count
    from source
)
select * from renamed
