/*Which are the most profitable surcharges?*/
SELECT 
	TaxID AS Surcharge
	, CAST(SUM(TaxAmt) AS Money) AS TotalSurchargeAmt
FROM ARInvoiceItemCompTax
WHERE CreatedBy = 'F'
GROUP BY TaxID
	HAVING SUM(TaxAmt) != 0
ORDER BY TotalSurchargeAmt DESC

/*Who are the most profitable freight customers?*/
SELECT TOP 50
	via.StandardAcctNo
	, CAST(SUM(arict.TaxAmt) AS Money) AS TotalSurchargeAmt 
FROM ARInvoiceItemCompTax arict
	JOIN vInvoiceAll via ON arict.SysTrxNo = via.SysTrxNo
GROUP BY via.StandardAcctNo
	HAVING SUM(arict.TaxAmt) != 0
ORDER BY TotalSurchargeAmt DESC

/*Which customers have the highest proportion of freight to total revenue?*/
SELECT TOP 50
	inv.StandardAcctNo
	, SUM(TotalFrtAmt) AS TotalFrtAmt
	, SUM(InvoiceTotal) AS InvoiceTotal
	, (SUM(TotalFrtAmt)/SUM(InvoiceTotal)) * 100 AS ProportionFrt
FROM vInvoiceAll inv
	JOIN ARStandardAcct asa ON inv.StandardAcctID = asa.StandardAcctID
WHERE asa.Active = 'Y'
GROUP BY inv.StandardAcctNo
	HAVING SUM(TotalFrtAmt) != 0
ORDER BY ProportionFrt DESC

/*Which counties have the highest freight per load in Indiana, Illinois, Kentucky, Tennessee, & Missouri?*/
SELECT
	sp.Code AS State
	, County.Code AS County
	, COUNT(via.SysTrxNo) as NumberofInvoices
	, CAST(SUM(arict.TaxAmt) AS Money) AS TotalSurchargeAmt
	, CAST(SUM(arict.TaxAmt)/COUNT(via.SysTrxNo) AS decimal(24,2)) AS FrtPerLoad
FROM ARInvoiceItemCompTax arict
	JOIN vInvoiceAll via ON arict.SysTrxNo = via.SysTrxNo
	JOIN ARShipToAddress on via.ShipToID = ARShipToAddress.ShipToID
	JOIN StateProv sp on ARShipToAddress.StateProvID = sp.ID
	JOIN County on ARShipToAddress.CountyID = County.ID
WHERE Status != 'A' 
	AND Status = 'C'
	AND sp.Code IN ('IN', 'IL', 'KY', 'TN', 'MO')
GROUP BY sp.Code, county.Code
	HAVING SUM(arict.TaxAmt) != 0
	AND COUNT(via.SysTrxNo) > 8
ORDER BY FrtPerLoad DESC