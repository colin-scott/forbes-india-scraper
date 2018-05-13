To run SQL queries, download the `q' tool:

```
curl 'https://raw.githubusercontent.com/harelba/q/1.7.1/bin/q' > q
chmod u+x q
```

Example queries:

### Sum up revenue of top 1000 companies
```
./q -H -d ',' "SELECT SUM(RevenueRsCrore) FROM companies.csv"
```

### Sum up revenue of from companies in the "media & entertainment" industry
```
./q -H -d ',' "SELECT SUM(RevenueRsCrore) FROM companies.csv WHERE Industry = 'media & entertainment'"
```

### Read a complex query from a file:

What are the largest industries in aggregate?

```
./q -H -d ',' -q multilinequery.sql
```
