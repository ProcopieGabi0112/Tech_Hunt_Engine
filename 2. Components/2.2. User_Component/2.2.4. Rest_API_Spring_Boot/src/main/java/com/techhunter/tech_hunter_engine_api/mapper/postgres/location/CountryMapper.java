package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LanguageEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.CurrencyEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CountryEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.RegionEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CountryMapper {

    @Mapping(source = "region.regionId", target = "regionId")
    @Mapping(source = "language.langCode", target = "languageId")
    @Mapping(source = "currency.currencyCode", target = "currencyId")
    CountryDTO toDto(CountryEntity entity);

    @Mapping(target = "region", expression = "java(createRegion(dto.regionId()))")
    @Mapping(target = "language", expression = "java(createLanguage(dto.languageId()))")
    @Mapping(target = "currency", expression = "java(createCurrency(dto.currencyId()))")
    CountryEntity toEntity(CountryDTO dto);

    default RegionEntity createRegion(Long id) {
        if (id == null) return null;
        RegionEntity r = new RegionEntity();
        r.setRegionId(id);
        return r;
    }

    default LanguageEntity createLanguage(Long id) {
        if (id == null) return null;
        LanguageEntity l = new LanguageEntity();
        l.setLangCode(id);
        return l;
    }

    default CurrencyEntity createCurrency(Long id) {
        if (id == null) return null;
        CurrencyEntity c = new CurrencyEntity();
        c.setCurrencyCode(id);
        return c;
    }
}