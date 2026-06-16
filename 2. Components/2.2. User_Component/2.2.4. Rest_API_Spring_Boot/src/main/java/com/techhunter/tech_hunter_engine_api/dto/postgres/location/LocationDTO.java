package com.techhunter.tech_hunter_engine_api.dto.postgres.location;

public record LocationDTO(
        Long locationId,
        String streetName,
        String streetNumber,
        String postalCode,
        String building,
        String staircase,
        String floor,
        String apartmentNumber,
        Long cityCode
) {}