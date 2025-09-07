-- Data cleaning

SHOW DATABASES;
USE world_layoffs;
SHOW TABLES;
RENAME TABLE `layoffs(1)` TO layoffs;
USE world_layoffs;
SHOW TABLES;
RENAME TABLE `layoffs (1)` TO layoffs;
select *
from layoffs;

-- 1.Remove Duplicates
-- 2.standardize the data
-- 3. Null values or blank values
-- 4.remove any columns


CREATE Table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

select *,
ROW_NUMBER() over(partition by company,industry,total_laid_off,percentage_laid_off,'date')
As row_num
from layoffs_staging;

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
                            stage, country, funds_raised_millions
               ORDER BY id
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


select *
from layoffs_staging
where company ='Casper';

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
                            stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
select *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2`(
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

Insert Into layoffs_staging2
 SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
                            stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging;
  
SET SQL_SAFE_UPDATES = 0;

delete 
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;


-- Standardizing data
-- Standardizing databases

select company,(Trim(company))
from layoffs_staging2;

Update layoffs_staging2
set company= Trim(company);

select *
from layoffs_staging2
where industry like 'Crypto%';

Update layoffs_staging2
set industry='Crypto'
where industry like 'Crypto%';

select distinct industry
from layoffs_staging2;

select Distinct country
from layoffs_staging2
where country like 'United states%'
order by 1;

select distinct country, Trim(Trailing '.' From Country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country='United States'
where country like 'United States%';

select Distinct country
from layoffs_staging2
order by 1;

select `date`,
str_to_date(`date`,'%m/%d/%Y') 
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y') ;

select `date`
from layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` Date;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_staging2
set industry= null
where industry ='';

select *
from layoffs_staging2
where industry is null
or industry ='';

select *
from layoffs_staging2
where company ='Airbnb';

select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
   
where (t1.industry is null or t1.industry ='')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;








