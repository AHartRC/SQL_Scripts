USE Hartography
GO

SELECT ROW_NUMBER() OVER(PARTITION BY A.StateId ORDER BY SalaryPerCapita DESC) AS [Rank],
		B.Name AS [State],
		C.Name AS [County],
		D.Name AS [City],
		TotalReturns,
		TotalSalary,
		TotalAGI,
		SalaryPerCapita,
		AGIPerCapita
INTO #TaxInfo
FROM (SELECT	StateId,
				CountyId,
				CityId,
				SUM(CONVERT(DECIMAL, N1)) AS TotalReturns,
				SUM(CONVERT(DECIMAL, A00200)) AS TotalSalary,
				SUM(CONVERT(DECIMAL, A00100)) AS TotalAGI,
				SUM(CONVERT(DECIMAL, A00200)) / SUM(CONVERT(DECIMAL, N1)) AS SalaryPerCapita,
				SUM(CONVERT(DECIMAL, A00100)) / SUM(CONVERT(DECIMAL, N1)) AS AGIPerCapita
		FROM SOITaxInfo
		GROUP BY StateId, CountyId, CityId) A
INNER JOIN [State] B
ON B.Id = A.StateId
INNER JOIN [County] C
ON C.Id = A.CountyId AND C.StateId = A.StateId
INNER JOIN [City] D
ON D.Id = A.CityId AND D.StateId = A.StateId AND D.CountyId = A.CountyId
ORDER BY A.StateId
GO

SELECT * FROM #TaxInfo WHERE [Rank] <= 50

DROP TABLE #TaxInfo
GO