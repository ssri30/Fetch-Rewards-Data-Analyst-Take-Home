/* What are the top 5 brands by receipts scanned among users 21 and over?
*/

SELECT TOP 5 p.[BRAND],
COUNT(DISTINCT t.[RECEIPT_ID]) AS total_receipts
 from 
     [dbo].[USER] u
JOIN [dbo].[TRANSACTIONS] t ON u.[ID]=t.[USER_ID]
JOIN [dbo].[PRODUCTS] p ON t.[BARCODE]=p.[BARCODE]
WHERE CAST(DATEADD(yyyy,-21,getdate()) AS DATE)>=CAST(u.[BIRTH_DATE] AS DATE) /* filters the data for age 21 and over */
AND p.[BRAND] IS NOT NULL /* excluding the null values for Brand column */
group by p.[BRAND]
order by total_receipts DESC;



/* What is the percentage of sales in the Health & Wellness category by generation? 

source -https://www.parents.com/parenting/better-parenting/style/generation-names-and-years-a-cheat-sheet-for-parents/ 
I have grouped the birth year to gernation groups and used case statements to implement it
*/

SELECT
CASE 
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1901 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1927 THEN 'Greatest Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1928 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1945 THEN 'Silent Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1946 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1964 THEN 'Baby Boom Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1965 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1980 THEN 'Genernation X'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1981 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1996 THEN 'Millennial'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1997 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 2010 THEN 'Generation Z'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 2010 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 2024 THEN 'Generation Alpha'
ELSE 'Generation Beta'
END AS Generation

, COUNT([RECEIPT_ID])*100.0/
(SELECT COUNT([RECEIPT_ID]) FROM [dbo].[USER] u
JOIN [dbo].[TRANSACTIONS] t ON u.[ID]=t.[USER_ID]
JOIN [dbo].[PRODUCTS] p ON t.[BARCODE]=p.[BARCODE]
WHERE [CATEGORY_1] LIKE '%Health%Wellness%') AS 'Percentage of Sales'

FROM [dbo].[USER] u
JOIN [dbo].[TRANSACTIONS] t ON u.[ID]=t.[USER_ID]
JOIN [dbo].[PRODUCTS] p ON t.[BARCODE]=p.[BARCODE]
WHERE [CATEGORY_1] LIKE '%Health%Wellness%' 
GROUP BY 
CASE 
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1901 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1927 THEN 'Greatest Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1928 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1945 THEN 'Silent Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1946 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1964 THEN 'Baby Boom Generation'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1965 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1980 THEN 'Genernation X'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1981 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 1996 THEN 'Millennial'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 1997 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 2010 THEN 'Generation Z'
WHEN  YEAR(CAST(BIRTH_DATE AS DATE))>= 2010 AND YEAR(CAST(BIRTH_DATE AS DATE))<= 2024 THEN 'Generation Alpha'
ELSE 'Generation Beta'
END ;




/* Which is the leading brand in the Dips & Salsa category?  

I have assumed that all user_id listed in transcations table are valid users, when using join conditions with user table it filters out a lot of data from the transcations table . 
To avoid this scenario , for this query I chose to use join between product and transctions only. 
*/
WITH RankedBrands AS 
(
    SELECT 
        p.[BRAND] AS Brand_name,
        COUNT(DISTINCT t.[RECEIPT_ID]) AS total_receipts,  
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT t.[RECEIPT_ID]) DESC) as brand_rank
    FROM [dbo].[TRANSACTIONS] t 
    JOIN [dbo].[PRODUCTS] p ON t.[BARCODE]=p.[BARCODE]
    WHERE p.[CATEGORY_2] LIKE '%Dips%Salsa%'
    AND p.[BRAND] IS NOT NULL
    GROUP BY p.[BRAND]
)
SELECT 
    Brand_name, total_receipts
FROM RankedBrands
WHERE brand_rank =1;