-- Compute a magnitude histogram of the deep-sources. The forced sources in
-- the r-band should have an essentially identical distribution.
CREATE TABLE qserv_in2p3_2015.MagHistogram (
    mag FLOAT,
    num_sources BIGINT NOT NULL
) AS SELECT
    ROUND(scisql_dnToAbMag(s.psfFlux, zp.fluxMag0), 1) as mag,
    COUNT(*) as num_sources
FROM DC_W13_Stripe82.DeepSource AS s INNER JOIN
     DC_W13_Stripe82.DeepCoadd AS zp ON (s.deepCoaddId = zp.deepCoaddId)
GROUP BY mag;

-- We need to determine a magnitude cut on r-band forced sources that gets
-- us to the desired number of sources for the large scale test. There are
-- ~1.3e9 r-band forced sources, and 14.67e6 deep sources, or 90.37 r-band
-- forced sources per deep source on average. We want an average of 19.4
-- sources per object, so we compute the magnitude M such that only ~19.44/90.37
-- or ~21.5% of the deep sources have magnitude <= M. We will select
-- the associated r-band forced sources and call them sources for the purpose
-- of large scale testing.

-- Find the magnitude bucket B with the largest number of sources of magnitude
-- <= B such that the number of sources is less than 3200000.
SELECT mag
FROM (
    -- The number of sources with magnitude <= B, for each magnitude bucket B.
    SELECT
        m1.mag AS mag,
        sum(m2.num_sources) AS num_sources
    FROM qserv_in2p3_2015.MagHistogram AS m1 INNER JOIN
         qserv_in2p3_2015.MagHistogram AS m2 ON (m1.mag >= m2.mag)
    GROUP BY m1.mag
) AS t
WHERE num_sources < 3200000
ORDER BY num_sources DESC
LIMIT 1;
