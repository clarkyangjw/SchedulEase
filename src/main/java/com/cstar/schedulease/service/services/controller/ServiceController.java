package com.cstar.schedulease.service.services.controller;

import com.cstar.schedulease.common.enums.Category;
import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.cstar.schedulease.service.services.service.ServiceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
@Slf4j
public class ServiceController {

    private final ServiceService serviceService;

    @PostMapping
    public ResponseEntity<ServiceDTO> createService(
            @Validated(ServiceDTO.Create.class) @RequestBody ServiceDTO dto) {
        log.info("REST request to create Service: {}", dto.getName());
        ServiceDTO createdService = serviceService.createService(dto);
        return new ResponseEntity<>(createdService, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<ServiceDTO>> getAllServices(
            @RequestParam(required = false) Boolean activeOnly,
            @RequestParam(required = false) Category category) {
        log.info("REST request to get all Services, activeOnly: {}, category: {}", activeOnly, category);
        List<ServiceDTO> services = serviceService.getAllServices(activeOnly, category);
        return ResponseEntity.ok(services);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceDTO> getServiceById(@PathVariable Long id) {
        log.info("REST request to get Service with id: {}", id);
        ServiceDTO service = serviceService.getServiceById(id);
        return ResponseEntity.ok(service);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceDTO> updateService(
            @PathVariable Long id,
            @Validated(ServiceDTO.Update.class) @RequestBody ServiceDTO dto) {
        log.info("REST request to update Service with id: {}", id);
        ServiceDTO updatedService = serviceService.updateService(id, dto);
        return ResponseEntity.ok(updatedService);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteService(@PathVariable Long id) {
        log.info("REST request to delete (deactivate) Service with id: {}", id);
        serviceService.deleteService(id);
        return ResponseEntity.noContent().build();
    }
}

