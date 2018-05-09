# Sum up revenue of top 1000 companies
./q -H -d ',' "SELECT SUM(RevenueRsCrore) FROM companies.csv"

# Sum up revenue of from companies in the "media & entertainment" industry
./q -H -d ',' "SELECT SUM(RevenueRsCrore) FROM companies.csv WHERE Industry = 'media & entertainment'"
