SET myisam_sort_buffer_size = 4294967296;

-- Find all level 8 HTM triangles with level 11 children that are all non-empty.
CREATE TABLE qserv_in2p3_2015.Htm8Triangles (htmId8 INTEGER NOT NULL) AS
SELECT (htmId11 DIV 64) as htmId8
FROM (
      -- Level 11 HTM triangles containing at least 1 Stripe 82 deep source
      SELECT (htmId20 DIV 262144) AS htmId11
      FROM DC_W13_Stripe82.DeepSource
      GROUP BY htmId11) AS t
GROUP BY htmId8
HAVING COUNT(*) = 64;

-- Extract IDs and positions for Stripe82 deep sources in such a level 8 HTM triangle.
CREATE TABLE qserv_in2p3_2015.DeepSource (
    deepSourceId BIGINT NOT NULL,
    ra DOUBLE PRECISION NOT NULL,
    decl DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (deepSourceId, ra, decl)
) AS SELECT deepSourceId, ra, decl
FROM DC_W13_Stripe82.DeepSource AS s INNER JOIN
     qserv_in2p3_2015.Htm8Triangles AS h ON (
        s.htmId20 >= h.htmId8 * 16777216 AND
        s.htmId20 < (h.htmId8 + 1) * 16777216);

-- Extract zero points for CCDs into a slim table with a covering index.
CREATE TABLE qserv_in2p3_2015.ZeroPoints (
    scienceCcdExposureId BIGINT not null,
    fluxMag0 FLOAT NOT NULL,
    fluxMag0Sigma FLOAT NOT NULL,
    PRIMARY KEY (scienceCcdExposureId, fluxMag0, fluxMag0Sigma)
) AS SELECT scienceCcdExposureId, fluxMag0, fluxMag0Sigma
FROM DC_W13_Stripe82.Science_Ccd_Exposure
ORDER BY scienceCcdExposureId;
