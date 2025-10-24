package com.cstar.schedulease.service.provider.controller;

import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.dto.ProviderListDTO;
import com.cstar.schedulease.service.provider.service.ProviderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
@Slf4j
public class ProviderController {

    private final ProviderService providerService;

    @PostMapping
    public ResponseEntity<ProviderDTO> createProvider(
            @Validated(ProviderDTO.Create.class) @RequestBody ProviderDTO dto) {
        log.info("REST request to create Provider: {} {}", dto.getFirstName(), dto.getLastName());
        ProviderDTO createdProvider = providerService.createProvider(dto);
        return new ResponseEntity<>(createdProvider, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<ProviderListDTO>> getAllProviders(
            @RequestParam(required = false) Boolean activeOnly) {
        log.info("REST request to get all Providers, activeOnly: {}", activeOnly);
        List<ProviderListDTO> providers = providerService.getAllProviders(activeOnly);
        return ResponseEntity.ok(providers);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProviderDTO> getProviderById(@PathVariable Long id) {
        log.info("REST request to get Provider with id: {}", id);
        ProviderDTO provider = providerService.getProviderById(id);
        return ResponseEntity.ok(provider);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProviderDTO> updateProvider(
            @PathVariable Long id,
            @Validated(ProviderDTO.Update.class) @RequestBody ProviderDTO dto) {
        log.info("REST request to update Provider with id: {}", id);
        ProviderDTO updatedProvider = providerService.updateProvider(id, dto);
        return ResponseEntity.ok(updatedProvider);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProvider(@PathVariable Long id) {
        log.info("REST request to delete (deactivate) Provider with id: {}", id);
        ProviderDTO dto = new ProviderDTO();
        dto.setIsActive(false);
        providerService.updateProvider(id, dto);
        return ResponseEntity.noContent().build();
    }
}
