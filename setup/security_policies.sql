-- 1. Create a function for Row-Level Security
-- This ensures only specific groups can see specific category data
CREATE OR REPLACE FUNCTION workspace.dev_silver_layer.category_filter(category STRING)
RETURN is_account_group_member('regional_managers') OR category IS NOT NULL;

-- 2. Apply the Row Filter to your Silver Table
ALTER TABLE workspace.dev_silver_layer.events_cleaned 
SET ROW FILTER workspace.dev_silver_layer.category_filter ON (category_code);

-- 3. Create a Masking Function for Column-Level Security
-- This masks the user_id for anyone who isn't an admin
CREATE OR REPLACE FUNCTION workspace.dev_silver_layer.user_id_mask(user_id STRING)
RETURN CASE WHEN is_account_group_member('admin') THEN user_id ELSE '####-REDACTED-####' END;

-- 4. Apply the Mask to the user_id column
ALTER TABLE workspace.dev_silver_layer.events_cleaned 
ALTER COLUMN user_id SET MASK workspace.dev_silver_layer.user_id_mask;