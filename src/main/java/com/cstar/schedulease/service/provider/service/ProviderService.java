package com.cstar.schedulease.service.provider.service;

import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.dto.ProviderListDTO;

import java.util.List;

public interface ProviderService {
    ProviderDTO createProvider(ProviderDTO dto);

    ProviderDTO getProviderById(Long id);

    List<ProviderListDTO> getAllProviders(Boolean activeOnly);

    ProviderDTO updateProvider(Long id, ProviderDTO dto);
}
