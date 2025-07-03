use Chinook

-- Consultas basicas

-- Top 5 canciones más vendidas
SELECT TOP 5 
    t.Name AS Cancion, 
    COUNT(*) AS VecesVendida
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.Name
ORDER BY VecesVendida DESC;

-- Clientes que más gastaron (Top clientes)
SELECT TOP 5 
    c.FirstName + ' ' + c.LastName AS Cliente,
    SUM(i.Total) AS TotalGastado
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName
ORDER BY TotalGastado DESC
GO

-- Ingresos por país
SELECT 
    c.Country, 
    SUM(i.Total) AS IngresosTotales
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY IngresosTotales DESC
GO

-- Artistas con más canciones vendidas
SELECT TOP 5 
    ar.Name AS Artista, 
    COUNT(*) AS CancionesVendidas
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY CancionesVendidas DESC
GO


-- Ventas por género musical
SELECT 
    g.Name AS Genero, 
    COUNT(*) AS TotalVentas
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY TotalVentas DESC
GO

-- Total de ingresos por empleado vendedor
SELECT 
    e.FirstName + ' ' + e.LastName AS Empleado,
    SUM(i.Total) AS TotalVentas
FROM Employee e
INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.FirstName, e.LastName
ORDER BY TotalVentas DESC
GO

-- Formato más vendido
SELECT 
    mt.Name AS Formato, 
    COUNT(*) AS VentasTotales
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
GROUP BY mt.Name
ORDER BY VentasTotales DESC
GO


-- Consultas intermedias

-- Clientes que han gastado más de 40 USD en total
SELECT 
    c.FirstName + ' ' + c.LastName AS Cliente,
    SUM(i.Total) AS TotalGastado
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName
HAVING SUM(i.Total) > 40
ORDER BY TotalGastado DESC
GO


-- Última compra realizada por cada cliente
SELECT 
    c.FirstName + ' ' + c.LastName AS Cliente,
    MAX(i.InvoiceDate) AS UltimaCompra
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName
GO

-- Top 3 géneros más vendidos

SELECT TOP 3
    g.Name AS Genero,
    COUNT(*) AS Ventas
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY Ventas DESC
GO

-- Facturas con más de 5 canciones

SELECT 
    i.InvoiceId,
    COUNT(il.InvoiceLineId) AS TotalCanciones,
    SUM(il.UnitPrice * il.Quantity) AS TotalFactura
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
GROUP BY i.InvoiceId
HAVING COUNT(il.InvoiceLineId) > 5
ORDER BY TotalFactura DESC
GO

-- Ingresos mensuales del año 2021

SELECT 
    MONTH(InvoiceDate) AS Mes,
    SUM(Total) AS IngresosMensuales
FROM Invoice
WHERE YEAR(InvoiceDate) = 2021
GROUP BY MONTH(InvoiceDate)
ORDER BY Mes
GO

-- Canciones con precio mayor al promedio

SELECT 
    Name, UnitPrice
FROM Track
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) FROM Track
)
ORDER BY UnitPrice DESC
GO


-- Ranking de clientes por total gastado
WITH RankingClientes AS (
    SELECT 
        c.FirstName + ' ' + c.LastName AS Cliente,
        SUM(i.Total) AS TotalGastado,
        ROW_NUMBER() OVER (ORDER BY SUM(i.Total) DESC) AS Posicion
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.FirstName, c.LastName
)
SELECT * FROM RankingClientes
GO


-- Ventas por tipo de formato

SELECT 
    mt.Name AS Formato,
    COUNT(*) AS TotalVentas,
    CASE 
        WHEN mt.Name LIKE '%MP3%' THEN 'Compresion Alta'
        WHEN mt.Name LIKE '%AAC%' THEN 'Compresion Media'
        ELSE 'Otro'
    END AS Categoria
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
GROUP BY mt.Name
ORDER BY TotalVentas DESC
GO
