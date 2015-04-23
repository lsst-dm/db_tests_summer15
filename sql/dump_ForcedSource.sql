SELECT
    fs.deepForcedSourceId,
    i.ra,
    i.decl,
    fs.deepSourceId,
    fs.scienceCcdExposureId,
    fs.psfFlux,
    fs.psfFluxSigma,
    fs.flagBadMeasCentroid,
    fs.flagPixEdge,
    fs.flagPixInterpAny,
    fs.flagPixInterpCen,
    fs.flagPixSaturAny,
    fs.flagPixSaturCen,
    fs.flagBadPsfFlux
FROM
    -- qserv_in2p3_2015.DeepSource has a PK prefixed by deepSourceId, which
    -- fits entirely into the MySQL key cache on lsst10 (key_buffer_size is 4GB),
    -- and we will touch almost all DeepForcedSource rows. So, doing the join in
    -- this order is many times faster than the other way around (which the MySQL
    -- optimizer prefers).
    DC_W13_Stripe82.DeepForcedSource AS fs STRAIGHT_JOIN
    qserv_in2p3_2015.DeepSource AS i ON (fs.deepSourceId = i.deepSourceId)
WHERE
    -- Stripe 82 has ~80 observations of each deep source in each of 3 filters.
    -- We would like ~40, so we drop all filters except r to get within a factor
    -- of ~2.
    fs.filterId = 2;
