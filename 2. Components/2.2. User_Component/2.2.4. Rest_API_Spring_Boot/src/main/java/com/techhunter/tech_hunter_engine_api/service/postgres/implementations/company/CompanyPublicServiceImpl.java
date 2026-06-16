package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CompanyPublicDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.CompanyEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.*;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.CompanyRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.IndustryTypeRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.OrganizationTypeRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.LocationRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.CompanyPublicService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CompanyPublicServiceImpl implements CompanyPublicService {

    private final CompanyRepository companyRepo;
    private final IndustryTypeRepository industryRepo;
    private final OrganizationTypeRepository orgRepo;
    private final LocationRepository locationRepo;

    @Override
    public List<CompanyPublicDTO> getAllPublicCompanies() {
        return companyRepo.findAll().stream()
                .filter(c -> !"Y".equals(c.getDeletedFlag()))
                .map(this::mapToPublicDTO)
                .toList();
    }

    @Override
    public CompanyPublicDTO getPublicCompanyById(Long companyId) {
        CompanyEntity c = companyRepo.findById(companyId)
                .filter(e -> !"Y".equals(e.getDeletedFlag()))
                .orElse(null);

        return c != null ? mapToPublicDTO(c) : null;
    }

    @Override
    public List<CompanyPublicDTO> searchCompaniesByName(String name) {
        return companyRepo.findAll().stream()
                .filter(c -> !"Y".equals(c.getDeletedFlag()))
                .filter(c -> c.getName().toLowerCase().contains(name.toLowerCase()))
                .map(this::mapToPublicDTO)
                .toList();
    }

    private CompanyPublicDTO mapToPublicDTO(CompanyEntity c) {

        LocationEntity loc = locationRepo.findById(c.getCompanyLocationId()).orElse(null);

        CityEntity city = loc != null ? loc.getCity() : null;
        AdministrativeUnitEntity unit = city != null ? city.getAdministrativeUnit() : null;

        Long administrativeUnitId = unit != null ? unit.getAdministrativeUnitId() : null;

        Long administrativeUnitTypeId =
                unit != null && unit.getType() != null
                        ? unit.getType().getAdministrativeUnitTypeId()
                        : null;

        Long countryId =
                unit != null && unit.getCountry() != null
                        ? unit.getCountry().getCountryId()
                        : null;

        Long cityId = city != null ? city.getCityCode() : null;
        String cityName = city != null ? city.getName() : null;

        String industryName = industryRepo.findById(c.getIndustryTypeId())
                .map(i -> i.getName())
                .orElse(null);

        String companyTypeName = orgRepo.findById(c.getCompanyTypeId())
                .map(t -> t.getName())
                .orElse(null);

        return new CompanyPublicDTO(
                c.getCompanyId(),
                c.getName(),
                c.getDescription(),
                c.getWebsite(),
                industryName,
                companyTypeName,
                countryId,
                administrativeUnitTypeId,
                administrativeUnitId,
                cityId,
                cityName,
                c.getNoEmployees(),
                c.getFoundationDate().toString(),
                c.getRating() != null ? c.getRating().toString() : null,
                c.getProfileImage()
        );
    }

    @Override
    public List<CompanyPublicDTO> filterCompanies(Long countryId,
                                                  Long administrativeUnitTypeId,
                                                  Long administrativeUnitId,
                                                  Long cityId) {

        return getAllPublicCompanies().stream()
                .filter(c -> countryId == null || countryId.equals(c.countryId()))
                .filter(c -> administrativeUnitTypeId == null || administrativeUnitTypeId.equals(c.administrativeUnitTypeId()))
                .filter(c -> administrativeUnitId == null || administrativeUnitId.equals(c.administrativeUnitId()))
                .filter(c -> cityId == null || cityId.equals(c.cityId()))
                .toList();
    }
}
