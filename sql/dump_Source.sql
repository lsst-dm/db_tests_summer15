SELECT
    s.*
FROM
    DC_W13_Stripe82.RunDeepForcedSource AS s IGNORE INDEX (IDX_exposure_filter_id) STRAIGHT_JOIN
    qserv_in2p3_2015.ZeroPoints AS zp ON (s.exposure_id = zp.scienceCcdExposureId) STRAIGHT_JOIN
    qserv_in2p3_2015.DeepSourceIds AS i ON (s.objectId = i.deepSourceId)
WHERE
    s.exposure_filter_id = 2 AND scisql_dnToAbMag(s.flux_psf, zp.fluxMag0) <= 22.5;
