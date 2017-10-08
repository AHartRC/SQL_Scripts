USE Geo
GO

--598579 Total
--18645 Unique

SELECT DISTINCT
		B.CountryCode,
		B.Code,
		B.SubCode,
		A.ChildSubCode,
		A.ChildName,
		A.ChildASCIIName
FROM	(SELECT	(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 0) AS ChildCountryCode,
				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 1) AS ChildCode,
				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 2) AS ChildSubCode,
				A.geonameId AS ChildGeonameId,
				A.name AS ChildName,
				A.asciiName AS ChildASCIIName
		FROM	Geoname.dbo.Admin2Code A) A
INNER JOIN	Admin1Code B
	ON		B.CountryCode = A.ChildCountryCode
	AND		B.Code = A.ChildCode
LEFT OUTER JOIN (SELECT	DISTINCT A.countryCode, A.admin1code, B.SubCode, A.admin1name, a.admin2code, a.admin2name
				FROM	Geoname.dbo.RawPostal A
				INNER JOIN Admin1Code B
				ON B.CountryCode = A.countryCode
				AND B.Code = A.admin1code
				WHERE A.admin2code IS NOT NULL AND A.admin2name IS NOT NULL) C
ON C.countryCode = A.ChildCountryCode
AND C.admin1code = A.ChildCode
AND C.SubCode = B.SubCode
ORDER BY B.CountryCode, B.Code, B.SubCode, A.ChildSubCode
GO

--SELECT	B.CountryCode,
--		B.Code,
--		B.SubCode,
--		A.ChildSubCode,
--		A.ChildName,
--		A.ChildASCIIName
--FROM	(SELECT	(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 0) AS ChildCountryCode,
--				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 1) AS ChildCode,
--				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 2) AS ChildSubCode,
--				A.geonameId AS ChildGeonameId,
--				A.name AS ChildName,
--				A.asciiName AS ChildASCIIName
--		FROM	Geoname.dbo.Admin2Code A) A
--INNER JOIN	Admin1Code B
--	ON		B.CountryCode = A.ChildCountryCode
--	AND		B.Code = A.ChildCode
--ORDER BY B.CountryCode, B.Code, B.SubCode, A.ChildSubCode