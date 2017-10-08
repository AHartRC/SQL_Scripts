USE RawCensusData
GO

SELECT SUM([Occurrances])
FROM	(SELECT	A.name AS [Schema],
				C.name AS [Column],
				COUNT(0) AS [Occurrances]
		FROM	sys.schemas A
		INNER JOIN	sys.tables B
			ON	B.[schema_id] = A.[schema_id]
		INNER JOIN	sys.all_columns C
			ON C.[object_id] = B.[object_id]
		--WHERE	A.name IN ('SummaryOne', 'SummaryTwo')
		GROUP BY A.name, C.name) AS Query


SELECT	A.name AS [Schema], 
		C.name AS [Column],
		COUNT(0) AS [Occurrances]
FROM	sys.schemas A
INNER JOIN	sys.tables B
	ON	B.[schema_id] = A.[schema_id]
INNER JOIN	sys.all_columns C
	ON C.[object_id] = B.[object_id]
--WHERE	A.name IN ('SummaryOne', 'SummaryTwo')
GROUP BY A.name, C.name
ORDER BY [Schema], COUNT(0) DESC