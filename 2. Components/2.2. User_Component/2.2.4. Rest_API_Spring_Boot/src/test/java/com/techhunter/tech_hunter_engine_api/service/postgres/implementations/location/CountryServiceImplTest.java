package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.CountryMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CountryEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.CountryRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CountryServiceImplTest {

    @Mock
    private CountryRepository countryRepository;

    @Mock
    private CountryMapper countryMapper;

    @InjectMocks
    private CountryServiceImpl countryService;

    // -----------------------------------------------------
    // GET COUNTRIES BY REGION - normal flow
    // -----------------------------------------------------
    @Test
    void getCountriesByRegion_shouldReturnMappedDTOs() {

        CountryEntity entity = new CountryEntity();
        entity.setCountryId(10L);

        CountryDTO dto = new CountryDTO(
                10L,
                "United Kingdom",
                "UK",
                67000000L,
                243610L,
                "GMT",
                4.2,
                3.1,
                3200.0,
                19.0,
                85.0,
                1L,
                44L,
                100L
        );

        when(countryRepository.findByRegion_RegionId(1L))
                .thenReturn(List.of(entity));

        when(countryMapper.toDto(entity))
                .thenReturn(dto);

        List<CountryDTO> result = countryService.getCountriesByRegion(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).countryId());
        assertEquals("United Kingdom", result.get(0).name());
        assertEquals("UK", result.get(0).code());
        assertEquals(67000000L, result.get(0).population());
        assertEquals(243610L, result.get(0).area());
        assertEquals("GMT", result.get(0).timeZone());
        assertEquals(4.2, result.get(0).unemploymentRate());
        assertEquals(3.1, result.get(0).inflationRate());
        assertEquals(3200.0, result.get(0).averageMonthlySalary());
        assertEquals(19.0, result.get(0).corporateTaxRate());
        assertEquals(85.0, result.get(0).rating());
        assertEquals(1L, result.get(0).regionId());
        assertEquals(44L, result.get(0).languageId());
        assertEquals(100L, result.get(0).currencyId());
    }

    // -----------------------------------------------------
    // GET COUNTRIES BY REGION - empty list
    // -----------------------------------------------------
    @Test
    void getCountriesByRegion_shouldReturnEmptyList_whenNoCountries() {

        when(countryRepository.findByRegion_RegionId(1L))
                .thenReturn(List.of());

        List<CountryDTO> result = countryService.getCountriesByRegion(1L);

        assertTrue(result.isEmpty());
    }
}


