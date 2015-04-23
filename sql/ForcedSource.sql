CREATE TABLE ForcedSource (
    deepSourceId         BIGINT NOT NULL,
    scienceCcdExposureId BIGINT NOT NULL,
    psfFlux              FLOAT,
    psfFluxSigma         FLOAT,
    flagBadMeasCentroid  BIT(1) NOT NULL,
    flagPixEdge          BIT(1) NOT NULL,
    flagPixInterpAny     BIT(1) NOT NULL,
    flagPixInterpCen     BIT(1) NOT NULL,
    flagPixSaturAny      BIT(1) NOT NULL,
    flagPixSaturCen      BIT(1) NOT NULL,
    flagBadPsfFlux       BIT(1) NOT NULL,
    chunkId              INTEGER NOT NULL,
    subChunkId           INTEGER NOT NULL,
    PRIMARY KEY (deepSourceId, scienceCcdExposureId)
) ENGINE=MyISAM;
