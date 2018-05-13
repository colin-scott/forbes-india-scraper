SELECT SUM(RevenueRsCrore), Industry, COUNT(*)
FROM companies.csv
GROUP BY Industry
ORDER BY SUM(RevenueRsCrore) DESC;
