\echo '=== START INIT SCRIPT 04_pg_db_out_owner.sql ==='

\echo '==============================';
\echo ' X1. CREATE SKILL AREA TABLES ';
\echo '==============================';

\echo '=================================';
\echo ' 1. CREATE TECHNOLOGY_TYPE_V TABLE ';
\echo '=================================';

DROP VIEW IF EXISTS db_out_owner.technology_type_v;

CREATE VIEW db_out_owner.technology_type_v AS
SELECT 
    technology_type_code,
    name,
    rating,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.technology_type;

\echo '==============================';
\echo ' 2. CREATE TECHNOLOGY_V TABLE ';
\echo '==============================';    

DROP VIEW IF EXISTS db_out_owner.technology_v;

CREATE VIEW db_out_owner.technology_v AS
SELECT 
    technology_code,
    name,
    release_date,
    creator,
    official_site,
    rating,
    description,
    sign_photo,
    technology_type_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.technology;

\echo '===========================';
\echo ' 3. CREATE VERSION_V TABLE ';
\echo '===========================';    

DROP VIEW IF EXISTS db_out_owner.version_v;

CREATE VIEW db_out_owner.version_v AS
SELECT 
    version_code,
    name,
    release_date,
    end_of_life,
    new_features,
    unsolved_problems,
    creator,
    developer_popularity,
    community_support,
    industry_usage_score,
    knowledge_score,
    skills_rating,
    rating,
    description,
    technology_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.version;

\echo '=========================';
\echo ' 4. CREATE SKILL_V TABLE ';
\echo '=========================';   

DROP VIEW IF EXISTS db_out_owner.skill_v;

CREATE VIEW db_out_owner.skill_v AS
SELECT 
    skill_code,
    name,
    prerequisite_knowledge,
    learning_difficulty,
    implementation_difficulty,
    cross_platform_applicability,
    rating,
    description,
    last_version_code,
    first_version_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.skill;

\echo '=========================================';
\echo ' 5. CREATE TECHNOLOGY_DEPENDENCY_V TABLE ';
\echo '=========================================';   

DROP VIEW IF EXISTS db_out_owner.technology_dependency_v;

CREATE VIEW db_out_owner.technology_dependency_v AS
SELECT 
    technology_dependency_code,
    source_type,
    source_id,
    target_type,
    target_id,
    relation,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.technology_dependency;

\echo '==============================';
\echo ' X2. CREATE USERS AREA TABLES ';
\echo '==============================';

\echo '========================';
\echo ' 6. CREATE ROLE_V TABLE ';
\echo '========================';

DROP VIEW IF EXISTS db_out_owner.role_v;

CREATE VIEW db_out_owner.role_v AS
SELECT 
    role_id,
    name,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.role;

\echo '============================';
\echo ' 7. CREATE LANGUAGE_V TABLE ';
\echo '============================';

DROP VIEW IF EXISTS db_out_owner.language_v;

CREATE VIEW db_out_owner.language_v AS
SELECT 
    lang_code,
    name,
    iso_code,
    no_native_speakers,
    no_speakers,
    no_countries,
    no_companies,
    rating,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.language;

\echo '==============================';
\echo ' 8. CREATE LANG_LEVEL_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.lang_level_v;

CREATE VIEW db_out_owner.lang_level_v AS
SELECT 
    lang_level_id,
    name,
    nivel,
    lang_code,
    validity_period,
    rating,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.lang_level;

\echo '=================================';
\echo ' X3. CREATE LOCATION AREA TABLES ';
\echo '=================================';

\echo '==========================';
\echo ' 9. CREATE REGION_V TABLE ';
\echo '==========================';

DROP VIEW IF EXISTS db_out_owner.region_v;

CREATE VIEW db_out_owner.region_v AS
SELECT 
    region_id,
    name,
    code,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.region;

\echo '================================';
\echo ' X4. CREATE COMPANY AREA TABLES ';
\echo '================================';

\echo '=============================';
\echo ' 10. CREATE CURRENCY_V TABLE ';
\echo '=============================';

DROP VIEW IF EXISTS db_out_owner.currency_v;

CREATE VIEW db_out_owner.currency_v AS
SELECT 
    currency_code,
    name,
    code,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.currency;

\echo '==================================';
\echo ' 11. CREATE CURRENCY_RATE_V TABLE ';
\echo '==================================';

DROP VIEW IF EXISTS db_out_owner.currency_rate_v;

CREATE VIEW db_out_owner.currency_rate_v AS
SELECT 
    currency_rate_id,
    rate_value,
    rate_type,
    from_currency_code,
    to_currency_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    source_system,
    sync_status,
    sync_version,
    last_synced_at,
    deleted_flag
FROM db_owner.currency_rate;

\echo '===========================';
\echo ' 12. CREATE COUNTRY_V TABLE  ';
\echo '===========================';

DROP VIEW IF EXISTS db_out_owner.country_v;

CREATE VIEW db_out_owner.country_v AS
SELECT 
country_id,
name,
code,
population,
area,
time_zone,
unemployment_rate,
inflation_rate,
average_monthly_salary,
corporate_tax_rate,
rating,
region_id,
official_lang_code,
currency_code,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.country;

\echo '==============================================';
\echo ' 13. CREATE ADMINISTRATIVE_UNIT_TYPE_V TABLE  ';
\echo '==============================================';

DROP VIEW IF EXISTS db_out_owner.administrative_unit_type_v;

CREATE VIEW db_out_owner.administrative_unit_type_v AS
SELECT 
administrative_unit_type_id,
name,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.administrative_unit_type;

\echo '=========================================';
\echo ' 14. CREATE ADMINISTRATIVE_UNIT_V TABLE  ';
\echo '=========================================';

DROP VIEW IF EXISTS db_out_owner.administrative_unit_v;

CREATE VIEW db_out_owner.administrative_unit_v AS
SELECT 
administrative_unit_id,
name,
code,
population,
area,
no_cities,
description,
administrative_unit_type_id,
country_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.administrative_unit;

\echo '==========================';
\echo ' 15. CREATE CITY_V TABLE  ';
\echo '==========================';

DROP VIEW IF EXISTS db_out_owner.city_v;

CREATE VIEW db_out_owner.city_v AS
SELECT 
city_code,
name,
population,
area,
is_capital,
latitude,
longitude,
description,
administrative_unit_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.city;

\echo '===========================';
\echo ' 16. CREATE LOCATION TABLE ';
\echo '===========================';

DROP VIEW IF EXISTS db_out_owner.location_v;

CREATE VIEW db_out_owner.location_v AS
SELECT 
location_id,
street_name,
street_number,
postal_code,
building,
staircase,
floor, 
appartment_number,
city_code,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.location;

\echo '================================';
\echo ' 17. CREATE INSTITUTION_V TABLE ';
\echo '================================';

DROP VIEW IF EXISTS db_out_owner.institution_v;

CREATE VIEW db_out_owner.institution_v AS
SELECT 
institution_id,
name,
website,
founding_year,
rating,
profile_picture,
description, 
location_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.institution;

\echo '========================================';
\echo ' 18. CREATE SPECIALIZATION_TYPE_V TABLE ';
\echo '========================================';

DROP VIEW IF EXISTS db_out_owner.specialization_type_v;

CREATE VIEW db_out_owner.specialization_type_v AS
SELECT 
specialization_type_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.specialization_type;

\echo '===================================';
\echo ' 19. CREATE SPECIALIZATION_V TABLE ';
\echo '===================================';

DROP VIEW IF EXISTS db_out_owner.specialization_v;

CREATE VIEW db_out_owner.specialization_v AS
SELECT 
specialization_id,
name,
degree_type,
employment_rate,
teachers_feedback,
courses_feedback,
entry_difficulty,
graduation_difficulty,
industry_reputation,
rating,
description,
institution_id,
specialization_type_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.specialization;

\echo '================================';
\echo ' 20. CREATE UTILIZATORI_V TABLE ';
\echo '================================';

DROP VIEW IF EXISTS db_out_owner.utilizatori_v;

CREATE VIEW db_out_owner.utilizatori_v AS
SELECT 
user_id,              
email,               
first_name,          
last_name,           
user_name,            
app_email,             
password,	            
date_of_birth,	       
phone,	              
gender,	            
profile_image,        
profile_document,     
account_status,	    
profile_approved_flag, 
report_sent_flag,	    
report_document,      
native_lang_code,	  
supervizor_id,	       
location_id,           
role_id,           
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.utilizatori;

\echo '==========================';
\echo ' 21. CREATE EMAIL_V TABLE ';
\echo '==========================';

DROP VIEW IF EXISTS db_out_owner.email_v;

CREATE VIEW db_out_owner.email_v AS
SELECT 
email_code,
subject,
content,
arrival_time,
importance,
reply_to_email,
receiver,
sender,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.email;

\echo '==============================';
\echo ' 22. CREATE USER_SPEC_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.user_spec_v;

CREATE VIEW db_out_owner.user_spec_v AS
SELECT 
specialization_id,
user_id,
graduation_date,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.user_spec;

\echo '===============================';
\echo ' 23. CREATE USER_LEVEL_V TABLE ';
\echo '===============================';

DROP VIEW IF EXISTS db_out_owner.user_level_v;

CREATE VIEW db_out_owner.user_level_v AS
SELECT 
user_id,
lang_level_id,
obtained_date, 
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.user_level;

\echo '===============================';
\echo ' 24. CREATE USER_SKILL_V TABLE ';
\echo '===============================';

DROP VIEW IF EXISTS db_out_owner.user_skill_v;

CREATE VIEW db_out_owner.user_skill_v AS
SELECT 
user_id,
skill_code,
proficiency_level,
experience_months,
last_used_date,
confidence_score,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.user_skill;


\echo '====================================';
\echo ' 25. CREATE ORGANIZATION_TYPE TABLE ';
\echo '====================================';

DROP VIEW IF EXISTS db_out_owner.organization_type_v;

CREATE VIEW db_out_owner.organization_type_v AS
SELECT 
company_type_id,
name,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.organization_type;

\echo '==================================';
\echo ' 26. CREATE INDUSTRY_TYPE_V TABLE ';
\echo '==================================';

DROP VIEW IF EXISTS db_out_owner.industry_type_v;

CREATE VIEW db_out_owner.industry_type_v AS
SELECT 
industry_type_id,
name,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.industry_type;


\echo '====================================';
\echo ' 27. CREATE DEPARTMENT_TYPE_V TABLE ';
\echo '====================================';

DROP VIEW IF EXISTS db_out_owner.department_type_v;

CREATE VIEW db_out_owner.department_type_v AS
SELECT 
department_type_id,
name,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.department_type;

\echo '====================================';
\echo ' 28. CREATE EMPLOYMENT_TYPE_V TABLE ';
\echo '====================================';

DROP VIEW IF EXISTS db_out_owner.employment_type_v;

CREATE VIEW db_out_owner.employment_type_v AS
SELECT 
employment_type_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.employment_type;

\echo '==============================';
\echo ' 29. CREATE WORK_TYPE_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.work_type_v;

CREATE VIEW db_out_owner.work_type_v AS
SELECT 
work_type_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.work_type;

\echo '=================================';
\echo ' 30. CREATE JOB_CATEGORY_V TABLE ';
\echo '=================================';

DROP VIEW IF EXISTS db_out_owner.job_category_v;

CREATE VIEW db_out_owner.job_category_v AS
SELECT 
job_category_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_category;

\echo '==============================';
\echo ' 31. CREATE JOB_TITLE_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.job_title_v;

CREATE VIEW db_out_owner.job_title_v AS
SELECT 
job_title_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_title;

\echo '==============================';
\echo ' 32. CREATE JOB_LEVEL_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.job_level_v;

CREATE VIEW db_out_owner.job_level_v AS
SELECT 
job_level_id,
name,
complexity_score,
code,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_level;

\echo '============================';
\echo ' 33. CREATE COMPANY_V TABLE ';
\echo '============================';

DROP VIEW IF EXISTS db_out_owner.company_v;

CREATE VIEW db_out_owner.company_v AS
SELECT 
company_id,
legal_entity_identifier,
name,
trade_register_number,
website,
foundation_date,
no_employees,
description,
sign_image,
profile_image,
share_capital,
net_profit,
average_annual_revenue,
total_assets,
total_liabilities,
debt_to_equity_ratio,
rating,
user_id,
user_email,
industry_type_id,
company_type_id,
company_location_id,
currency_code,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.company;

\echo '===============================';
\echo ' 34. CREATE DEPARTMENT_V TABLE ';
\echo '===============================';

DROP VIEW IF EXISTS db_out_owner.department_v;

CREATE VIEW db_out_owner.department_v AS
SELECT 
department_id,
description,
annual_budget,
operational_costs,
expenses,
revenue_generated,
no_employees,
avg_salary,
growth_potential,
training_budget,
no_open_positions,
turnover_rate,
rating,
company_id,
department_type_code,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.department;

\echo '========================';
\echo ' 35. CREATE JOB_V TABLE ';
\echo '========================';

DROP VIEW IF EXISTS db_out_owner.job_v;

CREATE VIEW db_out_owner.job_v AS
SELECT 
job_id,
description,
requirements,
responsabilities,
benefits,
salary_min,
salary_max,
hire_date,
expiry_date,
employment_period,
demand_score,
employees_rating,
job_status,
department_id,
employment_type_id,
work_type_id,
job_title_id,
job_level_id,
job_category_id,
currency_code,
location_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job;

\echo '========================================';
\echo ' 36. CREATE DEGREE_REQUIREMENTS_V TABLE ';
\echo '========================================';

DROP VIEW IF EXISTS db_out_owner.degree_requirement_v;

CREATE VIEW db_out_owner.degree_requirement_v AS
SELECT 
degree_requirement_code,
priority,
degree_type,
graduation_required,
description,
job_id,
specialization_type_code,
institution_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.degree_requirement;

\echo '==========================================';
\echo ' 37. CREATE LANGUAGE_REQUIREMENTS_V TABLE ';
\echo '==========================================';

DROP VIEW IF EXISTS db_out_owner.language_requirement_v;

CREATE VIEW db_out_owner.language_requirement_v AS
SELECT 
language_requirement_id,
priority,
importance,
nivel,
certification_required,
description,
job_id,
lang_code,
lang_level_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.language_requirement;

\echo '==============================';
\echo ' 38. CREATE JOB_SKILL_V TABLE ';
\echo '==============================';

DROP VIEW IF EXISTS db_out_owner.job_skill_v;

CREATE VIEW db_out_owner.job_skill_v AS
SELECT 
skill_code,
job_id,
required_level,
importance_weight,
is_mandatory,
min_experience_months,
max_months_since_used,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_skill;

\echo '====================================';
\echo ' 39. CREATE JOB_APPLICATION_V TABLE ';
\echo '====================================';

DROP VIEW IF EXISTS db_out_owner.job_application_v;

CREATE VIEW db_out_owner.job_application_v AS
SELECT 
application_id,
apply_date,
apply_source,
status,
salary,
user_id,
job_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_application;

\echo '================================';
\echo ' 40. CREATE JOB_HISTORY_V TABLE ';
\echo '================================';

DROP VIEW IF EXISTS db_out_owner.job_history_v;

CREATE VIEW db_out_owner.job_history_v AS
SELECT 
job_history_id,
start_date,
end_date,
salary,
user_id,
job_id,
application_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.job_history;


\echo '===========================';
\echo ' 41. CREATE REVIEW_V TABLE ';
\echo '===========================';

DROP VIEW IF EXISTS db_out_owner.review_v;

CREATE VIEW db_out_owner.review_v AS
SELECT 
review_id,
title, 
review_type,
description,
rating_overall,
work_rating,
salary_rating,
manager_rating,
team_rating,
would_recommend,
is_anonymous,
is_verified,
job_id,
user_id,
job_history_id,
application_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM db_owner.review;
\echo '=== END INIT SCRIPT 04_pg_db_out_owner.sql ==='