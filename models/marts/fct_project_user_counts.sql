with stg as (
    select * from {{ ref('stg_raw__project_user_counts') }}
)
select
    project_id,
    user_count,
    now() as _loaded_at
from stg
